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

**Your task:** complete `Packet` and write `CorruptPacket` in `packet_pkg.sv`.
**Check:** `learn check`
