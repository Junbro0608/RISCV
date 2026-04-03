`timescale 1ns / 1ps


module apb_slave_FND (
    input                         PCLK,
    input                         PRESET,
    //APB_bus
    input                  [31:0] PADDR,
    input                  [31:0] PWDATA,
    input                         PWRITE,
    input                         PENABLE,
           apb_if.slave_io        slv_FND,
    //output
    output logic           [ 13:0] FND_slv_data
);
    //ADDR
    localparam [11:0] FND_CTRL_ADDR = 12'h000;
    localparam [11:0] FND_D_ADDR = 12'h004;
    localparam [11:0] FND_ODATA_ADDR = 12'h004;
    //REG
    logic [13:0] FND_ODATA_REG, FND_CTRL_REG;

    //APB_bus
    assign slv_FND.PREADY = (PENABLE && slv_FND.PSEL);
    assign slv_FND.PRDATA = (PADDR[11:0] == FND_CTRL_ADDR)  ? {18'h0,FND_CTRL_REG}: 
                            (PADDR[11:0]  == FND_ODATA_ADDR)? {18'h0,FND_ODATA_REG}: 32'h0;


    always_ff @(posedge PCLK or posedge PRESET) begin : slv_FND_ff
        if (PRESET) begin
            FND_CTRL_REG  <= 14'h0;
            FND_ODATA_REG <= 14'h0;
        end else begin
            if (slv_FND.PREADY && PWRITE) begin
                case (PADDR[11:0])
                    FND_CTRL_ADDR:  FND_CTRL_REG <= PWDATA[13:0];
                    FND_ODATA_ADDR: FND_ODATA_REG <= PWDATA[13:0];
                endcase
            end
        end
    end

    genvar i;
    generate
        for (i = 0; i < 14; i++) begin
            assign FND_slv_data[i] = (FND_CTRL_REG[i]) ? FND_ODATA_REG[i] : 14'bz;
        end
    endgenerate



endmodule
