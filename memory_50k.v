`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.06.2025 17:01:41
// Design Name: 
// Module Name: memory_50k
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


module memory_50k #(
    parameter DATA_WIDTH = 16,
    parameter DEPTH = 4096,
    parameter ADDR_WIDTH = 12  // 2^12 = 4096 entries
)(
    input clk,
    input we,
    input [ADDR_WIDTH-1:0] addr,
    input [DATA_WIDTH-1:0] din,
    output [DATA_WIDTH-1:0] dout
);

    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    always @(posedge clk) begin
        if (we) begin
            mem[addr] <= din;
        end
    end

    assign dout = mem[addr];

endmodule