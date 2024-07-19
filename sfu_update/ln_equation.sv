module ln_equation#(
  parameter int dim_size = 128,
  parameter int data_width = 16)
  (
    input logic clk,
    input logic rst_n,

    input  logic [data_width-1:0] Garray[dim_size-1: 0],
    output logic [data_width-1:0] equat,
    output logic [data_width-1:0] equat_square,
    output logic                  equat_valid_o
  );

  // 元素的求和，三个加法器
  logic [data_width-1:0] res_sum;
  logic [data_width-1:0] res_sum1;
  logic [data_width-1:0] res_sum2;
  logic valid1, valid2;

  Accumulator #(
    .data_width (data_width),
    .data_cnt   (dim_size/2)
  )inst_acc1 (
    .clk    (clk),
    .rst_n  (rst_n),
    .array  (Garray[dim_size-1:dim_size/2]),
    .result (res_sum1),
    .done   (valid1)
  );
  Accumulator #(
    .data_width (data_width),
    .data_cnt   (dim_size/2)
  )inst_acc2 (
    .clk    (clk),
    .rst_n  (rst_n),
    .array  (Garray[dim_size/2-1:0]),
    .result (res_sum2),
    .done   (valid2)
  );

  logic sum_done;
  adder_fp16 u_adder_fp16 (
    .clk    (clk),
    .rst_n  (rst_n & valid1 & valid2),
    .mode   (1'b0),
    .op_a   (res_sum1),
    .op_b   (res_sum2),
    .res_o  (res_sum),
    .done   (sum_done)
  );

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

  //除dim_size，得到equation
  logic [data_width-1:0] d_model;
  logic [data_width-1:0] d_model_r;
  assign d_model = 16'h5800; //dim_size = 128 的fp16表示

  fp16_Rom_div inst_reverse (
    .operands (d_model),
    .result   (d_model_r)
  );

  logic multi_done;
  multiplier_fp16 inst_multi1(
    .clk    (clk),
    .rst_n  (rst_n & sum_done),
    .op_a   (res_sum),
    .op_b   (d_model_r),
    .res_o  (res_div),
    .done   (multi_done)
  );

  //作乘法，得到equation^2
  multiplier_fp16 inst_multi2(
    .clk    (clk),
    .rst_n  (rst_n & multi_done),
    .op_a   (res_div),
    .op_b   (res_div),
    .res_o  (equat_square),
    .done   (equat_valid_o)
  );

endmodule