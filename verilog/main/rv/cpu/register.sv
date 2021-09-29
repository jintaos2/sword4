

module register (clk,load,in,out);

    input logic clk, load;
    input Global::size_t in;
    output Global::size_t out;

    assign out = '0;
    always_ff @(posedge clk) begin
        if (load)
            out <= in;
    end

endmodule 
