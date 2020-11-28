module ALU_with_mux(

  input logic mux_ALU_ctrl,
  input logic [2:0] op,
  input logic [31:0] a,
  input logic [31:0] b,
  output logic [31:0] result,
  // output logic zero -> not yet sure if we are using it or not

);


  ALU_with_mux ALU_with_mux_0 (

    .mux_ALU_ctrl(mux_ALU_ctrl)
    .op(op),
    .a(a),
    .b(mux_ALU_result),
    .result(result),
    // .zero(zero)

  );

endmodule
