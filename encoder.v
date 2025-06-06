`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.06.2025 18:48:30
// Design Name: 
// Module Name: encoder
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



module priority_encoder_4to2 (
    input wire [3:0] in,      // 4 input lines
    output reg [1:0] out,     // 2-bit encoded output
    output reg valid          // High if any input is 1
);

    always @(*) begin
        valid = 1'b1;
        casez (in)
            4'b1???: begin out = 2'b11; end // in[3] has highest priority
            4'b01??: begin out = 2'b10; end // in[2]
            4'b001?: begin out = 2'b01; end // in[1]
            4'b0001: begin out = 2'b00; end // in[0]
            default: begin
                out = 2'b00;
                valid = 1'b0;
            end
        endcase
    end

endmodule

