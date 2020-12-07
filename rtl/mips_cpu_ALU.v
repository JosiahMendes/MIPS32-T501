module mips_cpu_ALU (
  input logic [4:0] op,
  input logic [31:0] a,
  input logic [31:0] b,
  input logic [4:0] sa,
  output logic [31:0] result,
  output logic zero

);
  timeunit 1ns / 10ps;

  logic [4:0] sav;
  logic signed [31:0] sra_var;
  logic [15:0] lower;

  assign zero = (result == 0);
  assign sav = (op==9 || op==10 || op==11) ? a[4:0] : 0;
  assign sra_var = b;
  assign lower = b[15:0];


  always_comb begin
    case (op)
      0: begin result = a & b; end //bitwise AND
      1: begin result = a | b; end //bitwise OR
      2: begin result = a + b; end //add
      3: begin result = a - b; end //sub
      4: begin result = a < b ? 1 : 0; end //slt
      5: begin result = a ^ b; end //bitwise XOR
      6: begin result = b << sa; end//shift left
      7: begin result = b >> sa; end //shift right
      8: begin result = sra_var >>> sa; end //arithmetic shift right
      9: begin result = b << sav; end //shift left variable
      10: begin result = b >> sav; end //shift right variable
      11: begin result = sra_var >>> sav; end //arithmetic shift right variable
      12: begin result = {lower,16'd0}; end

    endcase
  end

endmodule
