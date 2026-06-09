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
    //instr
    input                [           31:0] instr_data,
    output logic         [           31:0] instr_addr,
    //data_mem
    input  logic         [BIT_WIDTH - 1:0] drdata,
    output logic         [BIT_WIDTH - 1:0] daddr,
    output logic         [BIT_WIDTH - 1:0] dwdata
);
    logic [BIT_WIDTH-1:0] rf_wd_mux_out;
    logic [BIT_WIDTH-1:0] rd1, rd2;
    logic [BIT_WIDTH-1:0] imm_data;
    logic [BIT_WIDTH-1:0] alu_src2_mux_out;
    logic [BIT_WIDTH-1:0] alu_result;
    logic                 b_taken;

    assign daddr  = alu_result;
    assign dwdata = rd2;

    //REG_FILE-----------------------------------------
    mux_5x1 U_RF_WDATA_MUX (
        .in0    (alu_result),             //ALU
        .in1    (drdata),                 //LOAD
        .in2    (imm_data),               //LUI
        .in3    (instr_addr + imm_data),  //AUIPC
        .in4    (instr_addr + 4),         //JAL
        .mux_sel(rf_wd_sel),
        .mux_out(rf_wd_mux_out)
    );

    register_file #(
        .ADDR     (ADDR),
        .BIT_WIDTH(BIT_WIDTH)
    ) U_REG_FILE (
        .clk  (clk),
        .rst  (rst),
        .rf_we(rf_we),
        //write
        .wa   (instr_data[11:7]),
        .wd   (rf_wd_mux_out),
        //read
        .ra1  (instr_data[19:15]),
        .ra2  (instr_data[24:20]),
        .rd1  (rd1),
        .rd2  (rd2)
    );
    //IMM-----------------------------------------
    imm_extender U_IMM_EX (
        .instr_data(instr_data),
        .imm_data  (imm_data)
    );

    //ALU-----------------------------------------
    mux_2x1 U_ALU_SRC2_MUX (
        .in0    (rd2),
        .in1    (imm_data),
        .mux_sel(alu_src_sel),
        .mux_out(alu_src2_mux_out)
    );

    alu U_ALU (
        .a          (rd1),
        .b          (alu_src2_mux_out),
        .alu_control(alu_control),
        .alu_result (alu_result),
        .b_taken    (b_taken)
    );

    //PC-----------------------------------------
    pc U_PC (
        .clk         (clk),
        .rst         (rst),
        //control_unit
        .b_taken     (b_taken),
        .branch      (branch),
        .b_src_sel   (b_src_sel),
        //data
        .rs1_plus_imm(alu_result),
        .pc_plus_imm (instr_addr + imm_data),
        .pc_plus_4   (instr_addr + 4),
        .o_pc        (instr_addr)
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


module pc (
    input               clk,
    input               rst,
    //control_unit
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
    //output
    assign o_pc    = pc_reg;
    //branch_event
    assign j_event = b_taken && branch;

    always_ff @(posedge clk or posedge rst) begin : pc_ff
        if (rst) begin
            pc_reg <= 0;
        end else begin
            pc_reg <= pc_next;
        end
    end
    //mux
    always_comb begin : pc_comb
        pc_next = pc_reg;
        case ({
            j_event, b_src_sel
        })
            2'b00, 2'b01: pc_next = pc_plus_4;
            2'b10:        pc_next = pc_plus_imm;
            2'b11:        pc_next = rs1_plus_imm;
        endcase
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

module mux_5x1 (
    input        [31:0] in0,
    input        [31:0] in1,
    input        [31:0] in2,
    input        [31:0] in3,
    input        [31:0] in4,
    input        [ 2:0] mux_sel,
    output logic [31:0] mux_out
);

    always_comb begin : mux_4X1
        mux_out = 32'bx;
        case (mux_sel)
            3'd0: mux_out = in0;
            3'd1: mux_out = in1;
            3'd2: mux_out = in2;
            3'd3: mux_out = in3;
            3'd4: mux_out = in4;
            default: mux_out = 32'bx;
        endcase
    end

endmodule
