// Exercise 15 · Interfaces and modports (reference solution)
interface stream_if #(
    parameter int W = 8
) (
    input logic clk
);
  logic         valid;
  logic         ready;
  logic [W-1:0] data;

  modport source(output valid, data, input ready, clk);
  modport sink(input valid, data, clk, output ready);
endinterface
