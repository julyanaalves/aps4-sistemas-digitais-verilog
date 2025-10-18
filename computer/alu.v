`timescale 1ns/1ps

module not_gate(input wire a, output wire y);
  nand(y, a, a);
endmodule

module and_gate(input wire a, input wire b, output wire y);
  wire n1, n2;
  nand(n1, a, b);
  nand(y, n1, n1);
endmodule

module or_gate(input wire a, input wire b, output wire y);
  wire n1, n2, n3;
  nand(n1, a, a);
  nand(n2, b, b);
  nand(y, n1, n2);
endmodule

module xor_gate(input wire a, input wire b, output wire y);
  wire n1, n2, n3;
  nand(n1, a, b);
  nand(n2, a, n1);
  nand(n3, b, n1);
  nand(y, n2, n3);
endmodule

module nand8b (
    input wire [7:0] a,
    input wire [7:0] b,
    output wire [7:0] y
);

    nand(y[0], a[0], b[0]);
    nand(y[1], a[1], b[1]);
    nand(y[2], a[2], b[2]);
    nand(y[3], a[3], b[3]);
    nand(y[4], a[4], b[4]);
    nand(y[5], a[5], b[5]);
    nand(y[6], a[6], b[6]);
    nand(y[7], a[7], b[7]);

endmodule

module not8b (
  input wire [7:0] a,
  output wire [7:0] y
);
  not_gate not0(.a(a[0]), .y(y[0]));
  not_gate not1(.a(a[1]), .y(y[1]));
  not_gate not2(.a(a[2]), .y(y[2]));
  not_gate not3(.a(a[3]), .y(y[3]));
  not_gate not4(.a(a[4]), .y(y[4]));
  not_gate not5(.a(a[5]), .y(y[5]));
  not_gate not6(.a(a[6]), .y(y[6]));
  not_gate not7(.a(a[7]), .y(y[7]));

endmodule

module and8b (
  input wire [7:0] a, b,
  output wire [7:0] y
);
  and_gate and0 (.a(a[0]), .b(b[0]), .y(y[0]));
  and_gate and1 (.a(a[1]), .b(b[1]), .y(y[1]));
  and_gate and2 (.a(a[2]), .b(b[2]), .y(y[2]));
  and_gate and3 (.a(a[3]), .b(b[3]), .y(y[3]));
  and_gate and4 (.a(a[4]), .b(b[4]), .y(y[4]));
  and_gate and5 (.a(a[5]), .b(b[5]), .y(y[5]));
  and_gate and6 (.a(a[6]), .b(b[6]), .y(y[6]));
  and_gate and7 (.a(a[7]), .b(b[7]), .y(y[7]));

endmodule

module or8b (
  input wire [7:0] a,
  input wire [7:0] b,
  output wire [7:0] y
);
  or_gate or0(.a(a[0]), .b(b[0]), .y(y[0]));
  or_gate or1(.a(a[1]), .b(b[1]), .y(y[1]));
  or_gate or2(.a(a[2]), .b(b[2]), .y(y[2]));
  or_gate or3(.a(a[3]), .b(b[3]), .y(y[3]));
  or_gate or4(.a(a[4]), .b(b[4]), .y(y[4]));
  or_gate or5(.a(a[5]), .b(b[5]), .y(y[5]));
  or_gate or6(.a(a[6]), .b(b[6]), .y(y[6]));
  or_gate or7(.a(a[7]), .b(b[7]), .y(y[7]));

endmodule

module xor8b (
  input wire [7:0] a,
  input wire [7:0] b,
  output wire [7:0] y
);
  xor_gate xor0(.a(a[0]), .b(b[0]), .y(y[0]));
  xor_gate xor1(.a(a[1]), .b(b[1]), .y(y[1]));
  xor_gate xor2(.a(a[2]), .b(b[2]), .y(y[2]));
  xor_gate xor3(.a(a[3]), .b(b[3]), .y(y[3]));
  xor_gate xor4(.a(a[4]), .b(b[4]), .y(y[4]));
  xor_gate xor5(.a(a[5]), .b(b[5]), .y(y[5]));
  xor_gate xor6(.a(a[6]), .b(b[6]), .y(y[6]));
  xor_gate xor7(.a(a[7]), .b(b[7]), .y(y[7]));

endmodule

module mux(input wire a, input wire b, input wire sel, output wire y);

  wire n1, n2, n3;

  nand(n1, sel, sel);
  nand(n2, n1 , b);
  nand(n3, sel, a);
  nand(y, n2, n3);
  
endmodule

module mux2_1_8b(
    output wire [7:0] y,
    input wire [7:0] a, b,
    input wire sel
    );

    wire [7:0] inv_sel;
    wire [7:0] n1, n2;

    not8b invsel (.y(inv_sel), .a({8{sel}})); 
    and8b and0 (.y(n1), .a(a), .b(inv_sel));
    and8b and1 (.y(n2), .a(b), .b({8{sel}}));
    or8b Y (.y(y), .a(n1), .b(n2));

endmodule

module mux4_1_8b(
	output wire [7:0] y,
	input wire [7:0] a, b, c, d,
	input wire [1:0] sel
	);

	wire [7:0] n1, n2;
	mux2_1_8b mux0 (.y(n1), .a(a), .b(b), .sel(sel[0]));
	mux2_1_8b mux1 (.y(n2), .a(c), .b(d), .sel(sel[0]));
	mux2_1_8b mux2 (.y(y), .a(n1), .b(n2), .sel(sel[1]));

endmodule

module mux4_1(output y, input a, b, c, d, input [1:0] sel);

  wire n1, n2;

  mux mux0 (.y(n1), .a(a), .b(b), .sel(sel[0]));
  mux mux1 (.y(n2), .a(c), .b(d), .sel(sel[0]));
  mux mux2 (.y(y), .a(n1), .b(n2), .sel(sel[1]));

endmodule

module half_adder(
    output wire sum, cout,
    input wire a, b
    );
    and_gate carry (.y(cout), .a(a), .b(b));
    xor_gate sum_ (.y(sum), .a(a), .b(b));

endmodule

module full_adder(
    output wire sum, cout, 
    input wire a, b, cin
    );
        wire n1, n2;
        wire s0;

        half_adder hf0 (.sum(s0), .cout(n1), .a(a), .b(b));
        half_adder hf1 (.sum(sum), .cout(n2), .a(s0), .b(cin));
        or_gate cout_ (.y(cout), .a(n1), .b(n2));
endmodule


module full_adder_8b (
    input wire [7:0] a ,b,
    input wire cin,
    output wire [7:0] sum,
    output wire cout
);
    wire [7:0] carry; 

    full_adder fa0 (.a(a[0]), .b(b[0]), .cin(cin), .sum(sum[0]), .cout(carry[0]));
    full_adder fa1 (.a(a[1]), .b(b[1]), .cin(carry[0]), .sum(sum[1]), .cout(carry[1]));
    full_adder fa2 (.a(a[2]), .b(b[2]), .cin(carry[1]), .sum(sum[2]), .cout(carry[2]));
    full_adder fa3 (.a(a[3]), .b(b[3]), .cin(carry[2]), .sum(sum[3]), .cout(carry[3]));
    full_adder fa4 (.a(a[4]), .b(b[4]), .cin(carry[3]), .sum(sum[4]), .cout(carry[4]));
    full_adder fa5 (.a(a[5]), .b(b[5]), .cin(carry[4]), .sum(sum[5]), .cout(carry[5]));
    full_adder fa6 (.a(a[6]), .b(b[6]), .cin(carry[5]), .sum(sum[6]), .cout(carry[6]));
    full_adder fa7 (.a(a[7]), .b(b[7]), .cin(carry[6]), .sum(sum[7]), .cout(cout));
    
endmodule


module arithmetic_unit(
    input wire [7:0] a, b,
    input wire [1:0] sel,
    output wire [7:0] y,
    output wire cout
    );

    wire [7:0] b_inverted, sum, inc, sub, dec;
    wire cout_sub, cout_add;

    // Inverte b para operações de subtração e decremento
    not8b inv_b(.a(b), .y(b_inverted));

    // Somador
    full_adder_8b adder(.a(a), .b(b), .cin(1'b0), .sum(sum), .cout(cout_add));
    
    // Incrementador
    full_adder_8b incrementer(.a(a), .b(8'b00000001), .cin(1'b0), .sum(inc));
    
    // Subtrator
    full_adder_8b subtractor(.a(a), .b(b_inverted), .cin(1'b1), .sum(sub), .cout(cout_sub));
    
    // Decrementador
    full_adder_8b decrementer(.a(a), .b(8'b11111111), .cin(1'b0), .sum(dec));

    // Seleção da operação baseada no sel
    mux4_1_8b mux_arithmetic(
        .y(y),
        .a(sum),
        .b(inc),
        .c(sub),
        .d(dec),
        .sel(sel)
    );

    assign cout = (sel == 2'b00) ? cout_add : 
                  (sel == 2'b10) ? cout_sub : 1'b0;

endmodule


module logic_unit(
    input wire [7:0] a, b,
    input wire [1:0] sel,
    output wire [7:0] y
    );

    wire [7:0] and_, or_, xor_, nand_;

    and8b AND8 (.a(a), .b(b), .y(and_));
    or8b OR8 (.a(a), .b(b), .y(or_));
    xor8b XOR8 (.a(a), .b(b), .y(xor_));
    not8b NOT8 (.a(a), .y(nand_));

    mux4_1_8b mux_logic (
        .y(y),
        .a(and_),
        .b(or_),
        .c(xor_),
        .d(nand_),
        .sel(sel)
    );

endmodule

module flags (
  output wire [3:0] nzvc,
  input wire [7:0] y,
  input wire cout, 
  input wire [7:0] a,
  input wire [7:0] b
);
  wire negative, zero, carry, overflow;
  assign negative = y[7];
  assign zero = (y == 8'b00000000);
  assign carry = cout;
  assign overflow = (a[7] == b[7]) && (a[7] != y[7]);

  assign nzvc = {negative, zero, overflow, carry};
endmodule

module alu (
  output wire [7:0] Result, 
  output wire [3:0] NZVC,
  input wire [7:0] A, B, 
  input wire [2:0] ALU_Sel
);
  wire [7:0] y_arithmetic, y_logic;
  wire cout;

  // Unidade aritmética
  arithmetic_unit au(
    .y(y_arithmetic),
    .cout(cout),
    .a(A),
    .b(B),
    .sel(ALU_Sel[1:0])
  );

  // Unidade lógica
  logic_unit lu(
    .y(y_logic),
    .a(A),
    .b(B),
    .sel(ALU_Sel[1:0])
  );

  // Multiplexador para selecionar entre operações aritméticas e lógicas
  mux2_1_8b mux_sel(
    .y(Result),
    .a(y_arithmetic),
    .b(y_logic),
    .sel(ALU_Sel[2])
  );

  // Flags de condição
  flags fl(
    .nzvc(NZVC),
    .y(Result),
    .cout(cout),
    .a(A),
    .b(B)
  );

endmodule
