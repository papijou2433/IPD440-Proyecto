module adder_tree#(
    parameter int NINPUTS = 27,
    parameter int IWIDTH  = 8,
    parameter int OWIDTH  = 18
)(
    input  logic signed [IWIDTH-1:0] d[NINPUTS],
    output logic signed [OWIDTH-1:0] q
);

    localparam int NSTAGES = $clog2(NINPUTS);
    localparam int SWIDTH  = IWIDTH + NSTAGES; // Ancho suficiente para evitar overflow

    // Almacenamiento por etapa (la cantidad de elementos disminuye por etapa)
    logic signed [SWIDTH-1:0] stage_data [0:NSTAGES][0:NINPUTS-1];

    // Etapa 0: asignación directa de entradas
    genvar i;
    generate
        for (i = 0; i < NINPUTS; i++) begin : input_stage
            always_comb stage_data[0][i] = d[i];
        end
    endgenerate

    // Etapas intermedias: reducción en árbol binario
    genvar stage, j;
    generate
        for (stage = 1; stage <= NSTAGES; stage++) begin : adder_stages
            localparam int n_prev = (NINPUTS + (1 << (stage - 1)) - 1) >> (stage - 1);
            localparam int n_curr = (n_prev + 1) >> 1;

            for (j = 0; j < n_curr; j++) begin : sum_stage
                always_comb begin
                    if ((2*j + 1) < n_prev)
                        stage_data[stage][j] = stage_data[stage-1][2*j] + stage_data[stage-1][2*j + 1];
                    else
                        stage_data[stage][j] = stage_data[stage-1][2*j]; // Propaga si no hay par
                end
            end
        end
    endgenerate

    // Resultado final: el único dato restante en la última etapa
    assign q = stage_data[NSTAGES][0][OWIDTH-1:0];

endmodule
