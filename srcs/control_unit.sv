`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/07/2025 08:56:29 PM
// Design Name: 
// Module Name: control_unit
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


module control_unit(
    input logic clk,reset,
    input logic busy,
    input logic data_done,
    output logic enable_a,enable_b,
    output logic data_rdy,
    output logic [5:0]dir_A,
    output logic [7:0]dir_B
    );


    enum {IDLE,READ,WAIT,WRITE} state,next_state;
    logic [5:0]dir_A_next;
    logic [7:0]dir_B_next;


    // bloque secuencial 
    always_ff @( posedge clk ) begin 
        if(reset) begin
            state<=IDLE;
            dir_A<=0;
            dir_B<=0;
        end else
        begin
            state<=next_state;
            dir_A<=dir_A_next;
            dir_B<=dir_B_next;  
        end
    end

    //bloque de salidas
    always_comb begin
        case(state) 
            IDLE: begin
                dir_A_next=0;
                dir_B_next=0;
                enable_a=0;
                enable_b=0;
                data_rdy=0;
            end
            READ:begin
                dir_A_next=dir_A+1;
                dir_B_next=0;
                enable_a=1;
                enable_b=0;
                data_rdy=0;
            end
            WAIT:begin
                dir_A_next=0;
                dir_B_next=0;
                enable_a=0;
                enable_b=0;
                data_rdy=1;
            end
            WRITE:begin
                dir_A_next=0;
                dir_B_next=dir_B+1;
                enable_a=0;
                enable_b=1;
                data_rdy=0;
            end
            default: begin
                dir_A_next=0;
                dir_B_next=0;
                enable_a=0;
                enable_b=0;
                data_rdy=0;
            end
        endcase
    end

    //bloque de transiciones
    always_comb begin
        case(state) 
            IDLE: begin
                if(busy)begin
                    next_state=IDLE;
                end else begin
                    next_state=READ;
                end
            end
            READ:begin
                if(dir_A==63)begin
                    next_state=WAIT;
                end else begin
                    next_state=READ;
                end
            end
            WAIT:begin
                if(data_done)begin
                    next_state=WRITE;
                end else begin
                    next_state=WAIT;
                end
            end
            WRITE:begin
                if(dir_B==192)begin
                    next_state=WAIT;
                end else begin
                    next_state=IDLE;
                end
            end
            default: begin
                next_state=IDLE;
            end
        endcase
    end


endmodule
