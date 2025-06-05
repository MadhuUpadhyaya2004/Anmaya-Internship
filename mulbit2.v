`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.06.2025 16:49:14
// Design Name: 
// Module Name: mulbit2
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


module half_adder (
    input wire a,
    input wire b,
    output wire sum,
    output wire carry
);
    assign sum = a ^ b;
    assign carry = a & b;
endmodule

module mulbit2 (
    input wire [1:0] A,
    input wire [1:0] B,
    output wire [3:0] P
);
    // Intermediate signals for partial products and HA results
    wire pp1, pp2, pp3;
    wire sum1, carry1;
    wire sum2, carry2;

    // Generate basic partial products
    assign P[0] = A[0] & B[0];      // Least significant bit
    assign pp1 = A[1] & B[0];
    assign pp2 = A[0] & B[1];
    assign pp3 = A[1] & B[1];

    // Add partial products using half adders
    half_adder HA1 (
        .a(pp1),
        .b(pp2),
        .sum(sum1),
        .carry(carry1)
    );
    assign P[1] = sum1;

    half_adder HA2 (
        .a(pp3),
        .b(carry1),
        .sum(sum2),
        .carry(carry2)
    );
    assign P[2] = sum2;
    assign P[3] = carry2;           // Most significant bit
endmodule
