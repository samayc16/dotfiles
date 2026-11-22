// Testbench for exercise 13 (read-only): two FIFOs (8x4 and 16x5) against a queue model,
// with fill-heavy and drain-heavy phases so full and empty both get hit.
module tb;
  logic        clk, rst_n, push, pop;
  logic [15:0] din;
  logic [7:0]  dout_a;
  logic [15:0] dout_b;
  logic        full_a, empty_a, full_b, empty_b;
  logic [2:0]  count_a, count_b;

  fifo #(.W(8),  .DEPTH(4)) ua (.clk, .rst_n, .push, .din(din[7:0]), .pop, .dout(dout_a),
                                .full(full_a), .empty(empty_a), .count(count_a));
  fifo #(.W(16), .DEPTH(5)) ub (.clk, .rst_n, .push, .din, .pop, .dout(dout_b),
                                .full(full_b), .empty(empty_b), .count(count_b));

`ifdef DUMP
  initial begin $dumpfile("wave.vcd"); $dumpvars(0, tb); end
`endif

  initial clk = 0;
  always #5 clk = ~clk;

  logic [15:0] qa[$], qb[$];  // reference models
  int hit_full, hit_empty;

  task automatic check_outputs();
    tbu::check("8x4: count", count_a, qa.size());
    tbu::check("8x4: full", full_a, qa.size() == 4);
    tbu::check("8x4: empty", empty_a, qa.size() == 0);
    if (qa.size() > 0) tbu::check("8x4: dout (oldest entry)", dout_a, qa[0][7:0]);
    tbu::check("16x5: count", count_b, qb.size());
    tbu::check("16x5: full", full_b, qb.size() == 5);
    tbu::check("16x5: empty", empty_b, qb.size() == 0);
    if (qb.size() > 0) tbu::check("16x5: dout (oldest entry)", dout_b, qb[0]);
  endtask

  task automatic cycle(logic pu, logic po);
    bit a_push, a_pop, b_push, b_pop;
    @(negedge clk);
    push = pu;
    pop  = po;
    din  = 16'($urandom);
    #1;
    check_outputs();
    if (qa.size() == 4) hit_full++;
    if (qa.size() == 0) hit_empty++;
    // the FIFO decides using its state BEFORE the edge
    a_push = pu && qa.size() < 4;
    a_pop  = po && qa.size() > 0;
    b_push = pu && qb.size() < 5;
    b_pop  = po && qb.size() > 0;
    @(posedge clk);
    if (a_pop) void'(qa.pop_front());
    if (a_push) qa.push_back(din);
    if (b_pop) void'(qb.pop_front());
    if (b_push) qb.push_back(din);
  endtask

  task automatic phase(string name, int cycles, int push_pct, int pop_pct);
    tbu::group(name);
    repeat (cycles) cycle(1'($urandom_range(0, 99) < push_pct), 1'($urandom_range(0, 99) < pop_pct));
  endtask

  initial begin
    {push, pop, din} = '0;
    rst_n = 0;
    #3 rst_n = 1;
    tbu::group("empty after reset");
    #1 check_outputs();
    phase("fill-heavy (push 80%, pop 20%)", 150, 80, 20);
    phase("drain-heavy (push 20%, pop 80%)", 150, 20, 80);
    phase("push and pop every cycle", 30, 100, 100);
    phase("random 50/50", 300, 50, 50);
    tbu::group("stimulus sanity");
    tbu::check_true("the stimulus reached full", hit_full > 0);
    tbu::check_true("the stimulus reached empty", hit_empty > 0);
    tbu::finish();
  end
endmodule
