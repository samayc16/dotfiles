// Exercise 20 · Constrained random stimulus
package txn_pkg;
  typedef enum bit [1:0] {
    READ,
    WRITE,
    IDLE
  } kind_e;

  class BusTxn;
    rand kind_e     kind;
    rand bit [15:0] addr;
    rand bit [3:0]  len;

    // TODO: constraint blocks (any names) so that EVERY randomize() result obeys:
    //   1. addr is word-aligned: the two low bits are 0
    //   2. READ and WRITE use addresses 16'h1000 .. 16'h1FFF; IDLE uses addr 0
    //   3. IDLE has len 0; READ and WRITE have len 1 .. 8
    //   4. READ and WRITE are each 4x as likely as IDLE
    //
    //   constraint c_name { expr; (cond) -> expr; x inside {[lo:hi]}; kind dist { READ := 4, ... }; }
  endclass
endpackage
