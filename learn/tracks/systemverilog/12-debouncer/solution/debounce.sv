// Exercise 12 · Debouncer + edge detector (reference solution)
module debounce #(
    parameter int N = 4
) (
    input  logic clk,
    input  logic rst_n,
    input  logic noisy,
    output logic clean,
    output logic rise,
    output logic fall
);
  localparam int CW = $clog2(N + 1);
  localparam logic [CW-1:0] Last = CW'(N - 1);

  logic [CW-1:0] cnt;
  logic          clean_q;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      clean   <= 1'b0;
      clean_q <= 1'b0;
      cnt     <= '0;
    end else begin
      clean_q <= clean;
      if (noisy == clean) begin
        cnt <= '0;
      end else if (cnt == Last) begin
        clean <= noisy;
        cnt   <= '0;
      end else begin
        cnt <= cnt + 1'b1;
      end
    end
  end

  assign rise = clean & ~clean_q;
  assign fall = ~clean & clean_q;
endmodule
