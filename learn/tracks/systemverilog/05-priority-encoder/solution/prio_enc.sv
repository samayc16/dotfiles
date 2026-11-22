// Exercise 05 · Priority encoder (reference solution)
module prio_enc (
    input  logic [7:0] req,
    output logic [2:0] idx,
    output logic       valid
);
  always_comb begin
    idx   = '0;
    valid = 1'b0;
    for (int i = 0; i < 8; i++) begin
      if (req[i]) begin
        idx   = 3'(i);  // later (higher) bits overwrite earlier ones
        valid = 1'b1;
      end
    end
  end
endmodule
