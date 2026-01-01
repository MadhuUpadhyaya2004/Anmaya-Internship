`timescale 1ns / 1ps

module negative_edge_detector_tb; // Renamed testbench for clarity

    reg clk;
    reg rst;
    reg signal_in;
    wire edge_out;

    negative_edge_detector uut ( // Instantiating the new module
        .clk(clk),
        .rst(rst),
        .signal_in(signal_in),
        .edge_out(edge_out)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0; rst = 1; signal_in = 0;
        #10 rst = 0;

        #20 signal_in = 1;  // Rising edge - edge_out should be 0
        #20 signal_in = 0;  // Falling edge - edge_out should be 1
        #20 signal_in = 1;  // Rising edge - edge_out should be 0
        #20 signal_in = 0;  // Falling edge - edge_out should be 1
        #20 signal_in = 1;  // Rising edge - edge_out should be 0

        #20 $finish;
    end

    initial begin
        $monitor("Time=%0t | signal_in=%b | edge_out=%b",
                 $time, signal_in, edge_out);
    end

endmodule
