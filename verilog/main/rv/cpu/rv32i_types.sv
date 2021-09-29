
package Global;
    
    parameter width = 32;
    typedef logic [width-1:0] size_t;

endpackage


package ALU;

    typedef enum bit [2:0] {
        _add = 3'b000,
        _sll = 3'b001,
        _sra = 3'b010,
        _sub = 3'b011,
        _xor = 3'b100,
        _srl = 3'b101,
        _or  = 3'b110,
        _and = 3'b111
    } ops;

    typedef enum bit {
        rs1_out = 1'b0
        ,pc_out = 1'b1
    } mux1;

    typedef enum bit [2:0] {
        i_imm    = 3'b000
        ,u_imm   = 3'b001
        ,b_imm   = 3'b010
        ,s_imm   = 3'b011
        ,j_imm   = 3'b100
        ,rs2_out = 3'b101
    } mux2;

endpackage


package CMP;

    typedef enum bit [2:0] {
        beq  = 3'b000,
        bne  = 3'b001,
        blt  = 3'b100,
        bge  = 3'b101,
        bltu = 3'b110,
        bgeu = 3'b111
    } ops;

    typedef enum bit {
        rs2_out = 1'b0
        ,i_imm = 1'b1
    } mux1;

endpackage


package IR;

    typedef logic [2:0] funct3_t;
    typedef logic [6:0] funct7_t;
    typedef logic [4:0] reg_t;   // register address, 32 regs in total

    typedef enum bit [6:0] {
        op_lui   = 7'b0110111, //load upper immediate (U type)
        op_auipc = 7'b0010111, //add upper immediate PC (U type)
        op_jal   = 7'b1101111, //jump and link (J type)
        op_jalr  = 7'b1100111, //jump and link register (I type)
        op_br    = 7'b1100011, //branch (B type) note: offset is 2n, range +- 4kb
        op_load  = 7'b0000011, //load (I type)
        op_store = 7'b0100011, //store (S type)
        op_imm   = 7'b0010011, //arith ops with register/immediate operands (I type)
        op_reg   = 7'b0110011, //arith ops with register operands (R type)
        op_csr   = 7'b1110011  //control and status register (I type)
    } rv32i_opcode_t;


    typedef enum bit [2:0] {
        lb  = 3'b000,
        lh  = 3'b001,
        lw  = 3'b010,
        lbu = 3'b100,
        lhu = 3'b101
    } load_funct3_t;

    typedef enum bit [2:0] {
        sb = 3'b000,
        sh = 3'b001,
        sw = 3'b010
    } store_funct3_t;

    typedef enum bit [2:0] {
        add  = 3'b000, //check bit30 for sub if op_reg opcode
        sll  = 3'b001,
        slt  = 3'b010,
        sltu = 3'b011,
        axor = 3'b100,
        sr   = 3'b101, //check bit30 for logical/arithmetic
        aor  = 3'b110,
        aand = 3'b111
    } arith_funct3_t;

    typedef enum bit [2:0] {
        beq  = 3'b000,
        bne  = 3'b001,
        blt  = 3'b100,
        bge  = 3'b101,
        bltu = 3'b110,
        bgeu = 3'b111
    } branch_funct3_t;
endpackage


package PC;
    typedef enum bit [1:0] {
        pc_plus4  = 2'b00     // fetch
        ,alu_out  = 2'b01
        ,alu_mod2 = 2'b10
    } mux1;
endpackage

package MAR;
    typedef enum bit {
        pc_out = 1'b0
        ,alu_out = 1'b1
    } mux1;
endpackage


package Regfile;
    typedef enum bit [3:0] {
        alu_out   = 4'b0000
        ,br_take  = 4'b0001
        ,u_imm    = 4'b0010
        ,ld       = 4'b0011
        ,pc_plus4 = 4'b0100
    } mux1;
endpackage
