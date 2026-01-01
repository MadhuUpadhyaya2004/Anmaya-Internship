`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.06.2025 16:26:17
// Design Name: 
// Module Name: posedgedetector
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


module pos_edge_detector(
    input clk,
    input rst,
    input signal_in,
    output reg edge_out
);

    reg prev_signal;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            prev_signal <= 0;
            edge_out <= 0;
        end else begin
            edge_out <= signal_in & ~prev_signal;  // Detect positive edge
            prev_signal <= signal_in;
        end
    end

endmodule

