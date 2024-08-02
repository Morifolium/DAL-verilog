module ln_equation#(
  parameter int dim_size = 128,
  parameter int data_width = 16)
  (
    input logic clk,
    input logic rst,

    input  logic [data_width-1:0] Garray[dim_size-1: 0],
    output logic [data_width-1:0] equat,
    output logic [data_width-1:0] equat_square,
    output logic                  equat_valid_o
  );

  // Ԫ�ص���ͣ������ӷ���
  logic [data_width-1:0] res_sum;
  logic [data_width-1:0] res_sum1;
  logic [data_width-1:0] res_sum2;
  logic valid1, valid2;

  Accumulator #(
    .data_width (data_width),
    .data_cnt   (dim_size/2)
  )inst_acc1 (
    .clk    (clk),
    .rst  (rst),
    .array  (Garray[dim_size-1:dim_size/2]),
    .result (res_sum1),
    .done   (valid1)
  );

  Accumulator #(
    .data_width (data_width),
    .data_cnt   (dim_size/2)
  )inst_acc2 (
    .clk    (clk),
    .rst  (rst),
    .array  (Garray[dim_size/2-1:0]),
    .result (res_sum2),
    .done   (valid2)
  );

  
  new_fp16_add u_adder_fp16 (
    .operands_i({res_sum1,res_sum2}),
    .result_o  (res_sum)
  );

  // logic rst_adder;
  // assign rst_adder = rst & valid1 & valid2;
  // adder_fp16 u_adder_fp16 (
  //   .clk    (clk),
  //   .rst    (rst_adder),
  //   .mode   (1'b0),
  //   .op_a   (res_sum1),
  //   .op_b   (res_sum2),
  //   .res_o  (res_sum),
  //   .done   (sum_done)
  // );




  // always_comb begin
  //   if (valid1 && valid2) begin
  //     op_a = res_sum1;
  //     op_b = res_sum2;
  //   end
  //   else begin
  //     op_a = 16'h0000;
  //     op_b = 16'h0000;
  //   end
  // end

  logic [data_width-1:0] res_div;
  assign equat = res_div;

  //��dim_size���õ�equation
  logic [data_width-1:0] d_model;
  logic [data_width-1:0] d_model_r;
  assign d_model = 16'h5800; //dim_size = 128 ��fp16��ʾ

  fp16_Rom_div inst_reverse (
    .operands (d_model),
    .result   (d_model_r)
  );

  new_fp16_mul inst_multi1(
    .operands_i({res_sum,d_model_r}),
    .result_o  (res_div)
  );

  //���˷����õ�equation^2
  new_fp16_mul inst_multi2(
    .operands_i({res_div,res_div}),
    .result_o  (equat_square)
  );

  assign equat_valid_o=valid1&valid2;

endmodule