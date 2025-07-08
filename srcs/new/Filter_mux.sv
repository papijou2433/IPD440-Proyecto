module chanel_mux#
(
    parameter WIDTH = 8
)
(
    input logic filter_used[1:0],
    // Formato del filtro [FILA][COLUMNA][CANAL]
    input logic[WIDTH-1:0] Filtro1[2:0][2:0][2:0], 
    input logic[WIDTH-1:0] Filtro2[2:0][2:0][2:0], 
    input logic[WIDTH-1:0] Filtro3[2:0][2:0][2:0], 
    input logic[WIDTH-1:0] Filtro4[2:0][2:0][2:0], 
    output logic[WIDTH1-1:0] Out[2:0][2:0] //fila y columna

);
    logic[WIDTH-1:0] Filter[2:0][2:0][2:0];
    always_comb 
        case(filter_used)
            2'b00: Filter   = Filtro1;
            2'b01: Filter   = Filtro2;
            2'b10: Filter   = Filtro3;
            2'b11: Filter   = Filtro4;
            default: Filter = Filtro1;

        endcase
endmodule