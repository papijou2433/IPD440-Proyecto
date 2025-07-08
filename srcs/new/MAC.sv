`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/09/2025 09:10:52 PM
// Design Name: 
// Module Name: MAC
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


module mult#
(
    parameter IWIDTH = 8,
    parameter OWIDTH = 16
)    
    (
    input  logic  signed [IWIDTH-1:0] A, B,             // Q1.7 inputs
    output logic  signed [OWIDTH-1:0] Out              // Q1.15 output
);
    logic signed [IWIDTH-1:0] sA, sB;
    logic signed [OWIDTH-1:0] product;

    always_comb begin
        sA = A;
        sB = B;
        product = sA * sB;               // Q1.7 × Q1.7 = Q2.14
        Out = product <<< 1;            // Shift left 1 to get Q1.15 from Q2.14
    end
endmodule
