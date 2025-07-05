`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/09/2025 07:31:37 PM
// Design Name: 
// Module Name: Ctrl_2_bram
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


module Ctrl_2_bram( 
    input logic clk,reset
    );


    logic [5:0]dir_A;
    logic ena_a,ena_b;
    logic [7:0] input_tensor [7:0][7:0];
    logic [7:0]  second_stage [2:0] [7:0]  ;
    logic [7:0] mem_val ;
    logic busy;
    logic data_done;
    logic data_rdy;



    blk_mem_gen_0 BramA (
        .clka(clk),    // input wire clka
        .wea(),      // input wire [0 : 0] wea
        .addra(),  // input wire [2 : 0] addra
        .dina(),    // input wire [7 : 0] dina
        .douta(),  // output wire [7 : 0] douta
        .clkb(clk),    // input wire clkb
        .web(0),      // input wire [0 : 0] web
        .addrb(dir_A),  // input wire [2 : 0] addrb
        .dinb(),    // input wire [7 : 0] dinb
        .doutb(mem_val)  // output wire [7 : 0] doutb
      );
      
      control_unit  control_unit_inst (
        .clk(clk),
        .reset(reset),
        .busy(busy),
        .data_done(data_done),
        .enable_a(enable_a),
        .enable_b(enable_b),
        .data_rdy(data_rdy),
        .dir_A(dir_A),
        .dir_B(dir_B)
    );



    always_ff @( posedge clk ) begin
        if(!reset)begin
            input_tensor[dir_A[5:3]][dir_A[2:0]]<=mem_val;
        end
        else begin
            input_tensor[dir_A[5:3]][dir_A[2:0]]<=0;
        end
    end






    
endmodule
