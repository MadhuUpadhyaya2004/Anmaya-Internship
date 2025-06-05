`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.06.2025 23:38:47
// Design Name: 
// Module Name: counter2bit
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




module counter2bit (
    input wire clk,
    input wire rst,
    output reg [1:0] count
);
    always @(posedge clk or posedge rst) begin
        if (rst)
            count <= 2'b00;
        else
            count <= count + 1;
    end
endmodule
