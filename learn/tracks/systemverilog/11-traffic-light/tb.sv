// Testbench for exercise 11 (read-only): default timings (4/5/2) and an every-cycle light (1/1/1).
module tb;
  import traffic_pkg::*;

  logic   clk, rst_n;
  color_t l_def, l_fast;
  logic   w_def, w_fast;

  traffic                                         u_def  (.clk, .rst_n, .light(l_def),  .walk(w_def));
  traffic #(.GREEN_T(1), .YELLOW_T(1), .RED_T(1)) u_fast (.clk, .rst_n, .light(l_fast), .walk(w_fast));

`ifdef DUMP
  initial begin $dumpfile("wave.vcd"); $dumpvars(0, tb); end
`endif

  initial clk = 0;
  always #5 clk = ~clk;

  // Expected colour in cycle i after reset for a light with the given durations.
  function automatic color_t model(int i, int r, int g, int y);
    int t = i % (r + g + y);
    if (t < r) return RED;
    if (t < r + g) return GREEN;
    return YELLOW;
  endfunction

  // After k rising edges since reset, the light must show model(k).
  task automatic run(string which, int edges, int r, int g, int y);
    for (int k = 0; k <= edges; k++) begin
      if (k > 0) @(posedge clk);
      #1;
      if (which == "def") begin
        tbu::check($sformatf("after %0d edges: light (%s expected)", k, model(k, r, g, y).name()), l_def, model(k, r, g, y));
        tbu::check($sformatf("after %0d edges: walk", k), w_def, model(k, r, g, y) == RED);
      end else begin
        tbu::check($sformatf("after %0d edges: light (%s expected)", k, model(k, r, g, y).name()), l_fast, model(k, r, g, y));
      end
    end
  endtask

  initial begin
    rst_n = 0;
    #3 rst_n = 1;
    tbu::group("default timing: RED 4, GREEN 5, YELLOW 2");
    run("def", 40, 4, 5, 2);
    tbu::group("fast timing: one cycle each");
    @(negedge clk);
    rst_n = 0;
    #1 rst_n = 1;
    run("fast", 12, 1, 1, 1);
    tbu::finish();
  end
endmodule
