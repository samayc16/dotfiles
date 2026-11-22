// Testbench for exercise 06 (read-only): all 16 digits, drawn when wrong.
module tb;
  logic [3:0] hex;
  logic [6:0] seg;

  hex7seg dut (.*);

`ifdef DUMP
  initial begin $dumpfile("wave.vcd"); $dumpvars(0, tb); end
`endif

  localparam logic [6:0] EXPECTED[16] = '{
    7'h3F, 7'h06, 7'h5B, 7'h4F, 7'h66, 7'h6D, 7'h7D, 7'h07,
    7'h7F, 7'h6F, 7'h77, 7'h7C, 7'h39, 7'h5E, 7'h79, 7'h71
  };

  function automatic void draw(logic [6:0] s);
    $display("      %s", s[0] ? " ___ " : "     ");
    $display("      %s%s%s", s[5] ? "|" : " ", s[6] ? "___" : "   ", s[1] ? "|" : " ");
    $display("      %s%s%s", s[4] ? "|" : " ", s[3] ? "___" : "   ", s[2] ? "|" : " ");
  endfunction

  initial begin
    tbu::group("digits 0-F");
    for (int h = 0; h < 16; h++) begin
      hex = 4'(h);
      #1;
      if (seg !== EXPECTED[h]) begin
        $display("  digit %h: yours / expected", h);
        draw(seg);
        draw(EXPECTED[h]);
      end
      tbu::check($sformatf("hex=%h: seg", h), seg, EXPECTED[h]);
    end
    tbu::finish();
  end
endmodule
