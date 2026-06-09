`timescale 1ns / 1ps
`include "rv32i_opcode.svh"

module rv32i_cpu (
    input               clk,
    input               rst,
    //instr
    input        [31:0] instr_data,
    output logic [31:0] instr_addr,
    //data_mem
    input  logic [31:0] drdata,
    output logic        dwe,
    output logic [31:0] daddr,
    output logic [31:0] dwdata,
    output logic [ 2:0] o_funct3
);
    logic rf_we, alu_src_sel, b_src_sel, branch;
    logic [2:0] rf_wd_sel;
    alu_control_t alu_control;


    control_unit U_CTRL_UNIT (
        //instr
        .funct7     (instr_data[31:25]),
        .funct3     (instr_data[14:12]),
        .opcode     (opcode_t'(instr_data[6:0])),
        //datapath
        .rf_we      (rf_we),
        .alu_src_sel(alu_src_sel),
        .rf_wd_sel  (rf_wd_sel),
        .alu_control(alu_control),
        .b_src_sel  (b_src_sel),
        .branch     (branch),
        //data_mem
        .o_funct3   (o_funct3),
        .dwe        (dwe)
    );

    data_path #(
        .ADDR(32),
        .BIT_WIDTH(32)
    ) U_DATA_PATH (
        .*
    );

endmodule

