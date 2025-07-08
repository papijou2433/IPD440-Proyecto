module s2_tensor_procesing(
    input logic[1:0] proc_dir,
    input logic[3:0] proc_counter,
    input logic[16:0] Filter[2:0][2:0][2:0],
    input logic[16:0] input_tensor[7:0][7:0][2:0]
);
//1. Obtener matriz 3x3
//2. multiplicar según filtro
//3. adder tree
//4. añadir bias
//5. ReLu
//6. Salida
logic[16:0] matrix[2:0][2:0][2:0];
logic[1:0]  row_dir,col_dir,cha_dir;
logic[16:0] mult_res[26:0]; // matrix 3x3 por 3 canales, all se sumam en adder tree
assign row_dir = proc_counter[3:2];
assign col_dir = proc_counter[1:0];
assign cha_dir = proc_dir;
genvar i,j,k;
generate
    for(k=0;k<3;k++) // canal
        for(i=0;i<3;i++) //fila
            for(j=0;j<3;j++) //columna
            always_comb begin: Matrix_filler
                matrix[i][j] = input_tensor[row_dir+i][col_dir+j][cha_dir+k];
            end
endgenerate

generate
    for(k=0;k<3;k++)
        for(i=0;i<3;i++)
            for(j=0;j<3;j++)
            always_comb begin: Matrixes_mult
                mult#
                (.IWIDTH(17),.OWIDTH(34))
                mult_s2_inst(
                    .A(Filter[i][j]),
                    .B(matrix[i][j]),
                    .Out(mult_res[k*9+3*i+j])
                );
            end

endgenerate

endmodule