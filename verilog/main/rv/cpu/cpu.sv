`define BAD_MUX_SEL $fatal("%0t %s %0d: Illegal mux select", $time, `__FILE__, `__LINE__)

module cpu (clk,mem_resp,mem_rdata,mem_read,mem_write,mem_byte_enable,mem_address,mem_wdata);
	Global::size_t  cmpmux1_out;
	Global::size_t  alumux2_out;
	Global::size_t  alumux1_out;
	Global::size_t  regfilemux1_out;
	Global::size_t  marmux1_out;
	Global::size_t  pcmux1_out;
	PC::mux1  control_pcmux1_sel;
	ALU::mux1  control_alumux1_sel;
	ALU::mux2  control_alumux2_sel;
	Regfile::mux1  control_regfilemux1_sel;
	MAR::mux1  control_marmux1_sel;
	CMP::mux1  control_cmpmux1_sel;
	ALU::ops  control_aluop;
	CMP::ops  control_cmpop;
	logic  control_load_pc;
	logic  control_load_ir;
	logic  control_load_regfile;
	logic  control_load_mar;
	logic  control_load_mdr;
	logic  control_load_wmdr;
	logic  control_mem_read;
	logic  control_mem_write;
	Global::size_t  pc_out;
	Global::size_t  mar_out;
	Global::size_t  mdr_out;
	Global::size_t  wmdr_out;
	Global::size_t  ld_unit_out;
	logic [3:0]  st_unit_wmask;
	Global::size_t  st_unit_out;
	IR::funct3_t  ir_funct3;
	IR::funct7_t  ir_funct7;
	IR::rv32i_opcode_t  ir_opcode;
	Global::size_t  ir_i_imm;
	Global::size_t  ir_s_imm;
	Global::size_t  ir_b_imm;
	Global::size_t  ir_u_imm;
	Global::size_t  ir_j_imm;
	IR::reg_t  ir_rs1;
	IR::reg_t  ir_rs2;
	IR::reg_t  ir_rd;
	Global::size_t  regfile_reg_a;
	Global::size_t  regfile_reg_b;
	Global::size_t  alu_out;
	logic  cmp_br_take;

    input logic clk;
    input logic mem_resp;
    input Global::size_t mem_rdata;
    output logic mem_read;
    output logic mem_write;
    output logic [3:0] mem_byte_enable;
    output Global::size_t mem_address;
    output Global::size_t mem_wdata;

    /**************************** Control Signals ********************************/
    control control(
	.clk(clk),
	.mem_resp(mem_resp),
	.opcode(ir_opcode),
	.funct3(ir_funct3),
	.funct7(ir_funct7),
	.br_take(cmp_br_take),
	.pcmux1_sel(control_pcmux1_sel),
	.alumux1_sel(control_alumux1_sel),
	.alumux2_sel(control_alumux2_sel),
	.regfilemux1_sel(control_regfilemux1_sel),
	.marmux1_sel(control_marmux1_sel),
	.cmpmux1_sel(control_cmpmux1_sel),
	.aluop(control_aluop),
	.cmpop(control_cmpop),
	.load_pc(control_load_pc),
	.load_ir(control_load_ir),
	.load_regfile(control_load_regfile),
	.load_mar(control_load_mar),
	.load_mdr(control_load_mdr),
	.load_wmdr(control_load_wmdr),
	.mem_read(control_mem_read),
	.mem_write(control_mem_write));
    

    always_comb begin
        mem_read = control_mem_read;
        mem_write = control_mem_write;
        mem_address = mar_out;
    end

    /**************************** PC ********************************/
    register pc(
	.clk(clk),
	.load(control_load_pc),
	.in(pcmux1_out),
	.out(pc_out));

    Global::size_t  pc_plus4;
    assign pc_plus4 = pc_out + 4;

	always_comb begin
		unique case(control_pcmux1_sel)
			PC::pc_plus4 : pcmux1_out = pc_plus4;
			PC::alu_out : pcmux1_out = alu_out;
			PC::alu_mod2 : pcmux1_out = {alu_out[31:1],1'b0};
		endcase
	end

    /**************************** MAR ********************************/

	always_comb begin
		unique case(control_marmux1_sel)
			MAR::pc_out : marmux1_out = pc_out;
			MAR::alu_out : marmux1_out = alu_out;
		endcase
	end

    register mar(
	.clk(clk),
	.load(control_load_mar),
	.in(marmux1_out),
	.out(mar_out));

    /**************************** MDR ********************************/
    register mdr(
	.clk(clk),
	.load(control_load_mdr),
	.in(mem_rdata),
	.out(mdr_out));
    // write memory data register
    register wmdr(
	.clk(clk),
	.load(control_load_wmdr),
	.in(st_unit_out),
	.out(wmdr_out));

    ld_unit ld_unit(
	.in(mdr_out),
	.load_funct3(IR::load_funct3_t'(ir_funct3)),
	.mem_address(mem_address),
	.out(ld_unit_out));

    st_unit st_unit(
	.in(regfile_reg_b),
	.store_funct3(IR::store_funct3_t'(ir_funct3)),
	.mem_address(mem_address),
	.wmask(st_unit_wmask),
	.out(st_unit_out));

    assign mem_byte_enable = st_unit_wmask & {mem_write,mem_write,mem_write,mem_write};
    /**************************** IR ********************************/ 
    ir ir(
	.clk(clk),
	.load(control_load_ir),
	.in(mdr_out),
	.funct3(ir_funct3),
	.funct7(ir_funct7),
	.opcode(ir_opcode),
	.i_imm(ir_i_imm),
	.s_imm(ir_s_imm),
	.b_imm(ir_b_imm),
	.u_imm(ir_u_imm),
	.j_imm(ir_j_imm),
	.rs1(ir_rs1),
	.rs2(ir_rs2),
	.rd(ir_rd));

    /**************************** regfile ********************************/

	always_comb begin
		unique case(control_regfilemux1_sel)
			Regfile::alu_out : regfilemux1_out = alu_out;
			Regfile::pc_plus4 : regfilemux1_out = pc_plus4;
			Regfile::br_take : regfilemux1_out = {31'b0,cmp_br_take};
			Regfile::u_imm : regfilemux1_out = ir_u_imm;
			Regfile::ld : regfilemux1_out = ld_unit_out;
		endcase
	end

    regfile regfile(
	.clk(clk),
	.load(control_load_regfile),
	.in(regfilemux1_out),
	.src_a(ir_rs1),
	.src_b(ir_rs2),
	.dest(ir_rd),
	.reg_a(regfile_reg_a),
	.reg_b(regfile_reg_b));

    /**************************** alu ********************************/

	always_comb begin
		unique case(control_alumux1_sel)
			ALU::rs1_out : alumux1_out = regfile_reg_a;
			ALU::pc_out : alumux1_out = pc_out;
		endcase
	end

	always_comb begin
		unique case(control_alumux2_sel)
			ALU::i_imm : alumux2_out = ir_i_imm;
			ALU::u_imm : alumux2_out = ir_u_imm;
			ALU::b_imm : alumux2_out = ir_b_imm;
			ALU::s_imm : alumux2_out = ir_s_imm;
			ALU::j_imm : alumux2_out = ir_j_imm;
			ALU::rs2_out : alumux2_out = regfile_reg_b;
		endcase
	end

    alu alu(
	.aluop(control_aluop),
	.a(alumux1_out),
	.b(alumux2_out),
	.out(alu_out));

    /**************************** cmp ********************************/

	always_comb begin
		unique case(control_cmpmux1_sel)
			CMP::rs2_out : cmpmux1_out = regfile_reg_b;
			CMP::i_imm : cmpmux1_out = ir_i_imm;
		endcase
	end

    cmp cmp(
	.cmpop(control_cmpop),
	.a(regfile_reg_a),
	.b(cmpmux1_out),
	.br_take(cmp_br_take));

endmodule 
