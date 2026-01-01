`timescale 1ns / 1ps



module clk_bram_design_tb;

    reg clk_70mhz = 0;
    reg reset = 0;
    wire [31:0] read_data_out;
    wire locked;

    // Instantiate DUT
    top uut (
        .clk_70mhz(clk_70mhz),
        .reset(reset),
        .read_data_out(read_data_out),
        .locked(locked)
    );

    // Generate 70 MHz input clock (14.285 ns period)
    always #7.142 clk_70mhz = ~clk_70mhz;

    // Simulated derived clocks for testbench
    reg sim_clk_30mhz = 0;
    reg sim_clk_100mhz = 0;

    // 30 MHz clock = 33.33 ns
    always #16.66 sim_clk_30mhz = ~sim_clk_30mhz;

    // 100 MHz clock = 10 ns
    always #5 sim_clk_100mhz = ~sim_clk_100mhz;

    initial begin
        // Override internal clocks from Clocking Wizard
        force uut.clk_30mhz = sim_clk_30mhz;
        force uut.clk_100mhz = sim_clk_100mhz;
        force uut.locked = 1'b1;

        // Apply reset
        reset = 1;
        #50;
        reset = 0;
    end

    // Monitor key signals with clean formatting
    initial begin
        $monitor("Time = %0t ns | wr_addr = %0d | wr_data = %0d | rd_addr = %0d | read_data_out = %0d | reset = %b",
            $time,
            uut.write_addr,
            uut.write_data,
            uut.read_addr,
            read_data_out,
            reset
        );

        #2000000;  // Run simulation for 2 ms
        $finish;
    end

endmodule


