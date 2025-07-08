module control_unit(
    input logic clk, reset,
    input logic busy,
    input logic data_done,
    output logic enable_a,
    output logic data_rdy,
    output logic [5:0] dir_A,
    output logic [5:0] dir_A_buff
);

    // Agregamos el estado MEM
    enum {IDLE, READ, MEM, WAIT} state, next_state;

    logic [5:0] dir_A_next;
    logic [7:0] dir_B_next;

    logic [5:0] dir_A_buffn;

    // Contador para MEM (2 ciclos)
    logic [1:0] mem_counter, mem_counter_next;

    // Bloque secuencial
    always_ff @(posedge clk) begin
        if (reset) begin
            state <= IDLE;
            dir_A <= 0;
            dir_A_buffn <= 0;
            dir_A_buff <= 0;
            mem_counter <= 0;
        end else begin
            state <= next_state;
            dir_A_buff <= dir_A_buffn;
            dir_A_buffn <= dir_A;
            dir_A <= dir_A_next;
            mem_counter <= mem_counter_next;
        end
    end

    // Bloque de salidas
    always_comb begin
        // Defaults
        dir_A_next = dir_A;
        enable_a = 0;
        data_rdy = 0;
        mem_counter_next = mem_counter;

        case (state)
            IDLE: begin
                dir_A_next = 0;
            end

            READ: begin
                dir_A_next = dir_A + 1;
                enable_a = 1;
            end

            MEM: begin
                enable_a = 0;  // o dejarlo igual a READ si se desea mantener enable_a en alto
                mem_counter_next = mem_counter + 1;
            end

            WAIT: begin
                dir_A_next = 0;
                data_rdy = 1;
            end
        endcase
    end

    // Bloque de transiciones
    always_comb begin
        next_state = state; // Default

        case (state)
            IDLE: begin
                if (busy)
                    next_state = IDLE;
                else
                    next_state = READ;
            end

            READ: begin
                if (dir_A == 63)
                    next_state = MEM;
                else
                    next_state = READ;
            end

            MEM: begin
                if (mem_counter == 2)
                    next_state = WAIT;
                else
                    next_state = MEM;
            end

            WAIT: begin
                if (data_done)
                    next_state = IDLE;
                else
                    next_state = WAIT;
            end

            default: next_state = IDLE;
        endcase
    end

endmodule
