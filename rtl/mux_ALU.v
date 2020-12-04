
module mux_ALU (
  input logic ALUmux,
  input logic [4:0] ALUop,
  input logic [31:0] a, b, c,
  output logic [31:0] ALUout,
  output logic ALUzero
);

  logic[31:0] source1, source2;

  assign source1 = a;
  assign source2 = (ALUmux) ? c : b;

  mips_cpu_ALU sym(
    .op(ALUop),
    .a(source1),
    .b(source2),
    .result(ALUout),
    .zero(ALUzero)
  );

endmodule
