`timescale 1ns / 1ps


module sword_top(
    input wire CLK_200M_P,CLK_200M_N,
    input wire RSTN,
    output wire LEDCLK,
    output wire LEDDT
);    
    // clock 
    wire clk200MHz;
    CLK_DIFF clk_diff  (
        .clk200P(CLK_200M_P),
        .clk200N(CLK_200M_N),
        .clk200MHz(clk200MHz)
    );
	// reset
	reg rst_all;
	reg [15:0] rst_count = 16'hFFFF;
	always @(posedge clk200MHz) begin
		rst_all <= (rst_count != 0);
		rst_count <= {rst_count[14:0], (!RSTN)};
	end    
    
    
    
    Hello hello(
        .clock(clk200MHz),
        .reset(rst_all),
        .io_LEDCLK(LEDCLK),
        .io_LEDDT(LEDDT)
    );



endmodule




