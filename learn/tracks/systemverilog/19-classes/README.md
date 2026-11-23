# 19 · Classes and inheritance

**Concepts:** `class`, `new()`, `this`, `static` members, `extends`, `super`, `virtual` methods, handles,
polymorphism.

Designs are modules. **Testbenches are built from classes**: transactions, drivers, monitors, scoreboards.
SystemVerilog classes work like Java's: objects live on the heap, variables hold *handles*, and the garbage
collector frees them.

```systemverilog
class Packet;
  bit [7:0] addr;
  static int count = 0;                    // one copy shared by every Packet
  function new(bit [7:0] addr); this.addr = addr; count++; endfunction
  virtual function bit is_valid(); return 1; endfunction
endclass

class CorruptPacket extends Packet;
  function new(bit [7:0] addr); super.new(addr); endfunction
  virtual function bit is_valid(); return 0; endfunction   // override
endclass

Packet p = CorruptPacket'(...);   // a base handle to a subclass object
p.is_valid();                     // 0: virtual dispatch picks the subclass method
```

Without `virtual`, the *handle type* decides which method runs. That's almost never what you want.

**Classic gotcha:** a variable declared *with an initializer* inside a loop in an `initial` block is
**static**, so the initializer runs once, not once per iteration. `Packet p = new(...);` in a loop creates one
object. Write `automatic Packet p = new(...);` (see the bottom of `tb.sv`).

## New syntax

| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `class C; ... endclass` | data + methods; objects are created at runtime | |
| `C h; h = new(...);` | `h` is a *handle* (a pointer, `null` until set); `new` makes an object and runs the constructor | `Coin c = new(5);` |
| `function new(args);` | the constructor | |
| `this.x = x;` | `this` is the current object: member `x` vs argument `x` | `this.cents = cents;` |
| `static int n;` | one copy shared by all objects of the class | `Coin::made` |
| `virtual function` | a subclass override runs even through a base-class handle | |
| `class B extends A;` | inheritance | `class Dime extends Coin;` |
| `super.new(...)`, `super.f()` | call the parent's constructor / method | `return {"dime/", super.name()};` |
| `bit [7:0] arr[4]`, `'{1, 2, 3, 4}` | a fixed array of 4 bytes, and an array literal (used in `tb.sv`) | `int prices[3] = '{3, 4, 5};` |
| `foreach (arr[i])` | loop over every index of an array | `foreach (prices[i]) t += prices[i];` |
| `string`, `$sformatf(...)` | text type; printf-style formatting into a string. `%02x` = 2 hex digits, zero-padded | `$sformatf("id=0x%02x", 8'h1f)` → `"id=0x1f"` |

**Your task:** complete `Packet` and write `CorruptPacket` in `packet_pkg.sv`.
**Check:** `learn check`
