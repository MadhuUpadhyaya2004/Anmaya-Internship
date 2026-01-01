`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.06.2025 14:13:00
// Design Name: 
// Module Name: param_single_port_ram
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


module param_single_port_ram #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 10,
    parameter DEPTH = 1 << ADDR_WIDTH
)(
    input                     clk,
    input                     we,
    input  [ADDR_WIDTH-1:0]   addr,
    input  [DATA_WIDTH-1:0]   din,
    output [DATA_WIDTH-1:0]   dout
);

    // Memory declaration
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    // Write operation
    always @(posedge clk) begin
        if (we)
            mem[addr] <= din;
    end

    // Read operation
    assign dout = mem[addr];

endmodule
