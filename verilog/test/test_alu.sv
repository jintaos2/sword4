
module test_alu();

timeunit 10ns;	
timeprecision 1ns;
logic         clk;

     logic load;
     Global::size_t in;
     Global::size_t out;

register r(.*);

/////////////////////////////////////////
always begin 
#1 clk = ~clk;
end
initial begin
    clk = 0;
end 
/////////////////////////////////////////
initial begin

load = 0;
in = '0;

#2;

load = 1;
in = 32'haaaabbbb;

#40;



#40;




#200;







end


endmodule
