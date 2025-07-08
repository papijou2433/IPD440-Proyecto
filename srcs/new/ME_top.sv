`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/07/2018 07:05:14 PM
// Design Name: 
// Module Name: ME_top
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

module ME_top
(
	input  logic               clk_100M,
	input  logic               reset_n,

	input  logic               uart_rx,
	output logic               uart_tx,
	output logic               uart_tx_busy,
	output logic               uart_tx_usb,
	
	input  logic               button_c
);
	/*
	 * Convertir la se�al del bot�n reset_n a 'active HIGH'
	 * y sincronizar con el reloj.
	 */
	logic [7:0]    tx_data; 
	logic [7:0]    rx_data; 
	logic [15:0]   result16;
	logic [1:0]    reset_sr;
	logic reset;
	assign reset = reset_sr[1];
	
	//Synchronization of reset push button
	always_ff @(posedge clk_100M)
		reset_sr <= {reset_sr[0], ~reset_n};

    assign uart_tx_usb = uart_tx;
    //assign uart_rx = uart_rx;
    //assign uart_tx = uart_tx;
    assign uart_tx_busy = tx_busy;

	

// Logica de control para transmitir las secuencias por la UART
UART_tx_control_wrapper 
#(  .INTER_BYTE_DELAY (100_000),
    .WAIT_FOR_REGISTER_DELAY (100)
    
    ) UART_control_inst (
	.clock      (clk_100M),
    .reset      (reset),
    .PB         (),
    .SW         (),
    .tx_data    (tx_data),
    .tx_start   (tx_start),
    .stateID    ()
    );


	/* M�dulo UART a 115200/8 bits datos/No paridad/1 bit stop */
	uart_basic #(
		.CLK_FREQUENCY(100000000), // reloj base de entrada
		.BAUD_RATE(115200)
	) uart_basic_inst (
		.clk          (clk_100M),
		.reset        (reset),
		.rx           (uart_rx),
		.rx_data      (rx_data),
		.rx_ready     (rx_ready),
		.tx           (uart_tx),
		.tx_start     (tx_start),
		.tx_data      (tx_data),
		.tx_busy      (tx_busy)
	);

// Logica de control para recibir los bytes desde la UART
// Notar el uso de un registro de desplazamiento para armar un numero de 16 bits
// a partir de la recepcion de 2 bytes

    always_ff @(posedge clk_100M) begin
        if(reset)
            result16 <= 16'd0;
        else 
        if (rx_ready)
            result16 <= {rx_data, result16[15:8]};
    end
    
/////////////////////////////////
// Los modulos siguientes son solo para las tareas de display de los datos recibidos

endmodule