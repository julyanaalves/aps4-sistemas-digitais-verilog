`timescale 1ns/1ps

module rom_128x8_sync(  output reg [7:0] data_out,
                        input wire [7:0] address,
                        input wire clk
                    );
     
     reg [7:0] ROM[0:127];
     reg EN;

     // Mnemonics of Instruction Set
     
     // Loads and Stores
     parameter LDA_IMM = 8'h04; // Load Register A (Immediate Addressing)
     parameter LDA_DIR = 8'h07; // Load Register A from memory (RAM or IO) (Direct Addressing)
     parameter LDB_IMM = 8'h0C; // Load Register B (Immediate Addressing)
     parameter LDB_DIR = 8'h0F; // Load Register B from memory (RAM or IO) (Direct Addressing)
     parameter STA_DIR = 8'h14; // Store Register A to memory (RAM or IO)
     parameter STB_DIR = 8'h18; // Store Register B to memory (RAM or IO)
     
     // Data Manipulations, Connect reg A (B) to Input A (B) of ALU (Easier)
     parameter ADD_AB  = 8'h1C; // A <= A + B
     parameter SUB_AB  = 8'h1D; // A <= A - B
     parameter SUB_BA  = 8'h20; // A <= B - A
     parameter AND_AB  = 8'h21; // A <= A & B
     parameter OR_AB   = 8'h22; // A <= A | B
     parameter XOR_AB  = 8'h23; // A <= A ^ B
     parameter NOTA	   = 8'h2A; // A <= ~A
     parameter NOTB	   = 8'h2C; // B <= ~B
     parameter INCA    = 8'h24; // A <= A + 1
     parameter INCB    = 8'h26; // B <= B + 1
     parameter DECA	   = 8'h27; // A <= A - 1
     parameter DECB	   = 8'h29; // B <= B - 1
     

     // Branches
     parameter BRA     = 8'h2D; // Branch Always    to (ROM) Address
     parameter BMI     = 8'h30; // Branch if N == 1 to (ROM) Address
     parameter BPL     = 8'h34; // Branch if N == 0 to (ROM) Address
     parameter BEQ     = 8'h38; // Branch if Z == 1 to (ROM) Address
     parameter BNE	   = 8'h3C; // Branch if Z == 0 to (ROM) Address
     parameter BVS	   = 8'h40; // Branch if V == 1 to (ROM) Address 
     parameter BVC     = 8'h44; // Branch if V == 0 to (ROM) Address
     parameter BCS     = 8'h48; // Branch if C == 1 to (ROM) Address
     parameter BCC     = 8'h4C; // Branch if C == 0 to (ROM) Address
     
     initial
     	begin: PROGRAM_CODE	
     		ROM[0] = LDA_IMM; 	// Load Direto de A
     		ROM[1] = 8'h0F;		// A Data
     		ROM[2] = LDB_IMM;	// Load Direto de B
     		ROM[3] = 8'h02;		// B Data
     		ROM[4] = ADD_AB;    // A = A + B
     		ROM[5] = STA_DIR;		// Store A (ROM)
            ROM[6] = 8'hE0;		// Address to store A (Output_port_0)
     	end
     
     always @ (address) 
     	begin: ADDRESS_LIMITS
            if ( (address >= 0) && (address <= 127) ) 
                EN = 1'b1;
            else
                EN = 1'b0;
        end
     	
     always @ (posedge clk) begin
     	    if (EN)
         	    data_out <= ROM[address];
     end
     		
endmodule
