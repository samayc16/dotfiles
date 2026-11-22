// Exercise 15 · Interfaces and modports
interface stream_if #(
    parameter int W = 8
) (
    input logic clk
);
  logic         valid;  // the source has a beat this cycle
  logic         ready;  // the sink accepts this cycle
  logic [W-1:0] data;

  // The source drives valid + data and watches ready.
  modport source(output valid, data, input ready, clk);

  // TODO: the sink's view of the bus: it watches valid, data and clk, and drives ready.
endinterface
