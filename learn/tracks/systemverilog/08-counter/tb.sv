// Testbench for exercise 08 (read-only): a decade counter (W=4, MAX=9) and a 0..99 counter
// (W=7, MAX=99), both compared against a reference model every cycle.
module tb;
  logic       clk, rst_n, en, load;
  logic [3:0] lv4, c4;
  logic [6:0] lv7, c7;
  logic       tc4, tc7;

  counter #(.W(4), .MAX(9))  u_dec (.clk, .rst_n, .en, .load, .load_val(lv4), .count(c4), .tc(tc4));
  counter #(.W(7), .MAX(99)) u_100 (.clk, .rst_n, .en, .load, .load_val(lv7), .count(c7), .tc(tc7));

`ifdef DUMP
  initial begin $dumpfile("wave.vcd"); $dumpvars(0, tb); end
`endif

  initial clk = 0;
  always #5 clk = ~clk;

  int m4, m7;  // reference model

  task automatic step(logic e, logic l, int v4, int v7);
    @(negedge clk);
    en   = e;
    load = l;
    lv4  = 4'(v4);
    lv7  = 7'(v7);
    #1;
    tbu::check($sformatf("decade: tc (count=%0d en=%0b)", m4, e), tc4, e && m4 == 9);
    tbu::check($sformatf("0..99: tc (count=%0d en=%0b)", m7, e), tc7, e && m7 == 99);
    @(posedge clk);
    #1;
    if (l) begin m4 = v4; m7 = v7; end
    else if (e) begin m4 = (m4 == 9) ? 0 : m4 + 1; m7 = (m7 == 99) ? 0 : m7 + 1; end
    tbu::check("decade: count", c4, m4);
    tbu::check("0..99: count", c7, m7);
  endtask

  initial begin
    {en, load, lv4, lv7} = '0;
    rst_n = 0;
    m4 = 0;
    m7 = 0;
    #12 rst_n = 1;
    tbu::group("reset value");
    tbu::check("decade: count after reset", c4, 0);
    tbu::group("counting + wrap");
    repeat (25) step(1, 0, 0, 0);
    tbu::group("enable low holds");
    repeat (3) step(0, 0, 0, 0);
    tbu::group("load (priority over en)");
    step(1, 1, 7, 97);
    repeat (4) step(1, 0, 0, 0);
    tbu::group("random en/load");
    repeat (300) step(1'($urandom_range(0, 3) != 0), 1'($urandom_range(0, 15) == 0), $urandom_range(0, 9), $urandom_range(0, 99));
    tbu::finish();
  end
endmodule
