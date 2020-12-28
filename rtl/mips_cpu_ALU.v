module mips_cpu_ALU (
  input logic [3:0] op,
  input logic [31:0] a,
  input logic [31:0] b,
  input logic [4:0] sa,
  output logic [31:0] result,
  output logic zero,
  input logic clk,
  input logic reset

);

  logic [4:0] sav;
  logic [15:0] lower;

  assign zero = (result == 0);
  assign sav = (op==9 || op==10 || op==11) ? a[4:0] : 5'b0;
  assign lower = b[15:0];


  always_ff @(posedge clk) begin
    if(reset) begin
      result <= 0;
    end else begin
    case (op)
      0: begin result <= a & b; end //bitwise AND
      1: begin result <= a | b; end //bitwise OR
      2: begin result <= a + b; end //add
      3: begin result <= a - b; end //sub
      4: begin result <= $signed(a) < $signed(b) ? 1 : 0; end //slt
      5: begin result <= a ^ b; end //bitwise XOR
      6: begin result <= b << sa; end//shift left
      7: begin result <= b >> sa; end //shift right
      8: begin result <= $signed(b) >>> sa; end //arithmetic shift right
      9: begin result <= b << sav; end //shift left variable
      10: begin result <= b >> sav; end //shift right variable
      11: begin result <= $signed(b) >>> sav; end //arithmetic shift right variable
      12: begin result <= {lower,16'd0}; end
      13: begin result <= $unsigned(a) < $unsigned(b) ? 1'b1 : 1'b0; end//sltu
      14: begin result <= a; end//a
      default: begin end

    endcase
  end
  end

endmodule
