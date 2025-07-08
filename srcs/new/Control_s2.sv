module Control_s2(
    input logic clk, reset,
    input logic data_done,
    output logic busy,
    output logic enable_a,
    output logic data_rdy,
    output logic [7:0] dir_A,
    output logic [7:0] dir_A_buff,
    output logic [2:0] row_addr,
    output logic [2:0] col_addr,
    output logic [2:0] cha_addr
);

logic [7:0] dir_A_next;

    logic [7:0] dir_A_buffn;
    // Agregamos el estado MEM
    enum {IDLE, READ, MEM, WAIT, READY} state, next_state;
    assign row_addr = dir_A_buffn[5:3]; //8 filas
    assign col_addr = dir_A_buffn[2:0]; //8  columnas
    assign cha_addr = dir_A_buffn[7:6]; //3 canales

    

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
                if (!data_done)
                    next_state = IDLE;
                else
                    next_state = READ;
            end

            READ: begin
                if (dir_A == 190)
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
                if (!data_done)
                    next_state = IDLE;
                else
                    next_state = WAIT;
            end

            default: next_state = IDLE;
        endcase
    end

endmodule