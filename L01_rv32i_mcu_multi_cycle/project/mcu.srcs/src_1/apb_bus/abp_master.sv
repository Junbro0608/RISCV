`timescale 1ns / 1ps

//0x0000_0000 ~ 0x0000_0FFF ROM
//0x1000_0000 ~ 0x1000_0FFF RAM
//0x2000_0000 ~ 0x2000_4FFF GPO

module apb_master (
    input                          PCLK,
    input                          PRESET,
    //Soc Internal signal with CPU
    input                   [31:0] addr,
    input                   [31:0] Wdata,
    input                          Wreq,
    input                          Rreq,
    //APB Interface
    // output logic                  slvERR,
    output logic            [31:0] Rdata,
    output logic                   ready,
    //output -> salve
    output logic            [31:0] PADDR,
    output logic            [31:0] PWDATA,
    output logic                   PENABLE,
    output logic                   PWRITE,
           apb_if.master_io        slv_RAM,
           apb_if.master_io        slv_GPO,
           apb_if.master_io        slv_GPI,
           apb_if.master_io        slv_GPIO,
           apb_if.master_io        slv_FND,
           apb_if.master_io        slv_UART
);
    logic [31:0] PADDR_next, PWDATA_next;
    logic decode_en, PWRITE_next;

    typedef enum logic [1:0] {
        IDLE,
        SETUP,
        ACCESS
    } state_t;
    state_t c_state, n_state;

    always_ff @(posedge PCLK or posedge PRESET) begin : apb_dec_ff
        if (PRESET) begin
            c_state <= IDLE;
            PADDR   <= 0;
            PWDATA  <= 0;
            PWRITE  <= 0;
        end else begin
            c_state <= n_state;
            PADDR   <= PADDR_next;
            PWDATA  <= PWDATA_next;
            PWRITE  <= PWRITE_next;
        end
    end

    always_comb begin : apb_dec_state_comb
        n_state = c_state;
        case (c_state)
            IDLE: if (Wreq || Rreq) n_state = SETUP;
            SETUP: begin
                n_state = ACCESS;
            end
            ACCESS: begin
                if (ready) begin
                    n_state = IDLE;
                    // if (transfer) n_state = SETUP;
                    // else n_state = IDLE;
                end
            end
        endcase
    end

    always_comb begin : apb_dec_output_comb
        decode_en   = 0;
        PENABLE     = 0;
        PWRITE_next = PWRITE;
        PADDR_next  = PADDR;
        PWDATA_next = PWDATA;
        case (c_state)
            IDLE: begin
                decode_en   = 0;
                PENABLE     = 0;
                PWRITE_next = 0;
                PADDR_next  = 0;
                PWDATA_next = 0;
                if (Wreq || Rreq) begin
                    PADDR_next  = addr;
                    PWDATA_next = Wdata;
                    if (Wreq) begin
                        PWRITE_next = 1'b1;
                    end else begin
                        PWRITE_next = 1'b0;
                    end
                end
            end
            SETUP: begin
                decode_en = 1;
                PENABLE   = 0;
            end
            ACCESS: begin
                decode_en = 1;
                PENABLE   = 1;
                if (ready) begin
                    PWDATA_next = 0;
                end
            end
        endcase
    end

    addr_decoder U_ADDR_DEC (
        .addr(PADDR),
        .decode_en(decode_en),
        .PSEL0(slv_RAM.PSEL),
        .PSEL1(slv_GPO.PSEL),
        .PSEL2(slv_GPI.PSEL),
        .PSEL3(slv_GPIO.PSEL),
        .PSEL4(slv_FND.PSEL),
        .PSEL5(slv_UART.PSEL)
    );




    mux_apb U_MUX_APB (
        //input
        .PRDATA0(slv_RAM.PRDATA),
        .PRDATA1(slv_GPO.PRDATA),
        .PRDATA2(slv_GPI.PRDATA),
        .PRDATA3(slv_GPIO.PRDATA),
        .PRDATA4(slv_FND.PRDATA),
        .PRDATA5(slv_UART.PRDATA),
        .PREADY0(slv_RAM.PREADY),
        .PREADY1(slv_GPO.PREADY),
        .PREADY2(slv_GPI.PREADY),
        .PREADY3(slv_GPIO.PREADY),
        .PREADY4(slv_FND.PREADY),
        .PREADY5(slv_UART.PREADY),
        .sel    (PADDR),
        //output
        .Rdata  (Rdata),
        .ready  (ready)
    );
endmodule

module addr_decoder (
    input [31:0] addr,
    input decode_en,
    output logic PSEL0,
    output logic PSEL1,
    output logic PSEL2,
    output logic PSEL3,
    output logic PSEL4,
    output logic PSEL5
);
    always_comb begin
        PSEL0 = 0;
        PSEL1 = 0;
        PSEL2 = 0;
        PSEL3 = 0;
        PSEL4 = 0;
        PSEL5 = 0;
        if (decode_en) begin
            case ({
                addr[31:28], addr[15:12]
            })
                8'h10, 8'h11: PSEL0 = 1;
                8'h20:        PSEL1 = 1;
                8'h21:        PSEL2 = 1;
                8'h22:        PSEL3 = 1;
                8'h23:        PSEL4 = 1;
                8'h24:        PSEL5 = 1;
            endcase
        end
    end
endmodule


module mux_apb (
    //input
    input        [31:0] PRDATA0,
    input        [31:0] PRDATA1,
    input        [31:0] PRDATA2,
    input        [31:0] PRDATA3,
    input        [31:0] PRDATA4,
    input        [31:0] PRDATA5,
    input               PREADY0,
    input               PREADY1,
    input               PREADY2,
    input               PREADY3,
    input               PREADY4,
    input               PREADY5,
    input        [31:0] sel,
    //output
    output logic [31:0] Rdata,
    output logic        ready
);
    always_comb begin
        Rdata = 32'h0;

        case ({
            sel[31:28], sel[15:12]
        })
            8'h10, 8'h11: begin
                Rdata = PRDATA0;
                ready = PREADY0;
            end
            8'h20: begin
                Rdata = PRDATA1;
                ready = PREADY1;
            end
            8'h21: begin
                Rdata = PRDATA2;
                ready = PREADY2;
            end
            8'h22: begin
                Rdata = PRDATA3;
                ready = PREADY3;
            end
            8'h23: begin
                Rdata = PRDATA4;
                ready = PREADY4;
            end
            8'h24: begin
                Rdata = PRDATA5;
                ready = PREADY5;
            end
            default: begin
                Rdata = 32'bx;
                ready = 1'bx;
            end
        endcase
    end

endmodule
