
module add_Bias(
    input logic[1:0] Bias_sel,
    input logic[34:0] adder_res,
    output logic[34:0] Bias_res
);
logic[34:0] Bias;
always_comb begin
    case(Bias_sel)
        2'b00: Bias = 35'h959B3D08; // Example bias value for channel 0
        2'b01: Bias = 35'h3FFFFFFBE ;
        2'b10: Bias = 35'hEE00D1B7 ;
        2'b11: Bias = 35'h1A305532 ;
        default:Bias= 35'h3353F7CF ;
    endcase
    Bias_res = Bias + adder_res;
end
endmodule