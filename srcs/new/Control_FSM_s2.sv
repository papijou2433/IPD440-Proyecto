module Control_FSM_s2(
    input logic clk, reset,
    input logic data_rdy,

    output logic [1:0] dir,
    output logic [5:0] dir_counter,
    output logic data_done
    );
    typedef enum logic [2:0] {
        IDLE,
        MULT_ONE,
        MULT_TWO,
        MULT_THREE,
        MULT_FOUR,
        DONE
    } state_t;

    state_t state, next_state;

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
            
            MULT_FOUR: begin
                data_done = 0;
                dir = 3;
                dir_counter_next = dir_counter+1;
                
            end
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
                if(dir_counter==35)begin
                    dir_counter_next=0;
                    next_state=MULT_TWO;
                end else begin
                    next_state=MULT_ONE;
                end
            end
            MULT_TWO:begin
                if(dir_counter==35)begin
                    dir_counter_next=0;
                    next_state=MULT_THREE;
                end else begin
                    next_state=MULT_TWO;
                end
            end
            MULT_THREE:begin
                if(dir_counter==35)begin
                    dir_counter_next=0;
                    next_state=MULT_FOUR;
                end else begin
                    next_state=MULT_THREE;
                end
            end
            MULT_FOUR:begin
                if(dir_counter==35)begin
                    next_state=DONE;
                end else begin
                    next_state=MULT_FOUR;
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
