// Testbench for exercise 15 (read-only): a source that respects valid/ready, random stalls.
module tb;
  logic        clk, rst_n, stall;
  logic [15:0] sum;
  logic [7:0]  beats;

  stream_if #(.W(8)) bus (clk);
  summer dut (.rst_n, .stall, .s(bus.sink), .sum, .beats);

`ifdef DUMP
  initial begin $dumpfile("wave.vcd"); $dumpvars(0, tb); end
`endif

  initial clk = 0;
  always #5 clk = ~clk;

  int msum, mbeats;

  initial begin
    bus.valid = 0;
    bus.data  = '0;
    stall     = 0;
    rst_n     = 0;
    msum      = 0;
    mbeats    = 0;
    #3 rst_n = 1;

    tbu::group("ready follows stall");
    stall = 1;
    #1 tbu::check("stall=1 -> ready", bus.ready, 0);
    stall = 0;
    #1 tbu::check("stall=0 -> ready", bus.ready, 1);

    tbu::group("200 cycles of handshakes");
    repeat (200) begin
      @(negedge clk);
      // a well-behaved source keeps valid+data stable until the beat is accepted
      if (!bus.valid || bus.ready) begin
        bus.valid = 1'($urandom_range(0, 3) != 0);
        bus.data  = 8'($urandom);
      end
      stall = 1'($urandom_range(0, 2) == 0);
      #1;
      tbu::check("ready == !stall", bus.ready, !stall);
      @(posedge clk);
      if (bus.valid && !stall) begin
        msum += int'(bus.data);
        mbeats++;
      end
      #1;
      tbu::check("sum", sum, $unsigned(16'(msum)));
      tbu::check("beats", beats, $unsigned(8'(mbeats)));
    end
    tbu::finish();
  end
endmodule
