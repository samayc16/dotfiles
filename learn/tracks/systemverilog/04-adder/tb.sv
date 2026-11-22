// Testbench for exercise 04 (read-only): two instances, W=8 (exhaustive-ish) and W=16 (random).
module tb;
  logic [7:0]  a8, b8, s8;
  logic [15:0] a16, b16, s16;
  logic        cin, c8, c16, v8, v16;

  adder #(.W(8))  u8  (.a(a8),  .b(b8),  .cin(cin), .sum(s8),  .cout(c8),  .overflow(v8));
  adder #(.W(16)) u16 (.a(a16), .b(b16), .cin(cin), .sum(s16), .cout(c16), .overflow(v16));

`ifdef DUMP
  initial begin $dumpfile("wave.vcd"); $dumpvars(0, tb); end
`endif

  task automatic check8(logic [7:0] x, logic [7:0] y, logic ci);
    logic [8:0] full;
    logic       ovf;
    a8 = x;
    b8 = y;
    cin = ci;
    #1;
    full = {1'b0, x} + {1'b0, y} + 9'(ci);
    ovf  = (x[7] == y[7]) && (full[7] != x[7]);
    tbu::check($sformatf("W=8  %0d+%0d+%0d: sum", x, y, ci), s8, full[7:0]);
    tbu::check($sformatf("W=8  %0d+%0d+%0d: cout", x, y, ci), c8, full[8]);
    tbu::check($sformatf("W=8  %0d+%0d+%0d: overflow", $signed(x), $signed(y), ci), v8, ovf);
  endtask

  task automatic check16(logic [15:0] x, logic [15:0] y, logic ci);
    logic [16:0] full;
    logic        ovf;
    a16 = x;
    b16 = y;
    cin = ci;
    #1;
    full = {1'b0, x} + {1'b0, y} + 17'(ci);
    ovf  = (x[15] == y[15]) && (full[15] != x[15]);
    tbu::check($sformatf("W=16 %0d+%0d+%0d: sum", x, y, ci), s16, full[15:0]);
    tbu::check($sformatf("W=16 %0d+%0d+%0d: cout", x, y, ci), c16, full[16]);
    tbu::check($sformatf("W=16 %0d+%0d+%0d: overflow", $signed(x), $signed(y), ci), v16, ovf);
  endtask

  initial begin
    a16 = 0;
    b16 = 0;
    tbu::group("W=8 every 7th pair, both carries");
    for (int x = 0; x < 256; x += 7)
      for (int y = 0; y < 256; y += 5) begin
        check8(8'(x), 8'(y), 0);
        check8(8'(x), 8'(y), 1);
      end
    tbu::group("W=8 corners");
    check8(8'hFF, 8'h01, 0);
    check8(8'h7F, 8'h01, 0);
    check8(8'h80, 8'h80, 0);
    check8(8'hFF, 8'hFF, 1);
    tbu::group("W=16 random");
    repeat (300) check16(16'($urandom), 16'($urandom), 1'($urandom));
    check16(16'h7FFF, 16'h0001, 0);
    check16(16'hFFFF, 16'h0000, 1);
    tbu::finish();
  end
endmodule
