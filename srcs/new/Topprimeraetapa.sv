`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/05/2025 01:00:52 PM
// Design Name: 
// Module Name: Topprimeraetapa
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


module Topprimeraetapa(
    input logic clk,
    input logic reset
);


logic [5:0]dir_A,dir_A_buff;
logic [7:0]dir_B;
    logic ena_a,ena_b;
    logic [7:0] input_tensor [0:7][0:7];
    logic [7:0]  second_stage [2:0] [7:0]  ;
    logic [7:0] mem_val ;
    logic busy;
    logic data_done;
    logic data_rdy;


    /// Memoria de entrada ///
blk_mem_gen_0 BramA (
    .clka(clk),    // input wire clka
    .wea(),      // input wire [0 : 0] wea
    .addra(),  // input wire [2 : 0] addra
    .dina(),    // input wire [7 : 0] dina
    .douta(),  // output wire [7 : 0] douta
    .clkb(clk),    // input wire clkb
    .enb(1),
    .web(0),      // input wire [0 : 0] web
    .addrb(dir_A),  // input wire [2 : 0] addrb
    .dinb(),    // input wire [7 : 0] dinb
    .doutb(mem_val)  // output wire [7 : 0] doutb
  );


// Control unit y actualizacion de tensor de entrada

  control_unit  control_unit_inst (
    .clk(clk),
    .reset(reset),
    .busy(0),
    .data_done(data_done),
    .enable_a(enable_a),
    .enable_b(enable_b),
    .data_rdy(data_rdy),
    .dir_A(dir_A),
    .dir_A_buff(dir_A_buff)
    // .dir_B(dir_B)
);

always_ff @( posedge clk ) begin
    if(!reset)begin
        input_tensor[dir_A_buff[5:3]][dir_A_buff[2:0]]<=mem_val;
    end
    else begin
        input_tensor[dir_A_buff[5:3]][dir_A_buff[2:0]]<=0;
    end
end


/// etapa de calculo 
logic [7:0] out_matrix [0:2] [0:2];


logic [5:0]dir_counter;
logic [1:0]dir;
Conv_1_FSM  Conv_1_FSM_inst (
    .clk(clk),
    .reset(reset),
    .data_rdy(data_rdy),
    .input_tensor(input_tensor),
    .dir(dir),
    .dir_counter(dir_counter),
    .data_done(data_done),
    .out_matrix(out_matrix)
  );

  



logic [7:0] filtro [2:0] [2:0];


logic [15:0] sumandos_resultado[7:0];
logic [19:0] resultado;

assign resultado=sumandos_resultado[0]+sumandos_resultado[1]+sumandos_resultado[2]+sumandos_resultado[3]+sumandos_resultado[4]+sumandos_resultado[5]+sumandos_resultado[6]+sumandos_resultado[7];


always_comb begin 
    filtro[2][2]=8'h0B;
    filtro[2][1]=8'hCC;
    filtro[2][0]=8'h19;
    filtro[1][2]=8'h1F;
    filtro[1][1]=8'hCD;
    filtro[1][0]=8'hC0;
    filtro[0][2]=8'hEB;
    filtro[0][1]=8'hAE;
    filtro[0][0]=8'h0E;
end


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





always_comb begin 
    assign dir_B={dir[1:0],dir_counter};
end
BRAMB bramb (
.clka(clk),    // input wire clka
.wea(1),      // input wire [0 : 0] wea
.addra(dir_B),  // input wire [7 : 0] addra
.dina(resultado),    // input wire [19 : 0] dina
.clkb(0),    // input wire clkb
.enb(0),      // input wire enb
.addrb(),  // input wire [7 : 0] addrb
.doutb()  // output wire [19 : 0] doutb
);





endmodule
