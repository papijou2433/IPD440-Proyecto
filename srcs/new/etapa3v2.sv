module etapa3v2(
    input logic clk,
    input logic reset,
    input logic signed [34:0] s2_Out[143:0],
    output logic [1:0] max_result_index,
    output logic max_index_changed_pulse
    );

    logic signed [34:0] Weights1 [143:0];
    logic signed [34:0] Weights2 [143:0];
    logic signed [34:0] Weights3 [143:0];
    logic signed [34:0] Weights4 [143:0];

    logic signed [70:0] Weights1m [143:0];
    logic signed [70:0] Weights2m [143:0];
    logic signed [70:0] Weights3m [143:0];
    logic signed [70:0] Weights4m [143:0];

    logic signed [70:0] bias [3:0];

    // Registered outputs of adder trees
    logic signed [71:0] Adder_tree_result1_r, Adder_tree_result2_r, Adder_tree_result3_r, Adder_tree_result4_r;

    // Registered outputs of ReLU
    logic signed [16:0] resultado1_r, resultado2_r, resultado3_r, resultado4_r;

    // Intermediate wires (adder tree outputs)
    logic signed [71:0] Adder_tree_result1, Adder_tree_result2, Adder_tree_result3, Adder_tree_result4;

    // Intermediate wires (ReLU outputs)
    logic signed [16:0] resultado1, resultado2, resultado3, resultado4;

    // Initialize biases combinationally
    always_comb begin
        bias[0] = -71'sd115000000000000000000000; // Bias for the first layer
        bias[1] =  71'sd112300000000000000000000; // Bias for the second layer
        bias[2] = -71'sd50000000000000000000000;
        bias[3] =  71'sd52740000000000000000000; // Bias for the third layer
    end  

    // Instantiate ROM for weights
    NeuronROM  NeuronROM_inst (
        .Weights1(Weights1),
        .Weights2(Weights2),
        .Weights3(Weights3),
        .Weights4(Weights4)
    );

    genvar p;
    generate
        for (p = 0; p < 144; p++) begin : col1
            mult #(.IWIDTH(35), .OWIDTH(72)) mult_inst (
                .A(Weights1[p]),
                .B(s2_Out[p]),
                .Out(Weights1m[p])
            );
        end
        for (p = 0; p < 144; p++) begin : col2
            mult #(.IWIDTH(35), .OWIDTH(72)) mult_inst (
                .A(Weights2[p]),
                .B(s2_Out[p]),
                .Out(Weights2m[p])
            );
        end
        for (p = 0; p < 144; p++) begin : col3
            mult #(.IWIDTH(35), .OWIDTH(72)) mult_inst (
                .A(Weights3[p]),
                .B(s2_Out[p]),
                .Out(Weights3m[p])
            );
        end
        for (p = 0; p < 144; p++) begin : col4
            mult #(.IWIDTH(35), .OWIDTH(72)) mult_inst (
                .A(Weights4[p]),
                .B(s2_Out[p]),
                .Out(Weights4m[p])
            );
        end
    endgenerate

    // Adder trees
    adder_tree #(.NINPUTS(144), .IWIDTH(71), .OWIDTH(73)) adder_inst1 (
        .d(Weights1m),
        .q(Adder_tree_result1)
    );

    adder_tree #(.NINPUTS(144), .IWIDTH(71), .OWIDTH(73)) adder_inst2 (
        .d(Weights2m),
        .q(Adder_tree_result2)
    );

    adder_tree #(.NINPUTS(144), .IWIDTH(71), .OWIDTH(73)) adder_inst3 (
        .d(Weights3m),
        .q(Adder_tree_result3)
    );

    adder_tree #(.NINPUTS(144), .IWIDTH(71), .OWIDTH(73)) adder_inst4 (
        .d(Weights4m),
        .q(Adder_tree_result4)
    );

    // Register adder tree outputs and subtract bias synchronously
    always_ff @(posedge clk ) begin
        if (reset) begin
            Adder_tree_result1_r <= 0;
            Adder_tree_result2_r <= 0;
            Adder_tree_result3_r <= 0;
            Adder_tree_result4_r <= 0;
        end else begin
            Adder_tree_result1_r <= Adder_tree_result1 - bias[0];
            Adder_tree_result2_r <= Adder_tree_result2 - bias[1];
            Adder_tree_result3_r <= Adder_tree_result3 - bias[2];
            Adder_tree_result4_r <= Adder_tree_result4 - bias[3];
        end
    end

    // ReLU instances
    ReLu #(.WIDTH(73)) Relu_inst1 (.in(Adder_tree_result1_r), .Out(resultado1));
    ReLu #(.WIDTH(73)) Relu_inst2 (.in(Adder_tree_result2_r), .Out(resultado2));
    ReLu #(.WIDTH(73)) Relu_inst3 (.in(Adder_tree_result3_r), .Out(resultado3));
    ReLu #(.WIDTH(73)) Relu_inst4 (.in(Adder_tree_result4_r), .Out(resultado4));

    // Register ReLU outputs
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            resultado1_r <= 0;
            resultado2_r <= 0;
            resultado3_r <= 0;
            resultado4_r <= 0;
        end else begin
            resultado1_r <= resultado1;
            resultado2_r <= resultado2;
            resultado3_r <= resultado3;
            resultado4_r <= resultado4;
        end
    end

    always_comb begin
    max_result_index = 2'd0;
    if (resultado2_r > resultado1_r)
        max_result_index = 2'd1;
    if (resultado3_r > resultado2_r && resultado3_r > resultado1_r)
        max_result_index = 2'd2;
    if (resultado4_r > resultado3_r && resultado4_r > resultado2_r && resultado4_r > resultado1_r)
        max_result_index = 2'd3;
end

logic [1:0] prev_max_result_index ;
always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
        prev_max_result_index <= 2'd0;
        max_index_changed_pulse <= 1'b0;
    end else begin
        max_index_changed_pulse <= (max_result_index != prev_max_result_index);
        prev_max_result_index <= max_result_index;
    end
end

endmodule
