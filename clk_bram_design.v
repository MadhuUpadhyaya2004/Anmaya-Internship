`timescale 1ns / 1ps



module clk_bram_design(
    input clk_70mhz,
    input reset,
    output [31:0] read_data_out,
    output locked
);

    wire clk_30mhz;
    wire clk_100mhz;

    // Clocking Wizard instance
    clk_wiz_0 clk_wiz_inst (
        .clk_in1(clk_70mhz),
        .reset(reset),
        .clk_out1(clk_30mhz),    // 30 MHz
        .clk_out2(clk_100mhz),   // 100 MHz
        .locked(locked)
    );

    // Write logic (30 MHz)
    reg [9:0] write_addr = 10'd0;
    always @(posedge clk_30mhz) begin
        if (reset || !locked)
            write_addr <= 0;
        else
            write_addr <= write_addr + 1;
    end

    // Write data = write_addr * 2 (stored in full 32-bit width)
    wire [31:0] write_data = write_addr << 1;

    // Write enable only when locked
    wire write_en = locked;

    // Read logic (100 MHz)
    reg [9:0] read_addr = 10'd0;
    reg [15:0] read_delay = 0;
    reg start_reading = 0;

    always @(posedge clk_100mhz) begin
        if (reset || !locked) begin
            read_delay     <= 0;
            read_addr      <= 0;
            start_reading  <= 0;
        end else begin
            if (!start_reading) begin
                read_delay <= read_delay + 1;
                if (read_delay >= 49)
                    start_reading <= 1;
            end else begin
                read_addr <= read_addr + 1;
            end
        end
    end

    // Block Memory Generator instantiation
    blk_mem_gen_0 bram_inst (
        .clka(clk_30mhz),
        .ena(locked),
        .wea(write_en),
        .addra(write_addr),
        .dina(write_data),

        .clkb(clk_100mhz),
        .enb(locked),
        .addrb(read_addr),
        .doutb(read_data_out)
    );

endmodule


