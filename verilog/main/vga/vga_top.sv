module vga_top (
    input  logic CLK_200M_P,CLK_200M_N,  // main clock
    input  logic RSTN,                   // reset button
    output logic [4:0] BTN_X,	         // matrix button line select
    input  logic [4:0] BTN_Y,	         // matrix button line data
    output logic LEDCLK,                 // clock of 16 leds
    output logic LEDDT,                  // led data
    output logic [3:0] vga_blue,
    output logic [3:0] vga_green,
    output logic [3:0] vga_red,
    output logic vga_hs, vga_vs
);

    /****************************************************************************
                                       clock
    ****************************************************************************/
    wire clk200MHz, clk100MHz,  clk50MHz, clk25MHz, clk10MHz;
    // clock diff
    IBUFGDS #(.DIFF_TERM("FALSE"), .IBUF_LOW_PWR("TRUE"), .IOSTANDARD("DEFAULT")) 
    IBUFGDS_inst (.O(clk200MHz), .I(CLK_200M_P), .IB(CLK_200M_N));
    // multiple clock signals
    my_clk_gen clk_gen0 (
        .clkin1(clk200MHz),
        .CLK_OUT1(clk100MHz), //100MHz
        .CLK_OUT2(clk50MHz),  //50MHz
        .CLK_OUT3(clk25MHz),  //25MHz
        .CLK_OUT4(clk10MHz)   //10MHz
    );
    wire clock = clk200MHz;
    /****************************************************************************
                                      reset
    ****************************************************************************/
	reg reset;
	reg [15:0] rst_count = 16'hFFFF;              // shift regester, debounce
	always_ff @(posedge clock) begin
		reset <= (rst_count != 0);
		rst_count <= {rst_count[14:0], !RSTN};    // RSTN = 0 when press
	end   
    /****************************************************************************
                                matrix button 
    ****************************************************************************/
    logic [4:0] btn, btn_;    
    assign BTN_X = 5'b01111;      // select first line of button (5 buttons)
    always_ff @(posedge clock or posedge reset) begin
        if(reset) begin 
            btn <= '0;
            btn_ <= '0;
        end else begin
            btn_ <= ~BTN_Y;       // read first line of button
            btn  <= {btn_[0], btn_[1], btn_[2], btn_[3], btn_[4]};  // reverse     
        end
    end
    /****************************************************************************
                                       leds 
    ****************************************************************************/
    logic [15:0] leds, leds_next;
    logic [11:0] leds_counter;   

    assign LEDDT =  leds[~leds_counter[4:1]];                         // select data bit: 16 - n
    assign LEDCLK = leds_counter < 6'b100000 ?  leds_counter[0] : 0;  // update data at start 

    always_ff @(posedge clock or posedge reset) begin
        if(reset) begin 
            leds <= 0;
            leds_counter <= 0;
        end else begin
            leds <=  leds_counter == 12'hF00 ? leds_next:leds;        // load during display
            leds_counter ++;         
        end
    end
    assign leds_next = {11'b11110000111, btn};
    /****************************************************************************
                                       vga 
    ****************************************************************************/
    logic [11:0] color;
    logic [9:0]  vga_x, vga_y;
    vga vga0(
        .clock(clk25MHz), 
        .reset(reset),
        .color(color), 
        .x(vga_x), 
        .y(vga_y),
        .R(vga_red), 
        .G(vga_green), 
        .B(vga_blue), 
        .HS(vga_hs), 
        .VS(vga_vs)
    );

    reg [0:7] [7:0] vga_test_ram =  64'h001c3636363c301c;
    logic vga_in = vga_test_ram[vga_y[2:0]][vga_x[2:0]];
    always_ff @( posedge clock ) begin
        if(reset) 
            color <= 0;
        else begin
            if( (vga_x == 0 || vga_x == 639) || (vga_y == 0 || vga_y == 479) )  
                color <= 12'h00f;
            else  
                color <= {12{vga_in}};
        end
    end


    
endmodule



module  vga(
    input  clock,				// clock = 25MHz
	input  reset,
	input  logic [11:0] color,  // bbbb_gggg_rrrr, pixel
	output logic [9:0] x,		// pixel ram col address, 640 (1024) pixels
	output logic [9:0] y,		// pixel ram row address, 480 (512) lines
	output logic [3:0] R, G, B, // red, green, blue colors
	output logic HS, VS			// horizontal and vertical synchronization
); 
				
    localparam H_PULSE = 96;             
    localparam H_START = H_PULSE + 47;    // 48 is standard 
    localparam H_END   = H_START + 640;
    localparam H_TOTAL = 800;
    localparam V_PULSE = 2;
    localparam V_START = V_PULSE + 33;  
    localparam V_END   = V_START + 480;
    localparam V_TOTAL = 525;

    logic [9:0] h_count;  // h_count: VGA horizontal counter (0-799)
    logic [9:0] v_count;  // v_count: VGA vertical counter (0-524)
    always_ff @ (posedge clock or posedge reset) begin
        if (reset) begin
            h_count <= 0;
            v_count <= 0;
        end else begin 
            h_count <= h_count == H_TOTAL-1 ? 0 : h_count + 1;
            if (h_count == H_TOTAL-1) begin
                v_count <= v_count == V_TOTAL-1 ? 0 : v_count + 1;
            end
        end
    end

    logic valid;
    always_ff @ (posedge clock or posedge reset) begin
        if (reset) begin 
            HS <= 0; 
            VS <= 0;
            R <= 0; 
            G <= 0; 
            B <= 0; 
            valid <= 0;
        end else begin
            HS <= h_count > H_PULSE-1;        //  96 -> 799
            VS <= v_count > V_PULSE-1;        //   2 -> 524  
            // output valid area, should be 640 x 480
            // sword4.0 : for some reason signal of the first column should hold on for two cycle 
            valid <= ((h_count > H_START-2) && (h_count < H_END)) && ((v_count > V_START-1) && (v_count < V_END)); 
            R <= valid ? color[3:0]  : 0;
            G <= valid ? color[7:4]  : 0;
            B <= valid ? color[11:8] : 0; 
        end
    end

    //  read pixel ram
    always_comb begin
        x = (h_count <  H_START) ? 0   :
            (h_count >= H_END)   ? 639 : 
            (h_count -  H_START) ;           // 143 -> 782  ===>  0 ~ 639
        y = (v_count <  V_START) ? 0   :
            (v_count >= V_END)   ? 479 : 
            (v_count -  V_START) ;           //  35 -> 514  ===>  0 ~ 479
    end
endmodule



