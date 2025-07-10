


module s2_tensor_procesing(
    input logic clk,
    input logic reset,
    input logic[1:0] proc_dir, // Filtro a usar
    input logic[5:0] proc_counter, // {Fila,Columna}
    input logic signed [16:0] Filter[2:0][2:0][2:0], 
    input logic signed [16:0] input_tensor[2:0][7:0][7:0],
    output logic signed [34:0] output_res[143:0]
);
//1. Obtener matriz 3x3
//2. multiplicar según filtro
//3. adder tree
//4. añadir bias
//5. ReLu
//6. Salida
logic signed [16:0] matrix[2:0][2:0][2:0];
logic[1:0]  row_dir,col_dir,cha_dir;
logic signed [33:0] mult_res[26:0]; // matrix 3x3 por 3 canales, all se sumam en adder tree
logic signed [34:0] adder_res;
logic signed [34:0] Bias_res,Bias;
logic[7:0] out_addr;
assign row_dir = proc_counter[3:2];
assign col_dir = proc_counter[1:0];
assign cha_dir = proc_dir;

genvar i,j,k;
generate
    for(k=0;k<3;k++) // canal
        for(i=0;i<3;i++) //fila
            for(j=0;j<3;j++) //columna
            always_comb begin
                matrix[k][j][i] = input_tensor[k][col_dir+j][row_dir+i];
            end
endgenerate

generate//para modificar que es cada cosa, canal vale = 9, fila = 3, col = 1
    for(k=0;k<3;k++) //canal 
        for(i=0;i<3;i++) //fila
            for(j=0;j<3;j++) //ficol
                mult#
                (.IWIDTH(17),.OWIDTH(34))
                mult_s2_instance 
                (
                    .A(Filter[k][j][i]),
                    .B(matrix[k][j][i]),
                    .Out(mult_res[k*9+3*i+j])
                );
endgenerate
//quick fix for adder tree; issue: does not work well with impares


always_comb begin
        case(proc_dir)
        2'b00: out_addr = 0+ proc_counter;
        2'b01: out_addr = 36+proc_counter;
        2'b10: out_addr = 72+proc_counter;
        2'b11: out_addr = 108+proc_counter;
    endcase
end
adder_tree#
(.NINPUTS(27),.IWIDTH(34),.OWIDTH(35))
adder_tree_s2(
    .d(mult_res),
    .q(adder_res)
);
add_Bias bias_inst
(
    .Bias_sel(proc_dir),
    .adder_res(adder_res),
    .Bias_res(Bias_res)
);

logic signed [34:0] relu_out; // intermediate signal
ReLu#
(
    .WIDTH(35)
)
Relu_s2
(
    .in(Bias_res),
    .Out(relu_out)
);


always_ff@(posedge clk) begin
    if(reset)
        foreach(output_res[i])
            output_res[i]   <= 0;
    else    
        output_res[out_addr]<= relu_out;
end
endmodule