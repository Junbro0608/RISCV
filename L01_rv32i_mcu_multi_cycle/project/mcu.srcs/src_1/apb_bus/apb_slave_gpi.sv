`timescale 1ns / 1ps

module apb_slave_gpi (
    input                        PCLK,
    input                        PRESET,
    //APB_bus
    input                 [31:0] PADDR,
    input                 [31:0] PWDATA,
    input                        PWRITE,
    input                        PENABLE,
          apb_if.slave_io        slv_GPI,
    //input
    input                 [15:0] GPI_in
);
    localparam [11:0] GPI_CTRL_ADDR = 12'h000;
    localparam [11:0] GPI_IDATA_ADDR = 12'h004;
    logic [15:0] GPI_IDATA_REG, GPI_CTRL_REG;

    //APB_bus
    assign slv_GPI.PREADY = (PENABLE && slv_GPI.PSEL);
    assign slv_GPI.PRDATA = (PADDR[11:0] == GPI_CTRL_ADDR)  ? {16'h0,GPI_CTRL_REG}: 
                            (PADDR[11:0]  == GPI_IDATA_ADDR)? {16'h0,GPI_IDATA_REG}: 32'h0;


    always_ff @(posedge PCLK or posedge PRESET) begin : slv_gpo_ff
        if (PRESET) begin
            GPI_CTRL_REG <= 16'h0;
        end else begin
            if (slv_GPI.PREADY && PWRITE) begin
                if (PADDR[11:0] == GPI_CTRL_ADDR) begin
                    GPI_CTRL_REG <= PWDATA[15:0];
                end
            end
        end
    end

    //input GPI
    genvar i;
    generate
        for (i = 0; i < 16; i++) begin
            assign GPI_IDATA_REG[i] = (GPI_CTRL_REG[i]) ? GPI_in[i] : 16'bz;
        end
    endgenerate
endmodule
