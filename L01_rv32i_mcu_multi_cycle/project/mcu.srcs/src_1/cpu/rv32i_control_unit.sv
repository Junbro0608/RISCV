`timescale 1ns / 1ps
`include "rv32i_opcode.svh"

module control_unit (
    input                      clk,
    input                      rst,
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
    output logic               pc_en,        //for muti cycle fecth
    //APB_BUS
    input                      ready,
    output logic         [2:0] o_funct3,
    output logic               dwe,
    output logic               dre
);
    typedef enum logic [2:0] {
        FETCH,
        DECODE,
        EXECUTE,
        MEM,
        WB
    } state_t;

    state_t c_state, n_state;

    always_ff @(posedge clk or posedge rst) begin : ctrl_unit_ff
        if (rst) begin
            c_state <= FETCH;
        end else begin
            c_state <= n_state;
        end
    end

    always_comb begin : ctrl_unit_comb
        n_state = c_state;
        case (c_state)
            FETCH: begin
                n_state = DECODE;
            end
            DECODE: begin
                n_state = EXECUTE;
            end
            EXECUTE: begin
                case (opcode)
                    R_type, I_type, LUI_type, AUIPC_type, JAL_type, JALR_type, B_type:
                    n_state = FETCH;
                    S_type, IL_type: n_state = MEM;
                endcase
            end
            MEM: begin
                case (opcode)
                    S_type: begin
                        if (ready) begin
                            n_state = FETCH;
                        end
                    end
                    IL_type: n_state = WB;
                endcase
            end
            WB: begin
                if (ready) begin
                    n_state = FETCH;
                end
            end
        endcase
    end

    always_comb begin : ouput_comb
        rf_we       = 0;
        alu_src_sel = 0;
        rf_wd_sel   = 0;
        alu_control = ADD;
        pc_en       = 0;
        //pc
        b_src_sel   = 0;
        branch      = 0;
        //APB_bus
        o_funct3    = 3'b000;
        dwe         = 0;
        dre         = 0;
        case (c_state)
            FETCH: begin
                pc_en = 1;
            end
            DECODE: begin
            end
            EXECUTE: begin
                case (opcode)
                    R_type: begin
                        //datapath
                        rf_we = 1;
                        rf_wd_sel = 0;
                        alu_src_sel = 0;
                        rf_wd_sel = 0;
                        alu_control = alu_control_t'({1'b0, funct7[5], funct3});
                    end
                    I_type: begin
                        //datapath
                        rf_we       = 1;
                        rf_wd_sel   = 0;
                        alu_src_sel = 1;
                        if (funct3 == `FNC3_SRL_SRA)
                            alu_control = alu_control_t'({
                                1'b0, funct7[5], funct3
                            });
                        else alu_control = alu_control_t'({1'b0, 1'b0, funct3});
                    end
                    B_type: begin
                        //datapath
                        alu_src_sel = 0;
                        alu_control = alu_control_t'({1'b1, 1'b0, funct3});
                        //pc
                        b_src_sel   = 0;
                        branch      = 1;
                    end
                    S_type: begin
                        //datapath
                        alu_src_sel = 1;
                        alu_control = ADD;
                    end
                    IL_type: begin
                        //datapath
                        alu_src_sel = 1;
                        alu_control = ADD;
                    end
                    LUI_type: begin
                        rf_we     = 1;
                        rf_wd_sel = 2;
                    end
                    AUIPC_type: begin
                        rf_we     = 1;
                        rf_wd_sel = 3;
                    end
                    JAL_type: begin
                        //datapath
                        rf_we       = 1;
                        rf_wd_sel   = 4;
                        alu_src_sel = 0;
                        alu_control = JUMP;
                        //pc
                        b_src_sel   = 0;
                        branch      = 1;
                    end
                    JALR_type: begin
                        //datapath
                        rf_we       = 1;
                        rf_wd_sel   = 4;
                        alu_src_sel = 1;
                        alu_control = JUMP;
                        //pc
                        b_src_sel   = 1;
                        branch      = 1;
                    end
                endcase
            end
            MEM: begin
                o_funct3 = funct3;
                if (opcode == S_type) dwe = 1;
                if (opcode == IL_type) dre = 1;
            end
            WB: begin
                rf_we = 1;
                rf_wd_sel = 1;
            end
        endcase
    end

endmodule
