
module add_Bias(
    input logic[1:0] Bias_sel,
    input logic[34:0] adder_res,
    output logic[34:0] Bias_res
);
logic[33:0] Bias;
always_comb begin
    case(Bias_sel)
        2'b00: Bias = 32'sh2566CF42; // Example bias value for channel 0
        2'b01: Bias = 34'h0AAAAAAAA;
        2'b10: Bias = 34'h0AAAAAAAA;
        2'b11: Bias = 34'h0AAAAAAAA;
        default:Bias= 34'h000000000;
    endcase
    Bias_res = Bias + adder_res;
end
endmodule