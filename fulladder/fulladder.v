`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.06.2025 20:28:25
// Design Name: 
// Module Name: fulladder
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




module fulladder (
    input wire a,        // First input bit
    input wire b,        // Second input bit
    input wire cin,      // Carry-in
    output wire sum,     // Sum output
    output wire cout     // Carry-out
);

    // Sum = a ⊕ b ⊕ cin
    assign sum = a ^ b ^ cin;

    // Carry-out = (a & b) | (b & cin) | (a & cin)
    assign cout = (a & b) | (b & cin) | (a & cin);

endmodule

