`timescale 1ns / 1ps
`include "../../src_1/rv32i_opcode.svh"

`define HEX_CODE 0
`define R 0
`define I 0
`define S 0
`define IL 0
`define B 0
`define U 1
`define J 0


module tb_rv32i_all_type ();
    //input
    logic clk, rst;

    //sim
    logic [4:0] rs1, rs2, shift_addr, rd, shamt;
    logic [31:0] rd1, rd2, shift;
    logic [31:0] imm;
    logic done, all_tests_passed;
    logic [31:0] cycle, timeout_cycle, current_result, current_output;
    logic [255:0] current_test_type;

    logic [31:0] sim_result;


    integer i,j;

    rv32I_top U_DUT (
        .clk(clk),
        .rst(rst)
    );

    always #5 clk = ~clk;


    task reset(input reg_option);
        rst = 1;

        //REG
        if (reg_option) begin
            for (i = 1; i < 32; i = i + 1) begin
                `REG_FILE.reg_file[i] = i;
            end
        end else begin
            for (i = 1; i < 32; i = i + 1) begin
                `REG_FILE.reg_file[i] = 32'bx;
            end
        end

        //DMEM
        for (i = 0; i < 32; i = i + 1) begin
            `DMEM.dmem[i] = 32'bx;
        end

        //INSTR_MEM
        for (i = 0; i < 32; i = i + 1) begin
            `INSTR_MEM.rom[i] = 32'bx;
        end
    endtask

    task run(input [31:0] cycle);
        @(negedge clk);
        rst = 0;
        repeat(cycle) @(posedge clk);
    endtask



    //sim
    initial begin
        clk =0;
        //sim0----------------HEX_CODE-----------------------
        if(`HEX_CODE) begin
            reset(0);
            $display("[Test HEX_CODE]");
            $readmemh("riscv_rv32i_rom.mem",`INSTR_MEM.rom);

            run(520);    
        end
        //sim1----------------r-type------------------------
        // - ADD, SUB, SLL, SLT, SLTU, XOR, OR, AND, SRL, SRA
        // - SLLI, SRLI, SRAI
        if(`R)begin
            reset(0);
            $display("%t : [Test R_type Instr]",$realtime);
            //REG
            rs1 = 1; rs2 = 2; shift_addr = 5'd3;
            rd = 4;
            `REG_FILE.reg_file[rs1] = -100;
            `REG_FILE.reg_file[rs2] = 200;
            `REG_FILE.reg_file[shift_addr] = 2;

            //PC
            `INSTR_MEM.rom[0] = {`FNC7_0,   rs2,            rs1,    `FNC3_ADD_SUB,  rd, `R_TYPE};
            `INSTR_MEM.rom[1] = {`FNC7_SUB, rs2,            rs1,    `FNC3_ADD_SUB,  rd, `R_TYPE};
            `INSTR_MEM.rom[2] = {`FNC7_0,   shift_addr,     rs1,    `FNC3_SLL,      rd, `R_TYPE};
            `INSTR_MEM.rom[3] = {`FNC7_0,   rs2,            rs1,    `FNC3_SLT,      rd, `R_TYPE};
            `INSTR_MEM.rom[4] = {`FNC7_0,   rs2,            rs1,    `FNC3_SLTU,     rd, `R_TYPE};
            `INSTR_MEM.rom[5] = {`FNC7_0,   rs2,            rs1,    `FNC3_XOR,      rd, `R_TYPE};
            `INSTR_MEM.rom[6] = {`FNC7_0,   shift_addr,     rs1,    `FNC3_SRL_SRA,  rd, `R_TYPE};
            `INSTR_MEM.rom[7] = {`FNC7_SRA, shift_addr,     rs1,    `FNC3_SRL_SRA,  rd, `R_TYPE};
            `INSTR_MEM.rom[8] = {`FNC7_0,   rs2,            rs1,    `FNC3_OR,       rd, `R_TYPE};
            `INSTR_MEM.rom[9] = {`FNC7_0,   rs2,            rs1,    `FNC3_AND,      rd, `R_TYPE};



            run(10); 
        end
        //sim2----------------i-type------------------------
        // - ADDI, SLTI, SLTUI, XORI, ORI, ANDI
        if(`I) begin
            reset(0);
            $display("%t : [Test I_type Instr]",$realtime);
            //REG
            rs1 = 1; shamt = 2;
            rd = 2;
            `REG_FILE.reg_file[1] = -100;
            imm = 200;


            //PC
            //rd <= ALU (rs1,imm) other : {imm[11:0], rs1[4:0],   funct3[2:0],    rd[4:0],    `I_TYPE}
            //rd <= ALU (rs1,imm) SLLI,SRLI,SRAI: {`FNC7_?? , shamt,  rs1[4:0],   funct3[2:0],    rd[4:0],    `I_TYPE}
            `INSTR_MEM.rom[0] = {imm,               rs1,   `FNC3_ADD_SUB,  rd,   `I_TYPE};    //ADDI x2 = x1 + imm
            `INSTR_MEM.rom[1] = {imm,               rs1,   `FNC3_SLT,      rd,   `I_TYPE};    //SLTI x2 = x1 + imm
            `INSTR_MEM.rom[2] = {imm,               rs1,   `FNC3_SLTU,     rd,   `I_TYPE};    //SLTIU x2 = x1 + imm
            `INSTR_MEM.rom[3] = {imm,               rs1,   `FNC3_XOR,      rd,   `I_TYPE};    //XORI x2 = x1 + imm
            `INSTR_MEM.rom[4] = {imm,               rs1,   `FNC3_OR,       rd,   `I_TYPE};    //ORI x2 = x1 + imm
            `INSTR_MEM.rom[5] = {imm,               rs1,   `FNC3_AND,      rd,   `I_TYPE};    //ANDI x2 = x1 + imm
            `INSTR_MEM.rom[6] = {`FNC7_0,   shamt,  rs1,   `FNC3_SLL,      rd,   `I_TYPE};    //SLLI x2 = x1 + imm
            `INSTR_MEM.rom[7] = {`FNC7_0,   shamt,  rs1,   `FNC3_SRL_SRA,  rd,   `I_TYPE};    //SRLI x2 = x1 + imm
            `INSTR_MEM.rom[8] = {`FNC7_SRA, shamt,  rs1,   `FNC3_SRL_SRA,  rd,   `I_TYPE};    //SRAI x2 = x1 + imm
            

            run(9); 
        end
        //sim3----------------s-type------------------------
        // - SW, SH, SB
        if(`S) begin
            reset(1);
            $display("%t : [Test S_type Instr]",$realtime);

            //REG
            rs1 = 0; rs2 = 28;
            imm = 0;
            `REG_FILE.reg_file[31] = 32'h11;
            `REG_FILE.reg_file[30] = 32'h22;
            `REG_FILE.reg_file[29] = 32'h33;
            `REG_FILE.reg_file[28] = 32'h44;
            
            //PC
            //dmem[rs1+imm] <= rs2[Byte,half,word] : {imm[6:0], rs2[4:0], rs1[4:0], funct3[2:0], imm[4:0],`S_TYPE}
            for(i=0;i<4;i=i+1) begin
                `INSTR_MEM.rom[0+i] =     {imm[6:0],    rs2+i[4:0],  rs1,  `FNC3_SB,   imm[4:0]+i[4:0], `S_TYPE};  //SB dmem[rs1+i] <= rs2+i
            end
            for(i=0;i<4;i=i+1) begin
                `INSTR_MEM.rom[4+i] =     {imm[6:0],    rs2+i[4:0],  rs1,  `FNC3_SH,   imm[4:0]+i[4:0], `S_TYPE};  //SH dmem[rs1+i] <= rs2+i
            end
            for(i=0;i<4;i=i+1) begin
                `INSTR_MEM.rom[8+i] =     {imm[6:0],    rs2+i[4:0],  rs1,  `FNC3_SW,   imm[4:0]+i[4:0], `S_TYPE};  //SW dmem[rs1+i] <= rs2+i
            end

            run(13);
        end
        //sim4----------------il-type-----------------------
        // - LW, LH, LB, LHU, LBU
        if(`IL) begin
            reset(0);
            $display("%t : [Test IL_type Instr]",$realtime);
            
            //REG
            rs1 = 0; imm = 0;
            rd = 1;
            `DMEM.dmem[0] = 32'h04_f3_f2_01;
            //PC
            //rd <= rs+imm : {imm[11:0],    rs1[4:0],  funct3[2:0],   rd[4:0],   `IL_TYPE}
            for(i=0;i<4;i=i+1) begin
                `INSTR_MEM.rom[0+i]   = {imm+i,  rs1,    `FNC3_LB,   rd, `IL_TYPE};    //LB  x5 = dmem[rs1+imm+i]
            end
            for(i=0;i<4;i=i+1) begin
                `INSTR_MEM.rom[4+i]   = {imm+i,  rs1,    `FNC3_LH,   rd, `IL_TYPE};    //LB  x5 = dmem[rs1+imm+i]
            end
            for(i=0;i<4;i=i+1) begin
                `INSTR_MEM.rom[8+i]   = {imm+i,  rs1,    `FNC3_LW,   rd, `IL_TYPE};    //LB  x5 = dmem[rs1+imm+i]
            end
            for(i=0;i<4;i=i+1) begin
                `INSTR_MEM.rom[12+i]  = {imm+i,  rs1,    `FNC3_LBU,  rd, `IL_TYPE};    //LB  x5 = dmem[rs1+imm+i]
            end
            for(i=0;i<4;i=i+1) begin
                `INSTR_MEM.rom[16+i]  = {imm+i,  rs1,    `FNC3_LHU,  rd, `IL_TYPE};    //LB  x5 = dmem[rs1+imm+i]
            end

            run(21);
        end
        //sim5----------------b-type-----------------------
        // - BEQ, BNE, BLT, BGE, BLTU, BGEU
        if(`B) begin
            reset(0);
            $display("[Test B_type Instr]");
            
            rs1 = 1;
            rd = 2;
            `REG_FILE.reg_file[rs1] = -1    ;
           
            //PC  
            //if(rs1 == rs2) PC += imm : {imm[12,10:5], rs2[4:0], rs1[4:0], funct3[2:0], imm[4:1,11],`B_TYPE}
            //-----all true case-----
            //signed
            imm = 2 * 4;    `INSTR_MEM.rom[0]  = {imm[12], imm[10:5], rs1, rs1, `FNC3_BEQ,  imm[4:1], imm[11], `B_TYPE};
                            `INSTR_MEM.rom[2]  = {imm[12], imm[10:5], rs1, 5'd0, `FNC3_BNE,  imm[4:1], imm[11], `B_TYPE}; 
                            `INSTR_MEM.rom[6]  = {imm[12], imm[10:5], rs1, 5'd0, `FNC3_BGE,  imm[4:1], imm[11], `B_TYPE};
                            `INSTR_MEM.rom[4]  = {imm[12], imm[10:5], 5'd0, rs1, `FNC3_BLT,  imm[4:1], imm[11], `B_TYPE};
            imm = 6 * 4;    `INSTR_MEM.rom[8]  = {imm[12], imm[10:5], rs1, rs1, `FNC3_BGE,  imm[4:1], imm[11], `B_TYPE};
            //unsigned
            imm = -2 * 4;   `INSTR_MEM.rom[14] = {imm[12], imm[10:5], rs1, 5'd0, `FNC3_BLTU, imm[4:1], imm[11], `B_TYPE};
                            `INSTR_MEM.rom[12] = {imm[12], imm[10:5], 5'd0, rs1, `FNC3_BGEU, imm[4:1], imm[11], `B_TYPE}; 
            imm = 8 * 4;    `INSTR_MEM.rom[10] = {imm[12], imm[10:5], rs1, rs1, `FNC3_BGEU, imm[4:1], imm[11], `B_TYPE};
            //-----all false case-----
            //signed
            imm = 30 * 4;    `INSTR_MEM.rom[18] = {imm[12], imm[10:5], 5'd0, rs1, `FNC3_BEQ,  imm[4:1], imm[11], `B_TYPE};
                            `INSTR_MEM.rom[19] = {imm[12], imm[10:5], 5'd0, 5'd0, `FNC3_BNE,  imm[4:1], imm[11], `B_TYPE}; 
                            `INSTR_MEM.rom[20] = {imm[12], imm[10:5], rs1, 5'd0, `FNC3_BLT,  imm[4:1], imm[11], `B_TYPE};
                            `INSTR_MEM.rom[21] = {imm[12], imm[10:5], rs1, rs1, `FNC3_BLT,  imm[4:1], imm[11], `B_TYPE};
                            `INSTR_MEM.rom[22] = {imm[12], imm[10:5], 5'd0, rs1, `FNC3_BGE,  imm[4:1], imm[11], `B_TYPE};
            //unsigned 
                            `INSTR_MEM.rom[23] = {imm[12], imm[10:5], 5'd0, rs1, `FNC3_BLTU, imm[4:1], imm[11], `B_TYPE}; 
                            `INSTR_MEM.rom[24] = {imm[12], imm[10:5], 5'd0, 5'd0, `FNC3_BLTU, imm[4:1], imm[11], `B_TYPE}; 
                            `INSTR_MEM.rom[25] = {imm[12], imm[10:5], rs1, 5'd0, `FNC3_BGEU, imm[4:1], imm[11], `B_TYPE};  
            //SUB
                            `INSTR_MEM.rom[26] = {`FNC7_SUB, 5'd1, 5'd1, `FNC3_ADD_SUB, rd, `R_TYPE};
            run(17);
        end
        //sim6----------------u-type------------------------
        // - LUI, AUIPC
        if(`U) begin
            reset(0);
            $display("%t : [Test U_type Instr]",$realtime);

            rd = 1;

            //PC
            //BEQ       if(0 == 0) 
            //LUI       rd = imm : {imm[31:12], rd, `LUI_TYPE}
            //AUIPC     rd = PC + imm : {imm[31:12], rd, `LUI_TYPE}
            
            //BEQ
            imm = 2 * 4;    
            `INSTR_MEM.rom[0]  = {imm[12], imm[10:5], 5'd0, 5'd0, `FNC3_BEQ,  imm[4:1], imm[11], `B_TYPE};
            imm = 32'h1800;
            //LUI
            `INSTR_MEM.rom[2] = {imm[31:12],   rd, `LUI_TYPE};
            //AUIPC
            `INSTR_MEM.rom[3] = {imm[31:12],    rd, `AUIPC_TYPE};


            run(3);
        end
        //sim7----------------j-type------------------------
        // - JAL
        // - JALR
        if(`J) begin
            reset(0);
            $display("%t : [Test J_type Instr]",$realtime);
            
            imm = 3 * 4;
            rs1 = 5;
            `REG_FILE.reg_file[rs1] = 4*4;
            /*
            [0] JAL     rd = PC+4; PC += imm        x1 = 0 + 4; PC = 0 + 3*4
            [3] JALR    rd = PC+4; PC = rs1 + imm   X2 = 3*4 + 4; PC = x1(4*4) + 3*4
            [9] SUB     rd = rs1 - rs2              X3 = x1(18) - x2(24)
            */
            
            //PC
            //JAL   rd = PC + 4; PC += imm      : {imm[20],imm[10:1],imm[11],imm[19:12], rd, `JAL_TYPE} 
            //JALR  rd = PC + 4; PC = rs1 + imm : {imm[11:0],   rs1,    3'd0,   rd, `JALR_TYPE}

            //JAL
            rd = 1;
            `INSTR_MEM.rom[0] = {imm[20],imm[10:1],imm[11],imm[19:12],rd,`JAL_TYPE};
            //JALR
            rd = 2; rs1 = 5;
            `INSTR_MEM.rom[3] = {imm[11:0], rs1,    3'b0,   rd, `JALR_TYPE};
            //ADD
            rd = 3; rs1 = 2; rs2 = 1;
            `INSTR_MEM.rom[7] = {`FNC7_SUB, rs2,   rs1,   `FNC3_ADD_SUB,  rd,   `R_TYPE};
            run(3);
        end

        $stop;
    end
endmodule
