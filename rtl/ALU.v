module ALU (

  input logic [2:0] op,
  input logic [31:0] a,
  input logic [31:0] b,
  output logic [31:0] result
  // output logic zero -> not yet sure if we are using it or not

);

  always_comb begin

    case (op)
      0: begin result = a & b; end
      1: begin result = a | b; end
      2: begin result = a + b; end
      3: begin result = a - b; end
      4: begin result = a < b ? 1 : 0; end
    endcase

  end

endmodule
