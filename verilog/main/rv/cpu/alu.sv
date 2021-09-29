

module alu(aluop,a,b,out);

    input ALU::ops aluop;
    input Global::size_t a, b;
    output Global::size_t out;

    always_comb begin
        unique case (aluop)
            ALU::_add :  out = a + b;
            ALU::_sll :  out = a << b;
            ALU::_sra :  out = signed'(a) >>> b;
            ALU::_sub :  out = a - b;
            ALU::_xor :  out = a ^ b;
            ALU::_srl :  out = a >> b;
            ALU::_or  :  out = a | b;
            ALU::_and :  out = a & b;
        endcase
    end

endmodule 
