module etapa2(
    input logic clk, reset,
    //Aawinput logic data_done,
    input logic[16:0] BRAM_input,

    //Lógica de control
    output logic busy,

    //lógica de lectura de datos
    //(192 datos, 7:6 = equivale resultado del filtro)
    output logic enable_read,
    output logic[7:0] read_addr,

    //Salida final del sistema?(se implementa Fc care palo aca nomas?)
    output logic signed [35:0] s2_Out[143:0]
);
    localparam Filter_WIDTH = 17;
            //-----------Control-----------\\
    logic[2:0] row_addr;
    logic[2:0] col_addr;
    logic[1:0] cha_addr;
    logic data_ready;
    logic[1:0] proc_dir;
    logic[5:0] proc_counter;
    
    
    
    Control_s2 data_builder_Control 
    (
        .clk(clk),
        .reset(reset),
        .data_done(data_done),

        .busy(busy),
        .enable_a(enable_read),
        .data_rdy(data_ready),
        .dir_A(read_addr),
        .row_addr(row_addr),
        .col_addr(col_addr),
        .cha_addr(cha_addr)
    );

    Control_FSM_s2  processing_Control
    (
        .clk(clk),
        .reset(rst),
        .data_rdy(data_ready),

        .data_done(data_done),
        .dir(proc_dir),
        .dir_counter(proc_counter)
    );



            //-----------Filtros-----------\\
    logic signed [Filter_WIDTH-1:0] Filtro1[2:0][2:0][2:0];
    logic signed [Filter_WIDTH-1:0] Filtro2[2:0][2:0][2:0];
    logic signed [Filter_WIDTH-1:0] Filtro3[2:0][2:0][2:0];
    logic signed [Filter_WIDTH-1:0] Filtro4[2:0][2:0][2:0];
    logic signed [Filter_WIDTH-1:0] Filtro_mux[2:0][2:0][2:0];

    
    Filtros_s2_ROM #(.WIDTH(Filter_WIDTH))
    Filtros_s2_rom_inst(
        .Filtro1(Filtro1),
        .Filtro2(Filtro2),
        .Filtro3(Filtro3),
        .Filtro4(Filtro4)
    );
    //Multiplexa cual filtro a usar y cual canal se utilizará
    // señales deben venir de una FSM que se encargue del recorrido de la BRAM
    chanel_mux #(.WIDTH(Filter_WIDTH))
    channel_mux_inst(
        .Filtro1(Filtro1),
        .Filtro2(Filtro2),
        .Filtro3(Filtro3),
        .Filtro4(Filtro4),
        .filter_used(filter_used),
        .Out(Filtro_mux)
    );
            //-----------Procesamiento-----------\\
    logic signed[16:0] input_tensor[7:0][7:0][2:0];
    assign out_addr = {proc_dir,proc_counter};
    tensor_builder#(.WIDTH(17))
    tensor  
    (   
        .clk(clk),                                                  
        .rst(reset),
        .row_addr(row_addr),
        .col_addr(col_addr),
        .cha_addr(cha_addr),
        .data_in({1'b0,BRAM_input}),
        .tensor(input_tensor)
    );
    s2_tensor_procesing s2tensonr_inst
    (
        .proc_dir(proc_dir),
        .proc_counter(proc_counter),
        .Filter(Filtro_mux),
        .input_tensor(input_tensor),
        .output_res(s2_Out)
    );
endmodule