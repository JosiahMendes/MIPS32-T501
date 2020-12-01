module mips_cpu_ALU (
  input logic [3:0] op,
  input logic [31:0] a,
  input logic [31:0] b,
  output logic [31:0] result,
  output logic zero

);
  assign zero = (result == 0);

  always_comb begin
    case (op)
      0: begin result = a & b; end //bitwise AND
      1: begin result = a | b; end //bitwise OR
      2: begin result = a + b; end //add
      3: begin result = a - b; end //sub
      4: begin result = a < b ? 1 : 0; end //slt
      5: begin result = a ^ b; end //bitwise XOR
    endcase
  end

endmodule
