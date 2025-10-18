`include "rom_128x8_sync.v"
`timescale 1ns/1ps

module rw_memory (
    output reg [7:0] data_out,
    input wire [7:0] address,
    input wire [7:0] data_in,
    input wire write,
    input wire clk,
    input wire reset
);

    reg [7:0] memory [0:95]; // Definindo uma memória de 96 posições (128 a 223)

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Inicializa a memória com zeros
            integer i;
            for (i = 0; i < 96; i = i + 1) begin
                memory[i] <= 8'b0;
            end
        end else if (write && (address >= 128) && (address <= 223)) begin
            memory[address - 128] <= data_in;
        end
    end

    always @(address) begin
        if ((address >= 128) && (address <= 223)) begin
            data_out = memory[address - 128];
        end else begin
            data_out = 8'b0;
        end
    end

endmodule

module port_out8_sync
    (output reg [7:0] port_out_00,
     output reg [7:0] port_out_01,
     output reg [7:0] port_out_02,
     output reg [7:0] port_out_03,
     output reg [7:0] port_out_04,
     output reg [7:0] port_out_05,
     output reg [7:0] port_out_06,
     output reg [7:0] port_out_07,
     output reg [7:0] port_out_08,
     output reg [7:0] port_out_09,
     output reg [7:0] port_out_10,
     output reg [7:0] port_out_11,
     output reg [7:0] port_out_12,
     output reg [7:0] port_out_13,
     output reg [7:0] port_out_14,
     output reg [7:0] port_out_15,
     input wire [7:0] address,
     input wire [7:0] data_in,
     input wire write, clk, reset);
     
     // port_out_00 (address E0)
     always @ (posedge clk or negedge reset)
        begin
            if (!reset)
                port_out_00 <= 8'h00; 
            else if (address == 8'hE0 && write) 
                port_out_00 <= data_in;
        end
                
     // port_out_01 (address E1)
     always @ (posedge clk or negedge reset)
        begin
            if (!reset)
                port_out_01 <= 8'h00; 
            else if (address == 8'hE1 && write) 
                port_out_01 <= data_in;
        end
        
     // port_out_02 (address E2)
     always @ (posedge clk or negedge reset)
        begin
            if (!reset)
                port_out_02 <= 8'h00; 
            else if (address == 8'hE2 && write) 
                port_out_02 <= data_in;
        end	
        
     // port_out_03 (address E3)
     always @ (posedge clk or negedge reset)
        begin
            if (!reset)
                port_out_03 <= 8'h00; 
            else if (address == 8'hE3 && write) 
                port_out_03 <= data_in;
        end	
        
     // port_out_04 (address E4)
     always @ (posedge clk or negedge reset)
        begin
            if (!reset)
                port_out_04 <= 8'h00; 
            else if (address == 8'hE4 && write) 
                port_out_04 <= data_in;
        end	
     	
     // port_out_05 (address E5)		
     always @ (posedge clk or negedge reset)
        begin
            if (!reset)
                port_out_05 <= 8'h00; 
            else if (address == 8'hE5 && write) 
                port_out_05 <= data_in;
        end
        
     // port_out_06 (address E6)		
     always @ (posedge clk or negedge reset)
        begin
            if (!reset)
                port_out_06 <= 8'h00; 
            else if (address == 8'hE6 && write) 
                port_out_06 <= data_in;
        end	
        
     // port_out_07 (address E7)		
     always @ (posedge clk or negedge reset)
        begin
            if (!reset)
                port_out_07 <= 8'h00; 
            else if (address == 8'hE7 && write) 
                port_out_07 <= data_in;
        end	
        
     // port_out_08 (address E8)		
     always @ (posedge clk or negedge reset)
        begin
            if (!reset)
                port_out_08 <= 8'h00; 
            else if (address == 8'hE8 && write) 
                port_out_08 <= data_in;
        end	
        
     // port_out_09 (address E9)		
     always @ (posedge clk or negedge reset)
        begin
            if (!reset)
                port_out_09 <= 8'h00; 
            else if (address == 8'hE9 && write) 
                port_out_09 <= data_in;
        end	
        
     // port_out_10 (address EA)		
     always @ (posedge clk or negedge reset)
        begin
            if (!reset)
                port_out_10 <= 8'h00; 
            else if (address == 8'hEA && write) 
                port_out_10 <= data_in;
        end	
        
     // port_out_11 (address EB)		
     always @ (posedge clk or negedge reset)
        begin
            if (!reset)
                port_out_11 <= 8'h00; 
            else if (address == 8'hEB && write) 
                port_out_11 <= data_in;
        end	
        
     // port_out_12 (address EC)		
     always @ (posedge clk or negedge reset)
        begin
            if (!reset)
                port_out_12 <= 8'h00; 
            else if (address == 8'hEC && write) 
                port_out_12 <= data_in;
        end	
        
     // port_out_13 (address ED)		
     always @ (posedge clk or negedge reset)
        begin
            if (!reset)
                port_out_13 <= 8'h00; 
            else if (address == 8'hED && write) 
                port_out_13 <= data_in;
        end
        
     // port_out_14 (address EE)		
     always @ (posedge clk or negedge reset)
        begin
            if (!reset)
                port_out_14 <= 8'h00; 
            else if (address == 8'hEE && write) 
                port_out_14 <= data_in;
        end	
        
     // port_out_15 (address EF)		
     always @ (posedge clk or negedge reset)
        begin
            if (!reset)
                port_out_15 <= 8'h00; 
            else if (address == 8'hEF && write) 
                port_out_15 <= data_in;
        end					
endmodule

module rw_96x8_sync (
    output reg [7:0] data_out,
    input wire [7:0] address,
    input wire WE,
    input wire [7:0] data_in,
    input wire clk
);
    reg [7:0] RW [128:223];
    reg EN; // Alterado de wire para reg

    always @ (address) begin
        if ((address >= 128) && (address <= 223))
            EN = 1'b1;
        else
            EN = 1'b0;
    end

    always @ (posedge clk) begin
        if (WE && EN)
            RW[address] = data_in;
        else if (!WE && EN)
            data_out = RW[address];
    end
endmodule

module memory (
    output reg [7:0] port_out_00,
    output reg [7:0] port_out_01,
    output reg [7:0] port_out_02,
    output reg [7:0] port_out_03,
    output reg [7:0] port_out_04,
    output reg [7:0] port_out_05,
    output reg [7:0] port_out_06,
    output reg [7:0] port_out_07,
    output reg [7:0] port_out_08,
    output reg [7:0] port_out_09,
    output reg [7:0] port_out_10,
    output reg [7:0] port_out_11,
    output reg [7:0] port_out_12,
    output reg [7:0] port_out_13,
    output reg [7:0] port_out_14,
    output reg [7:0] port_out_15,
    output reg [7:0] data_out,
    input wire [7:0] address,
    input wire [7:0] data_in,
    input wire [7:0] port_in_00,
    input wire [7:0] port_in_01,
    input wire [7:0] port_in_02,
    input wire [7:0] port_in_03,
    input wire [7:0] port_in_04,
    input wire [7:0] port_in_05,
    input wire [7:0] port_in_06,
    input wire [7:0] port_in_07,
    input wire [7:0] port_in_08,
    input wire [7:0] port_in_09,
    input wire [7:0] port_in_10,
    input wire [7:0] port_in_11,
    input wire [7:0] port_in_12,
    input wire [7:0] port_in_13,
    input wire [7:0] port_in_14,
    input wire [7:0] port_in_15,
    input wire write, clk, reset
);

    wire [7:0] rom_data_out, rw_data_out;

    // Instanciar o módulo ROM
    rom_128x8_sync rom_inst (
        .data_out(rom_data_out),
        .address(address),
        .clk(clk)
    );

    // Instanciar o módulo de memória de leitura/escrita
    rw_memory rw_mem_inst (
        .data_out(rw_data_out),
        .address(address),
        .data_in(data_in),
        .write(write),
        .clk(clk),
        .reset(reset)
    );

    always @ (address, rom_data_out, rw_data_out, port_in_00, port_in_01, port_in_02, port_in_03, port_in_04, port_in_05, port_in_06, port_in_07, port_in_08, port_in_09, port_in_10, port_in_11, port_in_12, port_in_13, port_in_14, port_in_15) begin: Multiplexing_to_Memory_Data_Bus
        if ( (address >= 0) && (address <= 127) ) 
            data_out = rom_data_out;
        else if ( (address >= 128) && (address <= 223) ) 
            data_out = rw_data_out;
        else if (address == 8'hF0) 
            data_out = port_in_00; 
        else if (address == 8'hF1) 
            data_out = port_in_01; 
        else if (address == 8'hF2) 
            data_out = port_in_02; 
        else if (address == 8'hF3) 
            data_out = port_in_03; 
        else if (address == 8'hF4) 
            data_out = port_in_04; 
        else if (address == 8'hF5) 
            data_out = port_in_05; 
        else if (address == 8'hF6) 
            data_out = port_in_06; 
        else if (address == 8'hF7) 
            data_out = port_in_07; 
        else if (address == 8'hF8) 
            data_out = port_in_08; 
        else if (address == 8'hF9) 
            data_out = port_in_09; 
        else if (address == 8'hFA) 
            data_out = port_in_10; 
        else if (address == 8'hFB) 
            data_out = port_in_11; 
        else if (address == 8'hFC) 
            data_out = port_in_12; 
        else if (address == 8'hFD) 
            data_out = port_in_13; 
        else if (address == 8'hFE) 
            data_out = port_in_14; 
        else if (address == 8'hFF) 
            data_out = port_in_15;
    end

    always @ (posedge clk or posedge reset) begin
        if (reset) begin
            port_out_00 <= 8'b0;
            port_out_01 <= 8'b0;
            port_out_02 <= 8'b0;
            port_out_03 <= 8'b0;
            port_out_04 <= 8'b0;
            port_out_05 <= 8'b0;
            port_out_06 <= 8'b0;
            port_out_07 <= 8'b0;
            port_out_08 <= 8'b0;
            port_out_09 <= 8'b0;
            port_out_10 <= 8'b0;
            port_out_11 <= 8'b0;
            port_out_12 <= 8'b0;
            port_out_13 <= 8'b0;
            port_out_14 <= 8'b0;
            port_out_15 <= 8'b0;
        end else if (write) begin
            case (address)
                8'hF0: port_out_00 <= data_in;
                8'hF1: port_out_01 <= data_in;
                8'hF2: port_out_02 <= data_in;
                8'hF3: port_out_03 <= data_in;
                8'hF4: port_out_04 <= data_in;
                8'hF5: port_out_05 <= data_in;
                8'hF6: port_out_06 <= data_in;
                8'hF7: port_out_07 <= data_in;
                8'hF8: port_out_08 <= data_in;
                8'hF9: port_out_09 <= data_in;
                8'hFA: port_out_10 <= data_in;
                8'hFB: port_out_11 <= data_in;
                8'hFC: port_out_12 <= data_in;
                8'hFD: port_out_13 <= data_in;
                8'hFE: port_out_14 <= data_in;
                8'hFF: port_out_15 <= data_in;
            endcase
        end
    end

endmodule
