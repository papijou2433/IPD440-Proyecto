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
    input logic                clk,
    input  logic               reset,
	input  logic               uart_rx,
	output logic               uart_tx
	// output logic               uart_tx_busy,
	// output logic               uart_tx_usb
    );


	logic [7:0]    rx_data; 
	logic [1:0]    reset_sr;
	logic resetd;
	assign resetd = reset_sr[1];
	  //////////////////////////////////////////////////////////////////////////////////////////////////////  //////////////////////////////////////////////////////////////////////////////////////////////////////
	//Synchronization of reset push button
	always_ff @(posedge clk)
		reset_sr <= {reset_sr[0], reset};

    assign uart_tx_usb = uart_tx;
    assign uart_tx_busy = tx_busy;
    logic [7:0] tx_data;
    UART_tx_control_wrapper 
    #(  .INTER_BYTE_DELAY (100_000),
        .WAIT_FOR_REGISTER_DELAY (100)
        
        ) UART_control_inst (
        .clock      (clk),
        .reset      (resetd),
        .PB         (max_index_changed_pulse),
        .SW         ({14'd0,max_result_index}),
        .tx_data    (tx_data),
        .tx_start   (),
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
        .tx_start     (),
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


    logic write;

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
        counter_next=0;
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



logic [5:0]dir_A,dir_A_buff;
logic [7:0]dir_B;
    logic ena_a,ena_b;
    logic [7:0] input_tensor [0:7][0:7];
    logic [7:0] second_stage [2:0] [7:0]  ;
    logic [7:0] mem_val ;
    logic busy;
    logic data_done; //lista la primera etapa
    logic data_rdy; //almacenado el 8x8


    /// Memoria de entrada ///
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
    .dinb(0),    // input wire [7 : 0] dinb
    .doutb(mem_val)  // output wire [7 : 0] doutb
  );











  //////////////////////////////////////////////////////////////////////////////////////////////////////  //////////////////////////////////////////////////////////////////////////////////////////////////////
// Control unit y actualizacion de tensor de entrada

  logic busy;
  control_unit  control_unit_inst (
    .clk(clk),
    .reset(reset),
    .busy(busy),
    .data_done(data_done),
    
    .enable_a(enable_a),
    .data_rdy(data_rdy),
    .dir_A(dir_A),
    .dir_A_buff(dir_A_buff)
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
    .enb(enb),
    .dir(dir),
    .dir_counter(dir_counter),
    .data_done(data_done),
    .out_matrix(out_matrix)
  );

  logic enb;







//////////////////////// Cambiar esta parte por un adder tree //////////////////////////
logic signed [16:0] sumandos_resultado[8:0];

logic signed [16:0] resultado;                // Declare as signed
logic signed [16:0] temp_sum,temp_sumbias;              // Temporary signed variable for accumulation
logic signed [16:0] Adder_tree_result;
// Proper signed accumulation
logic [16:0] bias [2:0];
logic [16:0] bias_mux;

always_comb begin 
    bias[0]=16'sh38EC;
    bias[1]=16'sh7FD;
    bias[2]=16'shB687;
end

always_comb begin 
    case (dir)
        2'd0: bias_mux = bias[0];
        2'd1: bias_mux = bias[1];
        2'd2: bias_mux = bias[2];
        default: bias_mux = 17'd0;
    endcase
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
    
logic signed [16:0] Adder_tree_resultbias;

assign Adder_tree_resultbias=Adder_tree_result + bias_mux; // Add bias to the result
ReLu #(
    .WIDTH(17)
    )
    Relu_inst(
        .in(Adder_tree_resultbias),
        .Out(resultado)
    );






logic signed [7:0] filtro1 [2:0] [2:0];
logic signed [7:0] filtro2 [2:0] [2:0];
logic signed [7:0] filtro3 [2:0] [2:0];
logic signed [7:0] filtro_mux [2:0] [2:0];


always_comb begin 
    filtro1[2][2]=8'shC9;
    filtro1[2][1]=8'sh13;
    filtro1[2][0]=8'shB7;
    filtro1[1][2]=8'shE3;
    filtro1[1][1]=8'shE9;
    filtro1[1][0]=8'sh94;
    filtro1[0][2]=8'sh18;
    filtro1[0][1]=8'sh0B;
    filtro1[0][0]=8'shA3;
end

always_comb begin 
    filtro2[2][2]=8'shF7;
    filtro2[2][1]=8'shBE;
    filtro2[2][0]=8'shBC;
    filtro2[1][2]=8'sh00;
    filtro2[1][1]=8'shEA;
    filtro2[1][0]=8'shCE;
    filtro2[0][2]=8'sh29;
    filtro2[0][1]=8'sh4D;
    filtro2[0][0]=8'sh32;
end

always_comb begin 
    filtro3[2][2]=8'sh42;
    filtro3[2][1]=8'sh32;
    filtro3[2][0]=8'sh43;
    filtro3[1][2]=8'shF1;
    filtro3[1][1]=8'sh0E;
    filtro3[1][0]=8'sh69;
    filtro3[0][2]=8'sh48;
    filtro3[0][1]=8'sh57;
    filtro3[0][0]=8'sh63;
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
            (.IWIDTH(8),.OWIDTH(17))
            mult_inst (
                .A(filtro_mux[p][q]),
                .B(out_matrix[p][q]),
                .Out(sumandos_resultado[p + 3*q])
            );
        end
    end
endgenerate
  //////////////////////////////////////////////////////////////////////////////////////////////////////  //////////////////////////////////////////////////////////////////////////////////////////////////////  //////////////////////////////////////////////////////////////////////////////////////////////////////

assign dir_B={dir[1:0],dir_counter};

logic [7:0] dir_B_buff, dir_B_buff_next;
logic [16:0] resultado_buff;
always_ff @(posedge clk) begin
    if (reset) begin
        dir_B_buff <= 0;
        resultado_buff <= 0;
    end else begin
        dir_B_buff <= dir_B;
        resultado_buff <= resultado;
    end
end

BRAMB bramb (
.clka(clk),    // input wire clka
.wea(enb),      // input wire [0 : 0] wea
.addra(dir_B_buff),  // input wire [7 : 0] addra
.dina(resultado_buff),    // input wire [19 : 0] dina
.clkb(clk),    // input wire clkb
.enb(1),      // input wire enb
.addrb(read_addr),  // input wire [7 : 0] addrb
.doutb(BRAM_input)  // output wire [19 : 0] doutb
);


logic [16:0] BRAM_input;
logic [7:0] read_addr;
logic signed[34:0] s2_Out[143:0];

 etapa2  etapa2_inst (
    .clk(clk),
    .reset(reset),
    .BRAM_input(BRAM_input),
    .data_done(data_done),
    .busy(busy),
    .enable_read(enable_read),
    .read_addr(read_addr),
    .s2_Out(s2_Out)
  );



logic [1:0] max_result_index;
logic max_index_changed_pulse;
 etapa3 neuron(
    .clk(clk),
    .reset(reset),
    .s2_Out(s2_Out),
    .max_result_index(max_result_index),
   .max_index_changed_pulse(max_index_changed_pulse)
    );


endmodule
