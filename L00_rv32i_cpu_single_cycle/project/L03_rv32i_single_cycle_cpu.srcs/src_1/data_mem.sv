`timescale 1ns / 1ps
`include "rv32i_opcode.svh"

module data_mem (
    input               clk,
    //control_unit
    input        [ 2:0] i_funct3,
    input               dwe,
    //write
    input        [31:0] daddr,
    input        [31:0] dwdata,
    //read
    output logic [31:0] drdata
);

    logic [31:0] dmem[0:255];


    //S_type
    always_ff @(posedge clk) begin : write_mem_ff
        if (dwe) begin
            case (i_funct3)
                `FNC3_SB: begin
                    case (daddr[1:0])
                        2'b00: dmem[daddr[31:2]][7:0] <= dwdata[7:0];
                        2'b01: dmem[daddr[31:2]][15:8] <= dwdata[7:0];
                        2'b10: dmem[daddr[31:2]][23:16] <= dwdata[7:0];
                        2'b11: dmem[daddr[31:2]][31:24] <= dwdata[7:0];
                    endcase
                end
                `FNC3_SH: begin
                    case (daddr[1])
                        1'b0: dmem[daddr[31:2]][15:0] <= dwdata[15:0];
                        1'b1: dmem[daddr[31:2]][31:16] <= dwdata[15:0];
                    endcase
                end
                `FNC3_SW: dmem[daddr[31:2]] <= dwdata;
            endcase
        end
    end


    //IL_type
    always_comb begin : read_mem_comb
        drdata = 0;
        case (i_funct3)
            `FNC3_LB: begin
                case (daddr[1:0])
                    2'b00: drdata = 32'($signed(dmem[daddr[31:2]][7:0]));
                    2'b01: drdata = 32'($signed(dmem[daddr[31:2]][15:8]));
                    2'b10: drdata = 32'($signed(dmem[daddr[31:2]][23:16]));
                    2'b11: drdata = 32'($signed(dmem[daddr[31:2]][31:24]));
                endcase
            end
            `FNC3_LH: begin
                case (daddr[1])
                    1'b0: drdata = 32'($signed(dmem[daddr[31:2]][15:0]));
                    2'b1: drdata = 32'($signed(dmem[daddr[31:2]][31:16]));
                endcase
            end
            `FNC3_LW: drdata = dmem[daddr[31:2]];
            `FNC3_LBU: begin
                case (daddr[1:0])
                    2'b00: drdata = 32'(dmem[daddr[31:2]][7:0]);
                    2'b01: drdata = 32'(dmem[daddr[31:2]][15:8]);
                    2'b10: drdata = 32'(dmem[daddr[31:2]][23:16]);
                    2'b11: drdata = 32'(dmem[daddr[31:2]][31:24]);
                endcase
            end
            `FNC3_LHU: begin
                case (daddr[1])
                    1'b0: drdata = 32'(dmem[daddr[31:2]][15:0]);
                    1'b1: drdata = 32'(dmem[daddr[31:2]][31:16]);
                endcase
            end
        endcase

    end
endmodule

