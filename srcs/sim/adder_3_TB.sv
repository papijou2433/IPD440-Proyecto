`timescale 1ns/1ps

module tb_adder_tree;

    // Parámetros del DUT
    localparam int NINPUTS = 27;
    localparam int IWIDTH  = 8;
    localparam int OWIDTH  = 18;

    // Señales del DUT
    logic signed [IWIDTH-1:0] d[NINPUTS];
    logic signed [OWIDTH-1:0] q;

    // DUT
    adder_tree #(
        .NINPUTS(NINPUTS),
        .IWIDTH(IWIDTH),
        .OWIDTH(OWIDTH)
    ) dut (
        .d(d),
        .q(q)
    );

    // Variables para comparación
    integer i;
    integer num_tests = 10;
    logic signed [OWIDTH-1:0] expected_sum;

    initial begin
        foreach(d[i])
            d[i] = 8'd1;
        #100
        foreach(d[i])
            d[i] = 8'h2;
    end

endmodule
