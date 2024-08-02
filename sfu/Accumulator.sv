module Accumulator #(
    parameter int data_width = 16,
    parameter int data_cnt   = 64
) (
    input logic clk,
    input logic rst,
    input logic [data_width-1:0] array[data_cnt-1:0],
    output logic [data_width-1:0] result,
    output logic done
);

  logic [data_width-1:0] op_a, op_b, res_o;
  logic [1:0] state;  //   �����ӷ������ӳ�

  //integer i;

  logic [data_width-1:0] i;
  assign done = i >= data_cnt;

  // Adder instance

  new_fp16_add adder_fp16 (
      .operands_i({op_a, op_b}),
      .result_o  (res_o)
  );

  always_ff @(posedge clk or posedge rst) begin
    if(rst) result<=0;
    else result <= res_o;
  end

  assign result = res_o;
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      i <= 0;
    end else begin
      i <= i + 1;
    end
  end

  always_comb begin
    op_a = result;
    op_b = array[i];
  end

endmodule
