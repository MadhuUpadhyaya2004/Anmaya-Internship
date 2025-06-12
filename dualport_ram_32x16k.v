`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.06.2025 20:00:08
// Design Name: 
// Module Name: dualport_ram_32x16k
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


module dualport_ram_32x16k (
    input wire clk,

    // Port A: Write only
    input wire [13:0] addr_a,     // 14-bit address → 16K
    input wire [31:0] din_a,
    input wire we_a,

    // Port B: Read/Write
    input wire [13:0] addr_b,
    input wire [31:0] din_b,
    input wire we_b,
    output reg [31:0] dout_b
);

    // Force block RAM style
    (* ram_style = "block" *) reg [31:0] mem [0:16383];

    // Port A: Write-only
    always @(posedge clk) begin
        if (we_a)
            mem[addr_a] <= din_a;
    end

    // Port B: Read/Write
    always @(posedge clk) begin
        if (we_b)
            mem[addr_b] <= din_b;
        dout_b <= mem[addr_b]; // Read after write in same cycle gives new/old depending on implementation
    end

endmodule

