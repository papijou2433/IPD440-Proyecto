module ReLu#
    (parameter  WIDTH=20,
    )(
        input logic signed[WIDTH-1:0] in,
        output logic signed[WIDT-1:0 ] Out
    );
    if(in[WIDTH-1])
        Out = 'd0;
    else    
        Out = in

endmodule