`timescale 1ns / 1ps


module apb_slave_gpo (
    input                         PCLK,
    input                         PRESET,
    //APB_bus
    input                  [31:0] PADDR,
    input                  [31:0] PWDATA,
    input                         PWRITE,
    input                         PENABLE,
           apb_if.slave_io        slv_GPO,
    //output
    output logic           [15:0] GPO_out
);
    localparam [11:0] GPO_CTRL_ADDR = 12'h000;
    localparam [11:0] GPO_ODATA_ADDR = 12'h004;
    logic [15:0] GPO_ODATA_REG, GPO_CTRL_REG;

    //APB_bus
    assign slv_GPO.PREADY = (PENABLE && slv_GPO.PSEL);
    assign slv_GPO.PRDATA = (PADDR[11:0] == GPO_CTRL_ADDR)  ? {16'h0,GPO_CTRL_REG}: 
                            (PADDR[11:0]  == GPO_ODATA_ADDR)? {16'h0,GPO_ODATA_REG}: 32'h0;


    always_ff @(posedge PCLK or posedge PRESET) begin : slv_gpo_ff
        if (PRESET) begin
            GPO_CTRL_REG  <= 16'h0;
            GPO_ODATA_REG <= 16'h0;
        end else begin
            if (slv_GPO.PREADY && PWRITE) begin
                case (PADDR[11:0])
                    GPO_CTRL_ADDR:  GPO_CTRL_REG <= PWDATA[15:0];
                    GPO_ODATA_ADDR: GPO_ODATA_REG <= PWDATA[15:0];
                endcase
            end
        end
    end
    
    genvar i;
    generate
        for (i = 0; i < 16; i++) begin
            assign GPO_out[i] = (GPO_CTRL_REG[i]) ? GPO_ODATA_REG[i] : 16'bz;
        end
    endgenerate


endmodule
