// Testbench for exercise 07 (read-only). Inputs change on the falling edge; outputs are checked
// just after the rising edge (or just after an asynchronous reset, with no clock edge at all).
module tb;
  logic       clk, rst_n, srst, en;
  logic [7:0] d, q_async, q_sync;

  regs dut (.*);

`ifdef DUMP
  initial begin $dumpfile("wave.vcd"); $dumpvars(0, tb); end
`endif

  initial clk = 0;
  always #5 clk = ~clk;

  task automatic tick();
    @(posedge clk);
    #1;
  endtask

  initial begin
    rst_n = 1;
    srst  = 0;
    en    = 1;
    d     = 8'h3C;
    @(negedge clk);

    tbu::group("loading");
    tick();
    tbu::check("q_async loads d when en=1", q_async, 8'h3C);
    tbu::check("q_sync loads d", q_sync, 8'h3C);

    tbu::group("clock enable");
    @(negedge clk);
    en = 0;
    d  = 8'hA5;
    tick();
    tbu::check("q_async holds when en=0", q_async, 8'h3C);
    tbu::check("q_sync ignores en", q_sync, 8'hA5);

    tbu::group("asynchronous reset");
    @(negedge clk);
    #2 rst_n = 0;  // mid-cycle, far from any rising edge
    #1;
    tbu::check("q_async clears immediately on rst_n=0 (no clock edge)", q_async, 8'h00);
    tbu::check("q_sync is not affected by rst_n", q_sync, 8'hA5);
    en = 1;
    tick();
    tbu::check("q_async stays 0 while rst_n=0", q_async, 8'h00);
    @(negedge clk);
    rst_n = 1;
    d = 8'h42;
    tick();
    tbu::check("q_async loads again after reset", q_async, 8'h42);

    tbu::group("synchronous reset");
    @(negedge clk);
    srst = 1;
    #1;
    tbu::check("q_sync does NOT reset before the clock edge", q_sync, 8'h42);
    tick();
    tbu::check("q_sync resets to 8'hFF on the clock edge", q_sync, 8'hFF);
    tbu::check("q_async is not affected by srst", q_async, 8'h42);
    @(negedge clk);
    srst = 0;
    d = 8'h17;
    tick();
    tbu::check("q_sync loads again after srst", q_sync, 8'h17);
    tbu::finish();
  end
endmodule
