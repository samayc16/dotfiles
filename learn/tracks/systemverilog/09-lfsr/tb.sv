// Testbench for exercise 09 (read-only): sequence vs model, enable, two seeds, full period.
module tb;
  logic       clk, rst_n, en;
  logic [7:0] q1, qa;

  lfsr #(.SEED(8'h01)) u1 (.clk, .rst_n, .en, .q(q1));
  lfsr #(.SEED(8'hA5)) ua (.clk, .rst_n, .en, .q(qa));

`ifdef DUMP
  initial begin $dumpfile("wave.vcd"); $dumpvars(0, tb); end
`endif

  initial clk = 0;
  always #5 clk = ~clk;

  function automatic logic [7:0] nxt(logic [7:0] x);
    return {x[6:0], x[7] ^ x[5] ^ x[4] ^ x[3]};
  endfunction

  initial begin
    logic [7:0] m1, ma;
    int period;
    en = 0;
    rst_n = 0;
    #12 rst_n = 1;
    tbu::group("reset loads SEED");
    tbu::check("SEED=8'h01", q1, 8'h01);
    tbu::check("SEED=8'hA5", qa, 8'hA5);

    tbu::group("first 40 steps match the polynomial");
    m1 = 8'h01;
    ma = 8'hA5;
    @(negedge clk) en = 1;
    for (int i = 0; i < 40; i++) begin
      @(posedge clk);
      #1;
      m1 = nxt(m1);
      ma = nxt(ma);
      tbu::check($sformatf("step %0d (seed 01)", i + 1), q1, m1);
      tbu::check($sformatf("step %0d (seed A5)", i + 1), qa, ma);
    end

    tbu::group("en=0 holds the state");
    @(negedge clk) en = 0;
    repeat (3) @(posedge clk);
    #1;
    tbu::check("held", q1, m1);

    tbu::group("maximal period (255)");
    rst_n = 0;
    #1 rst_n = 1;
    @(negedge clk) en = 1;
    period = 0;
    do begin
      @(posedge clk);
      #1;
      period++;
    end while (q1 != 8'h01 && period < 300);
    tbu::check("steps until the seed comes back", period, 255);
    tbu::finish();
  end
endmodule
