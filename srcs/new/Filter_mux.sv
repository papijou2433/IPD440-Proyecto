module Filter_mux#
(
    parameter WIDTH = 8
)
(
    input logic [1:0]filter_used,
    // Formato del filtro [FILA][COLUMNA][CANAL]
    input logic[WIDTH-1:0] Filtro1[2:0][2:0][2:0], 
    input logic[WIDTH-1:0] Filtro2[2:0][2:0][2:0], 
    input logic[WIDTH-1:0] Filtro3[2:0][2:0][2:0], 
    input logic[WIDTH-1:0] Filtro4[2:0][2:0][2:0], 
    output logic[WIDTH-1:0] Out[2:0][2:0][2:0]

);
    // logic[WIDTH-1:0] Filter[2:0][2:0][2:0];
    // always_comb 
    //     case(filter_used)
    //         2'b00: Filter   = Filtro1;
    //         2'b01: Filter   = Filtro2;
    //         2'b10: Filter   = Filtro3;
    //         2'b11: Filter   = Filtro4;
    //         default: Filter = Filtro1;

    //     endcase

    always_comb begin
        for (int k = 0; k < 3; k++) begin
            for (int i = 0; i < 3; i++) begin
                for (int j = 0; j < 3; j++) begin
                    case (filter_used)
                        2'd0: Out[i][j][k] = Filtro1[i][j][k];
                        2'd1: Out[i][j][k] = Filtro2[i][j][k];
                        2'd2: Out[i][j][k] = Filtro3[i][j][k];
                        2'd2: Out[i][j][k] = Filtro4[i][j][k];
                        default: Out[i][j][k] = 8'd0;
                    endcase
                end
            end
        end
    end


endmodule