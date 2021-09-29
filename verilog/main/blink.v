module Hello(
  input   clock,
  input   reset,
  output  io_LEDCLK,
  output  io_LEDDT
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
`endif // RANDOMIZE_REG_INIT
  reg [31:0] cntReg; // @[Hello.scala 20:23]
  reg  blkReg; // @[Hello.scala 21:23]
  reg  clkReg; // @[Hello.scala 22:23]
  wire [31:0] _T_1 = cntReg + 32'h1; // @[Hello.scala 24:20]
  wire  _T_4 = ~clkReg; // @[Hello.scala 28:15]
  assign io_LEDCLK = clkReg; // @[Hello.scala 34:13]
  assign io_LEDDT = blkReg; // @[Hello.scala 33:12]
  always @(posedge clock) begin
    if (reset) begin // @[Hello.scala 20:23]
      cntReg <= 32'h0; // @[Hello.scala 20:23]
    end else if (cntReg == 32'h2faf07f) begin // @[Hello.scala 25:28]
      cntReg <= 32'h0; // @[Hello.scala 26:12]
    end else begin
      cntReg <= _T_1; // @[Hello.scala 24:10]
    end
    if (reset) begin // @[Hello.scala 21:23]
      blkReg <= 1'h0; // @[Hello.scala 21:23]
    end else if (cntReg == 32'h2faf07f) begin // @[Hello.scala 25:28]
      blkReg <= ~blkReg; // @[Hello.scala 27:12]
    end
    if (reset) begin // @[Hello.scala 22:23]
      clkReg <= 1'h0; // @[Hello.scala 22:23]
    end else if (cntReg == 32'h2faf07f) begin // @[Hello.scala 25:28]
      clkReg <= ~clkReg; // @[Hello.scala 28:12]
    end else if (cntReg == 32'h17d783f) begin // @[Hello.scala 30:34]
      clkReg <= _T_4; // @[Hello.scala 31:12]
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  cntReg = _RAND_0[31:0];
  _RAND_1 = {1{`RANDOM}};
  blkReg = _RAND_1[0:0];
  _RAND_2 = {1{`RANDOM}};
  clkReg = _RAND_2[0:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
