// Exercise 11 · Traffic light: an FSM with a timer
module traffic
  import traffic_pkg::*;  // brings color_t (RED, GREEN, YELLOW) into scope
#(
    parameter int GREEN_T  = 5,  // number of clock cycles spent in each colour
    parameter int YELLOW_T = 2,
    parameter int RED_T    = 4
) (
    input  logic   clk,
    input  logic   rst_n,  // async active-low reset: RED, timer cleared
    output color_t light,
    output logic   walk    // pedestrians may cross: high exactly while light is RED
);
  // Sequence: RED (RED_T cycles) -> GREEN (GREEN_T) -> YELLOW (YELLOW_T) -> RED -> ...
  logic [7:0] timer;  // cycles spent in the current colour so far

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      light <= RED;
      timer <= '0;
    end else begin
      // TODO: when timer reaches (duration of current colour) - 1, switch colour and clear timer;
      //       otherwise increment timer
      timer <= timer + 1'b1;
    end
  end

  assign walk = 1'b0;  // TODO
endmodule
