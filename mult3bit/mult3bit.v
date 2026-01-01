`timescale 1ns / 1ps

// Half Adder module
module simple_half_adder(
    input x, y,
    output sum, carry
);
    assign sum = x ^ y;
    assign carry = x & y;
endmodule

// 3-bit multiplier
module threebit_mul (
    input [2:0] A,
    input [2:0] B,
    output [5:0] P
);
    wire pp0, pp1, pp2, pp3, pp4, pp5, pp6, pp7, pp8;

    wire s1, c1, s2, c2, s3, c3, s4, c4, s5, c5;
    wire s6, c6, s7, c7, s8, c8, s9, c9;
    wire s10, c10;

    // Partial Products
    assign pp0 = A[0] & B[0];
    assign pp1 = A[1] & B[0];
    assign pp2 = A[2] & B[0];
    assign pp3 = A[0] & B[1];
    assign pp4 = A[1] & B[1];
    assign pp5 = A[2] & B[1];
    assign pp6 = A[0] & B[2];
    assign pp7 = A[1] & B[2];
    assign pp8 = A[2] & B[2];

    assign P[0] = pp0;

    // P[1] = pp1 + pp3
    simple_half_adder ha1(pp1, pp3, P[1], c1);

    // P[2] = pp2 + pp4 + pp6 + c1
    simple_half_adder ha2(pp2, pp4, s1, c2);
    simple_half_adder ha3(s1, pp6, s2, c3);
    simple_half_adder ha4(s2, c1, P[2], c4);

    // P[3] = pp5 + pp7 + c2 + c3 + c4
    simple_half_adder ha5(pp5, pp7, s3, c5);
    simple_half_adder ha6(s3, c2, s4, c6);
    simple_half_adder ha7(s4, c3, s5, c7);
    simple_half_adder ha8(s5, c4, P[3], c8);

    // P[4] = pp8 + c5 + c6 + c7 + c8
    simple_half_adder ha9(pp8, c5, s6, c9);
    simple_half_adder ha10(s6, c6, s7, c10);
    simple_half_adder ha11(s7, c7, s8, );
    simple_half_adder ha12(s8, c8, P[4], );

    // P[5] = c9 + c10
    assign P[5] = c9 ^ c10; // simple final logic (ignore final carry for 6-bit output)

endmodule
