`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.06.2025 16:34:02
// Design Name: 
// Module Name: single_port_bram_16x2048
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module single_port_bram_16x2048 (
    input wire clk,
    input wire [10:0] addr,       // 2^11 = 2048
    input wire [15:0] din,        // 16-bit data in
    input wire we,                // write enable
    output reg [15:0] dout        // 16-bit data out
);
    // Memory declaration: 2048 x 16 bits
    reg [15:0] mem [0:2047];

    always @(posedge clk) begin
        if (we)
            mem[addr] <= din;
        dout <= mem[addr];
    end
endmodule

