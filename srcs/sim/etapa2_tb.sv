`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.07.2025 04:44:14
// Design Name: 
// Module Name: etapa2_tb
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


module etapa2_tb();


BRAMB your_instance_name (
  .clka(clk),    // input wire clka
  .wea(0),      // input wire [0 : 0] wea
  .addra(0),  // input wire [7 : 0] addra
  .dina(dina),    // input wire [16 : 0] dina
  .clkb(clk),    // input wire clkb
  .enb(1),      // input wire enb
  .addrb(read_addr),  // input wire [7 : 0] addrb
  .doutb(BRAM_input)  // output wire [16 : 0] doutb
);
  // Parameters

  //Ports
  logic clk;
  logic reset;
  logic data_done;
  logic [16:0] BRAM_input;
  logic busy;
  logic enable_read;
  logic [7:0] read_addr;
  logic [35:0] s2_Out[143:0];

  etapa2  etapa2_inst (
    .clk(clk),
    .reset(reset),
    .BRAM_input(BRAM_input),
    .busy(busy),
    .enable_read(enable_read),
    .read_addr(read_addr),
    .s2_Out(s2_Out)
  );

always #5  clk = ! clk ;
initial begin
    clk = 0;
    reset = 0;
    busy = 0;
    #10
    reset = 1; // Reset the system
    #10
    reset = 0; // Release reset
    
end

endmodule
