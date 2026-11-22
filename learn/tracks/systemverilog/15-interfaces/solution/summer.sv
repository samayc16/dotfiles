// Exercise 15 · Stream sink (reference solution)
module summer (
    input  logic        rst_n,
    input  logic        stall,
    stream_if.sink      s,
    output logic [15:0] sum,
    output logic [7:0]  beats
);
  assign s.ready = !stall;

  always_ff @(posedge s.clk or negedge rst_n) begin
    if (!rst_n) begin
      sum   <= '0;
      beats <= '0;
    end else if (s.valid && s.ready) begin
      sum   <= sum + 16'(s.data);
      beats <= beats + 1'b1;
    end
  end
endmodule
