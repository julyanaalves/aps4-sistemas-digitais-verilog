`timescale 1ns/1ps

module tb_control_unit;

  // Declaração de sinais
  reg [7:0] IR;
  reg [3:0] CCR_Result;
  reg Clk, Reset;
  wire IR_Load, MAR_Load, PC_Load, PC_Inc, A_Load, B_Load, CCR_Load, write;
  wire [2:0] ALU_Sel;
  wire [1:0] Bus1_Sel, Bus2_Sel;

  // Instanciação do módulo control_unit
  control_unit uut (
    .IR_Load(IR_Load),
    .MAR_Load(MAR_Load),
    .PC_Load(PC_Load),
    .PC_Inc(PC_Inc),
    .A_Load(A_Load),
    .B_Load(B_Load),
    .CCR_Load(CCR_Load),
    .ALU_Sel(ALU_Sel),
    .Bus1_Sel(Bus1_Sel),
    .Bus2_Sel(Bus2_Sel),
    .write(write),
    .IR(IR),
    .CCR_Result(CCR_Result),
    .Clk(Clk),
    .Reset(Reset)
  );

  // Geração de clock
  initial begin
    Clk = 0;
    forever #5 Clk = ~Clk; // Clock com período de 10 ns
  end

  // Estímulos de teste
  initial begin
    // Inicializa os sinais
    Reset = 1;
    IR = 8'b0;
    CCR_Result = 4'b0;

    // Reset do módulo
    Reset = 0;
    #10;
    Reset = 1;

    // Testa o estado S4_ADD_AB
    #10;
    IR = 8'h1C; // Opcode para S4_ADD_AB
    #30; // Aguarda o ciclo S4_ADD_AB

    
    // Testa o estado S4_SUB_AB
    #10;
    IR = 8'h1D; // Opcode para S4_SUB_AB
    #80; // Aguarda os três ciclos de S4_SUB_AB, S5_SUB_AB, S6_SUB_AB
    
    // Testa o estado S4_SUB_BA
    #10;
    IR = 8'h20; // Opcode para S4_SUB_BA
    #30; // Aguarda o ciclo S4_SUB_BA

    
    // Testa o estado S4_INC_A
    #10;
    IR = 8'h24; // Opcode para S4_INC_A
    #50; // Aguarda os dois ciclos de S4_INC_A, S5_INC_A
    
    // Testa o estado S4_INC_B
    #10;
    IR = 8'h26; // Opcode para S4_INC_B
    #30; // Aguarda o ciclo S4_INC_B
    
    
    // Testa o estado S4_DEC_A
    #10;
    IR = 8'h27; // Opcode para S4_DEC_A
    #50; // Aguarda os dois ciclos de S4_DEC_A, S5_DEC_A
    
    // Testa o estado S4_DEC_B
    #10;
    IR = 8'h29; // Opcode para S4_DEC_B
    #30; // Aguarda o ciclo S4_DEC_B

    
    #20;
    $finish;
  end

  // Geração de arquivos de waveform
  initial begin
    $dumpfile("tb_control_unit_arith.vcd");
    $dumpvars(0, tb_control_unit);
  end

  // Monitoramento de sinais
  initial begin
    $monitor("Time: %0t | IR: %h | State: %h | IR_Load: %b | MAR_Load: %b | PC_Load: %b | PC_Inc: %b | A_Load: %b | B_Load: %b | write: %b", 
             $time, IR, uut.current_state, IR_Load, MAR_Load, PC_Load, PC_Inc, A_Load, B_Load, write);
  end

endmodule