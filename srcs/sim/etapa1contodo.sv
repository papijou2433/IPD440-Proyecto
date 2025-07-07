`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/05/2025 01:21:25 PM
// Design Name: 
// Module Name: etapa1contodo
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


module etapa1contodo();

    logic clk;
    logic reset;
    Topprimeraetapa  Topprimeraetapa_inst (
    .clk(clk),
    .reset(reset)
  );




  always #5  clk = ! clk ;

  initial begin
      clk=0;
      reset=0;
      #10
      reset=1;
      #10
      reset=0;
  
  end
  






endmodule
