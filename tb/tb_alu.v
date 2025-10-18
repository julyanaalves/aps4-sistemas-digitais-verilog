`timescale 1ns/1ps

module alu_tb;
  // Inputs
  reg [7:0] A, B;
  reg [2:0] ALU_Sel;

  // Outputs
  wire [7:0] Result;
  wire [3:0] NZVC;

  // Instantiate the ALU
  alu uut (
    .Result(Result),
    .NZVC(NZVC),
    .A(A),
    .B(B),
    .ALU_Sel(ALU_Sel)
  );

  // Test procedure
  initial begin
    // Monitor signals
    $monitor("Time: %0t | ALU_Sel: %b | A: %h | B: %h | Result: %h | NZVC: %b", 
              $time, ALU_Sel, A, B, Result, NZVC);

    // Test 000 - Adder
    A = 8'b00001111; B = 8'b00000001; ALU_Sel = 3'b000;
    #10;
    if (Result == 8'b00010000) $display("Test 000 (Adder) passou");
    else $display("Test 000 (Adder) não passou");

    // Test 001 - Increment
    A = 8'b00001111; B = 8'b00000000; ALU_Sel = 3'b001;
    #10;
    if (Result == 8'b00010000) $display("Test 001 (Increment) passou");
    else $display("Test 001 (Increment) não passou");

    // Test 010 - Subtractor
    A = 8'b00001111; B = 8'b00000001; ALU_Sel = 3'b010;
    #10;
    if (Result == 8'b00001110) $display("Test 010 (Subtractor) passou");
    else $display("Test 010 (Subtractor) não passou");

    // Test 011 - Decrement
    A = 8'b00001111; B = 8'b00000000; ALU_Sel = 3'b011;
    #10;
    if (Result == 8'b00001110) $display("Test 011 (Decrement) passou");
    else $display("Test 011 (Decrement) não passou");

    // Test 100 - AND
    A = 8'b00001111; B = 8'b00001010; ALU_Sel = 3'b100;
    #10;
    if (Result == 8'b00001010) $display("Test 100 (AND) passou");
    else $display("Test 100 (AND) não passou");

    // Test 101 - OR
    A = 8'b00001111; B = 8'b00001010; ALU_Sel = 3'b101;
    #10;
    if (Result == 8'b00001111) $display("Test 101 (OR) passou");
    else $display("Test 101 (OR) não passou");

    // Test 110 - XOR
    A = 8'b00001111; B = 8'b00001010; ALU_Sel = 3'b110;
    #10;
    if (Result == 8'b00000101) $display("Test 110 (XOR) passou");
    else $display("Test 110 (XOR) não passou");

    // Test 111 - NOT
    A = 8'b00001111; B = 8'b00000000; ALU_Sel = 3'b111;
    #10;
    if (Result == 8'b11110000) $display("Test 111 (NOT) passou");
    else $display("Test 111 (NOT) não passou");

    $finish;
  end
endmodule
