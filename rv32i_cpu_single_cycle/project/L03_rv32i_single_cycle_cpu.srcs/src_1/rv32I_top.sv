`timescale 1ns / 1ps

module rv32I_top (
    input clk,
    input rst
);
    logic [31:0] instr_addr, instr_data;
    logic dwe;
    logic [31:0] daddr, dwdata, drdata;
    logic [2:0] o_funct3;

    instruction_mem U_INSTR_MEM (
        .instr_addr(instr_addr[31:2]),
        .instr_data(instr_data)
    );

    rv32i_cpu U_CPU (.*);

    data_mem U_DATA_MEM (
        .*,
        .i_funct3(o_funct3)
    );


endmodule
