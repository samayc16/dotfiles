// Read-only: the bus between the testbench classes and the FIFO (exercise 22).
interface fifo_if (
    input logic clk
);
  logic       rst_n;
  logic       push;
  logic       pop;
  logic [7:0] din;
  logic [7:0] dout;
  logic       full;
  logic       empty;
  logic [2:0] count;
endinterface
