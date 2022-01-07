module test_ram();
timeunit 10ns;	
timeprecision 1ns;
logic         clock;
logic         reset;



logic        clock;
logic        a_en, b_en, a_write_en;
logic [9:0]  a_addr, b_addr;
logic [7:0]  a_wdata;
logic [7:0]  a_rdata, b_rdata;
logic [1:0]  test;

ram ram1(.*);


/////////////////////////////////////////

always begin : CLOCK_GENERATION
#1 clock = ~clock;
end
initial begin: CLOCK_INITIALIZATION
    clock = 0;
end 
initial begin: TEST_VECTORS
/////////////////////////////////////////

a_en = 1;
a_write_en = 0;
a_wdata = 0;
b_en = 1;
a_addr = 0;
b_addr = 0;

#2;





end


endmodule

