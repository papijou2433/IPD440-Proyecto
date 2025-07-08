
module adder_tree#
(
    parameter NINPUTS = 2048,
    parameter IWIDTH = 8,
    parameter OWIDTH = 18
)
(
    input logic signed[IWIDTH-1:0] d[NINPUTS-1:0],
    output logic signed[OWIDTH-1:0] q
);

    localparam NSTAGES = $clog2(NINPUTS);   // Número de etapas
    localparam SWIDTH = IWIDTH + NSTAGES - 1;   // Tamaño máximo de los sumadores

    // Registros para almacenar los resultados de cada etapa
    logic signed[SWIDTH-1:0] stages_sum [NSTAGES:0][NINPUTS/2-1:0];

    // Generación de la lógica usando generate
    genvar stage, j;
    generate
        // Primera etapa: cálculo de la distancia Manhattan
        for (j = 0; j < NINPUTS/2; j++) begin: initial_stage
            always_comb begin
                if ((2*j + 1) < NINPUTS)
                    stages_sum[0][j] = d[2*j]+d[2*j+1]
                else
                    stages_sum[0][j] = d[2*j];
            end
        end

        // Etapas posteriores: sumas secuenciales
        for (stage = 1; stage <= NSTAGES; stage++) begin: adder_stages
            localparam num_sum = NINPUTS / (2 ** (stage + 1));
            for (j = 0; j < num_sum; j++) begin: stage_adder
                always_comb begin
                    stages_sum[stage][j] = stages_sum[stage-1][2*j] + stages_sum[stage-1][2*j + 1];
                end
            end
        end
    endgenerate

    // Salida: resultado final
    assign q = stages_sum[NSTAGES-1][0][OWIDTH-1:0];

endmodule