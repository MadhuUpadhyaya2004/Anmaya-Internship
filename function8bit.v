`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.06.2025 13:13:57
// Design Name: 
// Module Name: function8bit
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

module function8bit (
    input wire a, b, c, d, e, f, g, h,
    input wire clk,
    output reg y
);
    wire ab, de, gh;
    wire part1, part2;

    assign ab = a & b;
    assign de = d & e;
    assign gh = g & h;

    assign part1 = ab | c;
    assign part2 = de | f;

    always @(posedge clk) begin
        y <= (part1 ^ part2) ^ gh;
    end
endmodule

