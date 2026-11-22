// Exercise 06 · Hex digit to 7-segment display
//
//      a
//    -----        seg = {g, f, e, d, c, b, a}, 1 = segment lit
//  f|     |b
//   |  g  |       0 -> 7'b0111111 (a b c d e f lit, g dark)
//    -----        1 -> 7'b0000110 (b c)
//  e|     |c
//   |     |
//    -----
//      d
module hex7seg (
    input  logic [3:0] hex,
    output logic [6:0] seg
);
  always_comb begin
    case (hex)
      4'h0: seg = 7'b0111111;
      4'h1: seg = 7'b0000110;
      // TODO: 2 .. 9, then A b C d E F (lowercase b and d so they don't look like 8 and 0)
      default: seg = 7'b0000000;
    endcase
  end
endmodule
