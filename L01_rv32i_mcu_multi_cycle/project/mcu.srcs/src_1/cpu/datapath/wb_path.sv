`timescale 1ns / 1ps

module wb_path (
    //ctrl_unit
    input [2:0] i_cu_rf_wd_sel,
    //ID
    input [31:0] i_id_imm,
    output [31:0] o_wb_mux_out,
    //EX
    input [31:0] i_ex_alu_result,
    input [31:0] i_ex_pc_plus_imm,
    input [31:0] i_ex_pc_plus_4,
    //MEM
    input [31:0] i_mem_rdata
);

    mux_5x1 U_RF_WDATA_MUX (
        .in0    (i_ex_alu_result),   //ALU
        .in1    (i_mem_rdata),       //LOAD
        .in2    (i_id_imm),     //LUI
        .in3    (i_ex_pc_plus_imm),  //AUIPC
        .in4    (i_ex_pc_plus_4),    //JAL,JALR
        .mux_sel(i_cu_rf_wd_sel),
        .mux_out(o_wb_mux_out)
    );

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
