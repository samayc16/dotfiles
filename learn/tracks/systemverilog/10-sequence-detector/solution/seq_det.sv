// Exercise 10 · Sequence detector (reference solution)
module seq_det (
    input  logic clk,
    input  logic rst_n,
    input  logic din,
    output logic found
);
  typedef enum logic [2:0] {IDLE, S1, S10, S101, S1011} state_t;

  state_t state, next;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) state <= IDLE;
    else state <= next;
  end

  always_comb begin
    next = state;
    unique case (state)
      IDLE:  next = din ? S1 : IDLE;
      S1:    next = din ? S1 : S10;
      S10:   next = din ? S101 : IDLE;
      S101:  next = din ? S1011 : S10;
      S1011: next = din ? S1 : S10;  // overlap: the tail "1" or "10" starts a new match
      default: next = IDLE;
    endcase
  end

  assign found = (state == S1011);
endmodule
