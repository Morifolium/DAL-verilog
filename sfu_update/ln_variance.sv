module ln_variance#(
  parameter int dim_size = 128,
  parameter int data_width = 16)
  (
    input logic clk,
    input logic rst_n,

    input  logic [data_width-1:0] Garray[dim_size-1: 0],
    input  logic [data_width-1:0] equat_square,
    input  logic                  equat_valid_i,
    input  logic [data_width-1:0] gmma,
    output logic [data_width-1:0] vari_remul,
    output logic                  valid_vari_o
  );

    //calculate G^2 element by element
    logic [data_width-1:0] Garray_squ[dim_size-1: 0];
    logic mul_done;
    Acc_mul #(
        .data_width (data_width),
        .data_cnt   (dim_size)
    )inst_accmul (
        .clk     (clk),
        .rst_n   (rst_n),
        .array   (Garray),
        .sqarray (Garray_squ),
        .done    (mul_done)
    );

    //求和，得到res_sum
    logic [data_width-1:0] res_sum;
    logic [data_width-1:0] res_sum1;
    logic [data_width-1:0] res_sum2;
    logic sum_valid1, sum_valid2;
    Accumulator #(
        .data_width (data_width),
        .data_cnt   (dim_size/2)
    )inst_acc1 (
        .clk    (clk),
        .rst_n  (rst_n & mul_done),
        .array  (Garray_squ[dim_size-1:dim_size/2]),
        .result (res_sum1),
        .done   (sum_valid1)
    );
   Accumulator #(
        .data_width (data_width),
        .data_cnt   (dim_size/2)
    )inst_acc2 (
        .clk    (clk),
        .rst_n  (rst_n & mul_done),
        .array  (Garray[dim_size/2-1:0]),
        .result (res_sum2),
        .done   (sum_valid2)
    );
    logic sum_valid;
    adder_fp16 u_adder_fp16 (
        .clk    (clk),
        .rst_n  (rst_n & sum_valid1 & sum_valid2),
        .mode   (1'b0),
        .op_a   (res_sum1),
        .op_b   (res_sum2),
        .res_o  (res_sum),
        .done   (sum_valid)
    );

    //除dim_size
    logic [data_width-1:0] res_div;
    logic [data_width-1:0] d_model;
    logic [data_width-1:0] d_model_r;
    logic                  div_done;
    assign d_model = dim_size[data_width-1:0];
    fp16_Rom_div inst_reverse (
        .operands (d_model),
        .result   (d_model_r)
    );
    multiplier_fp16 inst_multi1(
        .clk    (clk),
        .rst_n  (rst_n & sum_valid),
        .op_a   (res_sum),
        .op_b   (d_model_r),
        .res_o  (res_div),
        .done   (div_done)
    );

    //作减法，得到variance = E^2 - res_div
    logic [data_width-1:0] variance;
    logic vari_done;
    adder_fp16 inst_adder_1(
        .clk    (clk),
        .rst_n  (rst_n & div_done & equat_valid_i),
        .mode   (1'b1),
        .op_a   (equat_square),
        .op_b   (res_div),
        .res_o  (variance),
        .done   (vari_done)
    );

    //下面求：var加偏置，开平方，取倒数
    logic [data_width-1:0] epsonal = 16'h0001; // 10^-8，极小数
    logic [data_width-1:0] tmp_to_sqrt;
    logic                 vari_re_valid_o;
    adder_fp16 inst_adder_2(
        .clk    (clk),
        .rst_n  (rst_n & vari_done),
        .mode   (1'b0),
        .op_a   (variance),
        .op_b   (epsonal),
        .res_o  (tmp_to_sqrt),
        .done   (vari_re_valid_o)
    );

    logic [data_width-1:0] vari_sqrt;
    fp16_Rom_sqrt inst_sqrt(
        .operands  (tmp_to_sqrt),
        .result    (vari_sqrt)
    );
    logic [data_width-1:0] vari_reverse;
    fp16_Rom_div inst_divider_2 (
        .operands (vari_sqrt),
        .result   (vari_reverse)
    );
    multiplier_fp16 inst_multi2(
        .clk    (clk),
        .rst_n  (rst_n & vari_re_valid_o),
        .op_a   (vari_reverse),
        .op_b   (gmma),
        .res_o  (vari_remul),
        .done   (valid_vari_o)
    );


endmodule