// instruction register
module ir (clk,load,in,funct3,funct7,opcode,i_imm,s_imm,b_imm,u_imm,j_imm,rs1,rs2,rd);

    input logic clk;
    input logic load;         // instruction fetch
    input Global::size_t in;

    output IR::funct3_t funct3;
    output IR::funct7_t funct7;
    output IR::rv32i_opcode_t opcode;
    output Global::size_t i_imm, s_imm, b_imm, u_imm, j_imm;
    output IR::reg_t rs1, rs2, rd;  // source register and destination register


    Global::size_t data;
    always_ff @(posedge clk) begin
        if (load == 1)
            data <= in;
    end

    always_comb begin 
        funct3 = data[14:12];
        funct7 = data[31:25];
        opcode = IR::rv32i_opcode_t'(data[6:0]);
        i_imm = {{21{data[31]}}, data[30:20]};
        s_imm = {{21{data[31]}}, data[30:25], data[11:7]};
        b_imm = {{20{data[31]}}, data[7], data[30:25], data[11:8], 1'b0};
        u_imm = {data[31:12], 12'h000};
        j_imm = {{12{data[31]}}, data[19:12], data[20], data[30:21], 1'b0};
        rs1 = data[19:15];
        rs2 = data[24:20];
        rd = data[11:7];
    end



endmodule 
