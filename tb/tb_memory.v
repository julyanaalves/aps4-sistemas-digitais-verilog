module memory_tb;

    // Sinais de entrada
    reg [7:0] address;
    reg [7:0] data_in;
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
    reg write, clk, reset;

    // Sinais de saída
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
    wire [7:0] data_out;

    // Instanciar o módulo memory
    memory uut (
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
        .port_out_15(port_out_15),
        .data_out(data_out),
        .address(address),
        .data_in(data_in),
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
        .write(write),
        .clk(clk),
        .reset(reset)
    );

    // Gerar o clock
    always #5 clk = ~clk;

    initial begin
        // Inicializar os sinais
        clk = 0;
        reset = 1;
        write = 0;
        address = 0;
        data_in = 0;
        port_in_00 = 8'hAA;
        port_in_01 = 8'hBB;
        port_in_02 = 8'hCC;
        port_in_03 = 8'hDD;
        port_in_04 = 8'hEE;
        port_in_05 = 8'hFF;
        port_in_06 = 8'h11;
        port_in_07 = 8'h22;
        port_in_08 = 8'h33;
        port_in_09 = 8'h44;
        port_in_10 = 8'h55;
        port_in_11 = 8'h66;
        port_in_12 = 8'h77;
        port_in_13 = 8'h88;
        port_in_14 = 8'h99;
        port_in_15 = 8'h00;

        // Desativar o reset
        #10 reset = 0;

        // Testar escrita nos registradores de saída
        #10 write = 1; address = 8'hF0; data_in = 8'h01;
        #10 address = 8'hF1; data_in = 8'h02;
        #10 address = 8'hF2; data_in = 8'h03;
        #10 address = 8'hF3; data_in = 8'h04;
        #10 address = 8'hF4; data_in = 8'h05;
        #10 address = 8'hF5; data_in = 8'h06;
        #10 address = 8'hF6; data_in = 8'h07;
        #10 address = 8'hF7; data_in = 8'h08;
        #10 address = 8'hF8; data_in = 8'h09;
        #10 address = 8'hF9; data_in = 8'h0A;
        #10 address = 8'hFA; data_in = 8'h0B;
        #10 address = 8'hFB; data_in = 8'h0C;
        #10 address = 8'hFC; data_in = 8'h0D;
        #10 address = 8'hFD; data_in = 8'h0E;
        #10 address = 8'hFE; data_in = 8'h0F;
        #10 address = 8'hFF; data_in = 8'h10;

        // Desativar escrita
        #10 write = 0;

        // Testar leitura dos registradores de saída
        #10 address = 8'hF0;
        #10 address = 8'hF1;
        #10 address = 8'hF2;
        #10 address = 8'hF3;
        #10 address = 8'hF4;
        #10 address = 8'hF5;
        #10 address = 8'hF6;
        #10 address = 8'hF7;
        #10 address = 8'hF8;
        #10 address = 8'hF9;
        #10 address = 8'hFA;
        #10 address = 8'hFB;
        #10 address = 8'hFC;
        #10 address = 8'hFD;
        #10 address = 8'hFE;
        #10 address = 8'hFF;

        // Finalizar a simulação
        #10 $finish;
    end

    // Monitorar os sinais
    initial begin
        $monitor("Time: %0t | Address: %h | Data In: %h | Data Out: %h | Write: %b | Reset: %b", $time, address, data_in, data_out, write, reset);
    end

endmodule