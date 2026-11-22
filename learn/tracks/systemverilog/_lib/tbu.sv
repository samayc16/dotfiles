// tbu: tiny testbench utilities shared by every exercise in this track.
//
//   tbu::group("adds");                  start a named group of checks
//   tbu::check("sum", got, expected);    compare (up to 128 bits), report mismatches
//   tbu::finish();                       print summary; $fatal on any failure
//
// Output contract with check.sh: a passing run prints "ALL TESTS PASSED".
//
// Gotcha: arguments are widened to 128 bits, and SIGNED values (int, $signed(x), N'(some_int))
// are sign-extended. Pass unsigned values: $unsigned(8'(my_int)) or a logic [7:0] variable.
package tbu;
  int    n_checks = 0;
  int    n_errors = 0;
  int    g_checks = 0;
  int    g_errors = 0;
  string g_name   = "";

  function automatic void end_group();
    if (g_name != "")
      $display("%s: %s (%0d checks)", g_errors == 0 ? "PASS" : "FAIL", g_name, g_checks);
    g_name = "";
  endfunction

  function automatic void group(string name);
    end_group();
    g_name   = name;
    g_checks = 0;
    g_errors = 0;
  endfunction

  function automatic void check(string what, logic [127:0] got, logic [127:0] expected);
    n_checks++;
    g_checks++;
    if (got !== expected) begin
      n_errors++;
      g_errors++;
      if (g_errors <= 5)
        $display("  FAIL %s: got %0d (0x%0h), expected %0d (0x%0h)", what, got, got, expected, expected);
      else if (g_errors == 6)
        $display("  ... more failures in this group not shown");
    end
  endfunction

  function automatic void check_true(string what, bit cond);
    check(what, 128'(cond), 128'(1));
  endfunction

  task automatic finish();
    end_group();
    if (n_errors == 0) begin
      $display("ALL TESTS PASSED (%0d checks)", n_checks);
      $finish;
    end else begin
      $fatal(1, "%0d of %0d checks FAILED", n_errors, n_checks);
    end
  endtask
endpackage
