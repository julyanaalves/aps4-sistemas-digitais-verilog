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

    // Testa o estado S4_AND_AB
    #10;
    IR = 8'h21; // Opcode para S4_AND_AB
    #30; // Aguarda o ciclo S4_AND_AB

    // Testa o estado S4_OR_AB
    #10;
    IR = 8'h22; // Opcode para S4_OR_AB
    #40; // Aguarda o ciclo S4_OR_AB
    
    // Testa o estado S4_XOR_AB
    #10;
    IR = 8'h23; // Opcode para S4_XOR_AB
    #40; // Aguarda o ciclo S4_XOR_AB

    // Testa o estado S4_NOT_A
    #10;
    IR = 8'h2A; // Opcode para S4_NOT_A
    #50; // Aguarda os dois ciclos de S4_NOT_A, S5_NOT_A
    
    // Testa o estado S4_NOT_B
    #10;
    IR = 8'h2C; // Opcode para S4_NOT_B
    #40; // Aguarda o ciclo S4_NOT_B
    
    #20;
    $finish;
  end

  // Geração de arquivos de waveform
  initial begin
    $dumpfile("tb_control_unit_logic.vcd");
    $dumpvars(0, tb_control_unit);
  end

  // Monitoramento de sinais
  initial begin
    $monitor("Time: %0t | IR: %h | State: %h | IR_Load: %b | MAR_Load: %b | PC_Load: %b | PC_Inc: %b | A_Load: %b | B_Load: %b | write: %b", 
             $time, IR, uut.current_state, IR_Load, MAR_Load, PC_Load, PC_Inc, A_Load, B_Load, write);
  end

endmodule