
module regfile (clk,load,in,src_a,src_b,dest,reg_a,reg_b);

    input logic clk, load;
    input Global::size_t in;
    input IR::reg_t src_a, src_b, dest;
    output Global::size_t reg_a, reg_b;

    logic [31:0] data [32] = '{default:'0};

    always_ff @(posedge clk)
    begin
        if (load && dest)
            data[dest] <= in;
    end

    always_comb
    begin
        reg_a = src_a ? data[src_a] : 0;
        reg_b = src_b ? data[src_b] : 0;
    end

endmodule
