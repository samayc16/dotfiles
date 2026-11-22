// Testbench for exercise 03 (read-only).
module tb;
  logic [7:0] d0, d1, d2, d3, y2, y4;
  logic       sel2;
  logic [1:0] sel4;

  mux dut (.*);

`ifdef DUMP
  initial begin $dumpfile("wave.vcd"); $dumpvars(0, tb); end
`endif

  initial begin
    {d0, d1, d2, d3} = {8'h11, 8'h22, 8'h33, 8'h44};
    tbu::group("2:1 mux (ternary)");
    for (int s = 0; s < 2; s++) begin
      sel2 = 1'(s);
      #1;
      tbu::check($sformatf("sel2=%0d: y2", s), y2, s ? d1 : d0);
    end
    tbu::group("4:1 mux (case)");
    repeat (20) begin
      {d0, d1, d2, d3} = {8'($urandom), 8'($urandom), 8'($urandom), 8'($urandom)};
      for (int s = 0; s < 4; s++) begin
        sel4 = 2'(s);
        #1;
        tbu::check($sformatf("sel4=%0d: y4", s), y4, s == 0 ? d0 : s == 1 ? d1 : s == 2 ? d2 : d3);
      end
    end
    tbu::finish();
  end
endmodule
