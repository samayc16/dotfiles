// Exercise 21 · Mailboxes, fork/join, events (reference solution)
package workers_pkg;
  class Workers;
    mailbox #(int) mb = new();
    int sum;
    bit got_event;

    task produce(int n);
      for (int i = 1; i <= n; i++) begin
        #1;
        mb.put(i);
      end
    endtask

    task consume(int n);
      int x;
      sum = 0;
      repeat (n) begin
        mb.get(x);
        sum += x;
      end
    endtask

    task run_pipeline(int n);
      fork
        produce(n);
        consume(n);
      join
    endtask

    task wait_or_timeout(event ev, int limit);
      got_event = 0;
      fork
        begin
          fork
            begin
              @(ev);
              got_event = 1;
            end
            #(limit);
          join_any
          disable fork;
        end
      join
    endtask
  endclass
endpackage
