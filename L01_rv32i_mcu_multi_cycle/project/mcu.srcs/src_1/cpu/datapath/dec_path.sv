`timescale 1ns / 1ps
`include "../rv32i_opcode.svh"

module dec_path (
    input               i_clk,
    input               i_rst,
    //ctrl_unit
    input               i_cu_rf_we,
    //IF
    input        [31:0] i_if_instr_data,
    //ID
    output logic [31:0] o_dec_rs1,
    output logic [31:0] o_dec_rs2,
    output logic [31:0] o_dec_imm,
    //WB
    input        [31:0] i_wb_mux_data
);
    //register_file
    logic [31:0] rd1, rd2;
    //imm_extender
    logic [31:0] imm_data;

    always_ff @(posedge i_clk or posedge i_rst) begin : dec_path_ff
        if (i_rst) begin
            o_dec_rs1 <= 0;
            o_dec_rs2 <= 0;
            o_dec_imm <= 0;
        end else begin
            o_dec_rs1 <= rd1;
            o_dec_rs2 <= rd2;
            o_dec_imm <= imm_data;
        end
    end


    register_file U_REG_FILE (
        .clk  (i_clk),
        .rst  (i_rst),
        .rf_we(i_cu_rf_we),
        //write
        .wa   (i_if_instr_data[11:7]),
        .wd   (i_wb_mux_data),
        //read
        .ra1  (i_if_instr_data[19:15]),
        .ra2  (i_if_instr_data[24:20]),
        .rd1  (rd1),
        .rd2  (rd2)
    );

    imm_extender U_IMM_EX (
        .instr_data(i_if_instr_data),
        .imm_data  (imm_data)
    );

endmodule

module register_file #(
    parameter ADDR = 32,
    BIT_WIDTH = 32
) (
    input                     clk,
    input                     rst,
    input                     rf_we,
    //write
    input  [$clog2(ADDR)-1:0] wa,
    input  [ BIT_WIDTH - 1:0] wd,
    //read
    input  [$clog2(ADDR)-1:0] ra1,
    input  [$clog2(ADDR)-1:0] ra2,
    output [ BIT_WIDTH - 1:0] rd1,
    output [ BIT_WIDTH - 1:0] rd2
);

    logic [BIT_WIDTH - 1:0] reg_file[0:ADDR-1];

    assign rd1 = reg_file[ra1];
    assign rd2 = reg_file[ra2];

    initial begin
        reg_file[0] = 0;
    end


    always_ff @(posedge clk) begin : reg_file_ff
        if (!rst && (rf_we) && (wa != 0)) begin  //reg_file[0] = Zero
            reg_file[wa] = wd;
        end
    end
endmodule

module imm_extender (
    input        [31:0] instr_data,
    output logic [31:0] imm_data
);
    always_comb begin : imm_comb
        imm_data = 32'b0;
        case (opcode_t'(instr_data[6:0]))
            // I-Type: imm[11:0]
            IL_type, I_type, JALR_type: begin
                imm_data = {{20{instr_data[31]}}, instr_data[31:20]};
            end

            // S-Type: imm[11:5] | imm[4:0]
            S_type: begin
                imm_data = {{20{instr_data[31]}}, instr_data[31:25], instr_data[11:7]};
            end

            // B-Type: imm[12] | imm[11] | imm[10:5] | imm[4:1] | 0
            B_type: begin
                imm_data = {{20{instr_data[31]}}, instr_data[7], instr_data[30:25], instr_data[11:8], 1'b0};
            end

            // U-Type: imm[31:12] | 0
            LUI_type, AUIPC_type: begin
                imm_data = {instr_data[31:12], 12'b0};
            end

            // J-Type: imm[20] | imm[19:12] | imm[11] | imm[10:1] | 0
            JAL_type: begin
                imm_data = {{12{instr_data[31]}}, instr_data[19:12], instr_data[20], instr_data[30:21], 1'b0};
            end
            default: imm_data = 32'b0;
        endcase
    end
endmodule

module mux_2x1 (
    input        [31:0] in0,
    input        [31:0] in1,
    input               mux_sel,
    output logic [31:0] mux_out
);
    assign mux_out = (mux_sel) ? in1 : in0;

endmodule
