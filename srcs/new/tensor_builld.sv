module tensor_builder#
(
    parameter WIDTH = 17
)
    (
    input logic clk,
    input logic rst,

    input logic[2:0] row_addr,  //8 filas
    input logic[2:0] col_addr,  //8 columnas
    input logic[1:0] cha_addr,  //3 canales
    input logic[WIDTH-1:0] data_in,

    output logic signed [WIDTH-1:0] tensor[2:0][7:0][7:0] //3 canales, 8 filas, 8 columnas
    );
    always_ff@(posedge clk) 
        if(rst)
            foreach(tensor[i,j,k])
                tensor[i][j][k]    <= '0;
        else    
            tensor[cha_addr][col_addr][row_addr]  <= data_in;  
endmodule