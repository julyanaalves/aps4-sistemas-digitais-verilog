`timescale 1ns/1ps

module control_unit (
	output reg IR_Load, 
	 output reg MAR_Load, 
	 output reg PC_Load, PC_Inc, 
	 output reg A_Load, B_Load,
	 output reg CCR_Load,
	 output reg [2:0] ALU_Sel,
	 output reg [1:0] Bus1_Sel, Bus2_Sel,
	 output reg write, 
	 input wire [7:0] IR, //opcode
	 input wire [3:0] CCR_Result,
     input wire clk, Reset
	 );
             
  	reg [7:0] current_state, next_state;

	parameter     S0_FETCH = 8'h00,  //-- Opcode fetch states
				  S1_FETCH = 8'h01,
				  S2_FETCH = 8'h02,
				  
				  S3_DECODE = 8'h03, //-- Opcode decode state
				  
				  S4_LDA_IMM = 8'h04, //-- LOAD REGISTER A IMEDIATO
				  S5_LDA_IMM = 8'h05,
				  S6_LDA_IMM = 8'h06,

                  S4_LDB_IMM = 8'h07, //-- LOAD REGISTER B IMEDIATO
				  S5_LDB_IMM = 8'h08,
				  S6_LDB_IMM = 8'h09,

                  S4_ADD_AB  = 8'h0A, // A <= A + B
                  
                  S4_STA_DIR = 8'h0B, //-- STORE REGISTER A DIRETO
                  S5_STA_DIR = 8'h0C,
                  S6_STA_DIR = 8'h0D,
                  S7_STA_DIR = 8'h0E;

  	initial
  		begin
    		current_state = S0_FETCH;
    		next_state = S0_FETCH;
    		IR_Load = 0;
    		MAR_Load = 1;
    		PC_Load = 0;
    		PC_Inc = 0;
    		A_Load = 0;
    		B_Load = 0;
    		CCR_Load = 0;
    		ALU_Sel = 3'b000;
    		Bus1_Sel = 2'b00;
    		Bus2_Sel = 2'b01;
    		write = 0;
    	end          
  
  	always @ (posedge clk or negedge Reset)
  		begin: STATE_MEMORY
  			if (!Reset)
  				current_state <= S0_FETCH;
  			else
  				current_state <= next_state;
  		end
  	
  	always @ (current_state or IR)
  		begin: NEXT_STATE_LOGIC
  			case (current_state)
  				S0_FETCH : next_state = S1_FETCH;
  				S1_FETCH : next_state = S2_FETCH;
  				S2_FETCH : next_state = S3_DECODE;
  				
  				S3_DECODE : 
  				    if (IR == S4_LDA_IMM) next_state = S4_LDA_IMM;
					else if (IR == S4_LDB_IMM) next_state = S4_LDB_IMM;
                    else if (IR == S4_ADD_AB) next_state = S4_ADD_AB;
                    else if (IR == S4_STA_DIR) next_state = S4_STA_DIR;
                    else next_state = S0_FETCH;
                
                // Estados para LDA
  				S4_LDA_IMM : next_state = S5_LDA_IMM; // Execute LOAD IMM for A
  				S5_LDA_IMM : next_state = S6_LDA_IMM;
				S6_LDA_IMM : next_state = S0_FETCH;

                // Estados para LDB
  				S4_LDB_IMM : next_state = S5_LDB_IMM; // Execute LDB_IMM for B
  				S5_LDB_IMM : next_state = S6_LDB_IMM;
				S6_LDB_IMM : next_state = S0_FETCH;

                // Estados para ADD
				S4_ADD_AB : next_state = S0_FETCH;

                // Estados para STA
				S4_STA_DIR : next_state = S5_STA_DIR; // Execute STA_DIR for A
				S5_STA_DIR : next_state = S6_STA_DIR;
				S6_STA_DIR : next_state = S7_STA_DIR;
				S7_STA_DIR : next_state = S0_FETCH;

                default  : next_state = S0_FETCH;
            endcase
        end
    
    //Lógica de output
  	always @ (current_state)
  		begin: OUTPUT_LOGIC
  			case (current_state)
  				
				// FETCH do opcode (IR)
  				S0_FETCH: //Bus1_Sel = 00 (PC), Bus2_Sel = 01 (Bus1), MAR_Load = 1
  					begin // Coloca o PC no MAR para fornecer o endereço do Opcode
  						IR_Load = 0;
						MAR_Load = 1;
						PC_Load = 0;
						PC_Inc = 0;
 						A_Load = 0;
						B_Load = 0;
 						ALU_Sel = 3'b000;
 						CCR_Load = 0;
 						Bus1_Sel = 2'b00; // PC
  						Bus2_Sel = 2'b01; // Bus1
 						write = 0;
					end

				S1_FETCH: // PC_Inc = 1
  					begin // Incrementa o PC
  						IR_Load = 0;
						MAR_Load = 0;
						PC_Load = 0;
						PC_Inc = 1;
 						A_Load = 0;
						B_Load = 0;
 						ALU_Sel = 3'b000;
 						CCR_Load = 0;
 						Bus1_Sel = 2'b00;
  						Bus2_Sel = 2'b00;
 						write = 0;
					end

				S2_FETCH: // Bus2_Sel = 10 (from_memory), IR_Load = 1
					begin // Carrega a instrução no IR
  						IR_Load = 1;
						MAR_Load = 0;
						PC_Load = 0;
						PC_Inc = 0;
 						A_Load = 0;
						B_Load = 0;
 						ALU_Sel = 3'b000;
 						CCR_Load = 0;
 						Bus1_Sel = 2'b00;
  						Bus2_Sel = 2'b10; // From_memory
 						write = 0;
					end
					
				S3_DECODE:
					begin // Decodificação do opcode
						IR_Load = 0;
						MAR_Load = 0;
						PC_Load = 0;
						PC_Inc = 0;
 						A_Load = 0;
						B_Load = 0;
 						ALU_Sel = 3'b000;
 						CCR_Load = 0;
 						Bus1_Sel = 2'b00;
  						Bus2_Sel = 2'b00;
 						write = 0;
					end
				
				// LOAD REGISTER A IMEDIATO
				S4_LDA_IMM: // Bus1_Sel = 00 (PC), Bus2_Sel = 01 (Bus1), MAR_Load = 1
					begin // Executa LDA_IMM para A
  						IR_Load = 0;
						MAR_Load = 1;
						PC_Load = 0;
						PC_Inc = 0;
 						A_Load = 0;
						B_Load = 0;
 						ALU_Sel = 3'b000;
 						CCR_Load = 0;
 						Bus1_Sel = 2'b00; // PC
  						Bus2_Sel = 2'b01; // Bus1
 						write = 0;
					end

				S5_LDA_IMM: // PC_Inc = 1
					begin // Incrementa o PC enquanto espera o operand da memória
  						IR_Load = 0;
						MAR_Load = 0;
						PC_Load = 0;
						PC_Inc = 1;
 						A_Load = 0;
						B_Load = 0;
 						ALU_Sel = 3'b000;
 						CCR_Load = 0;
 						Bus1_Sel = 2'b00;
  						Bus2_Sel = 2'b00;
 						write = 0;
					end
				
				S6_LDA_IMM: // Bus2_Sel = 10 (from_memory), A_Load = 1
					begin // Finaliza LDA_IMM
  						IR_Load = 0;
						MAR_Load = 0;
						PC_Load = 0;
						PC_Inc = 0;
 						A_Load = 1;
						B_Load = 0;
 						ALU_Sel = 3'b000;
 						CCR_Load = 0;
 						Bus1_Sel = 2'b00;
  						Bus2_Sel = 2'b10; // from_memory
 						write = 0;
					end

				// LOAD REGISTER B IMEDIATO
                S4_LDB_IMM: // Bus1_Sel = 00 (PC), Bus2_Sel = 01 (Bus1), MAR_Load = 1
					begin // Executa LDB_IMM
  						IR_Load = 0;
						MAR_Load = 1;
						PC_Load = 0;
						PC_Inc = 0;
 						A_Load = 0;
						B_Load = 0;
 						ALU_Sel = 3'b000;
 						CCR_Load = 0;
 						Bus1_Sel = 2'b00; // PC
  						Bus2_Sel = 2'b01; // Bus1
 						write = 0;
					end

				S5_LDB_IMM: // PC_Inc = 1
					begin // Incrementa o PC enquanto espera o operand da memória
  						IR_Load = 0;
						MAR_Load = 0;
						PC_Load = 0;
						PC_Inc = 1;
 						A_Load = 0;
						B_Load = 0;
 						ALU_Sel = 3'b000;
 						CCR_Load = 0;
 						Bus1_Sel = 2'b00;
  						Bus2_Sel = 2'b00;
 						write = 0;
					end
				
				S6_LDB_IMM: // Bus2_Sel = 10 (from_memory), B_Load = 1
					begin // Finaliza LDB_IMM
  						IR_Load = 0;
						MAR_Load = 0;
						PC_Load = 0;
						PC_Inc = 0;
 						A_Load = 0;
						B_Load = 1;
 						ALU_Sel = 3'b000;
 						CCR_Load = 0;
 						Bus1_Sel = 2'b00;
  						Bus2_Sel = 2'b10; // from_memory
 						write = 0;
					end
                
                // Implementa A + B
				S4_ADD_AB: // Bus1_Sel = 01 (A), Bus2_Sel = 00 (ALU), ALU_Sel = 000 (ADD), A_Load = 1, CCR_Load = 1
					begin // Executa A + B
  						IR_Load = 0;
						MAR_Load = 0;
						PC_Load = 0;
						PC_Inc = 0;
 						A_Load = 1;
						B_Load = 0;
 						ALU_Sel = 3'b000; // ADD
 						CCR_Load = 1;
 						Bus1_Sel = 2'b01; // A
  						Bus2_Sel = 2'b00; // ALU
 						write = 0;
					end
                
                //Implementa o Store Register A Direto
				S4_STA_DIR: // Bus1_Sel = 00 (PC), Bus2_Sel = 01 (Bus1), MAR_Load = 1
					begin // Manda o endereço para a memória
  						IR_Load = 0;
						MAR_Load = 1;
						PC_Load = 0;
						PC_Inc = 0;
 						A_Load = 0;
						B_Load = 0;
 						ALU_Sel = 3'b000;
 						CCR_Load = 0;
 						Bus1_Sel = 2'b00; // PC
  						Bus2_Sel = 2'b01; // Bus1
 						write = 0;
					end
				
				S5_STA_DIR: // PC_Inc = 1
					begin // Incrementa o PC enquanto espera a memória
  						IR_Load = 0;
						MAR_Load = 0;
						PC_Load = 0;
						PC_Inc = 1;
 						A_Load = 0;
						B_Load = 0;
 						ALU_Sel = 3'b000;
 						CCR_Load = 0;
 						Bus1_Sel = 2'b00;
  						Bus2_Sel = 2'b00;
 						write = 0;
					end
				
				S6_STA_DIR: // Bus2_Sel = 10 (from_memory), MAR_Load = 1
					begin // Carrega o MAR
  						IR_Load = 0;
						MAR_Load = 1;
						PC_Load = 0;
						PC_Inc = 0;
 						A_Load = 0;
						B_Load = 0;
 						ALU_Sel = 3'b000;
 						CCR_Load = 0;
 						Bus1_Sel = 2'b00;
  						Bus2_Sel = 2'b10; // from_memory
 						write = 0;
					end

				S7_STA_DIR: // Bus1_Sel = 01 (A), write = 1
					begin // Escreve e volta ao fetch
  						IR_Load = 0;
						MAR_Load = 0;
						PC_Load = 0;
						PC_Inc = 0;
 						A_Load = 0;
						B_Load = 0;
 						ALU_Sel = 3'b000;
 						CCR_Load = 0;
 						Bus1_Sel = 2'b01; // A
  						Bus2_Sel = 2'b00;
 						write = 1;
					end
            endcase
        end
endmodule