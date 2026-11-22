// Testbench for exercise 21 (read-only).
module tb;
  import workers_pkg::*;

  initial begin
    Workers w = new();
    event   ev;
    time    t0;
    int     x;

    tbu::group("produce: 1..n, one per time unit");
    t0 = $time;
    w.produce(4);
    tbu::check("time taken by produce(4)", $time - t0, 4);
    tbu::check("items in the mailbox", w.mb.num(), 4);
    void'(w.mb.try_get(x));
    tbu::check("first item", x, 1);
    while (w.mb.try_get(x)) ;

    tbu::group("consume blocks until items arrive");
    fork
      begin
        #3;
        for (int i = 1; i <= 3; i++) w.mb.put(10 * i);
      end
    join_none
    t0 = $time;
    w.consume(3);
    tbu::check("sum of 10+20+30", w.sum, 60);
    tbu::check("consume waited for the producer", $time - t0, 3);

    tbu::group("run_pipeline: producer and consumer in parallel");
    t0 = $time;
    w.run_pipeline(10);
    tbu::check("sum of 1..10", w.sum, 55);
    tbu::check("ran in parallel (10 time units, not 20)", $time - t0, 10);
    tbu::check("mailbox drained", w.mb.num(), 0);

    tbu::group("wait_or_timeout");
    fork
      #5 ->ev;
    join_none
    t0 = $time;
    w.wait_or_timeout(ev, 20);
    tbu::check("event arrived first: got_event", w.got_event, 1);
    tbu::check("returned as soon as the event fired", $time - t0, 5);
    t0 = $time;
    w.wait_or_timeout(ev, 7);
    tbu::check("no event: got_event", w.got_event, 0);
    tbu::check("gave up after the limit", $time - t0, 7);
    tbu::finish();
  end
endmodule
