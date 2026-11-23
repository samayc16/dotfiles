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

## New syntax

| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `function automatic` | `automatic`: every call gets fresh local variables | |
| `bit` | a 2-state type (0/1 only, no x/z); common in functions and testbenches | `bit p = 0;` |
| local variables | declare them at the top of the function body | `int n = 0;` |
| `for (int i = 7; i >= 0; i--)` | count down | |
| `+=`, `^=` | update in place: `n += 2` is `n = n + 2` | `p ^= x[i];` |
| `int'(x[i])` | cast one bit to `int` before adding it to an `int` | |
| `return` in a loop | leave the function immediately | |

```systemverilog
function automatic bit parity8(logic [7:0] x);
  bit p = 0;
  for (int i = 7; i >= 0; i--) p ^= x[i];
  return p;                                   // parity8(8'b0000_0111) == 1
endfunction
```

**Your task:** implement the five functions in `bits_pkg.sv`. Gray code is what async FIFOs use to pass
pointers between clock domains safely, because only one bit changes per increment.

**Check:** `learn check`
