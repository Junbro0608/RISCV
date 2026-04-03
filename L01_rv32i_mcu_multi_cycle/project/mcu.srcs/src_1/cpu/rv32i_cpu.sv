`timescale 1ns / 1ps
`include "rv32i_opcode.svh"

module rv32i_cpu (
    input               clk,
    input               rst,
    //instr
    input        [31:0] instr_data,
    output logic [31:0] instr_addr,
    //APB_bus
    input               ready,
    input        [31:0] bus_rdata,
    output logic        bus_wreq,
    output logic        bus_rreq,
    output logic [31:0] bus_addr,
    output logic [31:0] bus_wdata,
    output logic [ 2:0] o_funct3
);
    logic rf_we, alu_src_sel, b_src_sel, branch, pc_en;
    logic [2:0] rf_wd_sel;
    alu_control_t alu_control;


    control_unit U_CTRL_UNIT (
        .*,
        //instr
        .funct7(instr_data[31:25]),
        .funct3(instr_data[14:12]),
        .opcode(opcode_t'(instr_data[6:0])),
        .dwe   (bus_wreq),
        .dre   (bus_rreq)
    );

    data_path #(
        .ADDR(32),
        .BIT_WIDTH(32)
    ) U_DATA_PATH (
        .*
    );

endmodule

