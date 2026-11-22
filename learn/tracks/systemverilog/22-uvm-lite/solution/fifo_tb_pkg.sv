// Exercise 22 · Boss: a UVM-style testbench (reference solution)
//
//   Driver ---pins---> [ FIFO ] ---pins---> Monitor ---mailbox---> Scoreboard
//
// The Driver and Env are done. Write the Monitor and the Scoreboard.
package fifo_tb_pkg;

  // One random stimulus item.
  class FifoTxn;
    rand bit       push;
    rand bit       pop;
    rand bit [7:0] data;
  endclass

  // Drives random push/pop traffic. Inputs change on the falling edge (provided).
  class Driver;
    virtual fifo_if vif;

    function new(virtual fifo_if vif);
      this.vif = vif;
    endfunction

    task run(int n);
      FifoTxn t = new();
      repeat (n) begin
        @(negedge vif.clk);
        void'(t.randomize());
        vif.push = t.push;
        vif.pop  = t.pop;
        vif.din  = t.data;
      end
      @(negedge vif.clk);
      vif.push = 0;
      vif.pop  = 0;
    endtask
  endclass

  // What the monitor saw at ONE rising clock edge (values from just BEFORE the edge).
  class Observation;
    bit       pushed;  // a push was accepted: push && !full
    bit [7:0] din;
    bit       popped;  // a pop was accepted: pop && !empty
    bit [7:0] dout;    // the value that left the FIFO
    bit       full;
    bit       empty;
  endclass

  // TODO: forever: wait for a rising edge of vif.clk, then (in the same time step, before the
  // flops update) read push/pop/din/dout/full/empty, fill a NEW Observation and put it in to_sb.
  class Monitor;
    virtual fifo_if vif;
    std::mailbox #(Observation) to_sb;

    function new(virtual fifo_if vif, std::mailbox #(Observation) to_sb);
      this.vif   = vif;
      this.to_sb = to_sb;
    endfunction

    task run();
      forever begin
        Observation o;
        @(posedge vif.clk);
        o        = new();
        o.full   = vif.full;
        o.empty  = vif.empty;
        o.pushed = vif.push && !vif.full;
        o.din    = vif.din;
        o.popped = vif.pop && !vif.empty;
        o.dout   = vif.dout;
        to_sb.put(o);
      end
    endtask
  endclass

  // TODO: forever: get an Observation and check it against a reference queue model:
  //   * popped -> compare o.dout with the oldest model entry (pop_front); count matches / num_mismatches,
  //               and $display("SCOREBOARD MISMATCH: ...") on a mismatch
  //   * pushed -> push_back(o.din)   (handle the pop first: both can happen at the same edge)
  //   * remember whether you ever saw full / empty
  class Scoreboard;
    std::mailbox #(Observation) from_mon;
    bit [7:0] model[$];
    int num_matches = 0;
    int num_mismatches = 0;
    bit saw_full = 0;
    bit saw_empty = 0;

    function new(std::mailbox #(Observation) from_mon);
      this.from_mon = from_mon;
    endfunction

    task run();
      forever begin
        Observation o;
        from_mon.get(o);
        if (o.full) saw_full = 1;
        if (o.empty) saw_empty = 1;
        if (o.popped) begin
          if (model.size() == 0) begin
            num_mismatches++;
            $display("SCOREBOARD MISMATCH: pop from an empty model");
          end else begin
            bit [7:0] expected = model.pop_front();
            if (o.dout == expected) num_matches++;
            else begin
              num_mismatches++;
              $display("SCOREBOARD MISMATCH: dout=%02h expected=%02h", o.dout, expected);
            end
          end
        end
        if (o.pushed) model.push_back(o.din);
      end
    endtask
  endclass

  // Builds and connects the components (provided).
  class Env;
    Driver drv;
    Monitor mon;
    Scoreboard sb;
    std::mailbox #(Observation) mon2sb;

    function new(virtual fifo_if vif);
      mon2sb = new();
      drv    = new(vif);
      mon    = new(vif, mon2sb);
      sb     = new(mon2sb);
    endfunction

    task run(int n);
      fork
        mon.run();
        sb.run();
      join_none
      drv.run(n);
      repeat (3) @(posedge drv.vif.clk);
      #1;
    endtask
  endclass
endpackage
