module Control_FSM_s2(
    input logic clk, reset,
    input logic data_rdy,

    output logic [1:0] dir,
    output logic [5:0] dir_counter,
    output logic busy_proc
    );
    typedef enum logic [2:0] {
        IDLE,
        MULT_ONE,
        MULT_TWO,
        MULT_THREE,
        MULT_FOUR
    } state_t;

    state_t state, next_state;


    logic [5:0] dir_counter_next;
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
                busy_proc=0;
                dir=0;
            end
            MULT_ONE: begin
                busy_proc=1;
                dir=0;
            end
            MULT_TWO: begin
                busy_proc=1;
                dir=1;
            end
            MULT_THREE: begin
                busy_proc=1;
                dir=2;
            end
            MULT_FOUR: begin
                busy_proc=1;
                dir = 3;
                
            end

            default:
            begin
                busy_proc=0;
                dir=0;
            end
        endcase
    end

    //bloque de transiciones
    always_comb begin
        case(state) 
            IDLE: begin
                dir_counter_next=0; 
                if(!data_rdy)begin
                    next_state=IDLE;
                end else begin
                    next_state=MULT_ONE;
                end
            end
            MULT_ONE:begin
                if(dir_counter==35)begin
                    next_state=MULT_TWO;
                    dir_counter_next=0; 
                end else begin
                    next_state=MULT_ONE;
                    dir_counter_next=dir_counter+1; 
                end
            end
            MULT_TWO:begin
                if(dir_counter==35)begin
                    next_state=MULT_THREE;
                    dir_counter_next=0;
                end else begin
                    next_state=MULT_TWO;
                    dir_counter_next=dir_counter+1; 
                end
            end
            MULT_THREE:begin
                if(dir_counter==35)begin
                    next_state=MULT_FOUR;
                    dir_counter_next=0; 
                end else begin
                    next_state=MULT_THREE;
                    dir_counter_next=dir_counter+1; 
                end
            end
            MULT_FOUR:begin
                if(dir_counter==35)begin
                    next_state=IDLE;
                    dir_counter_next=0; 
                end else begin
                    next_state=MULT_FOUR;
                    dir_counter_next=dir_counter+1; 
                end
            end

            default: begin
                next_state=IDLE;
                dir_counter_next=0; 
            end
        endcase
    end

    

endmodule
