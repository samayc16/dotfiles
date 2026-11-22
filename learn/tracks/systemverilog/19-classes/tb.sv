// Testbench for exercise 19 (read-only).
module tb;
  import packet_pkg::*;

  initial begin
    Packet        p, base_handle;
    CorruptPacket c;
    Packet        all[$];
    int           valid_count;

    tbu::group("constructor + fields");
    p = new(8'h12, '{8'h01, 8'h02, 8'h03, 8'h04});
    tbu::check("addr", p.addr, 8'h12);
    tbu::check("payload[3]", p.payload[3], 8'h04);
    tbu::check("Packet::count after one packet", Packet::count, 1);

    tbu::group("checksum + to_string");
    tbu::check("checksum 0x12+1+2+3+4", p.checksum(), 8'h1C);
    tbu::check_true($sformatf("to_string() = \"%s\"", p.to_string()),
                    p.to_string() == "Packet(addr=0x12, payload=01 02 03 04, csum=0x1c)");
    p = new(8'hFF, '{8'hFF, 8'h01, 8'h00, 8'h10});
    tbu::check("checksum wraps modulo 256", p.checksum(), 8'h0F);

    tbu::group("inheritance + virtual methods");
    c = new(8'h12, '{8'h01, 8'h02, 8'h03, 8'h04});
    base_handle = c;  // a base-class handle pointing at a subclass object
    tbu::check("CorruptPacket checksum is inverted", c.checksum(), 8'hE3);
    tbu::check("...also through a Packet handle (virtual!)", base_handle.checksum(), 8'hE3);
    tbu::check("is_valid() through a Packet handle", base_handle.is_valid(), 0);
    tbu::check_true($sformatf("to_string() uses the overridden checksum: \"%s\"", base_handle.to_string()),
                    base_handle.to_string() == "Packet(addr=0x12, payload=01 02 03 04, csum=0xe3)");
    tbu::check("Packet::count counts subclasses too", Packet::count, 3);

    tbu::group("a mixed queue of packets");
    for (int i = 0; i < 10; i++) begin
      automatic bit [7:0] pl[4] = '{8'(i), 8'(i + 1), 8'(i + 2), 8'(i + 3)};
      if (i % 3 == 0) begin
        automatic CorruptPacket cp = new(8'(i), pl);
        all.push_back(cp);
      end else begin
        automatic Packet pp = new(8'(i), pl);
        all.push_back(pp);
      end
    end
    valid_count = 0;
    foreach (all[i]) if (all[i].is_valid()) valid_count++;
    tbu::check("valid packets among 10 (every third is corrupt)", valid_count, 6);
    tbu::check("Packet::count", Packet::count, 13);
    tbu::finish();
  end
endmodule
