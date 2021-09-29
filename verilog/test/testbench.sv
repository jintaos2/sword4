module testbench();
timeunit 10ns;	
timeprecision 1ns;
logic         clk;


top top1(.*);


/////////////////////////////////////////

always begin : CLOCK_GENERATION
#1 clk = ~clk;
end
initial begin: CLOCK_INITIALIZATION
    clk = 0;
end 
initial begin: TEST_VECTORS
/////////////////////////////////////////






#200;







end


endmodule

