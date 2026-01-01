`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: 
// Module Name: neg_edge_dect
// Description: Negative edge detector module
//////////////////////////////////////////////////////////////////////////////////

module neg_edge_dect(
    input wire clk,
    input wire signal,
    output reg neg_edge
);

    reg signal_d;

    always @(posedge clk) begin
        signal_d <= signal;
        neg_edge <= (signal_d == 1 && signal == 0);
    end

endmodule

