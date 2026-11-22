// Testbench for exercise 20 (read-only): 2000 randomizations, every rule checked, plus distribution.
module tb;
  import txn_pkg::*;

  initial begin
    BusTxn t = new();
    int    n_kind[3] = '{0, 0, 0};
    int    bad[4] = '{0, 0, 0, 0};
    int    distinct_addrs;
    bit    seen[bit [15:0]];

    tbu::group("2000 randomize() calls obey the rules");
    repeat (2000) begin
      tbu::check_true("randomize() succeeded", t.randomize() == 1);
      n_kind[t.kind]++;
      seen[t.addr] = 1;
      if (t.addr[1:0] != 0) bad[0]++;
      if (t.kind != IDLE && (t.addr < 16'h1000 || t.addr > 16'h1FFF)) bad[1]++;
      if (t.kind == IDLE && t.addr != 0) bad[1]++;
      if (t.kind == IDLE ? t.len != 0 : (t.len < 1 || t.len > 8)) bad[2]++;
    end
    tbu::check("rule 1 violations (alignment)", bad[0], 0);
    tbu::check("rule 2 violations (address range)", bad[1], 0);
    tbu::check("rule 3 violations (len)", bad[2], 0);

    tbu::group("distribution (READ:WRITE:IDLE ~ 4:4:1)");
    $display("  READ=%0d WRITE=%0d IDLE=%0d", n_kind[0], n_kind[1], n_kind[2]);
    tbu::check_true("IDLE is 5-20% of transactions", n_kind[2] > 100 && n_kind[2] < 400);
    tbu::check_true("READ is 35-55%", n_kind[0] > 700 && n_kind[0] < 1100);
    tbu::check_true("WRITE is 35-55%", n_kind[1] > 700 && n_kind[1] < 1100);
    distinct_addrs = seen.num();
    tbu::check_true($sformatf("not over-constrained: %0d distinct addresses (need > 200)", distinct_addrs),
                    distinct_addrs > 200);

    tbu::group("inline constraints: randomize() with {...}");
    repeat (20) begin
      tbu::check_true("randomize() with {kind == WRITE; len == 8;}",
                      t.randomize() with {kind == WRITE; len == 8;} == 1);
      tbu::check("kind", t.kind, WRITE);
      tbu::check("len", t.len, 8);
      tbu::check_true("addr still obeys the class constraints", t.addr[1:0] == 0 && t.addr >= 16'h1000 && t.addr <= 16'h1FFF);
    end
    tbu::finish();
  end
endmodule
