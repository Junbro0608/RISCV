// List of RISC-V opcodes, funct and define codes.
// simulation memory path

//typedef enum(Wave_foam for easy viewing)  : opcode, alu_control
//define(macro)                             : opcode, funct3, funct7

`ifndef rv32i_opcode
`define rv32i_opcode 

//mem_path
`define REG_FILE U_DUT.U_CPU.U_DATA_PATH.U_REG_FILE
`define INSTR_MEM U_DUT.U_INSTR_MEM
`define DMEM U_DUT.U_DATA_MEM

//opcode
`define R_TYPE      7'b011_0011
`define S_TYPE      7'b010_0011
`define I_TYPE      7'b001_0011
`define IL_TYPE     7'b000_0011
`define B_TYPE      7'b110_0011
`define LUI_TYPE    7'b011_0111
`define AUIPC_TYPE  7'b001_0111
`define JAL_TYPE    7'b110_1111
`define JALR_TYPE   7'b110_0111

typedef enum logic [6:0] {
    R_type     = `R_TYPE,
    S_type     = `S_TYPE,
    I_type     = `I_TYPE,
    IL_type    = `IL_TYPE,
    B_type     = `B_TYPE,
    LUI_type   = `LUI_TYPE,
    AUIPC_type = `AUIPC_TYPE,
    JAL_type   = `JAL_TYPE,
    JALR_type  = `JALR_TYPE
} opcode_t;

//--------------------R_type & I_type----------------------------
//funct3
`define FNC3_ADD_SUB 3'h0 
`define FNC3_SLL 3'h1 
`define FNC3_SLT 3'h2 
`define FNC3_SLTU 3'h3 
`define FNC3_XOR 3'h4 
`define FNC3_SRL_SRA 3'h5 
`define FNC3_OR 3'h6 
`define FNC3_AND 3'h7

//funct7
`define FNC7_0 7'b0
`define FNC7_SUB 7'b010_0000 
`define FNC7_SRA 7'b010_0000

//--------------------S_type----------------------------
`define FNC3_SB 3'b0
`define FNC3_SH 3'h1
`define FNC3_SW 3'h2

//--------------------IL_type----------------------------
`define FNC3_LB 3'h0
`define FNC3_LH 3'h1
`define FNC3_LW 3'h2
`define FNC3_LBU 3'h3
`define FNC3_LHU 3'h4
//--------------------B_type----------------------------
`define FNC3_BEQ 3'h0
`define FNC3_BNE 3'h1
`define FNC3_BLT 3'h4
`define FNC3_BGE 3'h5
`define FNC3_BLTU 3'h6
`define FNC3_BGEU 3'h7

// alu_control-----------------------------------------
//{b_type,func7[5],funct3}
//ALU = {0,func7[5],funct3}
//Brach = {1,0,funct3}
//JUMP = {1,1,0}
`define ADD {1'b0, 1'b0, `FNC3_ADD_SUB}
`define SUB {1'b0, 1'b1, `FNC3_ADD_SUB}
`define SLL {1'b0, 1'b0, `FNC3_SLL}
`define SLT {1'b0, 1'b0, `FNC3_SLT}
`define SLTU {1'b0, 1'b0, `FNC3_SLTU}
`define XOR {1'b0, 1'b0, `FNC3_XOR}
`define SRL {1'b0, 1'b0, `FNC3_SRL_SRA}
`define SRA {1'b0, 1'b1, `FNC3_SRL_SRA}
`define OR {1'b0, 1'b0, `FNC3_OR}
`define AND {1'b0, 1'b0, `FNC3_AND}
`define BEQ {1'b1, 1'b0, `FNC3_BEQ}
`define BNE {1'b1, 1'b0, `FNC3_BNE}
`define BLT {1'b1, 1'b0, `FNC3_BLT}
`define BGE {1'b1, 1'b0, `FNC3_BGE}
`define BLTU {1'b1, 1'b0, `FNC3_BLTU}
`define BGEU {1'b1, 1'b0, `FNC3_BGEU}
`define JUMP {1'b1,1'b1,3'b0}

typedef enum logic [4:0] {
    ADD     = `ADD,
    SUB     = `SUB,
    SLL     = `SLL,
    SLT     = `SLT,
    SLTU    = `SLTU,
    XOR     = `XOR,
    SRL     = `SRL,
    SRA     = `SRA,
    OR      = `OR,
    AND     = `AND,
    BEQ     = `BEQ,
    BNE     = `BNE,
    BLT     = `BLT,
    BGE     = `BGE,
    BLTU    = `BLTU,
    BGEU    = `BGEU,
    JUMP     = `JUMP,
    ALU_OFF = 5'hff
} alu_control_t;

`endif  //rv32i_opcode
