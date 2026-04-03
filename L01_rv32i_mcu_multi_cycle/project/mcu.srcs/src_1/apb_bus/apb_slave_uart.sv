`timescale 1ns / 1ps


module apb_slave_UART (
    input                         PCLK,
    input                         PRESET,
    //APB_bus
    input                  [31:0] PADDR,
    input                  [31:0] PWDATA,
    input                         PWRITE,
    input                         PENABLE,
           apb_if.slave_io        slv_UART,
    //Baud
    output                 [ 1:0] baud_mode,
    //TX
    input                         TX_busy,
    output                 [ 7:0] TX_data,
    output                        TX_start,
    output                        TX_done,
    //RX
    input                         RX_done,
    input  logic           [ 7:0] RX_data
);
    localparam [11:0]   UART_CTRL_ADDR = 12'h000,
                        UART_BAUD_ADDR = 12'h004,
                        UART_STATUS_ADDR = 12'h008,
                        UART_TX_DATA_ADDR = 12'h00c,
                        UART_RX_DATA_ADDR = 12'h010;

    logic [15:0]
        UART_CTRL_REG,
        UART_BAUD_REG,
        UART_STATUS_REG,
        UART_TX_DATA_REG,
        UART_RX_DATA_REG;

    //APB_bus
    assign slv_UART.PREADY = (PENABLE && slv_UART.PSEL);

    assign slv_UART.PRDATA = (PADDR[11:0] == UART_CTRL_ADDR)    ? {16'h0,UART_CTRL_REG}: 
                             (PADDR[11:0] == UART_BAUD_ADDR)    ? {16'h0,UART_BAUD_REG}: 
                             (PADDR[11:0] == UART_STATUS_ADDR)  ? {16'h0,UART_STATUS_REG}:
                             (PADDR[11:0] == UART_TX_DATA_ADDR) ? {16'h0,UART_TX_DATA_REG}:
                             (PADDR[11:0] == UART_RX_DATA_ADDR) ? {16'h0,UART_RX_DATA_REG}: 32'h0;


    //APB Bus Write
    always_ff @(posedge PCLK or posedge PRESET) begin : slv_UART_ff
        if (PRESET) begin
            UART_CTRL_REG    <= 16'h0;
            UART_BAUD_REG    <= 16'h0;
            UART_TX_DATA_REG <= 16'h0;
        end else begin
            if (slv_UART.PREADY && PWRITE) begin
                case (PADDR[11:0])
                    UART_CTRL_ADDR:    UART_CTRL_REG <= PWDATA[15:0];
                    UART_BAUD_ADDR:    UART_BAUD_REG <= PWDATA[15:0];
                    UART_TX_DATA_ADDR: UART_TX_DATA_REG <= PWDATA[15:0];
                endcase
            end
        end
    end

    //hardware i/o

    //Baud
    assign baud_mode           = UART_BAUD_REG[1:0];
    //TX
    assign UART_STATUS_REG[0]  = TX_busy;
    assign TX_data             = UART_TX_DATA_REG;
    assign TX_start            = UART_CTRL_REG[0];
    //RX
    assign UART_STATUS_REG[15] = RX_done;
    assign UART_RX_DATA_REG    = RX_data;


endmodule
