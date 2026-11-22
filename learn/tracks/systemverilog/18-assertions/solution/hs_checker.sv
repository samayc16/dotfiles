// Exercise 18 · Assertions (reference solution)
module hs_checker (
    input logic       clk,
    input logic       rst_n,
    input logic       req,
    input logic       ack,
    input logic [3:0] gnt
);
  always_comb begin
    a_gnt_onehot : assert ($onehot0(gnt))
    else $error("more than one grant: gnt=%b", gnt);
  end

  a_ack_in_time : assert property (@(posedge clk) disable iff (!rst_n) $rose(req) |-> ##[1:3] ack)
  else $error("req was not acknowledged within 3 cycles");

  a_no_spurious_ack : assert property (@(posedge clk) disable iff (!rst_n) ack |-> $past(req))
  else $error("ack without a request");

  a_req_held : assert property (@(posedge clk) disable iff (!rst_n) req && !ack |=> req)
  else $error("req dropped before it was acknowledged");
endmodule
