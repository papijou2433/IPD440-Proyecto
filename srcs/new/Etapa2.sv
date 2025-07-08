module etapa2(
    input logic clk, reset,
    input logic[16:0] BRAM_input,

    //Lógica de control
    output logic busy,
    output logic data_done,

    //lógica de lectura de datos
    output logic enab
    output logic[7:0] read_addr,

    //Salida final del sistema?(se imple,enta Fc care palo aca nomas?)
    output logic [3:0] Clase_out
)
    localparam Filter_WIDTH = 8

    logic[Filter_WIDTH-1:0] Filtro1[2:0][2:0][2:0];
    logic[Filter_WIDTH-1:0] Filtro2[2:0][2:0][2:0];
    logic[Filter_WIDTH-1:0] Filtro3[2:0][2:0][2:0];
    logic[Filter_WIDTH-1:0] Filtro4[2:0][2:0][2:0];
    logic[Filter_WIDTH-1:0] Filtro_mux[2:0][2:0];

    
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
        .chanel(chanel_used),
        .filter_used(filter_used),
        .Out(Filtro_mux)
    );

endmodule