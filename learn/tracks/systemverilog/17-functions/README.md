# 17 · Functions

**Concepts:** `function automatic`, `return`, loops inside functions, packages as libraries.

Functions take inputs and return a value in **zero simulation time**. Inside an `always_comb` they become
combinational logic, and in testbenches they're plain helpers. Put reusable ones in a package:

```systemverilog
package bits_pkg;
  function automatic logic [7:0] bin2gray(logic [7:0] b);
    return b ^ (b >> 1);
  endfunction
endpackage
// elsewhere: import bits_pkg::*;  ...  g = bin2gray(count);
```

`automatic` gives each call its own local variables (needed for recursion and safe in testbenches). Use it by
default.

**Your task:** implement the five functions in `bits_pkg.sv`. Gray code is what async FIFOs use to pass
pointers between clock domains safely, because only one bit changes per increment.

**Check:** `learn check`
