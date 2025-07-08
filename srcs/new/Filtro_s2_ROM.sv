


module Filtros_s2_ROM#
(
    parameter WIDTH = 17
)
(
    //FiltroX = [Fila][Columna][Canal] (es más simple la multiplexación escrita de esta manera)
    //input logic[WIDTH-1:0]  F1[2:0][2:0][2:0],
    //input logic[WIDTH-1:0]  F2[2:0][2:0][2:0],
    //input logic[WIDTH-1:0]  F3[2:0][2:0][2:0],

    output logic signed [WIDTH-1:0] Filtro1[2:0][2:0][2:0],
    output logic signed [WIDTH-1:0] Filtro2[2:0][2:0][2:0],
    output logic signed [WIDTH-1:0] Filtro3[2:0][2:0][2:0],
    output logic signed [WIDTH-1:0] Filtro4[2:0][2:0][2:0]
);
    always_comb begin
        // Filtro1[FILA][COLUMNA][CANAL] - Formato Q0.16 (1 bit de signo, 16 bits fraccionales)
    Filtro1 ='{
  '{ // Fila 0
    '{17'sb1110101101011110, 17'sb1110100001011111, 17'sb1111110101101110}, // Columna 0: canales 0,1,2
    '{17'sb1101100110111101, 17'sb1110110001101110, 17'sb1111100111000001}, // Columna 1
    '{17'sb1111001000110110, 17'sb1111001000010011, 17'sb1111110101101100}  // Columna 2
  },
  '{ // Fila 1
    '{17'sb1101010111010000, 17'sb0000111001101101, 17'sb1111100011000001},
    '{17'sb1110010010000101, 17'sb1111010000100101, 17'sb0011110111110101},
    '{17'sb1111100011101001, 17'sb1111111110111000, 17'sb1110101111111011}
  },
  '{ // Fila 2
    '{17'sb1011010100101001, 17'sb0101010011101001, 17'sb1111101001100111},
    '{17'sb1101101011000000, 17'sb0100010100000000, 17'sb1111101100100101},
    '{17'sb1110010001111101, 17'sb0100000000101110, 17'sb0000011010000111}
  }
};

    end

endmodule