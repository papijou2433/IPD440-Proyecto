


module Filtros_s2_ROM#me dejo
(
    parameter WIDTH = 8
)
(
    //Formato = [Fila][Columna][Canal] (es más simple la multiplexación escrita de esta manera)
    //input logic[WIDTH-1:0]  F1[2:0][2:0][2:0],
    //input logic[WIDTH-1:0]  F2[2:0][2:0][2:0],
    //input logic[WIDTH-1:0]  F3[2:0][2:0][2:0],

    output logic[WIDTH-1:0] Filtro1[2:0][2:0][2:0],
    output logic[WIDTH-1:0] Filtro2[2:0][2:0][2:0],
    output logic[WIDTH-1:0] Filtro3[2:0][2:0][2:0],
    output logic[WIDTH-1:0] Filtro4[2:0][2:0][2:0]
);
    always_comb begin
        Filtro1[0][0][0] = 
    end

endmodule