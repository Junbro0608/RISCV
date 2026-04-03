`timescale 1ns / 1ps
`include "../../src_1/cpu/rv32i_opcode.svh"

`define HEX_CODE 1
`define R 0
`define I 0
`define S 0
`define IL 0
`define B 0
`define U 0
`define J 0


module tb_rv32i_smoll_type ();
    //input
    logic clk, rst;
    logic [7:0] gpi, gpo;
    logic [15:0] gpio;
    logic [7:0] uart_rx, uart_tx;
    //sim
    logic [4:0] rs1, rs2, shift_addr, rd, shamt;
    logic [31:0] rd1, rd2, shift;
    logic [31:0] imm;
    logic done, all_tests_passed = 0;
    logic [31:0]
        cycle = 0, timeout_cycle = 31, current_result = 0, current_output = 0;
    logic [255:0] current_test_type = 0;

    logic [ 31:0] sim_tast;




    integer i, j;

    rv32I_mcu U_DUT (
        .clk(clk),
        .rst(rst),
        .gpi(gpi),
        .gpo(gpo),
        .gpio(),
        .fnd_data(),
        .fnd_digit(),
        .uart_rx(uart_rx),
        .uart_tx(uart_tx)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    task reset(input reg_option);
        rst = 1;

        //REG
        if (reg_option) begin
            for (i = 1; i < 32; i = i + 1) begin
                `REG_FILE.reg_file[i] = i;
            end
        end else begin
            for (i = 1; i < 32; i = i + 1) begin
                `REG_FILE.reg_file[i] = 32'bx;
            end
        end

        //DMEM
        for (i = 0; i < 32; i = i + 1) begin
            `DMEM.dmem[i] = 32'bx;
        end

        //INSTR_MEM
        for (i = 0; i < 32; i = i + 1) begin
            `INSTR_MEM.rom[i] = 32'bx;
        end
    endtask

    task run(input [31:0] cycle);
        @(negedge clk);
        rst = 0;
        repeat (cycle) @(posedge clk);
    endtask

    initial begin
        reset(0);



        rs1 = 1;
        rs2 = 2;
        shift_addr = 5'd3;
        rd = 5;
        `REG_FILE.reg_file[rs1] = -100;
        `REG_FILE.reg_file[rs2] = 200;
        `REG_FILE.reg_file[shift_addr] = 2;
        `REG_FILE.reg_file[4] = 32'h1000_0000;

        //PC
        //R
        `INSTR_MEM.rom[0] = {`FNC7_SUB, rs2, rs1, `FNC3_ADD_SUB, rd, `R_TYPE};
        `INSTR_MEM.rom[1] = {`FNC7_0,   shift_addr,     rs1,    `FNC3_SLL,  rd, `R_TYPE};
        `INSTR_MEM.rom[2] = {`FNC7_0,   rs2,            rs1,    `FNC3_AND,      rd, `R_TYPE};
        //I
        imm = 200;
        shamt = 2;
        `INSTR_MEM.rom[3] = {imm,               rs1,   `FNC3_ADD_SUB,  rd,   `I_TYPE};
        `INSTR_MEM.rom[4] = {`FNC7_0,   shamt,  rs1,   `FNC3_SLL,  rd,   `I_TYPE};
        `INSTR_MEM.rom[5] = {imm,               rs1,   `FNC3_AND,      rd,   `I_TYPE};
        //J
        imm = 12; rs1 = 3; 
        `INSTR_MEM.rom[6] = {imm[20],imm[10:1],imm[11],imm[19:12],rd,`JAL_TYPE};
        imm = 110; rs1 = 3; 
        `INSTR_MEM.rom[9] = {imm[11:0], rs1,    3'b0,   rd, `JALR_TYPE};
        //B
        imm = 40; rs1 = 1; rs2 = 2;
        `INSTR_MEM.rom[28]  = {imm[12], imm[10:5], rs2, rs1, `FNC3_BLT,  imm[4:1], imm[11], `B_TYPE};
        //U
        imm = 32'b11_0000_0000;
        `INSTR_MEM.rom[38] = {imm,   rd, `LUI_TYPE};
        `INSTR_MEM.rom[39] = {imm,    rd, `AUIPC_TYPE};
        //S
        rs1 = 4; rs2 = 1; imm = 4;
        `INSTR_MEM.rom[40] =  {imm[11:5],    rs2,  rs1,  `FNC3_SW,   imm[4:0], `S_TYPE};
        //IL
        `INSTR_MEM.rom[41]   = {imm,  rs1,    `FNC3_LW,   rd, `IL_TYPE}; 
        run(100);
    end


endmodule
