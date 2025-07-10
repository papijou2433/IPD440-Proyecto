`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.07.2025 14:10:04
// Design Name: 
// Module Name: System_tb
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


module System_tb();



logic clk;
logic reset;
logic uart_rx;
logic uart_tx;


Topprimeraetapa  Topprimeraetapa_inst (
    .clk(clk),
    .reset(reset),
    .uart_rx(uart_rx),
    .uart_tx(uart_tx)
  );


always #5 clk=!clk;

initial begin
    clk=0;
    reset=0;
    uart_rx=1;
    #10
    reset=1;
    #30
    reset=0;
end



endmodule
