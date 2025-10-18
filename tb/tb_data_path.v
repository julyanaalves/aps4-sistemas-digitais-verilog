`timescale 1ns/1ps

module data_path_tb;
    reg [7:0] from_memory;
    reg [2:0] ALU_Sel;
    reg [1:0] Bus1_Sel, Bus2_Sel;
    reg IR_Load, MAR_Load, PC_Load, A_Load, B_Load, CCR_Load, PC_Inc;
    reg Clk, Reset;
    wire [7:0] address, to_memory, IR_out, PC_out;
    wire [3:0] CCR_Result;

    data_path uut (
        .CCR_Result(CCR_Result),
        .address(address),
        .to_memory(to_memory),
        .IR_out(IR_out),
        .PC_out(PC_out),
        .from_memory(from_memory),
        .ALU_Sel(ALU_Sel),
        .Bus1_Sel(Bus1_Sel),
        .Bus2_Sel(Bus2_Sel),
        .IR_Load(IR_Load),
        .MAR_Load(MAR_Load),
        .PC_Load(PC_Load),
        .PC_Inc(PC_Inc),
        .A_Load(A_Load),
        .B_Load(B_Load),
        .CCR_Load(CCR_Load),
        .Clk(Clk),
        .Reset(Reset)
    );

    initial begin
        // Inicialização
        Clk = 0;
        Reset = 1;
        IR_Load = 0; MAR_Load = 0; PC_Load = 0; PC_Inc = 0;
        A_Load = 0; B_Load = 0; CCR_Load = 0;
        #10 Reset = 0;
        #10 Reset = 1;

        // Teste 1: Carregar IR com from_memory
        from_memory = 8'hAA;
        IR_Load = 1;
        Bus2_Sel = 2'b10; // Seleciona 'from_memory' como entrada para o Bus2
        #10 IR_Load = 0;
      	$display(" ");
      	$display("CARREGAR IR COM FROM_MEMORY");
      	if (IR_out != 8'hAA) $display("Teste 1 falhou: IR_out = %d", IR_out);
      	else $display("Teste 1 passou: from_memory = %d | IR_out = %d", from_memory, IR_out);

        // Teste 2: Carregar PC com from_memory
        from_memory = 8'hBB;
        PC_Load = 1;
        Bus2_Sel = 2'b10; // Seleciona 'from_memory' como entrada para o Bus2
        #10 PC_Load = 0;
      	$display(" ");
      	$display("CARREGAR PC COM FROM_MEMORY");
      	if (PC_out != 8'hBB) $display("Teste 2 falhou: PC_out = %d", PC_out);
      	else $display("Teste 2 passou: from_memory = %d | PC_out = %d", from_memory, PC_out);

        // Teste 3: Incrementar o PC
      	$display(" ");
      	$display("INCREMENTAR PC");
        PC_Inc = 1;
        #10 PC_Inc = 0;
      	if (PC_out != 8'hBC) $display("Teste 3 falhou: PC_out = %d", PC_out);
      	else $display("Teste 3 passou: PC_out = %d", PC_out);

        // Teste 4: Carregar registradores A e B com from_memory
        from_memory = 8'h12;
        Bus2_Sel = 2'b10;
        A_Load = 1;
        #10 A_Load = 0;
      	$display(" ");
      	$display("CARREGAR A COM FROM MEMORY");
      	if (uut.A != 8'h12) $display("Teste 4 falhou para A: from_memory = %d | A = %d", from_memory, uut.A);
      	else $display("Teste 4 passou para A: from_memory = %d | A = %d", from_memory, uut.A);
		
        from_memory = 8'h34;
        Bus2_Sel = 2'b10;
        B_Load = 1;
        #10 B_Load = 0;
      	$display(" ");
      	$display("CARREGAR B COM FROM MEMORY");
      	if (uut.B != 8'h34) $display("Teste 4 falhou para B: from_memory = %d | B = %d", from_memory, uut.B);
      	else $display("Teste 4 passou para B: from_memory = %d | B = %d", from_memory, uut.B);
      
        // Teste 5: Verificar operação ALU       
        Bus1_Sel = 2'b01;
        Bus2_Sel = 2'b00;
        ALU_Sel = 3'b000; // Seleciona a operação de soma
        #10;
      	$display(" ");
      	$display("VERIFICAR ALU: A + B");
      	if (uut.ALU_A != 8'h34 || uut.ALU_B != 8'h12) $display("Configuração errada: A = %h, B = %h", uut.ALU_A, uut.ALU_B);
      	if (uut.ALU_Result != 8'd70) $display("Teste 5 falhou: ALU = %b | A = %d | B = %d | Result = %d | NZVC = %b", ALU_Sel, uut.ALU_A, uut.ALU_B, uut.ALU_Result, uut.NZVC);

        else $display("Teste 5 passou: ALU = %b | A = %d | B = %d | Result = %d | NZVC = %b", ALU_Sel, uut.ALU_A, uut.ALU_B, uut.ALU_Result, uut.NZVC);

        // Teste 6: Verificar CCR update após operação da ALU
      	$display(" ");
      	$display("VERIFICAR CCR");
      	A_Load = 1;
        CCR_Load = 1;
        #10 CCR_Load = 0;
        if (CCR_Result != 4'b0000) $display("Teste 6 falhou: CCR_Result = %b", CCR_Result);
        else $display("Teste 6 passou: CCR_Result = %b", CCR_Result);
      	$display(" ");

        $finish;
    end

    always #5 Clk = ~Clk; // Geração de clock
  
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, data_path_tb);
    end
endmodule
