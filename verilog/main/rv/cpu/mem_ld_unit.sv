/** located between MDR and regfilemux.
 *  select correct bytes in a word for LD opcodes
 *  does not support unaligned memory access between words (it will do circular shift)
**/
module ld_unit(in,load_funct3,mem_address,out);

    input Global::size_t in;
    input IR::load_funct3_t load_funct3;
    input Global::size_t mem_address;
    output Global::size_t out;

    Global::size_t data_shifted;

    always_comb begin
        case (mem_address[1:0])
            2'b01 : data_shifted = {in[7:0], in[31:8]};
            2'b10 : data_shifted = {in[15:0], in[31:16]};
            2'b11 : data_shifted = {in[23:0], in[31:24]};
            default : data_shifted = in;
        endcase
    end 

    always_comb begin
        case (load_funct3)
            IR::lbu : out = {24'b0, data_shifted[7:0]};
            IR::lb  : out = {{24{data_shifted[7]}}, data_shifted[7:0]};
            IR::lhu : out = {16'b0, data_shifted[15:0]};
            IR::lh  : out = {{16{data_shifted[7]}}, data_shifted[15:0]};
            default : out = data_shifted;
        endcase
    end 

endmodule
