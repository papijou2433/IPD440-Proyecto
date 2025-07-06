`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/05/2025 11:44:47 AM
// Design Name: 
// Module Name: Etapa1
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


module Etapa1(

    );

      //Ports
  logic clk;
  logic reset;
  logic data_rdy;
  logic [7:0] input_tensor [7:0] [7:0];
  logic [2:0] dir;
  logic data_done;
  logic [7:0] out_matrix [2:0] [2:0];

  Conv_1_FSM  Conv_1_FSM_inst (
    .clk(clk),
    .reset(reset),
    .data_rdy(data_rdy),
    .input_tensor(input_tensor),
    .dir(dir),
    .data_done(data_done),
    .out_matrix(out_matrix)
  );
  integer j;
  integer i;
always #5  clk = ! clk ;



logic [7:0] filtro [2:0] [2:0];
logic [15:0] sumandos_resultado[7:0];
logic [15:0] resultado;

assign resultado=sumandos_resultado[0]+sumandos_resultado[1]+sumandos_resultado[2]+sumandos_resultado[3]+sumandos_resultado[4]+sumandos_resultado[5]+sumandos_resultado[6]+sumandos_resultado[7];




genvar p;
genvar q;
for (q=0;q<3;q++) begin
    for (p=0;p<3;p++) begin
        mult  mult_inst (
        .A(filtro[p][q]),
        .B(out_matrix[p][q]),
        .Out(sumandos_resultado[p+3*q])
    );
    end
end


initial begin
    clk=0;
    reset=0;
    
    for (i=0;i<8;i++) begin
        for (j=0;j<8;j++) begin
            input_tensor[i][j]=i+j;
        end 
    end

    for (i=0;i<3;i++) begin
        for (j=0;j<3;j++) begin
            filtro[i][j]=i+j;
        end 
    end
    #10
    reset=1;
    #10
    reset=0;
end



endmodule
