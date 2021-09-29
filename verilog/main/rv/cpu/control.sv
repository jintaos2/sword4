
module control(clk,mem_resp,opcode,funct3,funct7,br_take,pcmux1_sel,alumux1_sel,alumux2_sel,regfilemux1_sel,marmux1_sel,cmpmux1_sel,aluop,cmpop,load_pc,load_ir,load_regfile,load_mar,load_mdr,load_wmdr,mem_read,mem_write);

    input logic clk;
    // mem out
    input logic mem_resp;
    // IR out 
    input IR::rv32i_opcode_t opcode;
    input IR::funct3_t funct3;
    input IR::funct7_t funct7;
    // cmp out
    input logic br_take;
    // control out
    output PC::mux1 pcmux1_sel;
    output ALU::mux1 alumux1_sel;
    output ALU::mux2 alumux2_sel;
    output Regfile::mux1 regfilemux1_sel;
    output MAR::mux1 marmux1_sel;
    output CMP::mux1 cmpmux1_sel;
    output ALU::ops aluop;
    output CMP::ops cmpop;

    output logic load_pc;
    output logic load_ir;
    output logic load_regfile;
    output logic load_mar;
    output logic load_mdr;
    output logic load_wmdr;
    output logic mem_read;
    output logic mem_write;

typedef enum int unsigned {
    /* List of states */
    fetch1,fetch2,fetch3, decode,
    fetch_next,
    imm,
    regs,
    lui,auipc,
    jal1, jal2,
    jalr1, jalr2,
    br,
    st1, st2, st3,
    ld1, ld2, ld3
} state_t;
state_t state, next_states, decode_next_states;
/************************* Function Definitions *******************************/

/**
 *  Rather than filling up an always_block with a whole bunch of default values,
 *  set the default values for controller outputs signals in this function,
 *   and then call it at the beginning of your always_comb block.
**/
function void set_defaults();
    next_states = fetch_next;

    pcmux1_sel = PC::pc_plus4;
    alumux1_sel = ALU::rs1_out;
    alumux2_sel = ALU::i_imm;
    regfilemux1_sel = Regfile::alu_out;
    marmux1_sel = MAR::pc_out;
    cmpmux1_sel = CMP::rs2_out;

    aluop = ALU::ops'(funct3);
    cmpop = CMP::ops'(funct3);

    load_pc = 1'b0;
    load_ir = 1'b0;
    load_regfile = 1'b0;
    load_mar = 1'b0;
    load_mdr = 1'b0;
    load_wmdr = 1'b0;

    mem_read = 1'b0;
    mem_write = 1'b0;
endfunction

/**
 * SystemVerilog allows for default argument values in a way similar to
 *   C++.
**/
function void ALU_add(  ALU::mux1 sel1,
                        ALU::mux2 sel2
);
    alumux1_sel = sel1;
    alumux2_sel = sel2;
    aluop = ALU::_add;
endfunction

/****************** USED BY RVFIMON --- DO NOT MODIFY ************************/
logic trap;
logic [3:0] rmask, wmask;
logic is_funct7;

IR::branch_funct3_t branch_funct3;
IR::store_funct3_t store_funct3;
IR::load_funct3_t load_funct3;
IR::arith_funct3_t arith_funct3;

assign arith_funct3 = IR::arith_funct3_t'(funct3);
assign branch_funct3 = IR::branch_funct3_t'(funct3);
assign load_funct3 = IR::load_funct3_t'(funct3);
assign store_funct3 = IR::store_funct3_t'(funct3);
assign is_funct7 = funct7[5];

always_comb
begin : trap_check_do_not_modify
    trap = 0;
    rmask = '0;
    wmask = '0;

    case (opcode)
        IR::op_lui, IR::op_auipc, IR::op_imm, IR::op_reg, IR::op_jal, IR::op_jalr:;

        IR::op_br: begin
            case (branch_funct3)
                IR::beq, IR::bne, IR::blt, IR::bge, IR::bltu, IR::bgeu:;
                default: trap = 1;
            endcase
        end

        IR::op_load: begin
            case (load_funct3)
                IR::lw: rmask = 4'b1111;
                IR::lh, IR::lhu: rmask = 4'b0011;
                IR::lb, IR::lbu: rmask = 4'b0001;
                default: trap = 1;
            endcase
        end

        IR::op_store: begin
            case (store_funct3)
                IR::sw: wmask = 4'b1111;
                IR::sh: wmask = 4'b0011;
                IR::sb: wmask = 4'b0001;
                default: trap = 1;
            endcase
        end

        default: trap = 1;
    endcase
end




// decode: get next state for different opcodes
always_comb 
begin
    decode_next_states = fetch_next;
    case (opcode)
        // (I type): ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI
        IR::op_imm  : decode_next_states = imm;
        // (B type): BEQ, BNE, BLT, BGE, BLTU, BGEU
        IR::op_br   : decode_next_states = br;
        // (I type): LB, LH, LW, LBU, LHU
        IR::op_load : decode_next_states = ld1;
        // (S type): SB, SH, SW
        IR::op_store: decode_next_states = st1;
        // (R type): ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND
        IR::op_reg  : decode_next_states = regs;
        // (U type): LUI
        IR::op_lui  : decode_next_states = lui;
        // (U type): AUIPC
        IR::op_auipc  : decode_next_states = auipc;  
        // (J type): JAL 
        IR::op_jal  : decode_next_states = jal1;
        // (I type): JALR
        IR::op_jalr  : decode_next_states = jalr1;
		default : ;
    endcase
