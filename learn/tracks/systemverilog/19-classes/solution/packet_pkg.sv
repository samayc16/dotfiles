// Exercise 19 · Classes (reference solution)
package packet_pkg;
  class Packet;
    static int count = 0;

    bit [7:0] addr;
    bit [7:0] payload[4];

    function new(bit [7:0] addr, bit [7:0] payload[4]);
      this.addr    = addr;
      this.payload = payload;
      count++;
    endfunction

    virtual function bit [7:0] checksum();
      bit [7:0] sum = addr;
      foreach (payload[i]) sum += payload[i];
      return sum;
    endfunction

    virtual function string to_string();
      return $sformatf("Packet(addr=0x%02x, payload=%02x %02x %02x %02x, csum=0x%02x)",
                       addr, payload[0], payload[1], payload[2], payload[3], checksum());
    endfunction

    virtual function bit is_valid();
      return 1'b1;
    endfunction
  endclass

  class CorruptPacket extends Packet;
    function new(bit [7:0] addr, bit [7:0] payload[4]);
      super.new(addr, payload);
    endfunction

    virtual function bit [7:0] checksum();
      return ~super.checksum();
    endfunction

    virtual function bit is_valid();
      return 1'b0;
    endfunction
  endclass
endpackage
