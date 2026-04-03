`timescale 1ns / 1ps
`include "../rv32i_opcode.svh"

module ex_path (
    input                       i_clk,
    input                       i_rst,
    //ctrl_unit
    input  alu_control_t        i_cu_alu_control,
    input                       i_cu_alu_src_sel,
    //ID
    input                [31:0] i_id_rs1,
    input                [31:0] i_id_rs2,
    input                [31:0] i_id_imm_data,
    //MEM
    output logic         [31:0] o_ex_alu_result,
    //WB
    output logic         [31:0] alu_result,
    output logic         [31:0] o_ex_pc_plus_imm,
    //IF
    input  logic         [31:0] i_if_pc,
    output logic                o_if_b_taken,
    output logic         [31:0] o_ex_pc_plus_4,
    output logic         [31:0] pc_plus_imm
);

    //alu
    logic [31:0] alu_src2_mux_out;
    assign pc_plus_imm = i_if_pc + i_id_imm_data;

    always_ff @(posedge i_clk or posedge i_rst) begin : ex_path_ff
        if (i_rst) begin
            o_ex_alu_result  <= 0;
            o_ex_pc_plus_4   <= 0;
            o_ex_pc_plus_imm <= 0;
        end else begin
            o_ex_alu_result  <= alu_result;
            o_ex_pc_plus_4   <= i_if_pc + 4;
            o_ex_pc_plus_imm <= pc_plus_imm;
        end
    end

    mux_2x1 U_ALU_SRC2_MUX (
        .in0    (i_id_rs2),
        .in1    (i_id_imm_data),
        .mux_sel(i_cu_alu_src_sel),
        .mux_out(alu_src2_mux_out)
    );


    alu U_ALU (
        .a          (i_id_rs1),
        .b          (alu_src2_mux_out),
        .alu_control(i_cu_alu_control),
        .alu_result (alu_result),
        .b_taken    (o_if_b_taken)
    );


endmodule


module alu (
    input                [31:0] a,
    input                [31:0] b,
    input  alu_control_t        alu_control,
    output logic         [31:0] alu_result,
    output logic                b_taken
);

    always_comb begin : alu_comb
        alu_result = 0;
        b_taken = 0;
        case (alu_control)
            //common ALU 
            ADD:  alu_result = a + b;
            SUB:  alu_result = a - b;
            SLL:  alu_result = a << b[4:0];
            SLT:  alu_result = ($signed(a) < $signed(b)) ? 32'b1 : 32'b0;
            SLTU: alu_result = (a < b) ? 32'b1 : 32'b0;
            XOR:  alu_result = a ^ b;
            SRL:  alu_result = a >> b[4:0];
            SRA:  alu_result = $signed(a) >>> b[4:0];
            OR:   alu_result = a | b;
            AND:  alu_result = a & b;
            //branch
            BEQ:  b_taken = ($signed(a) == $signed(b)) ? 1'b1 : 1'b0;
            BNE:  b_taken = ($signed(a) != $signed(b)) ? 1'b1 : 1'b0;
            BLT:  b_taken = ($signed(a) < $signed(b)) ? 1'b1 : 1'b0;
            BGE:  b_taken = ($signed(a) >= $signed(b)) ? 1'b1 : 1'b0;
            BLTU: b_taken = (a < b) ? 1'b1 : 1'b0;
            BGEU: b_taken = (a >= b) ? 1'b1 : 1'b0;
            //LUI
            JUMP: begin
                alu_result = a + b;
                b_taken = 1;
            end
        endcase
    end

endmodule

