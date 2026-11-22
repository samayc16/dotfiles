// Exercise 19 · Classes, constructors, inheritance, virtual methods
package packet_pkg;
  class Packet;
    static int count = 0;  // number of packets created so far (shared by ALL instances and subclasses)

    bit [7:0] addr;
    bit [7:0] payload[4];

    function new(bit [7:0] addr, bit [7:0] payload[4]);
      // TODO: store both fields (use this.addr = addr) and increment count
    endfunction

    // Sum of addr and the four payload bytes, modulo 256.
    virtual function bit [7:0] checksum();
      return 8'h00;  // TODO
    endfunction

    // Exactly: Packet(addr=0x12, payload=01 02 03 04, csum=0x1c)
    // ($sformatf with %02x; the csum comes from checksum(), so subclasses change it automatically)
    virtual function string to_string();
      return "";  // TODO
    endfunction

    virtual function bit is_valid();
      return 1'b1;
    endfunction
  endclass

  // TODO: class CorruptPacket extends Packet
  //   * constructor: same arguments, calls super.new(addr, payload)
  //   * checksum(): the parent's checksum with every bit inverted (~super.checksum())
  //   * is_valid(): returns 0
endpackage
