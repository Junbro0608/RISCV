`timescale 1ns / 1ps
`include "rv32i_opcode.svh"

module data_path #(
    parameter ADDR = 32,
    BIT_WIDTH = 32
) (
    input                                  clk,
    input                                  rst,
    //control
    input                                  rf_we,
    input                                  alu_src_sel,
    input                [            2:0] rf_wd_sel,
    input  alu_control_t                   alu_control,
    input                                  b_src_sel,
    input                                  branch,
    input                                  pc_en,
    //instr
    input                [           31:0] instr_data,
    output logic         [           31:0] instr_addr,
    //APB_BUS
    input  logic         [BIT_WIDTH - 1:0] bus_rdata,
    output logic         [BIT_WIDTH - 1:0] bus_addr,
    output logic         [BIT_WIDTH - 1:0] bus_wdata
);
    logic [31:0] o_dec_rs1, o_dec_rs2, o_dec_imm;
    logic o_if_b_taken;
    logic [31:0]
        o_ex_alu_result,
        alu_result,
        o_ex_pc_plus_4,
        o_ex_pc_plus_imm,
        pc_plus_imm;
    logic [31:0] o_mem_rdata;
    logic [31:0] o_wb_mux_out;
    logic [31:0] o_pc_delay;

    assign bus_addr  = o_ex_alu_result;
    assign bus_wdata = o_dec_rs2;


    dec_path U_DEC_PATH (
        .i_clk          (clk),
        .i_rst          (rst),
        //ctrl_unit
        .i_cu_rf_we     (rf_we),
        //IF
        .i_if_instr_data(instr_data),
        //ID
        .o_dec_rs1      (o_dec_rs1),
        .o_dec_rs2      (o_dec_rs2),
        .o_dec_imm      (o_dec_imm),
        //WB
        .i_wb_mux_data  (o_wb_mux_out)
    );

    ex_path U_EX_PATH (
        .i_clk           (clk),
        .i_rst           (rst),
        //ctrl_unit
        .i_cu_alu_src_sel(alu_src_sel),
        .i_cu_alu_control(alu_control),
        //ID
        .i_id_rs1        (o_dec_rs1),
        .i_id_rs2        (o_dec_rs2),
        .i_id_imm_data   (o_dec_imm),
        //MEM
        .o_ex_alu_result (o_ex_alu_result),
        //WB
        .alu_result      (alu_result),
        .o_ex_pc_plus_imm(o_ex_pc_plus_imm),
        //IF
        .i_if_pc         (o_pc_delay),
        .o_if_b_taken    (o_if_b_taken),
        .o_ex_pc_plus_4  (o_ex_pc_plus_4),
        .pc_plus_imm     (pc_plus_imm)
    );

    mem_path U_MEM_PATH (
        .i_clk       (clk),
        .i_rst       (rst),
        //data_mem
        .i_dmem_rdata(bus_rdata),
        //WB
        .o_mem_rdata (o_mem_rdata)
    );

    wb_path U_WB_PATH (
        //ctrl_unit
        .i_cu_rf_wd_sel  (rf_wd_sel),
        //ID
        .i_id_imm        (o_dec_imm),
        .o_wb_mux_out    (o_wb_mux_out),
        //EX
        .i_ex_alu_result (alu_result),
        .i_ex_pc_plus_imm(o_ex_pc_plus_imm),
        .i_ex_pc_plus_4  (o_ex_pc_plus_4),
        //MEM
        .i_mem_rdata     (o_mem_rdata)
    );

    //PC-----------------------------------------

    pc U_PC (
        .clk         (clk),
        .rst         (rst),
        //control_unit
        .pc_en       (pc_en),
        .b_taken     (o_if_b_taken),
        .branch      (branch),
        .b_src_sel   (b_src_sel),
        //data
        .rs1_plus_imm(alu_result),
        .pc_plus_imm (pc_plus_imm),
        .pc_plus_4   (o_ex_pc_plus_4),
        .o_pc        (instr_addr)
    );

    always_ff @( posedge clk or posedge rst ) begin : blockName
        if(rst)
        o_pc_delay <= 0;
        else
        o_pc_delay <= instr_addr;
    end

endmodule

module pc (
    input               clk,
    input               rst,
    //control_unit
    input               pc_en,
    input               b_taken,
    input               branch,
    input               b_src_sel,
    //data
    input        [31:0] rs1_plus_imm,
    input        [31:0] pc_plus_imm,
    input        [31:0] pc_plus_4,
    output logic [31:0] o_pc
);

    logic [31:0] pc_reg, pc_next;
    logic j_event;

    //branch_event
    assign j_event = b_taken && branch;

    always_ff @(posedge clk or posedge rst) begin : pc_ff
        if (rst) begin
            pc_reg   <= 0;
            o_pc   <= 0;
        end else begin
            pc_reg <= pc_next;
            if (pc_en) o_pc <= pc_reg;
        end
    end


    always_comb begin : pc_comb
        //mux   
        case ({
            j_event, b_src_sel
        })
            2'b00, 2'b01: pc_next = pc_plus_4;
            2'b10:        pc_next = pc_plus_imm;
            2'b11:        pc_next = rs1_plus_imm;
        endcase
    end

endmodule

