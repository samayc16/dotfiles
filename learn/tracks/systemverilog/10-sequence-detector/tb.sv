// Testbench for exercise 10 (read-only): hand-picked streams, then 600 random bits.
module tb;
  logic clk, rst_n, din, found;

  seq_det dut (.*);

`ifdef DUMP
  initial begin $dumpfile("wave.vcd"); $dumpvars(0, tb); end
`endif

  initial clk = 0;
  always #5 clk = ~clk;

  logic [3:0] hist;  // last 4 bits, newest in bit 0
  int         n;     // bits since reset

  task automatic send(logic b);
    @(negedge clk);
    din = b;
    @(posedge clk);
    #1;
    hist = {hist[2:0], b};
    n++;
    tbu::check($sformatf("bit #%0d (last four: %04b): found", n, hist), found, n >= 4 && hist == 4'b1011);
  endtask

  task automatic stream(string bits);
    foreach (bits[i]) send(bits[i] == "1");
  endtask

  task automatic reset();
    rst_n = 0;
    #3 rst_n = 1;
    hist = '0;
    n = 0;
  endtask

  initial begin
    din = 0;
    reset();
    tbu::group("1011");
    stream("1011");
    tbu::group("overlap: 1011011 has two matches");
    reset();
    stream("1011011");
    tbu::group("near misses: 1001 1010 1100 1111");
    reset();
    stream("1001101011001111");
    tbu::group("600 random bits");
    reset();
    repeat (600) send(1'($urandom));
    tbu::finish();
  end
endmodule
