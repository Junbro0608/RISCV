`timescale 1ns / 1ps

module mem_path (
    input               i_clk,
    input               i_rst,
    //data_mem
    input        [31:0] i_dmem_rdata,
    //WB
    output logic [31:0] o_mem_rdata
);

    always_ff @(posedge i_clk or posedge i_rst) begin : mem_path_ff
        if (i_rst) begin
            o_mem_rdata <= 0;
        end else begin
            o_mem_rdata <= i_dmem_rdata;
        end
    end

endmodule
