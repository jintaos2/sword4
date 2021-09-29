

module top(clk);
	logic  cpu_mem_read;
	logic  cpu_mem_write;
	logic [3:0]  cpu_mem_byte_enable;
	Global::size_t  cpu_mem_address;
	Global::size_t  cpu_mem_wdata;
	logic  memory_resp;
	logic [31:0]  memory_rdata;


    input logic clk;


    cpu cpu(
	.clk(clk),
	.mem_resp(memory_resp),
	.mem_rdata(memory_rdata),
	.mem_read(cpu_mem_read),
	.mem_write(cpu_mem_write),
	.mem_byte_enable(cpu_mem_byte_enable),
	.mem_address(cpu_mem_address),
	.mem_wdata(cpu_mem_wdata));

    memory memory(
	.clk(clk),
	.read(cpu_mem_read),
	.write(cpu_mem_write),
	.address(cpu_mem_address),
	.wdata(cpu_mem_wdata),
	.resp(memory_resp),
	.rdata(memory_rdata));
    
endmodule 

