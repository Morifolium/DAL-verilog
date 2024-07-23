module new_fp16_add_timing #(
    localparam WIDTH = 16
) (
    input clk,
    input logic [7:0][WIDTH-1:0] operands_i,
    output logic [WIDTH-1:0] add_reg_o
);

  logic [7:0][WIDTH-1:0] op_i;

  always_ff @(posedge clk) begin
    op_i <= operands_i;
  end

  logic [6:0][WIDTH-1:0] result_o;
  new_fp16_add u_new_fp16_add1 (
      .operands_i(op_i[1:0]),
      .result_o  (result_o[0])
  );
  new_fp16_add u_new_fp16_add2 (
      .operands_i({op_i[3:2]}),
      .result_o  (result_o[1])
  );

  new_fp16_add u_new_fp16_add3 (
      .operands_i({op_i[5:4]}),
      .result_o  (result_o[2])
  );
    new_fp16_add u_new_fp16_add4 (
      .operands_i({op_i[7:6]}),
      .result_o  (result_o[3])
  );
    new_fp16_add u_new_fp16_add5 (
      .operands_i({result_o[0], result_o[1]}),
      .result_o  (result_o[4])
  );
    new_fp16_add u_new_fp16_add6 (
      .operands_i({result_o[2], result_o[3]}),
      .result_o  (result_o[5])
  );
    new_fp16_add u_new_fp16_add7 (
      .operands_i({result_o[4], result_o[5]}),
      .result_o  (result_o[6])
  );


  always_ff @(posedge clk) begin
    add_reg_o <= result_o[6];
  end
endmodule
