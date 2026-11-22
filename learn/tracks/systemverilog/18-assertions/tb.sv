// Testbench for exercise 18 (read-only).
// +MODE=good runs only legal traffic: no assertion may fire.
// +MODE=bad_* runs legal traffic, then injects ONE violation: the matching assertion must fire.
module tb;
  logic       clk, rst_n, req, ack;
  logic [3:0] gnt;

  hs_checker u_chk (.*);

`ifdef DUMP
  initial begin $dumpfile("wave.vcd"); $dumpvars(0, tb); end
`endif

  initial clk = 0;
  always #5 clk = ~clk;

  task automatic transaction(int latency, int hold_extra = 0);
    @(negedge clk);
    req = 1;
    gnt = 4'(1 << $urandom_range(0, 3));
    repeat (latency - 1 + hold_extra) @(negedge clk);
    @(negedge clk);
    ack = 1;           // req still high in the ack cycle
    @(negedge clk);
    ack = 0;
    req = 0;
    gnt = '0;
    repeat ($urandom_range(0, 2)) @(negedge clk);
  endtask

  initial begin
    string mode;
    if (!$value$plusargs("MODE=%s", mode)) mode = "good";
    {req, ack, gnt} = '0;
    rst_n = 0;
    #12 rst_n = 1;

    repeat (30) transaction($urandom_range(1, 3));

    case (mode)
      "bad_onehot": begin
        @(negedge clk);
        gnt = 4'b0110;
      end
      "bad_late": transaction(5);
      "bad_spurious": begin
        @(negedge clk);
        ack = 1;
        @(negedge clk);
        ack = 0;
      end
      "bad_drop": begin
        @(negedge clk);
        req = 1;
        @(negedge clk);
        req = 0;
      end
      default: ;
    endcase
    repeat (8) @(negedge clk);
    $display("ALL TESTS PASSED (no assertion fired in mode %s)", mode);
    $finish;
  end
endmodule
