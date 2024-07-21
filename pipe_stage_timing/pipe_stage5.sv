`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/03 17:47:07
// Design Name: 
// Module Name: pipe_stage5
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////



module pipe_stage5 #(
    localparam int unsigned WIDTH = 16,
    localparam interval_size=8,
    localparam para=8,
    localparam parallel_size=2
) (
    input logic clk,
    input logic rst,
    input logic [parallel_size-1:0][WIDTH-1:0] acc_s,
    input logic [interval_size-1:0][para-1:0] interval_cnt_i,
    input logic [parallel_size-1:0][interval_size-1:0] mode_i,
    output logic [parallel_size-1:0][interval_size-1:0] mode_o,
    output logic [interval_size-1:0][para-1:0] interval_cnt_o,

    input  logic [parallel_size-1:0][para-1:0] max_cnt_i,
    output logic [parallel_size-1:0][para-1:0] max_cnt_o,

    output logic [parallel_size-1:0][WIDTH-1:0] alpha_o,
    output logic [parallel_size-1:0][WIDTH-1:0] _alpha_o,
    output logic [parallel_size-1:0][WIDTH-1:0] beta_o,

    output logic [parallel_size-1:0][interval_size-1:0][para-1:0] acc_interval_o,

    input logic [parallel_size-1:0][WIDTH-1:0] a_acc_i,
    input logic [parallel_size-1:0][WIDTH-1:0] a_pos_i,
    input logic [parallel_size-1:0][WIDTH-1:0] b_acc_i,
    input logic [parallel_size-1:0][WIDTH-1:0] b_pos_i,
    output logic [parallel_size-1:0] U_add,


    input logic [para-1:0] J_size,
    output logic finished,

    output logic mode
    //VPE always 1

);

  assign mode = 1;  //VPE always 1


  genvar i, j;
  generate
    for (i = 0; i < parallel_size; i++) begin
      logic [interval_size-1:0] acc_interval;

      interval check_int (
          .s_i(acc_s[i]),
          .interval_o(acc_interval)
      );

      assign acc_interval_o[i] = acc_interval;

      logic [para-1:0] current_cnt;



      always_comb begin
        unique case (acc_interval)  //current增加寄存器
          8'b00000001: current_cnt = interval_cnt_i[i][0] + 1;
          8'b00000010: current_cnt = interval_cnt_i[i][1] + 1;
          8'b00000100: current_cnt = interval_cnt_i[i][2] + 1;
          8'b00001000: current_cnt = interval_cnt_i[i][3] + 1;
          8'b00010000: current_cnt = interval_cnt_i[i][4] + 1;
          8'b00100000: current_cnt = interval_cnt_i[i][5] + 1;
          8'b01000000: current_cnt = interval_cnt_i[i][6] + 1;
          8'b10000000: current_cnt = interval_cnt_i[i][7] + 1;
          default: current_cnt = interval_cnt_i[i][0] + 1;
        endcase
      end




      logic [WIDTH-1:0] alpha_t;
      logic [WIDTH-1:0] _alpha_t;
      logic [WIDTH-1:0] beta_t;


      new_fp16_add add1 (
          .operands_i({a_acc_i[i], {~a_pos_i[i][15], a_pos_i[i][14:0]}}),  // 2 operands
          .result_o  (alpha_t)
      );

      new_fp16_add add2 (
          .operands_i({b_acc_i[i], {~b_pos_i[i][15], b_pos_i[i][14:0]}}),  // 2 operands
          .result_o  (beta_t)
      );

      new_fp16_mul mul1 (
          .operands_i({alpha_t, acc_s[i]}),  // 2 operands
          .result_o  (_alpha_t)
      );


      assign alpha_o[i] = alpha_t;
      assign _alpha_o[i] = _alpha_t;
      assign beta_o[i] = beta_t;
      assign U_add[i] = current_cnt > max_cnt_i[i];

      always_comb begin
        if (U_add[i]) begin
          mode_o[i] = acc_interval;
          max_cnt_o[i] = current_cnt;
        end else begin
          mode_o[i] = 0;
          max_cnt_o[i] = 0;
        end
      end
    end
  endgenerate

  for (genvar j = 0; j < interval_size; j++) begin
    always_ff @(posedge clk or posedge rst) begin
      if (rst) interval_cnt_o[j] <= interval_cnt_i;
      else interval_cnt_o[j] <= interval_cnt_i[j] + acc_interval_o[0][j] + acc_interval_o[i][j];
    end
  end

  logic [para-1:0] step;

  always_ff @(posedge clk or posedge rst) begin
    if (rst) step <= 0;
    else step <= step + 1;
  end

  assign finished = (step >= J_size);

endmodule
