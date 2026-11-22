// Exercise 21 · Concurrency in testbenches: mailboxes, fork/join, events
package workers_pkg;
  class Workers;
    mailbox #(int) mb = new();  // unbounded mailbox of ints
    int sum;                    // result of consume()
    bit got_event;              // result of wait_or_timeout()

    // Put the numbers 1..n into mb, waiting #1 (1 time unit) BEFORE each put.
    task produce(int n);
      // TODO
    endtask

    // Take exactly n numbers out of mb (get blocks until one is available); store their total in sum.
    task consume(int n);
      sum = 0;
      // TODO
    endtask

    // Run produce(n) and consume(n) at the same time, and return when BOTH are done.
    task run_pipeline(int n);
      // TODO: fork ... join
    endtask

    // Wait for `ev`, but give up after `limit` time units. got_event = 1 if the event came first.
    // Use the guarded-fork idiom so disable fork only kills YOUR two branches:
    //   fork begin
    //     fork <branch A> <branch B> join_any
    //     disable fork;
    //   end join
    task wait_or_timeout(event ev, int limit);
      got_event = 0;
      // TODO
    endtask
  endclass
endpackage
