// Simple Dual-Port Block RAM with One Clock
// read data next clock
module ram (
    input               clock,
    input               a_en, b_en, a_write_en,
    input [9:0]         a_addr, b_addr,
    input [7:0]         a_wdata,
    output reg [7:0]    a_rdata, b_rdata,
    output logic [1:0]   test
);

    reg [7:0] mem [1023:0]; 

        
    initial	begin
        $readmemh("D:/local/Desktop/vivado_proj/verilog/main/ram.hex", mem);
    end

    always @(posedge clock) begin 
        if(a_en) begin 
            if (a_write_en) mem[a_addr] <= a_wdata;
        end
    end

    always @(posedge clock) begin 
        if (a_en) a_rdata <= mem[a_addr];
        if (b_en) b_rdata <= mem[b_addr];
    end

    always_comb begin 
        if (a_en) 
            test = 2'b10;  
        else 
            test = 2'b01;
        if (b_en) 
            test = 2'b11;
    end

endmodule


