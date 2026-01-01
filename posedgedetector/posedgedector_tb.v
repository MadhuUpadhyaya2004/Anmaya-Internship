`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.06.2025 16:27:28
// Design Name: 
// Module Name: tbposedgedetector
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


module tbposedgedetector;

    reg clk;
    reg rst;
    reg signal_in;
    wire edge_out;

    // Instantiate DUT
    pos_edge_detector uut (
        .clk(clk),
        .rst(rst),
        .signal_in(signal_in),
        .edge_out(edge_out)
    );

    // Clock generation
    always #5 clk = ~clk;  // 10ns clock

    initial begin
        // Initial values
        clk = 0;
        rst = 1;
        signal_in = 0;

        // Release reset after 20ns
        #20 rst = 0;

        // Generate signal with positive edges
        #10 signal_in = 1;  // Positive edge
        #10 signal_in = 1;
        #10 signal_in = 0;  // Falling edge
        #10 signal_in = 1;  // Positive edge
        #10 signal_in = 0;
        #20 $finish;
    end

endmodule
