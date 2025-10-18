`include "control_unit.v"
`include "data_path.v"
`timescale 1ns/1ps

module cpu ( input wire Clk,
             input wire Reset,
             input wire [7:0] from_memory,
             output wire write,
             output wire [7:0] to_memory,
             output wire [7:0] address
             );

    wire IR_Load, MAR_Load, PC_Load, PC_Inc, A_Load, B_Load, CCR_Load;
    wire [1:0] Bus1_Sel, Bus2_Sel;
    wire [2:0] ALU_Sel;
    reg [3:0] CCR_Result;
    wire [7:0] IR;

    control_unit control_unit (
        .Clk(Clk),
        .CCR_Result(CCR_Result),
        .IR_Load(IR_Load),
        .MAR_Load(MAR_Load),
        .PC_Load(PC_Load),
        .PC_Inc(PC_Inc),
        .ALU_Sel(ALU_Sel),
        .A_Load(A_Load),
        .B_Load(B_Load),
        .CCR_Load(CCR_Load),
        .Bus1_Sel(Bus1_Sel),
        .Bus2_Sel(Bus2_Sel),
        .IR(IR),
        .Reset(Reset),
        .write(write)
    );

    data_path data_path (
        .Clk(Clk),
        .Reset(Reset),
        .IR_Load(IR_Load),
        .MAR_Load(MAR_Load),
        .PC_Load(PC_Load),
        .PC_Inc(PC_Inc),
        .ALU_Sel(ALU_Sel),
        .A_Load(A_Load),
        .B_Load(B_Load),
        .CCR_Load(CCR_Load),
        .Bus1_Sel(Bus1_Sel),
        .Bus2_Sel(Bus2_Sel),
        .from_memory(from_memory),
        .to_memory(to_memory),
        .address(address),
        .CCR_Result(CCR_Result),
        .IR_out(IR)
    );

endmodule