end
/*****************************************************************************/


always_comb
begin 
    /* Default outputs assignments */
    set_defaults();
    /* Actions for each state */
    case (state)
        fetch1: begin       // PC -> MAR
            load_mar = 1'b1;     
            next_states = fetch2;
        end
        fetch2: begin       // memory[MAR] -> MDR
            mem_read = 1'b1;
            load_mdr = 1'b1;    
            next_states = mem_resp ? fetch3 : fetch2;
        end        
        fetch3: begin       // MDR  -> IR
            load_ir = 1'b1;     
            next_states = decode;
        end         
        decode: begin
            next_states = trap ? fetch_next : decode_next_states;
        end          
        fetch_next: begin  // PC = PC + 4
            load_pc = 1'b1;
            next_states = fetch1;
        end      
        
        imm: begin
            // alumax: default
            case(arith_funct3)
                IR::slt : begin     // set less than
                    cmpop = CMP::blt; 
                    cmpmux1_sel = CMP::i_imm;
                    regfilemux1_sel = Regfile::br_take;
                end
                IR::sltu : begin    // set less than unsigned
                    cmpop = CMP::bltu; 
                    cmpmux1_sel = CMP::i_imm;
                    regfilemux1_sel = Regfile::br_take;                
                end
                IR::sr : begin
                    if(is_funct7) 
                        aluop = ALU::_sra;  // shift right algorithm
                end
				default : ;
            endcase
            load_regfile = 1'b1;
            load_pc = 1'b1;
            next_states = fetch1;
        end

        regs: begin
            alumux2_sel = ALU::rs2_out;
            case(arith_funct3)
                IR::slt : begin     // set less than
                    cmpop = CMP::blt; 
                    cmpmux1_sel = CMP::rs2_out;
                    regfilemux1_sel = Regfile::br_take;
                end
                IR::sltu : begin    // set less than unsigned
                    cmpop = CMP::bltu; 
                    cmpmux1_sel = CMP::rs2_out;
                    regfilemux1_sel = Regfile::br_take;                
                end
                IR::sr : begin
                    if(is_funct7) 
                        aluop = ALU::_sra;  // shift right algorithm
                end
                IR::add : begin
                    if(is_funct7) 
                        aluop = ALU::_sub;  //sub
                end
				default :;
            endcase
            load_regfile = 1'b1;
            load_pc = 1'b1;
            next_states = fetch1;
        end

        br: begin       // branch
            ALU_add(ALU::pc_out, ALU::b_imm);
            pcmux1_sel = br_take ? PC::alu_mod2 : PC::pc_plus4;
            load_pc = 1'b1;
            next_states = fetch1;
        end        

        ld1: begin      // load from mem
            ALU_add(ALU::rs1_out, ALU::i_imm);
            marmux1_sel = MAR::alu_out;
            load_mar = 1'b1;
            next_states = ld2;
        end

        ld2: begin
            mem_read = 1'b1;
            load_mdr = 1'b1;
            next_states = mem_resp ? ld3 : ld2;
        end
        ld3: begin
            regfilemux1_sel = Regfile::ld;
            load_regfile = 1'b1;
            load_pc = 1'b1;
            next_states = fetch1;
        end 

        st1: begin
            ALU_add(ALU::rs1_out, ALU::s_imm);
            marmux1_sel = MAR::alu_out;
            load_mar = 1'b1;
            next_states = st2;
        end 
        st2: begin
            load_wmdr = 1'b1;
            next_states = st3;
        end   
        st3: begin
            mem_write = 1'b1;
            if (mem_resp) begin
                load_pc = 1'b1;
                next_states = fetch1;
            end
            else begin
                next_states = st3;
            end
        end   
        lui: begin      // load upper immediate
            regfilemux1_sel = Regfile::u_imm;
            load_regfile = 1'b1;
            load_pc = 1'b1;
            next_states = fetch1;
        end        
        auipc: begin    // add upper imme to PC
            ALU_add(ALU::pc_out, ALU::u_imm);
            load_regfile = 1'b1;
            load_pc = 1'b1;
            next_states = fetch1;
        end   

        jal1: begin    // jump and link
            regfilemux1_sel = Regfile::pc_plus4;
            load_regfile = 1'b1;
            next_states = jal2;
        end   
        jal2: begin    // jump and link
            ALU_add(ALU::pc_out, ALU::j_imm);
            pcmux1_sel = PC::alu_mod2;
            load_pc = 1'b1;
            next_states = fetch1;
        end   

        jalr1: begin    
            regfilemux1_sel = Regfile::pc_plus4;
            load_regfile = 1'b1;
            next_states = jalr2;
        end   
        jalr2: begin    
            ALU_add(ALU::rs1_out, ALU::i_imm);
            pcmux1_sel = PC::alu_mod2;
            load_pc = 1'b1;
            next_states = fetch1;
        end   
        default :;
    endcase
end


always_ff @(posedge clk)
begin: next_state_assignment
    state <= next_states;
end

endmodule
