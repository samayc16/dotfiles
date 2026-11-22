// Testbench for exercise 12 (read-only): bouncy presses vs a cycle-accurate model, for N=4 and N=1.
module tb;
  logic clk, rst_n, noisy;
  logic c4, r4, f4, c1, r1, f1;

  debounce #(.N(4)) u4 (.clk, .rst_n, .noisy, .clean(c4), .rise(r4), .fall(f4));
  debounce #(.N(1)) u1 (.clk, .rst_n, .noisy, .clean(c1), .rise(r1), .fall(f1));

`ifdef DUMP
  initial begin $dumpfile("wave.vcd"); $dumpvars(0, tb); end
`endif

  initial clk = 0;
  always #5 clk = ~clk;

  // reference model state
  logic m4, m4q, m1, m1q;
  int   k4, k1;

  task automatic model_step();
    m4q = m4;
    if (noisy == m4) k4 = 0;
    else if (k4 == 3) begin m4 = noisy; k4 = 0; end
    else k4++;
    m1q = m1;
    if (noisy != m1) m1 = noisy;
  endtask

  task automatic cycle(logic v);
    @(negedge clk);
    noisy = v;
    @(posedge clk);
    model_step();
    #1;
    tbu::check("N=4 clean", c4, m4);
    tbu::check("N=4 rise", r4, m4 & ~m4q);
    tbu::check("N=4 fall", f4, ~m4 & m4q);
    tbu::check("N=1 clean", c1, m1);
    tbu::check("N=1 rise", r1, m1 & ~m1q);
    tbu::check("N=1 fall", f1, ~m1 & m1q);
  endtask

  task automatic bounce_to(logic v);
    repeat ($urandom_range(1, 5)) cycle(1'($urandom));  // contact bounce
    repeat ($urandom_range(4, 9)) cycle(v);              // settles
  endtask

  initial begin
    noisy = 0;
    {m4, m4q, m1, m1q} = '0;
    k4 = 0;
    k1 = 0;
    rst_n = 0;
    #3 rst_n = 1;
    tbu::group("short glitches are ignored");
    cycle(1); cycle(0); cycle(1); cycle(1); cycle(0); cycle(0);
    tbu::group("a clean press and release");
    repeat (6) cycle(1);
    repeat (6) cycle(0);
    tbu::group("40 bouncy presses");
    repeat (40) begin
      bounce_to(1);
      bounce_to(0);
    end
    tbu::finish();
  end
endmodule
