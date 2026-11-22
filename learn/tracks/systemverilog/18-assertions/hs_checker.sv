// Exercise 18 · Assertions: a protocol checker for a request/acknowledge bus
//
// The protocol:
//   * the requester raises req and keeps it high until (and including) the cycle ack is high
//   * the arbiter answers with a one-cycle ack, 1 to 3 cycles after req rose
//   * ack never appears unless req was high in the previous cycle
//   * at most one of the four grant lines gnt[3:0] is high at any time
module hs_checker (
    input logic       clk,
    input logic       rst_n,
    input logic       req,
    input logic       ack,
    input logic [3:0] gnt
);
  // TODO: write these four NAMED assertions. The testbench injects one violation per run and checks
  //       that the matching name fires, so spell the labels exactly:
  //
  //   a_gnt_onehot       immediate, inside always_comb    at most one gnt bit set      ($onehot0)
  //   a_ack_in_time      concurrent   req rose -> ack 1..3 cycles later               ($rose, |->, ##[1:3])
  //   a_no_spurious_ack  concurrent   ack -> req was high the cycle before            ($past)
  //   a_req_held         concurrent   req && !ack -> req is still high next cycle     (|=>)
  //
  // Concurrent template:
  //   a_name: assert property (@(posedge clk) disable iff (!rst_n) <antecedent> |-> <consequent>);
endmodule
