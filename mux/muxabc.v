`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.06.2025 18:23:44
// Design Name: 
// Module Name: muxabc
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


module muxabc(
    input a,
    input b,
    input c,
    output y

    );
/*
    wire i,j;
    assign i=b&c;
    assign j=~c&a;
    assign y= i | j;
 */

/*
    assign y=(b&c) | (~c&a);
*/
    assign y = c?b:a;
endmodule
