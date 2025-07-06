`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/09/2025 09:10:24 PM
// Design Name: 
// Module Name: Conv_1_FSM
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

module Conv_1_FSM(
    input logic clk, reset,
    input logic data_rdy,
    input logic [7:0] input_tensor [0:7] [0:7],

    output logic [1:0] dir,
    output logic [5:0] dir_counter,
    output logic data_done,
    output logic [7:0] out_matrix [0:2] [0:2]
    );
    typedef enum logic [2:0] {
        IDLE,
        MULT_ONE,
        MULT_TWO,
        MULT_THREE,
        DONE
    } state_t;

    state_t state, next_state;

    logic [5:0] dir_counter_next; 

    logic [7:0] padded_matrix [0:9][0:9];
    genvar i,j;
    generate
        // Zero out the left and right columns
        for (i = 1; i < 9; i++) begin
            always_comb begin : Columns_zero
                padded_matrix[i][0] = input_tensor[i-1][0];
                padded_matrix[i][9] = input_tensor[i-1][7];
            end
        end
        always_comb begin
            padded_matrix[0][0] = input_tensor[0][0];
            padded_matrix[0][9] = input_tensor[0][7];
            padded_matrix[9][0] = input_tensor[0][0];
            padded_matrix[9][9] = input_tensor[0][7];
        end
        // Zero out the top and bottom rows
        for (i = 1; i < 9; i++) begin
            always_comb begin : Row_zero
                padded_matrix[0][i] = input_tensor[0][i-1];
                padded_matrix[9][i] =  input_tensor[7][i-1];
            end 
        end

        // Fill the center from input_tensor
        for (i = 1; i < 9; i++) begin
            for (j = 1; j < 9; j++) begin
                always_comb begin :center_input
                    padded_matrix[i][j] = input_tensor[i-1][j-1];

                end
            end    
        end
    endgenerate




    generate
        for (i = 0; i < 3; i++) begin
            for (j = 0; j < 3; j++) begin
                always_comb begin : blockName
                    out_matrix[i][j]=padded_matrix[dir_counter[5:3]+i][dir_counter[2:0]+j];
                end
            end    
        end
    endgenerate


    always_ff @(posedge clk)  
        if(reset) begin
            state<=IDLE;
            dir_counter<=0;
        end
        else begin
            state<=next_state;  
            dir_counter<=dir_counter_next;
        end
    

    //bloque de salidas
    always_comb begin
        case(state) 
            IDLE: begin
                data_done=0;
                dir=0;
                dir_counter_next=0;
            end
            MULT_ONE: begin
                data_done=0;
                dir=0;
                dir_counter_next=dir_counter+1;
            end
            MULT_TWO: begin
                data_done=0;
                dir=1;
                dir_counter_next=dir_counter+1;
            end
            MULT_THREE: begin
                data_done=0;
                dir=2;
                dir_counter_next=dir_counter+1;
            end
            DONE: begin
                data_done=1;
                dir=0;
                dir_counter_next=0;
            end
            default:
            begin
                data_done=0;
                dir=0;
                dir_counter_next=0;
            end
        endcase
    end

    //bloque de transiciones
    always_comb begin
        case(state) 
            IDLE: begin
                if(!data_rdy)begin
                    next_state=IDLE;
                end else begin
                    next_state=MULT_ONE;
                end
            end
            MULT_ONE:begin
                if(dir_counter==63)begin
                    next_state=MULT_TWO;
                end else begin
                    next_state=MULT_ONE;
                end
            end
            MULT_TWO:begin
                if(dir_counter==63)begin
                    next_state=MULT_THREE;
                end else begin
                    next_state=MULT_TWO;
                end
            end
            MULT_THREE:begin
                if(dir_counter==63)begin
                    next_state=DONE;
                end else begin
                    next_state=MULT_THREE;
                end
            end
            DONE:begin
                next_state=IDLE;
            end
            default: begin
                next_state=IDLE;
            end
        endcase
    end

    

endmodule
