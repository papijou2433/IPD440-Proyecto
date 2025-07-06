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


module mult(
    input logic[7:0]    A,B,
    output logic[15:0]  Out
    );
    // logic[2:0] Fila1,Fila2,Columna1,Columna2;
    // logic[1:0] Fila3,Columna3;
    // logic[5:0] M1,M2,M4,M5;
    // logic[4:0] M3,M6,M7,M8;
    // logic[3:0] M9;
    // assign Fila1    = A[2:0];
    // assign Fila2    = A[5:3];
    // assign Fila3    = A[7:6];
    // assign Columna1 = B[2:0];
    // assign Columna2 = B[5:3];
    // assign Columna3 = B[7:6];
    logic [14:0]preout;   
    always_comb begin
        preout=A*B;
    end
    assign Out[14:0]={0,preout[14:0]};
    assign Out[15]=A[7]^B[7];
endmodule