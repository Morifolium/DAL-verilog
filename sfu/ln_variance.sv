module ln_variance #(
    parameter int dim_size   = 128,
    parameter int data_width = 16
) (
    input logic clk,
    input logic rst,

    input  logic [data_width-1:0] Garray       [dim_size-1:0],
    input  logic [data_width-1:0] equat_square,
    input  logic                  equat_valid_i,
    input  logic [data_width-1:0] gmma,
    output logic [data_width-1:0] vari_remul,
    output logic                  valid_vari_o
);
  assign valid_vari_o = 1'b1;

  //calculate G^2 element by element
  logic [data_width-1:0] Garray_squ[dim_size-1:0];
  logic mul_done;
  Acc_mul #(
      .data_width(data_width),
      .data_cnt  (dim_size)
  ) inst_accmul (
      .clk    (clk),
      .rst    (rst),
      .array  (Garray),
      .sqarray(Garray_squ),
      .done   (mul_done)
  );

  //��ͣ��õ�res_sum
  logic [data_width-1:0] res_sum;
  logic [data_width-1:0] res_sum1;
  logic [data_width-1:0] res_sum2;
  logic sum_valid1, sum_valid2;
  Accumulator #(
      .data_width(data_width),
      .data_cnt  (dim_size / 2)
  ) inst_acc1 (
      .clk   (clk),
      .rst   (rst & mul_done),
      .array (Garray_squ[dim_size-1:dim_size/2]),
      .result(res_sum1),
      .done  (sum_valid1)
  );

  Accumulator #(
      .data_width(data_width),
      .data_cnt  (dim_size / 2)
  ) inst_acc2 (
      .clk   (clk),
      .rst   (rst & mul_done),
      .array (Garray[dim_size/2-1:0]),
      .result(res_sum2),
      .done  (sum_valid2)
  );

  logic sum_valid;
  new_fp16_add u_adder_fp16 (
      .operands_i({res_sum1, res_sum2}),
      .result_o  (res_sum)
  );

  //��dim_size
  logic [data_width-1:0] res_div;

  assign res_div = {res_sum[15], res_sum[14:10] - 7, res_sum[9:0]};

  //���������õ�variance = E^2 - res_div
  logic [data_width-1:0] variance;
  logic vari_done;
  new_fp16_add inst_adder_1 (
      .operands_i({equat_square, res_div}),
      .result_o  (variance)
  );

  //������var��ƫ�ã���ƽ����ȡ����
  logic [data_width-1:0] epsonal;
  logic [data_width-1:0] tmp_to_sqrt;
  logic                  vari_re_valid_o;
  assign epsonal = 16'h0001;  // ������ 10^-8 �ļ�С��
  new_fp16_add inst_adder_2 (
      .operands_i({variance, epsonal}),
      .result_o  (tmp_to_sqrt)
  );

  logic [data_width-1:0] vari_sqrt;
  fp16_Rom_sqrt inst_sqrt (
      .operands(tmp_to_sqrt),
      .result  (vari_sqrt)
  );
  logic [data_width-1:0] vari_reverse;
  fp16_Rom_div inst_divider_2 (
      .operands(vari_sqrt),
      .result  (vari_reverse)
  );
  new_fp16_mul inst_multi2 (
      .operands_i({vari_reverse, gmma}),
      .result_o  (vari_remul)
  );


endmodule
