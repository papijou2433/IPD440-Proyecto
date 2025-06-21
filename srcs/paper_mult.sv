`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.06.2025 00:28:15
// Design Name: 
// Module Name: comb_paper
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
    logic[2:0] Fila1,Fila2,Columna1,Columna2;
    logic[1:0] Fila3,Columna3;
    logic[5:0] M1,M2,M4,M5;
    logic[4:0] M3,M6,M7,M8;
    logic[3:0] M9;
    assign Fila1    = A[2:0];
    assign Fila2    = A[5:3];
    assign Fila3    = A[7:6];
    assign Columna1 = B[2:0];
    assign Columna2 = B[5:3];
    assign Columna3 = B[7:6];
    
    always_comb begin
        M1 = Fila1 * Columna1;
        M2 = Fila1 * Columna2;
        M3 = Fila1 * Columna3;
        M4 = Fila2 * Columna1;
        M5 = Fila2 * Columna2;
        M6 = Fila2 * Columna3;
        M7 = Fila3 * Columna1;
        M8 = Fila3 * Columna2;
        M9 = Fila3 * Columna3;
        
        Out = M1 + (M2<<3) + (M3<<6) + (M4<<3) + (M5<<6) + (M6<<9) + (M7<<6) + (M8<<9) + (M9<<12);
    end
endmodule
