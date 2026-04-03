`timescale 1ns / 1ps


module apb_slave_GPIO (
    input                        PCLK,
    input                        PRESET,
    //APB_bus
    input                 [31:0] PADDR,
    input                 [31:0] PWDATA,
    input                        PWRITE,
    input                        PENABLE,
          apb_if.slave_io        slv_GPIO,
    //inout
    inout logic           [15:0] GPIO_io
);
    localparam [11:0] GPIO_CTRL_ADDR = 12'h000;
    localparam [11:0] GPIO_ODATA_ADDR = 12'h004;
    localparam [11:0] GPIO_IDATA_ADDR = 12'h008;
    logic [15:0] GPIO_ODATA_REG, GPIO_CTRL_REG, GPIO_IDATA_REG;

    //APB_bus
    assign slv_GPIO.PREADY = (PENABLE && slv_GPIO.PSEL);

    assign slv_GPIO.PRDATA = (PADDR[11:0] == GPIO_CTRL_ADDR)  ? {16'h0,GPIO_CTRL_REG}: 
                             (PADDR[11:0]  == GPIO_ODATA_ADDR)? {16'h0,GPIO_ODATA_REG}: 
                             (PADDR[11:0] == GPIO_IDATA_ADDR) ? {16'h0,GPIO_IDATA_REG}:32'h0;


    always_ff @(posedge PCLK or posedge PRESET) begin : slv_GPIO_ff
        if (PRESET) begin
            GPIO_CTRL_REG  <= 16'h0;
            GPIO_ODATA_REG <= 16'h0;
        end else begin
            if (slv_GPIO.PREADY && PWRITE) begin
                case (PADDR[11:0])
                    GPIO_CTRL_ADDR:  GPIO_CTRL_REG <= PWDATA[15:0];
                    GPIO_ODATA_ADDR: GPIO_ODATA_REG <= PWDATA[15:0];
                endcase
            end
        end
    end

    //inout
    genvar i;
    generate
        for (i = 0; i < 16; i++) begin
            assign GPIO_IDATA_REG[i] = ~(GPIO_CTRL_REG[i]) ? GPIO_io[i] : 1'bz;
            assign GPIO_io[i] = (GPIO_CTRL_REG[i]) ? GPIO_ODATA_REG[i] : 1'bz;
        end
    endgenerate

endmodule
