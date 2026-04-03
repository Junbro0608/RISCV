`timescale 1ns / 1ps


module tb_apb_bus ();

    logic clk, rst, Wreq, Rreq, ready, PENABLE, PWRITE;
    logic [31:0] addr, Wdata, Rdata, PADDR, PWDATA;

    apb_if
        slv_RAM (),
        slv_GPO (),
        slv_GPI (),
        slv_GPIO (),
        slv_FND (),
        slv_UART ();


    apb_master DUT (
        .PCLK  (clk),
        .PRESET(rst),
        .*
    );

    initial clk = 0;
    always #5 clk = ~clk;

    always @(*) begin
        if (PENABLE && slv_RAM.PSEL) begin
            slv_RAM.PREADY = 1;
        end else if (PENABLE && slv_UART.PSEL) begin
            slv_UART.PREADY = 1;
        end else begin
            #1;
            slv_RAM.PREADY  = 0;
            slv_UART.PREADY = 0;
        end
    end

    task write_data(input [31:0] addr_t, [31:0] Wdata_t);
        #1;
        Wreq  = 1;
        Rreq  = 0;
        addr  = addr_t;
        Wdata = Wdata_t;

        @(posedge clk);
        Wreq  = 0;
        Wdata = 0;
        addr  = 0;
    endtask

    task read_data(input [31:0] addr_t, [31:0] Rdata_t, [2:0] mode);
        #1;
        Rreq = 1;
        addr = addr_t;

        @(posedge clk);
        Rreq = 0;
        addr = 0;
        @(posedge clk);
        @(ready);
        case (mode)
            0: slv_RAM.PRDATA = Rdata_t;
            5: slv_UART.PRDATA = Rdata_t;
        endcase
    endtask

    initial begin
        rst = 1;
        Wreq = 0;
        Rreq = 0;
        slv_RAM.PRDATA = 0;
        slv_RAM.PREADY = 0;
        slv_UART.PREADY = 0;

        repeat (2) @(posedge clk);
        rst = 0;
        @(posedge clk);

        write_data(32'h1000_0000, 32'h41);
        @(slv_RAM.PREADY);
        @(posedge clk);
        @(posedge clk);
        read_data(32'h2000_4000, 32'h41, 5);
        repeat (10) @(posedge clk);
        $stop;
    end
endmodule
