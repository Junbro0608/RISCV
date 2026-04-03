`timescale 1ns / 1ps


module instruction_mem (
    input        [29:0] instr_addr,
    output logic [31:0] instr_data
);

    logic [31:0] rom[0:511];

    initial begin
        //$readmemh("uart_test.mem",rom);
    end

    assign instr_data = rom[instr_addr];

endmodule
