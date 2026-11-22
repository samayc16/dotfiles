// Exercise 05 · Priority encoder
module prio_enc (
    input  logic [7:0] req,
    output logic [2:0] idx,   // index of the HIGHEST set bit of req
    output logic       valid  // 1 if any bit of req is set
);
  always_comb begin
    idx   = '0;    // defaults first: every path now assigns both outputs (no latch)
    valid = 1'b0;
    // TODO: find the highest set bit of req
  end
endmodule
