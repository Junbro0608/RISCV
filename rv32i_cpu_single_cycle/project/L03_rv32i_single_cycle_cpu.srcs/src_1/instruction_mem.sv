`timescale 1ns / 1ps


module instruction_mem (
    input        [29:0] instr_addr,
    output logic [31:0] instr_data
);

    logic [31:0] rom[0:127];

    initial begin
        // rom[0] = 32'h005201b3;
        // rom[1] = 32'h005201b3;
    end

    assign instr_data = rom[instr_addr];

endmodule
