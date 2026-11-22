// Testbench top for exercise 22 (read-only).
// +MODE=good  : correct FIFO, your scoreboard must match >= 100 pops with 0 mismatches
// +MODE=buggy : the FIFO corrupts data, your scoreboard must notice (num_mismatches > 0)
module tb;
  import fifo_tb_pkg::*;

  logic clk;
  logic bug_en;
  initial clk = 0;
  always #5 clk = ~clk;

  fifo_if bus (clk);
  fifo dut (
      .clk,
      .rst_n (bus.rst_n),
      .push  (bus.push),
      .din   (bus.din),
      .pop   (bus.pop),
      .dout  (bus.dout),
      .full  (bus.full),
      .empty (bus.empty),
      .count (bus.count),
      .bug_en
  );

`ifdef DUMP
  initial begin $dumpfile("wave.vcd"); $dumpvars(0, tb); end
`endif

  initial begin
    string mode;
    Env    env;
    if (!$value$plusargs("MODE=%s", mode)) mode = "good";
    bug_en    = (mode == "buggy");
    bus.push  = 0;
    bus.pop   = 0;
    bus.din   = '0;
    bus.rst_n = 0;
    #12 bus.rst_n = 1;

    env = new(bus);
    env.run(500);
    $display("  scoreboard: %0d num_matches, %0d num_mismatches, saw_full=%0b saw_empty=%0b",
             env.sb.num_matches, env.sb.num_mismatches, env.sb.saw_full, env.sb.saw_empty);
    if (mode == "buggy") begin
      tbu::group("buggy FIFO: the scoreboard must catch the corruption");
      tbu::check_true("num_mismatches > 0", env.sb.num_mismatches > 0);
      tbu::check_true("and it still matched the healthy pops (num_matches > 50)", env.sb.num_matches > 50);
    end else begin
      tbu::group("correct FIFO: everything must match");
      tbu::check_true("compared at least 100 pops", env.sb.num_matches >= 100);
      tbu::check("mismatches", env.sb.num_mismatches, 0);
      tbu::check_true("the monitor saw the FIFO full", env.sb.saw_full);
      tbu::check_true("the monitor saw the FIFO empty", env.sb.saw_empty);
    end
    tbu::finish();
  end
endmodule
