// Testbench for exercise 16 (read-only): W=8 and W=12 instances, plus a peek inside the generate blocks.
module tb;
  logic [7:0]  a8, b8, s8;
  logic [11:0] a12, b12, s12;
  logic        cin, c8, c12;

  ripple_adder #(.W(8))  u8  (.a(a8),  .b(b8),  .cin, .sum(s8),  .cout(c8));
  ripple_adder #(.W(12)) u12 (.a(a12), .b(b12), .cin, .sum(s12), .cout(c12));

`ifdef DUMP
  initial begin $dumpfile("wave.vcd"); $dumpvars(0, tb); end
`endif

  initial begin
    logic [8:0]  e8;
    logic [12:0] e12;
    tbu::group("structure: g_bit[i].fa instances exist and are wired");
    a8 = 8'b0000_0100;
    b8 = 8'b0000_0100;
    cin = 0;
    a12 = '0;
    b12 = '0;
    #1;
    tbu::check("u8.g_bit[2].fa.cout (4+4 carries out of bit 2)", u8.g_bit[2].fa.cout, 1);
    tbu::check("u8.g_bit[3].fa.cin", u8.g_bit[3].fa.cin, 1);
    tbu::check("u12.g_bit[11].fa.s", u12.g_bit[11].fa.s, 0);

    tbu::group("W=8 and W=12 random sums");
    repeat (500) begin
      a8  = 8'($urandom);
      b8  = 8'($urandom);
      a12 = 12'($urandom);
      b12 = 12'($urandom);
      cin = 1'($urandom);
      #1;
      e8  = {1'b0, a8} + {1'b0, b8} + 9'(cin);
      e12 = {1'b0, a12} + {1'b0, b12} + 13'(cin);
      tbu::check($sformatf("W=8  %0d+%0d+%0d", a8, b8, cin), {c8, s8}, e8);
      tbu::check($sformatf("W=12 %0d+%0d+%0d", a12, b12, cin), {c12, s12}, e12);
    end
    tbu::finish();
  end
endmodule
