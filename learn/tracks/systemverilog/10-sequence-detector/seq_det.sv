// Exercise 10 · Sequence detector: a Moore FSM that spots 1011 (overlaps allowed)
module seq_det (
    input  logic clk,
    input  logic rst_n,  // async active-low reset -> IDLE
    input  logic din,    // one bit per clock, sampled on the rising edge
    output logic found   // 1 while the last four bits received were 1,0,1,1 (oldest first)
);
  // Each state remembers how much of "1011" we've matched so far.
  typedef enum logic [2:0] {
    IDLE,   // nothing useful yet
    S1,     // seen ...1
    S10,    // seen ...10
    S101,   // seen ...101
    S1011   // seen ...1011  -> found
  } state_t;

  state_t state, next;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) state <= IDLE;
    else state <= next;
  end

  always_comb begin
    next = state;  // default: stay
    // TODO: unique case (state) with one arm per state; look at din to pick `next`
  end

  assign found = 1'b0;  // TODO: Moore output depends only on the state
endmodule
