// Exercise 17 · Functions in a package
package bits_pkg;
  // Binary -> Gray code: consecutive numbers differ in exactly one bit.
  function automatic logic [7:0] bin2gray(logic [7:0] b);
    return '0;  // TODO
  endfunction

  // Gray -> binary: binary bit i = XOR of gray bits 7 down to i.
  function automatic logic [7:0] gray2bin(logic [7:0] g);
    return '0;  // TODO
  endfunction

  // Number of 1 bits. Write the loop yourself (no $countones).
  function automatic int popcount(logic [31:0] x);
    return 0;  // TODO
  endfunction

  // 1 if x is a power of two (exactly one bit set).
  function automatic bit is_pow2(logic [31:0] x);
    return 0;  // TODO
  endfunction

  // Index of the lowest set bit, or -1 if x == 0.
  function automatic int lowest_set(logic [31:0] x);
    return -1;  // TODO
  endfunction
endpackage
