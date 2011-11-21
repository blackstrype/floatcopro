import float_pack::*;

module tb_float_pack(
  input float operand1,
  input float operand2,
  output float result
);

  assign result = float_mul(operand1, operand2);

endmodule
