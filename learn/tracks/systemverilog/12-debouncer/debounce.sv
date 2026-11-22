// Exercise 12 · Debouncer + edge detector
module debounce #(
    parameter int N = 4  // noisy must differ from clean for N consecutive cycles before clean follows it
) (
    input  logic clk,
    input  logic rst_n,  // async active-low: clean = 0, counter = 0
    input  logic noisy,  // bouncy push-button input
    output logic clean,  // debounced level
    output logic rise,   // high for exactly one cycle: the first cycle in which clean is 1
    output logic fall    // high for exactly one cycle: the first cycle in which clean is 0 again
);
  // Rules, evaluated at each rising clock edge:
  //   noisy == clean            -> counter = 0
  //   differs and counter==N-1  -> clean = noisy, counter = 0
  //   differs otherwise         -> counter + 1
  // TODO: implement the counter + clean register, and an extra register clean_q (clean delayed
  //       by one cycle) for the edge detector: rise = clean & ~clean_q, fall = ~clean & clean_q
  assign clean = noisy;  // no debouncing at all - replace me
  assign rise  = 1'b0;
  assign fall  = 1'b0;
endmodule
