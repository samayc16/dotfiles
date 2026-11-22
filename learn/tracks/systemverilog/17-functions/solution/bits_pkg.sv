// Exercise 17 · Functions (reference solution)
package bits_pkg;
  function automatic logic [7:0] bin2gray(logic [7:0] b);
    return b ^ (b >> 1);
  endfunction

  function automatic logic [7:0] gray2bin(logic [7:0] g);
    logic [7:0] b;
    b[7] = g[7];
    for (int i = 6; i >= 0; i--) b[i] = b[i+1] ^ g[i];
    return b;
  endfunction

  function automatic int popcount(logic [31:0] x);
    int n = 0;
    for (int i = 0; i < 32; i++) n += int'(x[i]);
    return n;
  endfunction

  function automatic bit is_pow2(logic [31:0] x);
    return x != 0 && (x & (x - 1)) == 0;
  endfunction

  function automatic int lowest_set(logic [31:0] x);
    for (int i = 0; i < 32; i++) if (x[i]) return i;
    return -1;
  endfunction
endpackage
