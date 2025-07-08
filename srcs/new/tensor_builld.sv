module tensor_builder#
(
    parameter WIDTH = 17
)
    (
    input logic clk,
    input logic rst,

    input logic[2:0] row_addr,
    input logic[2:0] col_addr,
    input logic[WIDTH-1:0] data_in,

    output logic[WIDTH-1:0] tensor[2:0][2:0]
    );
    always_ff@(posedge clk) 
        if(rst)
            foreach(tensor[i,j])
                tensor[i][j]    <= '0;
        else    
            tensor[row_addr][col_addr]  <= data_in;  
endmodule