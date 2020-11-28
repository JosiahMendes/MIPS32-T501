module mux_ALU (

  input logic mux_ALU_ctrl,
  input logic [31:0] from_arithmetic_instr,
  input logic [31:0] from_load_instr,
  output logic [31:0] mux_ALU_result

);

  assign mux_ALU_result = mux_ALU_ctrl ? from_arithmetic_instr : from_load_instr;

endmodule
