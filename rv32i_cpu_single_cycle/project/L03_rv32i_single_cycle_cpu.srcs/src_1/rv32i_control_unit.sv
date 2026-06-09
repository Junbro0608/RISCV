`timescale 1ns / 1ps
`include "rv32i_opcode.svh"

module control_unit (
    //instr
    input                [6:0] funct7,
    input                [2:0] funct3,
    input  opcode_t            opcode,
    //datapath
    output logic               rf_we,
    output logic               alu_src_sel,
    output logic         [2:0] rf_wd_sel,
    output alu_control_t       alu_control,
    output logic               b_src_sel,
    output logic               branch,
    //data_mem
    output logic         [2:0] o_funct3,
    output logic               dwe
);

    always_comb begin : ctrl_unit_comb
        //datapath
        rf_we       = 0;
        alu_src_sel = 0;
        rf_wd_sel   = 0;
        alu_control = ADD;
        //pc
        b_src_sel   = 0;
        branch      = 0;
        //data_mem
        o_funct3    = 3'b000;
        dwe         = 0;
        case (opcode)
            R_type: begin
                //datapath
                rf_we       = 1;
                alu_src_sel = 0;
                rf_wd_sel   = 0;
                alu_control = alu_control_t'({1'b0, funct7[5], funct3});
                b_src_sel   = 0;
                branch      = 0;
                //data_mem
                o_funct3    = 3'b000;
                dwe         = 0;
            end
            I_type: begin
                //datapath
                rf_we       = 1;
                alu_src_sel = 1;
                rf_wd_sel   = 0;
                if (funct3 == `FNC3_SRL_SRA)
                    alu_control = alu_control_t'({1'b0, funct7[5], funct3});
                else alu_control = alu_control_t'({1'b0, 1'b0, funct3});
                //pc
                b_src_sel   = 0;
                branch      = 0;
                //data_mem
                o_funct3 = 3'b000;
                dwe      = 0;
            end
            S_type: begin
                //datapath
                rf_we       = 0;
                alu_src_sel = 1;
                rf_wd_sel   = 0;
                alu_control = ADD;
                //pc
                b_src_sel   = 0;
                branch      = 0;
                //data_mem
                o_funct3    = funct3;
                dwe         = 1;
            end
            IL_type: begin
                //datapath
                rf_we       = 1;
                alu_src_sel = 1;
                rf_wd_sel   = 1;
                alu_control = ADD;
                //pc
                b_src_sel   = 0;
                branch      = 0;
                //data_mem
                o_funct3    = funct3;
                dwe         = 0;
            end
            B_type: begin
                //datapath
                rf_we       = 0;
                alu_src_sel = 0;
                rf_wd_sel   = 0;
                alu_control = alu_control_t'({1'b1, 1'b0, funct3});
                //pc
                b_src_sel   = 0;
                branch      = 1;
                //data_mem
                o_funct3    = 3'b000;
                dwe         = 0;
            end
            LUI_type: begin
                //datapath
                rf_we       = 1;
                alu_src_sel = 0;
                rf_wd_sel   = 2;
                alu_control = ADD;
                //pc
                b_src_sel   = 0;
                branch      = 0;
                //data_mem
                o_funct3    = 3'b000;
                dwe         = 0;
            end
            AUIPC_type: begin
                //datapath
                rf_we       = 1;
                alu_src_sel = 0;
                rf_wd_sel   = 3;
                alu_control = ADD;
                //pc
                b_src_sel   = 0;
                branch      = 0;
                //data_mem
                o_funct3    = 3'b000;
                dwe         = 0;
            end
            JAL_type: begin
                //datapath
                rf_we       = 1;
                alu_src_sel = 0;
                rf_wd_sel   = 4;
                alu_control = JUMP;
                //pc
                b_src_sel   = 0;
                branch      = 1;
                //data_mem
                o_funct3    = 3'b000;
                dwe         = 0;
            end
            JALR_type: begin
                //datapath
                rf_we       = 1;
                alu_src_sel = 1;
                rf_wd_sel   = 4;
                alu_control = JUMP;
                //pc
                b_src_sel   = 1;
                branch      = 1;
                //data_mem
                o_funct3    = 3'b000;
                dwe         = 0;
            end
        endcase
    end
endmodule
