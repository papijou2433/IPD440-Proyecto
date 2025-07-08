`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/07/2025 08:11:25 PM
// Design Name: 
// Module Name: receptionstg
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


module receptionstg(
    input  logic               clk, reset_n,
	input  logic               uart_rx,
	output logic               uart_tx,
	output logic               uart_tx_busy,
	output logic               uart_tx_usb
    );


	logic [7:0]    tx_data; 
	logic [7:0]    rx_data; 
	logic [1:0]    reset_sr;
	logic reset;
	assign reset = reset_sr[1];
	
	//Synchronization of reset push button
	always_ff @(posedge clk)
		reset_sr <= {reset_sr[0], ~reset_n};

    assign uart_tx_usb = uart_tx;
    assign uart_tx_busy = tx_busy;

    UART_tx_control_wrapper 
    #(  .INTER_BYTE_DELAY (100_000),
        .WAIT_FOR_REGISTER_DELAY (100)
        
        ) UART_control_inst (
        .clock      (clk),
        .reset      (reset),
        .PB         (),
        .SW         (),
        .tx_data    (tx_data),
        .tx_start   (tx_start),
        .stateID    ()
        );


    uart_basic #(
        .CLK_FREQUENCY(100000000), // reloj base de entrada
        .BAUD_RATE(115200)
    ) uart_basic_inst (
        .clk          (clk),
        .reset        (reset),
        .rx           (uart_rx),
        .rx_data      (rx_data),
        .rx_ready     (rx_ready),
        .tx           (uart_tx),
        .tx_start     (tx_start),
        .tx_data      (tx_data),
        .tx_busy      (tx_busy)
    );
    

    typedef enum logic [1:0] {
        IDLE,
        RX,
        DONE
    } state_t;

    state_t state,next_state;


    logic [5:0]counter, counter_next;


    always_ff @( posedge clk ) begin 
        if(reset) begin
            state<=IDLE;
            counter<=0;
        end
            state<=next_state;
            counter<=counter_next;
    end






    /// logica de transicion


    always_comb begin 
        case (state)
             IDLE:begin
                if((rx_data==1 )&&(rx_ready)) begin
                    next_state=RX;
                end else begin
                    next_state=IDLE;
                end
             end
             RX:begin
                if(rx_ready) begin
                    next_state=DONE;
                end else begin
                    next_state=RX;
                end
             end
             DONE: begin
                if(counter==63) begin
                    next_state=IDLE;
                end else begin
                    next_state=RX;
                end
             end
             default: next_state=IDLE;
        endcase
    end

    // logica de salida

    always_comb begin
        write=0; 
        case (state)
             IDLE:begin
                counter_next=0;
             end
             RX:begin
                counter_next=counter;
                write=1;
             end
             DONE: begin
                counter_next=counter+1;
             end
        endcase
    end


    logic write;



    blk_mem_gen_0 BramA (
    .clka(clk),    // input wire clka
    .wea(write),      // input wire [0 : 0] wea
    .addra(counter),  // input wire [2 : 0] addra
    .dina(rx_data),    // input wire [7 : 0] dina
    .douta(),  // output wire [7 : 0] douta
    .clkb(clk),    // input wire clkb
    .enb(1),
    .web(0),      // input wire [0 : 0] web
    .addrb(dir_A),  // input wire [2 : 0] addrb
    .dinb(),    // input wire [7 : 0] dinb
    .doutb(mem_val)  // output wire [7 : 0] doutb
  );




endmodule
