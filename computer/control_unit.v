// ALU_Sel: 000 = ADD, 001 = INC, 010 = SUB, 011 = DEC, 
// 100 = AND, 101 = OR, 110 = XOR, 111 = NOT

// Bus1_Sel: 00 = PC, 01 = A, 10 = B
// Bus2_Sel: 00 = ALU, 01 = Bus1, 10 = from_memory
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
     input wire Clk, Reset
	 );

	wire N = CCR_Result[3], Z = CCR_Result[2], V = CCR_Result[1], C = CCR_Result[0];         
  	reg [7:0] current_state, next_state;

	parameter     S0_FETCH = 8'h00,  //-- Opcode fetch states
				  S1_FETCH = 8'h01,
				  S2_FETCH = 8'h02,
				  
				  S3_DECODE = 8'h03, //-- Opcode decode state
				  
				  S4_LDA_IMM = 8'h04, //-- LOAD REGISTER A IMEDIATO
				  S5_LDA_IMM = 8'h05,
				  S6_LDA_IMM = 8'h06,
				  
				  S4_LDA_DIR = 8'h07, //-- LOAD REGISTER A DIRETO
				  S5_LDA_DIR = 8'h08,
				  S6_LDA_DIR = 8'h09,
				  S7_LDA_DIR = 8'h0A,
				  S8_LDA_DIR = 8'h0B,
	
				  S4_LDB_IMM = 8'h0C, //-- LOAD REGISTER B IMEDIATO
				  S5_LDB_IMM = 8'h0D,
				  S6_LDB_IMM = 8'h0E,
					
				  S4_LDB_DIR = 8'h0F, //-- LOAD REGISTER B DIRETO
				  S5_LDB_DIR = 8'h10,
				  S6_LDB_DIR = 8'h11,
				  S7_LDB_DIR = 8'h12,
				  S8_LDB_DIR = 8'h13,
	
				  S4_STA_DIR = 8'h14, //-- STORE REGISTER A DIRETO
				  S5_STA_DIR = 8'h15,
				  S6_STA_DIR = 8'h16,
				  S7_STA_DIR = 8'h17,
	
				  S4_STB_DIR = 8'h18, //-- STORE REGISTER B DIRETO
				  S5_STB_DIR = 8'h19,
				  S6_STB_DIR = 8'h1A,
				  S7_STB_DIR = 8'h1B,
	
				  S4_ADD_AB  = 8'h1C, // A <= A + B
				  
				  S4_SUB_AB  = 8'h1D, // A <= A - B
				  S5_SUB_AB  = 8'h1E,
				  S6_SUB_AB  = 8'h1F,
				  S4_SUB_BA  = 8'h20, // B <= B - A
	
				  S4_AND_AB  = 8'h21, // A <= A & B
				  S4_OR_AB   = 8'h22, // A <= A | B
				  S4_XOR_AB  = 8'h23, // A <= A ^ B
	
				  S4_INC_A   = 8'h24, // A <= A + 1
				  S5_INC_A   = 8'h25, 
				  S4_INC_B   = 8'h26, // B <= B + 1
	
				  S4_DEC_A   = 8'h27, // A <= A - 1
				  S5_DEC_A   = 8'h28, 
				  S4_DEC_B   = 8'h29, // B <= B - 1
				  
				  S4_NOT_A   = 8'h2A, // A <= ~A
				  S5_NOT_A   = 8'h2B, 
				  S4_NOT_B   = 8'h2C, // B <= ~B
	
				  S4_BRA     = 8'h2D, // Branch always
				  S5_BRA     = 8'h2E,
				  S6_BRA     = 8'h2F,
	
				  S4_BMI     = 8'h30, // Branch if minus than 0 (N = 1)
				  S5_BMI     = 8'h31,
				  S6_BMI     = 8'h32,
				  S7_BMI     = 8'h33, // Branch if N = 0
	
				  S4_BPL     = 8'h34, // Branch if greater than 0 (N = 0)
				  S5_BPL     = 8'h35,
				  S6_BPL     = 8'h36,
				  S7_BPL     = 8'h37, // Branch if N = 1
	
				  S4_BEQ     = 8'h38, // Branch if equal to 0 (Z = 1)
				  S5_BEQ     = 8'h39,
				  S6_BEQ     = 8'h3A,
				  S7_BEQ     = 8'h3B, // Branch if Z = 0
	
				  S4_BNE     = 8'h3C, // Branch if not equal to 0 (Z = 0)
				  S5_BNE     = 8'h3D,
				  S6_BNE     = 8'h3E,
				  S7_BNE     = 8'h3F, // Branch if Z = 1
	
				  S4_BVS     = 8'h40, // Branch if overflow (V = 1)
				  S5_BVS     = 8'h41,
				  S6_BVS     = 8'h42,
				  S7_BVS     = 8'h43, // Branch if V = 0
	
				  S4_BVC     = 8'h44, // Branch if not overflow (V = 0)
				  S5_BVC     = 8'h45,
				  S6_BVC     = 8'h46,
				  S7_BVC     = 8'h47, // Branch if V = 1
	
				  S4_BCS     = 8'h48, // Branch if carry (C = 1)
				  S5_BCS     = 8'h49,
				  S6_BCS     = 8'h4A,
				  S7_BCS     = 8'h4B, // Branch if C = 0
	
				  S4_BCC     = 8'h4C, // Branch if not carry (C = 0)
				  S5_BCC     = 8'h4D,
				  S6_BCC     = 8'h4E,
				  S7_BCC     = 8'h4F; // Branch if C = 1


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
  
  	always @ (posedge Clk or negedge Reset)
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
  					else if (IR == S4_LDA_DIR) next_state = S4_LDA_DIR;
					else if (IR == S4_LDB_IMM) next_state = S4_LDB_IMM;
					else if (IR == S4_LDB_DIR) next_state = S4_LDB_DIR;
					else if (IR == S4_STA_DIR) next_state = S4_STA_DIR;
					else if (IR == S4_STB_DIR) next_state = S4_STB_DIR;
					else if (IR == S4_ADD_AB) next_state = S4_ADD_AB;
					else if (IR == S4_SUB_AB) next_state = S4_SUB_AB;
					else if (IR == S4_SUB_BA) next_state = S4_SUB_BA;
					else if (IR == S4_AND_AB) next_state = S4_AND_AB;
					else if (IR == S4_OR_AB) next_state = S4_OR_AB;
					else if (IR == S4_XOR_AB) next_state = S4_XOR_AB;
					else if (IR == S4_INC_A) next_state = S4_INC_A;
					else if (IR == S4_INC_B) next_state = S4_INC_B;
					else if (IR == S4_DEC_A) next_state = S4_DEC_A;
					else if (IR == S4_DEC_B) next_state = S4_DEC_B;
					else if (IR == S4_NOT_A) next_state = S4_NOT_A;
					else if (IR == S4_NOT_B) next_state = S4_NOT_B;
					else if (IR == S4_BRA)  next_state = S4_BRA;
					else if (IR == S4_BMI && N == 1)  next_state = S4_BMI;
					else if (IR == S4_BMI && N == 0)  next_state = S7_BMI;
					else if (IR == S4_BPL && N == 0)  next_state = S4_BPL;
					else if (IR == S4_BPL && N == 1)  next_state = S7_BPL;
					else if (IR == S4_BEQ && Z == 1)  next_state = S4_BEQ;
					else if (IR == S4_BEQ && Z == 0)  next_state = S7_BEQ;
					else if (IR == S4_BNE && Z == 0)  next_state = S4_BNE;
					else if (IR == S4_BNE && Z == 1)  next_state = S7_BNE;
					else if (IR == S4_BVS && V == 1)  next_state = S4_BVS;
					else if (IR == S4_BVS && V == 0)  next_state = S7_BVS;
					else if (IR == S4_BVC && V == 0)  next_state = S4_BVC;
					else if (IR == S4_BVC && V == 1)  next_state = S7_BVC;
					else if (IR == S4_BCS && C == 1)  next_state = S4_BCS;
					else if (IR == S4_BCS && C == 0)  next_state = S7_BCS;
					else if (IR == S4_BCC && C == 0)  next_state = S4_BCC;
					else if (IR == S4_BCC && C == 1)  next_state = S7_BCC;
  					else next_state = S0_FETCH;  // Padrão de segurança
  			 
  				// Estados para LDA
  				S4_LDA_IMM : next_state = S5_LDA_IMM; // Execute LOAD IMM for A
  				S5_LDA_IMM : next_state = S6_LDA_IMM;
				S6_LDA_IMM : next_state = S0_FETCH;

  				S4_LDA_DIR : next_state = S5_LDA_DIR; // Execute LOAD DIR for A
  				S5_LDA_DIR : next_state = S6_LDA_DIR;
  				S6_LDA_DIR : next_state = S7_LDA_DIR;
  				S7_LDA_DIR : next_state = S8_LDA_DIR;
  				S8_LDA_DIR : next_state = S0_FETCH;

                // Estados para LDB
  				S4_LDB_IMM : next_state = S5_LDB_IMM; // Execute LDB_IMM for B
  				S5_LDB_IMM : next_state = S6_LDB_IMM;
				S6_LDB_IMM : next_state = S0_FETCH;

  				S4_LDB_DIR : next_state = S5_LDB_DIR; // Execute LDB_DIR for B
  				S5_LDB_DIR : next_state = S6_LDB_DIR;
  				S6_LDB_DIR : next_state = S7_LDB_DIR;
  				S7_LDB_DIR : next_state = S8_LDB_DIR;
  				S8_LDB_DIR : next_state = S0_FETCH;

				// Estados para STA
				S4_STA_DIR : next_state = S5_STA_DIR; // Execute STA_DIR for A
				S5_STA_DIR : next_state = S6_STA_DIR;
				S6_STA_DIR : next_state = S7_STA_DIR;
				S7_STA_DIR : next_state = S0_FETCH;

				// Estados para STB
				S4_STB_DIR : next_state = S5_STB_DIR; // Execute STB_DIR for B
				S5_STB_DIR : next_state = S6_STB_DIR;
				S6_STB_DIR : next_state = S7_STB_DIR;
				S7_STB_DIR : next_state = S0_FETCH;

				// Estados para ADD
				S4_ADD_AB : next_state = S0_FETCH;

				// Estados para SUB
				S4_SUB_AB : next_state = S5_SUB_AB;
				S5_SUB_AB : next_state = S6_SUB_AB;
				S6_SUB_AB : next_state = S0_FETCH;
				S4_SUB_BA : next_state = S0_FETCH;

				// Estados para INC
				S4_INC_A : next_state = S5_INC_A;
				S5_INC_A : next_state = S0_FETCH;
				S4_INC_B : next_state = S0_FETCH;

				// Estados para DEC
				S4_DEC_A : next_state = S5_DEC_A;
				S5_DEC_A : next_state = S0_FETCH;
				S4_DEC_B : next_state = S0_FETCH;

				// Estados para NOT
				S4_NOT_A : next_state = S5_NOT_A;
				S5_NOT_A : next_state = S0_FETCH;
				S4_NOT_B : next_state = S0_FETCH;

				// Estados para AND, OR, XOR
				S4_AND_AB : next_state = S0_FETCH;
				S4_OR_AB : next_state = S0_FETCH;
				S4_XOR_AB : next_state = S0_FETCH;
				
				// Estados para Branch Always
				S4_BRA : next_state = S5_BRA;
				S5_BRA : next_state = S6_BRA;
				S6_BRA : next_state = S0_FETCH;

				// Estados para Branch if Minus
				S4_BMI : next_state = S5_BMI;
				S5_BMI : next_state = S6_BMI;
				S6_BMI : next_state = S0_FETCH;
				S7_BMI : next_state = S0_FETCH;

				// Estados para Branch if Plus
				S4_BPL : next_state = S5_BPL;
				S5_BPL : next_state = S6_BPL;
				S6_BPL : next_state = S0_FETCH;
				S7_BPL : next_state = S0_FETCH;

				// Estados para Branch if Equal
				S4_BEQ : next_state = S5_BEQ;
				S5_BEQ : next_state = S6_BEQ;
				S6_BEQ : next_state = S0_FETCH;
				S7_BEQ : next_state = S0_FETCH;

				// Estados para Branch if Not Equal
				S4_BNE : next_state = S5_BNE;
				S5_BNE : next_state = S6_BNE;
				S6_BNE : next_state = S0_FETCH;
				S7_BNE : next_state = S0_FETCH;

				// Estados para Branch if Overflow
				S4_BVS : next_state = S5_BVS;
				S5_BVS : next_state = S6_BVS;
				S6_BVS : next_state = S0_FETCH;
				S7_BVS : next_state = S0_FETCH;

				// Estados para Branch if Not Overflow
				S4_BVC : next_state = S5_BVC;
				S5_BVC : next_state = S6_BVC;
				S6_BVC : next_state = S0_FETCH;
				S7_BVC : next_state = S0_FETCH;

				// Estados para Branch if Carry
				S4_BCS : next_state = S5_BCS;
				S5_BCS : next_state = S6_BCS;
				S6_BCS : next_state = S0_FETCH;
				S7_BCS : next_state = S0_FETCH;
				
				// Estados para Branch if Not Carry
				S4_BCC : next_state = S5_BCC;
				S5_BCC : next_state = S6_BCC;
				S6_BCC : next_state = S0_FETCH;
				S7_BCC : next_state = S0_FETCH;

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
				
				// LOAD REGISTER A DIRETO
                S4_LDA_DIR: // Bus1_Sel = 00 (PC), Bus2_Sel = 01 (Bus1), MAR_Load = 1
					begin // Fetch o endereço da memória direta
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
				
				S5_LDA_DIR: // PC_Inc = 1
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
				
				S6_LDA_DIR: // Bus2_Sel = 10 (from_memory), MAR_Load = 1
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
				
				S7_LDA_DIR:
					begin // Pausa para a memória responder
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

				S8_LDA_DIR: // Bus2_Sel = 10 (from_memory), A_Load = 1
					begin // Finaliza e retorna ao fetch
						IR_Load = 0;
						MAR_Load = 0;
						PC_Load = 0;
						PC_Inc = 0;
						A_Load = 1;
						B_Load = 0;
						ALU_Sel = 3'b000;
						CCR_Load = 0;
						Bus1_Sel = 2'b00; 
						Bus2_Sel = 2'b10; // from memory
						write = 0;
					end

				// LOAD REGISTER B DIRETO
                S4_LDB_DIR: // Bus1_Sel = 00 (PC), Bus2_Sel = 01 (Bus1), MAR_Load = 1
					begin // Fetch o endereço da memória direta
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
				
				S5_LDB_DIR: // PC_Inc = 1
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
				
				S6_LDB_DIR: // Bus2_Sel = 10 (from_memory), MAR_Load = 1
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
				
				S7_LDB_DIR: 
					begin // Pausa para a memória responder		
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

				S8_LDB_DIR: // Bus2_Sel = 10 (from_memory), B_Load = 1
					begin // Finaliza e retorna ao fetch
						IR_Load = 0;
						MAR_Load = 0;
						PC_Load = 0;
						PC_Inc = 0;
						A_Load = 0;
						B_Load = 1;
						ALU_Sel = 3'b000;
						CCR_Load = 0;
						Bus1_Sel = 2'b00; 
						Bus2_Sel = 2'b10; // from memory
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
				
				//Implementa o Store Register B Direto
				S4_STB_DIR: // Bus1_Sel = 00 (PC), Bus2_Sel = 01 (Bus1), MAR_Load = 1
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
				
				S5_STB_DIR: // PC_Inc = 1
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
				
				S6_STB_DIR: // Bus2_Sel = 10 (from_memory), MAR_Load = 1
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

				S7_STB_DIR: // Bus1_Sel = 10 (B), write = 1
					begin // Escreve e volta ao fetch
  						IR_Load = 0;
						MAR_Load = 0;
						PC_Load = 0;
						PC_Inc = 0;
 						A_Load = 0;
						B_Load = 0;
 						ALU_Sel = 3'b000;
 						CCR_Load = 0;
 						Bus1_Sel = 2'b10; // B
  						Bus2_Sel = 2'b00;
 						write = 1;
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
				
				// Implementa B - A
				S4_SUB_BA: // Bus1_Sel = 01 (A), Bus2_Sel = 00 (ALU), ALU_Sel = 010 (SUB), B_Load = 1, CCR_Load = 1
					begin // Executa B - A
  						IR_Load = 0;
						MAR_Load = 0;
						PC_Load = 0;
						PC_Inc = 0;
 						A_Load = 0;
						B_Load = 1;
 						ALU_Sel = 3'b010; //SUB
 						CCR_Load = 1;
 						Bus1_Sel = 2'b01; // A 
  						Bus2_Sel = 2'b00; // ALU
 						write = 0;
					end
				
				// Implementa A - B
				S4_SUB_AB: // Bus1_Sel = 10 (B), Bus2_Sel = 01 (Bus1), A_Load = 1
					begin // Passa a informação de B para A
  						IR_Load = 0;
						MAR_Load = 0;
						PC_Load = 0;
						PC_Inc = 0;
 						A_Load = 1;
						B_Load = 0;
 						ALU_Sel = 3'b000;
 						CCR_Load = 0;
 						Bus1_Sel = 2'b10; // B
  						Bus2_Sel = 2'b01; // Bus1
 						write = 0;
					end

				S5_SUB_AB: // Bus1_Sel = 01 (A), Bus2_Sel = 01 (Bus1), B_Load = 1
					begin // Passa a informação de A para B
  						IR_Load = 0;
						MAR_Load = 0;
						PC_Load = 0;
						PC_Inc = 0;
 						A_Load = 0;
						B_Load = 1;
 						ALU_Sel = 3'b000;
 						CCR_Load = 0;
 						Bus1_Sel = 2'b01; // A
  						Bus2_Sel = 2'b01; // Bus1
 						write = 0;
					end
				S6_SUB_AB: // Bus1_Sel = 01 (A), Bus2_Sel = 00 (ALU), ALU_Sel = 010 (SUB), A_Load = 1, CCR_Load = 1
					begin // Executa A - B
  						IR_Load = 0;
						MAR_Load = 0;
						PC_Load = 0;
						PC_Inc = 0;
 						A_Load = 1;
						B_Load = 0;
 						ALU_Sel = 3'b010; // SUB
 						CCR_Load = 1;
 						Bus1_Sel = 2'b01; // A
  						Bus2_Sel = 2'b00; // ALU
 						write = 0;
					end
				
				// Implementa A & B
				S4_AND_AB: // Bus1_Sel = 01 (A), Bus2_Sel = 00 (ALU), ALU_Sel = 100 (AND), A_Load = 1, CCR_Load = 1
					begin // Executa A & B
  						IR_Load = 0;
						MAR_Load = 0;
						PC_Load = 0;
						PC_Inc = 0;
 						A_Load = 1;
						B_Load = 0;
 						ALU_Sel = 3'b100; //AND
 						CCR_Load = 1;
 						Bus1_Sel = 2'b01; // A
  						Bus2_Sel = 2'b00; // ALU
 						write = 0;
					end

				S4_OR_AB: // Bus1_Sel = 01 (A), Bus2_Sel = 00 (ALU), ALU_Sel = 101 (OR), A_Load = 1, CCR_Load = 1
					begin // Executa A | B
  						IR_Load = 0;
						MAR_Load = 0;
						PC_Load = 0;
						PC_Inc = 0;
 						A_Load = 1;
						B_Load = 0;
 						ALU_Sel = 3'b101; //OR
 						CCR_Load = 1;
 						Bus1_Sel = 2'b01; // A
  						Bus2_Sel = 2'b00; // ALU
 						write = 0;
					end
				
				S4_XOR_AB: // Bus1_Sel = 01 (A), Bus2_Sel = 00 (ALU), ALU_Sel = 110 (XOR), A_Load = 1, CCR_Load = 1
					begin // Executa A ^ B
  						IR_Load = 0;
						MAR_Load = 0;
						PC_Load = 0;
						PC_Inc = 0;
 						A_Load = 1;
						B_Load = 0;
 						ALU_Sel = 3'b110; //XOR
 						CCR_Load = 1;
 						Bus1_Sel = 2'b01; // A
  						Bus2_Sel = 2'b00; // ALU
 						write = 0;
					end
				
				// Implementa A = A + 1
				S4_INC_A: // Bus1_Sel = 01 (A), Bus2_Sel = 01 (Bus1), B_Load = 1
					begin // Passa a informação de A para B
  						IR_Load = 0;
						MAR_Load = 0;
						PC_Load = 0;
						PC_Inc = 0;
 						A_Load = 0;
						B_Load = 1;
 						ALU_Sel = 3'b000; //INC
 						CCR_Load = 0;
 						Bus1_Sel = 2'b01; // A
  						Bus2_Sel = 2'b01; // Bus1
 						write = 0;
					end
				
				S5_INC_A: // Bus1_Sel = 01 (A), Bus2_Sel = 00 (ALU), ALU_Sel = 001 (INC), A_Load = 1, CCR_Load = 1
					begin // Executa A + 1
  						IR_Load = 0;
						MAR_Load = 0;
						PC_Load = 0;
						PC_Inc = 0;
 						A_Load = 1;
						B_Load = 0;
 						ALU_Sel = 3'b001; //INC
 						CCR_Load = 1;
 						Bus1_Sel = 2'b01; // A
  						Bus2_Sel = 2'b00; // ALU
 						write = 0;
					end
				
				// Implementa B = B + 1
				S4_INC_B: // Bus2_Sel = 00 (ALU), ALU_Sel = 001 9INC), B_Load = 1, CCR_Load = 1
					begin // Executa B + 1
  						IR_Load = 0;
						MAR_Load = 0;
						PC_Load = 0;
						PC_Inc = 0;
 						A_Load = 0;
						B_Load = 1;
 						ALU_Sel = 3'b001; //INC
 						CCR_Load = 1;
 						Bus1_Sel = 2'b00;
  						Bus2_Sel = 2'b00; // ALU
 						write = 0;
					end
				
				// Implementa A = A - 1
				S4_DEC_A: // Bus1_Sel = 01 (A), Bus2_Sel = 01 (Bus1), B_Load = 1
					begin // Passa a informação de A para B
  						IR_Load = 0;
						MAR_Load = 0;
						PC_Load = 0;
						PC_Inc = 0;
 						A_Load = 0;
						B_Load = 1;
 						ALU_Sel = 3'b000; //INC
 						CCR_Load = 0;
 						Bus1_Sel = 2'b01; // A
  						Bus2_Sel = 2'b01; // Bus1
 						write = 0;
					end
				
				// Implementa B = B - 1
				S5_DEC_A: // Bus2_Sel = 00 (ALU), ALU_Sel = 011 (DEC), A_Load = 1, CCR_Load = 1
					begin // Executa A - 1
  						IR_Load = 0;
						MAR_Load = 0;
						PC_Load = 0;
						PC_Inc = 0;
 						A_Load = 1;
						B_Load = 0;
 						ALU_Sel = 3'b011; //DEC
 						CCR_Load = 1;
 						Bus1_Sel = 2'b00;
  						Bus2_Sel = 2'b00; // ALU
 						write = 0;
					end

				S4_DEC_B: // Bus2_Sel = 00 (ALU), ALU_Sel = 011 (DEC), B_Load = 1, CCR_Load = 1 
					begin // Executa B - 1
  						IR_Load = 0;
						MAR_Load = 0;
						PC_Load = 0;
						PC_Inc = 0;
 						A_Load = 0;
						B_Load = 1;
 						ALU_Sel = 3'b011; //INC
 						CCR_Load = 1;
 						Bus1_Sel = 2'b00;
  						Bus2_Sel = 2'b00; // ALU
 						write = 0;
					end
				
				// Implementa A = ~A
				S4_NOT_A: // Bus1_Sel = 01 (A), Bus2_Sel = 01 (Bus1), B_Load = 1
					begin // Passa a informação de A para B
  						IR_Load = 0;
						MAR_Load = 0;
						PC_Load = 0;
						PC_Inc = 0;
 						A_Load = 0;
						B_Load = 1;
 						ALU_Sel = 3'b000;
 						CCR_Load = 0;
 						Bus1_Sel = 2'b01; // A
  						Bus2_Sel = 2'b01; // Bus1
 						write = 0;
					end

				S5_NOT_A: // Bus2_Sel = 00 (ALU), ALU_Sel = 111 (NOT), A_Load = 1, CCR_Load = 1
					begin // Executa ~A
  						IR_Load = 0;
						MAR_Load = 0;
						PC_Load = 0;
						PC_Inc = 0;
 						A_Load = 1;
						B_Load = 0;
 						ALU_Sel = 3'b111; //NOT
 						CCR_Load = 1;
 						Bus1_Sel = 2'b00;
  						Bus2_Sel = 2'b00; // ALU
 						write = 0;
					end
				
				// Implementa B = ~B
				S4_NOT_B: // Bus2_Sel = 00 (ALU), ALU_Sel = 111 (NOT), B_Load = 1, CCR_Load = 1
					begin // Executa ~B
  						IR_Load = 0;
						MAR_Load = 0;
						PC_Load = 0;
						PC_Inc = 0;
 						A_Load = 0;
						B_Load = 1;
 						ALU_Sel = 3'b111; //NOT
 						CCR_Load = 1;
 						Bus1_Sel = 2'b00;
  						Bus2_Sel = 2'b00; // ALU
 						write = 0;
					end
				
				// Implementa Branch Always
				S4_BRA: // Bus1_Sel = 00 (PC), Bus2_Sel = 01 (Bus1), MAR_Load = 1
					begin // Coloca o endereço do branch no MAR
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

				S5_BRA:
					begin // Espera a memória responder
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
				
				S6_BRA: // Bus2_Sel = 10 (from_memory), PC_Load = 1
					begin // Coloca o endereço do branch no PC
  						IR_Load = 0;
						MAR_Load = 0;
						PC_Load = 1;
						PC_Inc = 0;
 						A_Load = 0;
						B_Load = 0;
 						ALU_Sel = 3'b000;
 						CCR_Load = 0;
 						Bus1_Sel = 2'b00;
  						Bus2_Sel = 2'b10; // from_memory
 						write = 0;
					end
				
				//Implementa Branch Minus (se N = 1)
				S4_BMI: // Bus1_Sel = 00 (PC), Bus2_Sel = 01 (Bus1), MAR_Load = 1
					begin // Coloca o endereço do branch no MAR
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
				
				S5_BMI:
					begin // Espera a memória responder
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
				
				S6_BMI: // Bus2_Sel = 10 (from_memory), PC_Load = 1
					begin // Coloca o endereço do branch no PC
  						IR_Load = 0;
						MAR_Load = 0;
						PC_Load = 1;
						PC_Inc = 0;
 						A_Load = 0;
						B_Load = 0;
 						ALU_Sel = 3'b000;
 						CCR_Load = 0;
 						Bus1_Sel = 2'b00;
  						Bus2_Sel = 2'b10; // from_memory
 						write = 0;
					end
				
				//Implementa Branch Minus (se N = 0)
				S7_BMI: // PC_Inc = 1
					begin // Incrementa o PC e branch não é tomado
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
				
				// Implementa Branch Plus (se N = 0)
				S4_BPL: // Bus1_Sel = 00 (PC), Bus2_Sel = 01 (Bus1), MAR_Load = 1
					begin // Coloca o endereço do branch no MAR
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
				
				S5_BPL:
					begin // Espera a memória responder
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
				
				S6_BPL: // Bus2_Sel = 10 (from_memory), PC_Load = 1
					begin // Coloca o endereço do branch no PC
  						IR_Load = 0;
						MAR_Load = 0;
						PC_Load = 1;
						PC_Inc = 0;
 						A_Load = 0;
						B_Load = 0;
 						ALU_Sel = 3'b000;
 						CCR_Load = 0;
 						Bus1_Sel = 2'b00;
  						Bus2_Sel = 2'b10; // from_memory
 						write = 0;
					end
				
				//Implementa Branch Plus (se N = 1)
				S7_BPL: // PC_Inc = 1
					begin // Incrementa o PC e branch não é tomado
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

				// Implementa Branch Zero (se Z = 1)
				S4_BEQ: // Bus1_Sel = 00 (PC), Bus2_Sel = 01 (Bus1), MAR_Load = 1
					begin // Coloca o endereço do branch no MAR
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
				
				S5_BEQ:
					begin // Espera a memória responder
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
				
				S6_BEQ: // Bus2_Sel = 10 (from_memory), PC_Load = 1
					begin // Coloca o endereço do branch no PC
  						IR_Load = 0;
						MAR_Load = 0;
						PC_Load = 1;
						PC_Inc = 0;
 						A_Load = 0;
						B_Load = 0;
 						ALU_Sel = 3'b000;
 						CCR_Load = 0;
 						Bus1_Sel = 2'b00;
  						Bus2_Sel = 2'b10; // from_memory
 						write = 0;
					end
				
				// Implementa Branch Zero (se Z = 0)
				S7_BEQ: // PC_Inc = 1
					begin // Incrementa o PC e branch não é tomado
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
				
				// Implementa Branch Not Zero (se Z = 0)
				S4_BNE: // Bus1_Sel = 00 (PC), Bus2_Sel = 01 (Bus1), MAR_Load = 1
					begin // Coloca o endereço do branch no MAR
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
				
				S5_BNE:
					begin // Espera a memória responder
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
				
				S6_BNE: // Bus2_Sel = 10 (from_memory), PC_Load = 1
					begin // Coloca o endereço do branch no PC
  						IR_Load = 0;
						MAR_Load = 0;
						PC_Load = 1;
						PC_Inc = 0;
 						A_Load = 0;
						B_Load = 0;
 						ALU_Sel = 3'b000;
 						CCR_Load = 0;
 						Bus1_Sel = 2'b00;
  						Bus2_Sel = 2'b10; // from_memory
 						write = 0;
					end
				
				// Implementa Branch Not Zero (se Z = 1)
				S7_BNE: // PC_Inc = 1
					begin // Incrementa o PC e branch não é tomado
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
				
				// Implementa Branch Overload (se V = 1)
				S4_BVS: // Bus1_Sel = 00 (PC), Bus2_Sel = 01 (Bus1), MAR_Load = 1
					begin // Coloca o endereço do branch no MAR
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
				
				S5_BVS:
					begin // Espera a memória responder
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
				
				S6_BVS: // Bus2_Sel = 10 (from_memory), PC_Load = 1
					begin // Coloca o endereço do branch no PC
  						IR_Load = 0;
						MAR_Load = 0;
						PC_Load = 1;
						PC_Inc = 0;
 						A_Load = 0;
						B_Load = 0;
 						ALU_Sel = 3'b000;
 						CCR_Load = 0;
 						Bus1_Sel = 2'b00;
  						Bus2_Sel = 2'b10; // from_memory
 						write = 0;
					end
				
				// Implementa Branch Overload (se V = 0)
				S7_BVS: // PC_Inc = 1
					begin // Incrementa o PC e branch não é tomado
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
				
				// Implementa Branch Not Overload (se V = 0)
				S4_BVC: // Bus1_Sel = 00 (PC), Bus2_Sel = 01 (Bus1), MAR_Load = 1
					begin // Coloca o endereço do branch no MAR
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
				
				S5_BVC:
					begin // Espera a memória responder
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
				
				S6_BVC: // Bus2_Sel = 10 (from_memory), PC_Load = 1
					begin // Coloca o endereço do branch no PC
  						IR_Load = 0;
						MAR_Load = 0;
						PC_Load = 1;
						PC_Inc = 0;
 						A_Load = 0;
						B_Load = 0;
 						ALU_Sel = 3'b000;
 						CCR_Load = 0;
 						Bus1_Sel = 2'b00;
  						Bus2_Sel = 2'b10; // from_memory
 						write = 0;
					end
				
				// Implementa Branch Not Overload (se V = 1)
				S7_BVC: // PC_Inc = 1
					begin // Incrementa o PC e branch não é tomado
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
				
				// Implementa Branch Carry (se C = 1)
				S4_BCS: // Bus1_Sel = 00 (PC), Bus2_Sel = 01 (Bus1), MAR_Load = 1
					begin // Coloca o endereço do branch no MAR
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
				
				S5_BCS:
					begin // Espera a memória responder
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
				
				S6_BCS: // Bus2_Sel = 10 (from_memory), PC_Load = 1
					begin // Coloca o endereço do branch no PC
  						IR_Load = 0;
						MAR_Load = 0;
						PC_Load = 1;
						PC_Inc = 0;
 						A_Load = 0;
						B_Load = 0;
 						ALU_Sel = 3'b000;
 						CCR_Load = 0;
 						Bus1_Sel = 2'b00;
  						Bus2_Sel = 2'b10; // from_memory
 						write = 0;
					end
				
				// Implementa Branch Carry (se C = 0)
				S7_BCS: // PC_Inc = 1
					begin // Incrementa o PC e branch não é tomado
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
				
				// Implementa Branch Not Carry (se C = 0)
				S4_BCC: // Bus1_Sel = 00 (PC), Bus2_Sel = 01 (Bus1), MAR_Load = 1
					begin // Coloca o endereço do branch no MAR
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
				
				S5_BCC:
					begin // Espera a memória responder
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
				
				S6_BCC: // Bus2_Sel = 10 (from_memory), PC_Load = 1
					begin // Coloca o endereço do branch no PC
  						IR_Load = 0;
						MAR_Load = 0;
						PC_Load = 1;
						PC_Inc = 0;
 						A_Load = 0;
						B_Load = 0;
 						ALU_Sel = 3'b000;
 						CCR_Load = 0;
 						Bus1_Sel = 2'b00;
  						Bus2_Sel = 2'b10; // from_memory
 						write = 0;
					end
				
				// Implementa Branch Not Carry (se C = 1)
				S7_BCC: // PC_Inc = 1
					begin // Incrementa o PC e branch não é tomado
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

				// Padrão de Segurança
				default: 
					begin
						IR_Load = 0;
						MAR_Load = 0;
						PC_Load = 0;
						PC_Inc = 0;
 						A_Load = 0;
						B_Load = 0;
 						ALU_Sel = 3'b000;
 						CCR_Load = 0;
 						Bus1_Sel = 2'b00;
  						Bus2_Sel = 2'b01;
 						write = 0;
					end
  			endcase
  		end
endmodule