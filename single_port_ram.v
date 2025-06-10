`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.06.2025 23:01:28
// Design Name: 
// Module Name: single_port_ram
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


module single_port_ram(

input        clk,
input        we,
input  [9:0] addr,
input  [31:0] din,
output [31:0] dout
);

reg [31:0] mem [0:1023];

always @(posedge clk)
begin
    if (we)
        mem[addr] <= din;
end

assign dout = mem[addr];
endmodule