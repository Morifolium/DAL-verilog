module Acc_mul #(
    parameter int data_width = 16,
    parameter int data_cnt   = 64
) (
    input logic clk,
    input logic rst,
    input logic [data_width-1:0] array[data_cnt-1:0],
    output logic [data_width-1:0] sqarray[data_cnt-1:0],
    output logic done
);

  logic [data_width-1:0] op_a, op_b, res_o;

  logic [data_width-1:0] i;

  // Adder instance

  new_fp16_mul multier_fp16 (
      .operands_i({op_a, op_b}),
      .result_o  (res_o)
  );

  assign done = i >= data_cnt;

  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      i <= 0;
    end else begin
      if (!done) begin
        i <= i + 1;
      end
    end
  end

  always_comb begin
    op_a = array[i];
    op_b = array[i];
    sqarray[i] = res_o;
  end

endmodule
