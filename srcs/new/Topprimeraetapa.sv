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
    logic data_done; //lista la primera etapa
    logic data_rdy; //almacenado el 8x8


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

  







//////////////////////// Cambiar esta parte por un adder tree //////////////////////////
logic signed [15:0] sumandos_resultado[8:0];

logic signed [16:0] resultado;                // Declare as signed
logic signed [16:0] temp_sum,temp_sumbias;              // Temporary signed variable for accumulation
logic signed [16:0] Adder_tree_result;
// Proper signed accumulation
logic [15:0] bias [2:0];


always_comb begin 
    bias[0]=16'hA9BD;
    bias[1]=16'h0DF5;
    bias[2]=16'hD70A;
end

// 4 etapas de sumadores
// Revisar si es que está pescando bien la suma del último dato

adder_tree#(
    .NINPUTS(9),
    .IWIDTH(17),
    .OWIDTH(17)
    )
    adder_inst
    (
    .d(sumandos_resultado),
    .q(Adder_tree_result)
    );
ReLu #(
    .WIDTH(17)
    )
    Relu_inst(
        .in(Adder_tree_result),
        .Out(resultado)
    );






logic [7:0] filtro1 [2:0] [2:0];
logic [7:0] filtro2 [2:0] [2:0];
logic [7:0] filtro3 [2:0] [2:0];
logic [7:0] filtro_mux [2:0] [2:0];


always_comb begin 
    filtro1[2][2]=8'h2D;
    filtro1[2][1]=8'h43;
    filtro1[2][0]=8'h53;
    filtro1[1][2]=8'h55;
    filtro1[1][1]=8'h4C;
    filtro1[1][0]=8'h62;
    filtro1[0][2]=8'h3C;
    filtro1[0][1]=8'h1D;
    filtro1[0][0]=8'h4F;
end

always_comb begin 
    filtro2[2][2]=8'h2C;
    filtro2[2][1]=8'h27;
    filtro2[2][0]=8'hED;
    filtro2[1][2]=8'h2E;
    filtro2[1][1]=8'hE7;
    filtro2[1][0]=8'hB4;
    filtro2[0][2]=8'h1B;
    filtro2[0][1]=8'hFB;
    filtro2[0][0]=8'hB3;
end

always_comb begin 
    filtro3[2][2]=8'h49;
    filtro3[2][1]=8'hF1;
    filtro3[2][0]=8'h02;
    filtro3[1][2]=8'h38;
    filtro3[1][1]=8'h37;
    filtro3[1][0]=8'h2D;
    filtro3[0][2]=8'h47;
    filtro3[0][1]=8'h3D;
    filtro3[0][0]=8'h3E;
end


     
// Quizás acá se deba apretar o modificar la descripción para reducir lógica utilizada
genvar p;
genvar q;
genvar i;
genvar j;
// es necesario un for? no bastaría con un filtro_mux=filtroN a secas?
always_comb begin
    for (int i = 0; i < 3; i++) begin
        for (int j = 0; j < 3; j++) begin
            case (dir)
                2'd0: filtro_mux[i][j] = filtro1[i][j];
                2'd1: filtro_mux[i][j] = filtro2[i][j];
                2'd2: filtro_mux[i][j] = filtro3[i][j];
                default: filtro_mux[i][j] = 8'd0;
            endcase
        end
    end
end



generate
    for (q = 0; q < 3; q++) begin : row
        for (p = 0; p < 3; p++) begin : col
            mult #
            (.IWIDTH(8),.OWIDTH(16))
            mult_inst (
                .A(filtro_mux[p][q]),
                .B(out_matrix[p][q]),
                .Bias(bias[dir]),
                .Out(sumandos_resultado[p + 3*q])
            );
        end
    end
endgenerate


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
