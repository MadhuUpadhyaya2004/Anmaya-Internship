`timescale 1ns / 1ps

module negative_edge_detector ( // Renamed module for clarity
    input wire clk,
    input wire rst,
    input wire signal_in,
    output reg edge_out
);

    reg signal_d;

    always @(posedge clk) begin
        if (rst) begin
            signal_d <= 0;
            edge_out <= 0;
        end else begin
            signal_d <= signal_in;
            // Detect negative edge: signal_in is 0 AND signal_d (previous signal_in) was 1
            edge_out <= (~signal_in) & signal_d;
        end
    end

endmodule