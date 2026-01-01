`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: 
// Module Name: neg_edge_dect_tb
// Description: Testbench for neg_edge_dect
//////////////////////////////////////////////////////////////////////////////////

module neg_edge_dect_tb;

    reg clk;
    reg signal;
    wire neg_edge;

    // Instantiate the design under test (DUT)
    neg_edge_dect uut (
        .clk(clk),
        .signal(signal),
        .neg_edge(neg_edge)
    );

    // Clock generation: 10 ns period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test stimulus
    initial begin
        signal = 0;
        #12 signal = 1;
        #10 signal = 0;
        #10 signal = 1;
        #10 signal = 0;
        #10 signal = 0;
        #10 signal = 1;
        #10 $finish;
    end

    // Monitor signal changes
    initial begin
        $monitor("Time=%0t | signal=%b | neg_edge=%b", $time, signal, neg_edge);
    end

endmodule
