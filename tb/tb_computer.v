`timescale 1ns/1ps

module computer_tb;

    // Inputs
    reg Clk;
    reg Reset;
    reg [7:0] port_in_00;
    reg [7:0] port_in_01;
    reg [7:0] port_in_02;
    reg [7:0] port_in_03;
    reg [7:0] port_in_04;
    reg [7:0] port_in_05;
    reg [7:0] port_in_06;
    reg [7:0] port_in_07;
    reg [7:0] port_in_08;
    reg [7:0] port_in_09;
    reg [7:0] port_in_10;
    reg [7:0] port_in_11;
    reg [7:0] port_in_12;
    reg [7:0] port_in_13;
    reg [7:0] port_in_14;
    reg [7:0] port_in_15;

    // Outputs
    wire [7:0] port_out_00;
    wire [7:0] port_out_01;
    wire [7:0] port_out_02;
    wire [7:0] port_out_03;
    wire [7:0] port_out_04;
    wire [7:0] port_out_05;
    wire [7:0] port_out_06;
    wire [7:0] port_out_07;
    wire [7:0] port_out_08;
    wire [7:0] port_out_09;
    wire [7:0] port_out_10;
    wire [7:0] port_out_11;
    wire [7:0] port_out_12;
    wire [7:0] port_out_13;
    wire [7:0] port_out_14;
    wire [7:0] port_out_15;

    // Instantiate the Unit Under Test (UUT)
    computer uut (
        .Clk(Clk),
        .Reset(Reset),
        .port_in_00(port_in_00),
        .port_in_01(port_in_01),
        .port_in_02(port_in_02),
        .port_in_03(port_in_03),
        .port_in_04(port_in_04),
        .port_in_05(port_in_05),
        .port_in_06(port_in_06),
        .port_in_07(port_in_07),
        .port_in_08(port_in_08),
        .port_in_09(port_in_09),
        .port_in_10(port_in_10),
        .port_in_11(port_in_11),
        .port_in_12(port_in_12),
        .port_in_13(port_in_13),
        .port_in_14(port_in_14),
        .port_in_15(port_in_15),
        .port_out_00(port_out_00),
        .port_out_01(port_out_01),
        .port_out_02(port_out_02),
        .port_out_03(port_out_03),
        .port_out_04(port_out_04),
        .port_out_05(port_out_05),
        .port_out_06(port_out_06),
        .port_out_07(port_out_07),
        .port_out_08(port_out_08),
        .port_out_09(port_out_09),
        .port_out_10(port_out_10),
        .port_out_11(port_out_11),
        .port_out_12(port_out_12),
        .port_out_13(port_out_13),
        .port_out_14(port_out_14),
        .port_out_15(port_out_15)
    );

    // Clock generation
    initial begin
        Clk = 0;
        forever #5 Clk = ~Clk;  // 10 ns period
    end

    initial begin
        // Initialize Inputs
        Reset = 1;

        // Wait 100 ns for global reset to finish
        #100;
        
        // Release reset
        Reset = 0;

        // Wait for some time
        #300;

        // Check the value of port_out_00
        $display("A = 15 | B = 2 | OP = + | Saída = %d", port_out_00);
        
        // End simulation
        $finish;
    end
      
endmodule