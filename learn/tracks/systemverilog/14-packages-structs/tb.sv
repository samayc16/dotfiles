// Testbench for exercise 14 (read-only): struct layout, union aliasing, and every opcode.
module tb;
  import cpu_pkg::*;

  logic [7:0] a, y;
  instr_t     instr;
  instr_u     u;

  alu dut (.*);

`ifdef DUMP
  initial begin $dumpfile("wave.vcd"); $dumpvars(0, tb); end
`endif

  function automatic logic [7:0] model(logic [7:0] x, logic [15:0] raw);
    logic [4:0] sh  = raw[12:8];
    logic [7:0] imm = raw[7:0];
    case (raw[15:13])
      3'd0: return x + imm;
      3'd1: return x - imm;
      3'd2: return x & imm;
      3'd3: return x | imm;
      3'd4: return x ^ imm;
      3'd5: return x << sh;
      3'd6: return x >> sh;
      default: return imm;
    endcase
  endfunction

  initial begin
    tbu::group("layout");
    tbu::check("$bits(instr_t)", $bits(instr_t), 16);
    tbu::check("$bits(instr_u)", $bits(instr_u), 16);
    u.raw = 16'b101_00011_11110000;
    tbu::check("u.f.op is raw[15:13]", u.f.op, 3'b101);
    tbu::check("u.f.shamt is raw[12:8]", u.f.shamt, 5'b00011);
    tbu::check("u.f.imm is raw[7:0]", u.f.imm, 8'hF0);

    tbu::group("struct literal");
    instr = '{op: OP_ADD, shamt: 5'd0, imm: 8'd5};
    a = 8'd37;
    #1;
    tbu::check("37 + 5", y, 42);

    tbu::group("every opcode, 400 random instructions");
    repeat (400) begin
      u.raw = 16'($urandom);
      instr = u.f;
      a = 8'($urandom);
      #1;
      tbu::check($sformatf("%s a=%0d imm=%0d shamt=%0d", u.f.op.name(), a, u.f.imm, u.f.shamt), y, model(a, u.raw));
    end
    tbu::finish();
  end
endmodule
