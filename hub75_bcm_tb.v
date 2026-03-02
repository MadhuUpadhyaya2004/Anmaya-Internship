`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.06.2025 11:21:17
// Design Name: 
// Module Name: hub75_bcm_tb
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


`default_nettype none

module hub75_bcm_tb;

    // Parameters
    parameter integer N_ROWS   = 32;
    parameter integer N_PLANES = 8;
    parameter integer LOG_N_ROWS = $clog2(N_ROWS);

    // Clock and Reset
    reg clk;
    reg rst;

    // DUT Inputs
    reg shift_rdy;
    reg blank_rdy;
    reg [LOG_N_ROWS-1:0] ctrl_row;
    reg ctrl_row_first;
    reg ctrl_go;
    reg [7:0] cfg_pre_latch_len;
    reg [7:0] cfg_latch_len;
    reg [7:0] cfg_post_latch_len;

    // DUT Outputs
    wire phy_addr_inc;
    wire phy_addr_rst;
    wire [LOG_N_ROWS-1:0] phy_addr;
    wire phy_le;
    wire [N_PLANES-1:0] shift_plane;
    wire shift_go;
    wire [N_PLANES-1:0] blank_plane;
    wire blank_go;
    wire ctrl_rdy;

    // Instantiate DUT
    hub75_bcm #(
        .N_ROWS(N_ROWS),
        .N_PLANES(N_PLANES)
    ) dut (
        .phy_addr_inc(phy_addr_inc),
        .phy_addr_rst(phy_addr_rst),
        .phy_addr(phy_addr),
        .phy_le(phy_le),
        .shift_plane(shift_plane),
        .shift_go(shift_go),
        .shift_rdy(shift_rdy),
        .blank_plane(blank_plane),
        .blank_go(blank_go),
        .blank_rdy(blank_rdy),
        .ctrl_row(ctrl_row),
        .ctrl_row_first(ctrl_row_first),
        .ctrl_go(ctrl_go),
        .ctrl_rdy(ctrl_rdy),
        .cfg_pre_latch_len(cfg_pre_latch_len),
        .cfg_latch_len(cfg_latch_len),
        .cfg_post_latch_len(cfg_post_latch_len),
        .clk(clk),
        .rst(rst)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100 MHz
    end

    // Dump VCD file
    initial begin
        $dumpfile("hub75_bcm.vcd");
        $dumpvars(0, hub75_bcm_tb);
    end

    // Latch pulse width debug
    reg [7:0] latch_counter;
    reg phy_le_prev;
    always @(posedge clk) begin
        phy_le_prev <= phy_le;
        if (phy_le) begin
            latch_counter <= latch_counter + 1;
        end else if (phy_le_prev && !phy_le) begin
            $display("[Latch] Width: %0d at time %0t", latch_counter, $time);
            latch_counter <= 0;
        end
    end

    // FSM activity monitor
    initial begin
        $monitor("T=%0t | Row=%0d | Plane=%b | LE=%b | ShiftGo=%b | BlankGo=%b | Addr=%0d | Rdy=%b",
                 $time, ctrl_row, shift_plane, phy_le, shift_go, blank_go, phy_addr, ctrl_rdy);
    end

    // Test stimulus
    integer i=0;
    initial begin
        // Init signals
        rst = 1;
        ctrl_go = 0;
        shift_rdy = 0;
        blank_rdy = 0;
        ctrl_row = 0;
        ctrl_row_first = 0;
        latch_counter = 0;
        phy_le_prev = 0;

        cfg_pre_latch_len  = 8'd5;
        cfg_latch_len      = 8'd10;
        cfg_post_latch_len = 8'd5;

        #40 rst = 0;
        @(posedge clk);

        wait(ctrl_rdy);
        $display("Initial ctrl_rdy received at %0t", $time);

        shift_rdy = 1;
        blank_rdy = 1;

        // === First Frame ===
        for (i = 0; i < N_ROWS; i = i + 1) begin
            @(posedge clk);
            ctrl_row = i;
            ctrl_row_first = (i == 0);
            ctrl_go = 1;
            $display("[Frame1] Sending ctrl_row=%0d at %0t", i, $time);
            @(posedge clk);
            ctrl_go = 0;

            $display("[Frame1] Waiting for ctrl_rdy at %0t", $time);
            wait(ctrl_rdy);
            $display("[Frame1] ctrl_rdy received at %0t", $time);
        end

        $display("==== Full Frame Done ====");

        // === Second Frame ===
        for (i = 0; i < N_ROWS; i = i + 1) begin
            @(posedge clk);
            ctrl_row = i;
            ctrl_row_first = (i == 0);
            ctrl_go = 1;
            $display("[Frame2] Sending ctrl_row=%0d at %0t", i, $time);
            @(posedge clk);
            ctrl_go = 0;

            $display("[Frame2] Waiting for ctrl_rdy at %0t", $time);
            wait(ctrl_rdy);
            $display("[Frame2] ctrl_rdy received at %0t", $time);
        end

        $display("==== Second Frame Done ====");

        #100_000; // simulate 100 us
$finish;

        $finish;
    end

endmodule