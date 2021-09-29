
module cmp (cmpop,a,b,br_take);

    input CMP::ops cmpop;
    input Global::size_t a, b;
    output logic br_take;

    logic equal, lessthan_signed, lessthan_unsigned;
    always_comb begin
        equal = a == b;
        lessthan_signed = signed'(a) < signed'(b);
        lessthan_unsigned = a < b;
        case (cmpop)
            CMP::beq : br_take = equal;
            CMP::bne : br_take = ~equal;
            CMP::blt : br_take = lessthan_signed;
            CMP::bge : br_take = ~lessthan_signed;
            CMP::bltu : br_take = lessthan_unsigned;
            CMP::bgeu : br_take = ~lessthan_unsigned;
            default : br_take = 1'b0;
        endcase
    end

endmodule
