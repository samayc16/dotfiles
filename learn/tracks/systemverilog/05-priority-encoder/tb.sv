// Testbench for exercise 05 (read-only): all 256 request patterns.
module tb;
  logic [7:0] req;
  logic [2:0] idx;
  logic       valid;

  prio_enc dut (.*);

`ifdef DUMP
  initial begin $dumpfile("wave.vcd"); $dumpvars(0, tb); end
`endif

  initial begin
    tbu::group("all 256 inputs");
    for (int r = 0; r < 256; r++) begin
      automatic int hi = 0;
      req = 8'(r);
      #1;
      for (int i = 0; i < 8; i++) if (r[i]) hi = i;
      tbu::check($sformatf("req=8'b%08b: valid", req), valid, r != 0);
      if (r != 0) tbu::check($sformatf("req=8'b%08b: idx", req), idx, hi);
    end
    tbu::finish();
  end
endmodule
