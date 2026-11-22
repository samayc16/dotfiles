// Testbench for exercise 02 (read-only): corner cases + 200 random vectors.
module tb;
  logic [7:0]  a, b;
  logic [7:0]  both, swapped, reversed;
  logic        parity, all_ones, any_set;
  logic [15:0] sign_extended;

  vectors dut (.*);

`ifdef DUMP
  initial begin $dumpfile("wave.vcd"); $dumpvars(0, tb); end
`endif

  function automatic logic [7:0] rev(logic [7:0] x);
    for (int i = 0; i < 8; i++) rev[i] = x[7-i];
  endfunction

  task automatic apply(logic [7:0] va, logic [7:0] vb);
    string s;
    a = va;
    b = vb;
    #1;
    s = $sformatf("a=8'h%02h b=8'h%02h", va, vb);
    tbu::check({s, ": both"}, both, va & vb);
    tbu::check({s, ": swapped"}, swapped, {va[3:0], va[7:4]});
    tbu::check({s, ": parity"}, parity, $countones(va) % 2);
    tbu::check({s, ": all_ones"}, all_ones, va == 8'hFF);
    tbu::check({s, ": any_set"}, any_set, va != 0);
    tbu::check({s, ": sign_extended"}, sign_extended, $unsigned(16'($signed(va))));
    tbu::check({s, ": reversed"}, reversed, rev(va));
  endtask

  initial begin
    tbu::group("corner cases");
    apply(8'h00, 8'h00);
    apply(8'hFF, 8'h0F);
    apply(8'h80, 8'hFF);
    apply(8'h7F, 8'hAA);
    apply(8'h01, 8'h55);
    tbu::group("random vectors");
    repeat (200) apply(8'($urandom), 8'($urandom));
    tbu::finish();
  end
endmodule
