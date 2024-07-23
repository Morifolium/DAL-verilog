module new_fp16_add_timing #(
    localparam WIDTH = 16
) (
    input clk,
    input logic [3:0][WIDTH-1:0] operands_i,
    output logic [WIDTH-1:0] add_reg_o
);

  logic [3:0][WIDTH-1:0] op_i;
  always_ff @(posedge clk) begin
    op_i <= operands_i;
  end

  logic [3:0][WIDTH-1:0] result_o;
  new_fp16_add_nolzc u_new_fp16_add1 (
      .operands_i(op_i[1:0]),
      .result_o  (result_o[0])
  );
  new_fp16_add_nolzc u_new_fp16_add2 (
      .operands_i({op_i[2], result_o[0]}),
      .result_o  (result_o[1])
  );

  new_fp16_add_nolzc u_new_fp16_add3 (
      .operands_i({op_i[3], result_o[1]}),
      .result_o  (result_o[2])
  );


  always_ff @(posedge clk) begin
    add_reg_o <= result_o[2];
  end
endmodule
