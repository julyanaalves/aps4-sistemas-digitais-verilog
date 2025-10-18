`include "alu.v"
`timescale 1ns/1ps

module data_path 
    (output reg [3:0] CCR_Result, // Alterado de wire para reg
     output wire [7:0] address,
     output wire [7:0] to_memory,
     output wire [7:0] IR_out,
     output wire [7:0] PC_out,
     input wire [7:0] from_memory,
     input wire [2:0] ALU_Sel,
     input wire [1:0] Bus1_Sel, Bus2_Sel,
     input wire IR_Load, MAR_Load, PC_Load, PC_Inc, A_Load, B_Load, CCR_Load,  
     input wire Clk, Reset);
     
     reg [7:0] PC, MAR, A, B, IR;
     wire [7:0] Bus1, Bus2, ALU_Result, ALU_A, ALU_B;
     wire [3:0] NZVC;

      // Unidade de Lógica e Aritmética
      alu my_alu (
        .Result(ALU_Result),
        .NZVC(NZVC),
        .A(ALU_A),
        .B(ALU_B),
        .ALU_Sel(ALU_Sel)
      );

     // Multiplexador para Bus1
     reg [7:0] Bus1_reg;
     always @(*) begin
         case (Bus1_Sel)
             2'b00: Bus1_reg = PC;
             2'b01: Bus1_reg = A;
             2'b10: Bus1_reg = B; 
             default: Bus1_reg = 8'h00; // Valor padrão válido
         endcase
     end
     assign Bus1 = Bus1_reg;

     // Multiplexador para Bus2
     reg [7:0] Bus2_reg;
     always @(*) begin
         case (Bus2_Sel)
             2'b00: Bus2_reg = ALU_Result;
             2'b01: Bus2_reg = Bus1;
             2'b10: Bus2_reg = from_memory; 
             default: Bus2_reg = 8'h00; // Valor padrão válido
         endcase
     end
     assign Bus2 = Bus2_reg;

     // Carregamento de registros
     always @(posedge Clk or negedge Reset) begin
         if (!Reset) begin
             PC <= 8'b0;
             MAR <= 8'b0;
             A <= 8'b0;
             B <= 8'b0;
             IR <= 8'b0;
             CCR_Result <= 4'b0;
         end else begin
             if (MAR_Load) MAR <= Bus2;
             if (A_Load) A <= Bus2;
             if (B_Load) B <= Bus2;
             if (IR_Load) IR <= Bus2;
             if (CCR_Load) CCR_Result <= NZVC;
             if (PC_Load) PC <= Bus2;
             else if (PC_Inc) PC <= PC + 1;
         end
     end

     // Saídas
     assign address = MAR;
     assign to_memory = Bus1;
     assign IR_out = IR;
     assign PC_out = PC;

     // ALU
     assign ALU_A = B;
     assign ALU_B = Bus1;

endmodule