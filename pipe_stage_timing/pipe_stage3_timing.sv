`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/02 17:27:15
// Design Name: 
// Module Name: pipe_stage_3
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

module pipe_stage3_timing #(
    localparam int unsigned WIDTH = 16,
    localparam n=4096,
    localparam para=16,
    localparam parallel_size=12
) (
    input clk,
    input rst,
    input logic [7:0][WIDTH-1:0] interval_lb,
    input logic [7:0][WIDTH-1:0] interval_ub,
    input logic [parallel_size-1:0][7:0] mode,
    input logic [parallel_size-1:0][para-1:0] interval_cnt_i,
    input logic [WIDTH-1:0] max_score,
    input logic [parallel_size-1:0][WIDTH-1:0] s_i,
    output logic [parallel_size-1:0] out_of_mode_interval,
    output logic [parallel_size-1:0][para-1:0] interval_cnt_o,

  input logic [parallel_size-1:0][para-1:0]idx_i,
    output logic [parallel_size-1:0][para-1:0] J_o
    //output logic [parallel_size-1:)][]

);

  logic [parallel_size-1:0][WIDTH-1:0] mode_interval_lb;
  logic [parallel_size-1:0][WIDTH-1:0] mode_interval_ub;

  logic [parallel_size-1:0][WIDTH-1:0] s_score;

  logic [parallel_size-1:0] out_of_mode_interval_l;
  logic [parallel_size-1:0] out_of_mode_interval_r;




  for (genvar i = 0; i < parallel_size; i++) begin

    always_comb begin  //lut 
      unique case (mode[i])
        8'b1: begin
          mode_interval_lb[i] = interval_lb[0];
          mode_interval_ub[i] = interval_ub[0];
        end
        2: begin
          mode_interval_lb[i] = interval_lb[1];
          mode_interval_ub[i] = interval_ub[1];
        end
        4: begin
          mode_interval_lb[i] = interval_lb[2];
          mode_interval_ub[i] = interval_ub[2];
        end
        8: begin
          mode_interval_lb[i] = interval_lb[3];
          mode_interval_ub[i] = interval_ub[3];
        end
        16: begin
          mode_interval_lb[i] = interval_lb[4];
          mode_interval_ub[i] = interval_ub[4];
        end
        32: begin
          mode_interval_lb[i] = interval_lb[5];
          mode_interval_ub[i] = interval_ub[5];
        end
        64: begin
          mode_interval_lb[i] = interval_lb[6];
          mode_interval_ub[i] = interval_ub[6];
        end
        128: begin
          mode_interval_lb[i] = interval_lb[7];
          mode_interval_ub[i] = interval_ub[7];
        end
        default: begin
          mode_interval_lb[i] = interval_lb[0];
          mode_interval_ub[i] = interval_ub[0];
        end
      endcase
    end

    new_fp16_add add (
        // Input signals
        .operands_i({s_i[i], {1'b1, max_score[14:0]}}),  // 2 operands
        .result_o  (s_score[i])
    );

    //logic out_of_mode_interval;

    assign out_of_mode_interval[i] = out_of_mode_interval_l[i] | out_of_mode_interval_r[i];

    new_fp16_cmp cmp1 (
        .operands_i({s_score[i], mode_interval_lb[i]}),  // 2 operands
        .result_o(out_of_mode_interval_l[i])
    );

    new_fp16_cmp cmp2 (
        .operands_i({mode_interval_ub[i], s_score[i]}),  // 2 operands
        .result_o(out_of_mode_interval_r[i])
    );
    /*
    FFReg Reg1(
        .__q_o(J_o[i]),
        .__reset_value(idx_i[i]),
        .__clk(clk),
        .__arst_n(out_of_mode_interval[i])
    );
    */
    always_ff @( posedge clk ) begin : Reg1
      if(rst) J_o[i]<=8'b0;
      else if(out_of_mode_interval[i]) J_o[i]<=idx_i[i];
      else J_o[i]<=J_o[i];
    end

  end



endmodule
