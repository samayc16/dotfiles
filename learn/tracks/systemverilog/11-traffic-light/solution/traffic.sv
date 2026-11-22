// Exercise 11 · Traffic light (reference solution)
module traffic
  import traffic_pkg::*;
#(
    parameter int GREEN_T  = 5,
    parameter int YELLOW_T = 2,
    parameter int RED_T    = 4
) (
    input  logic   clk,
    input  logic   rst_n,
    output color_t light,
    output logic   walk
);
  logic [7:0] timer;

  function automatic logic [7:0] last_cycle(color_t c);
    unique case (c)
      RED:     return 8'(RED_T - 1);
      GREEN:   return 8'(GREEN_T - 1);
      YELLOW:  return 8'(YELLOW_T - 1);
      default: return '0;
    endcase
  endfunction

  function automatic color_t after(color_t c);
    unique case (c)
      RED:     return GREEN;
      GREEN:   return YELLOW;
      default: return RED;
    endcase
  endfunction

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      light <= RED;
      timer <= '0;
    end else if (timer == last_cycle(light)) begin
      light <= after(light);
      timer <= '0;
    end else begin
      timer <= timer + 1'b1;
    end
  end

  assign walk = (light == RED);
endmodule
