/*
 * memory
 */
 

module memory(clk,read,write,wmask,address,wdata,resp,rdata);

    input logic clk;
    input logic read, write;
    input logic [3:0] wmask;
    input logic [31:0] address;
    input logic [31:0] wdata;
    output logic resp;
    output logic [31:0] rdata;


    Global::size_t ram[0:16'hffff];

    initial begin
         $readmemh("D:/local/Desktop/sword_start/sword_start.srcs/sources_1/new/rv/memory.lst", ram);
        //$display("0x00: %h", ram[0]);
    end

    enum int unsigned{
        idle, busy, exec, respond
    } state, next_state;
    int unsigned count = 0;
    int unsigned next_count;

    always @(posedge clk) begin
        next_state = state;
        next_count = count;
        resp = 1'b0;  

        unique case(state)
            idle: begin 
                if (read | write) begin 
                    next_state = busy;
                    next_count = 1;
                end
            end
            busy: begin
                next_count = count + 1;
                next_state = count == 10 ? exec : busy;
            end
            exec: begin
                if(write)
                    ram[address] <= wdata;
                if(read)
                    rdata <= ram[address];
                next_state = respond;
            end
            respond: begin
                next_state = idle;
                resp = 1'b1;
            end
        endcase
    end

    always_ff @(posedge clk) begin
        state <= next_state;
        count <= next_count;
    end

endmodule
