/** mem_data_out
 *  shift reg values according to ST opcodes, store in register
 *  does not support unaligned memory store between words (it will do circular shift)
**/
module st_unit(in,store_funct3,mem_address,wmask,out);

    input Global::size_t in;
    input IR::store_funct3_t store_funct3;
    input Global::size_t mem_address;

    output logic [3:0] wmask;
    output Global::size_t out;

    logic [3:0] wmask_;

    always_comb begin
        case (store_funct3)
            IR::sw: wmask_ = 4'b1111;
            IR::sh: wmask_ = 4'b0011;
            IR::sb: wmask_ = 4'b0001;
            default : wmask_ = 4'b0;
        endcase

        case (mem_address[1:0])
            2'b01 : begin
                out = {in[23:0], in[31:24]};
                wmask = {wmask_[2],wmask_[1],wmask_[0],wmask_[3]};
            end
            2'b10 : begin
                out = {in[15:0], in[31:16]};
                wmask = {wmask_[1],wmask_[0],wmask_[3],wmask_[2]};
            end
            2'b11 : begin
                out = {in[7:0], in[31:8]};
                wmask = {wmask_[0],wmask_[3],wmask_[2],wmask_[1]};
            end
            default : begin
                out = in;
                wmask = wmask_;
            end
        endcase
    end
        
endmodule
