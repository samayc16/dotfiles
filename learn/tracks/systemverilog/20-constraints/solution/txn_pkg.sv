// Exercise 20 · Constrained random (reference solution)
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

    constraint c_align {addr[1:0] == 2'b00;}

    constraint c_range {
      (kind != IDLE) -> addr inside {[16'h1000 : 16'h1FFF]};
      (kind == IDLE) -> addr == 16'h0000;
    }

    constraint c_len {
      (kind == IDLE) -> len == 0;
      (kind != IDLE) -> len inside {[1 : 8]};
    }

    constraint c_kind {kind dist {READ := 4, WRITE := 4, IDLE := 1};}
  endclass
endpackage
