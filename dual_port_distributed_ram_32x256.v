`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.06.2025 21:42:19
// Design Name: 
// Module Name: dual_port_distributed_ram_32x256
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


module dual_port_distributed_ram_32x256 (
    input wire clk,
    input wire we,
    input wire [7:0] addr,         
    input wire [31:0] din,
    output reg [31:0] dout
);
    (* ram_style = "distributed" *) reg [31:0] mem [0:255];

    always @(posedge clk) begin
        if (we)
            mem[addr] <= din;    
        dout <= mem[addr];        
    end

endmodule