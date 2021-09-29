module test_vga();
timeunit 10ns;	
timeprecision 1ns;
logic         clock;
logic         reset;



reg [11:0] color;
logic [9:0] x;
logic [9:0] y;
logic [3:0] R, G, B;
logic HS, VS;

vga vga2(.*);


/////////////////////////////////////////

always begin : CLOCK_GENERATION
#1 clock = ~clock;
end
initial begin: CLOCK_INITIALIZATION
    clock = 0;
end 
initial begin: TEST_VECTORS
/////////////////////////////////////////



reset = 1;
#2;
reset = 0;

color = 12'hfff;

#2000;







end


endmodule



