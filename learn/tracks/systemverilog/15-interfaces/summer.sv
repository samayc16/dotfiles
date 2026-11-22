// Exercise 15 · A stream sink that sums what it accepts
module summer (
    input  logic        rst_n,  // async active-low: sum = 0, beats = 0
    input  logic        stall,  // 1 = refuse data this cycle
    stream_if.sink      s,      // the incoming stream (uses the sink modport)
    output logic [15:0] sum,    // sum of the data of every accepted beat since reset
    output logic [7:0]  beats   // number of accepted beats since reset
);
  // TODO: s.ready = !stall
  // TODO: a beat is accepted at a rising edge of s.clk when s.valid && s.ready
  assign s.ready = 1'b0;

  always_ff @(posedge s.clk or negedge rst_n) begin
    if (!rst_n) begin
      sum   <= '0;
      beats <= '0;
    end
  end
endmodule
