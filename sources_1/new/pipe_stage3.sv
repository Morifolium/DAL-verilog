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
`include "registers.svh"

module pipe_stage3 #(
    localparam int unsigned WIDTH = 16,
    localparam n=4096,
    localparam para=16,
    localparam parallel_size=12
) (

    input logic [7:0][WIDTH-1:0] interval_lb,
    input logic [7:0][WIDTH-1:0] interval_ub,
    input logic [parallel_size-1:0][7:0] mode,
    input logic [parallel_size-1:0][para-1:0] interval_cnt_i,
    input logic [WIDTH-1:0] max_score,
    input logic [parallel_size-1:0][WIDTH-1:0] s_i,
    output logic [parallel_size-1:0] out_of_mode_interval,
    output logic [parallel_size-1:0][para-1:0] interval_cnt_o
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

    fp16_add add (
        // Input signals
        .operands_i({s_i[i], {1'b1, max_score[14:0]}}),  // 2 operands
        .is_boxed_i(2'b11),                              // 2 operands
        .rnd_mode_i(),
        // Output signals
        .result_o  (s_score[i]),
        .status_o  ()
    );

    //logic out_of_mode_interval;

    assign out_of_mode_interval[i] = out_of_mode_interval_l[i] | out_of_mode_interval_r[i];

    fpnew_noncomp cmp1 (
        // Input signals
        .operands_i({s_score[i], mode_interval_lb[i]}),  // 2 operands
        .is_boxed_i(2'b11),  // 2 operands
        .op_i(fpnew_pkg::CMP),  //cmp1_i<cmp2_i
        // Output signals
        //result_o(cmp_o),
        .extension_bit_o(out_of_mode_interval_l[i])
    );

    fpnew_noncomp cmp2 (
        // Input signals
        .operands_i({mode_interval_ub[i], s_score[i]}),  // 2 operands
        .is_boxed_i(2'b11),  // 2 operands
        .op_i(fpnew_pkg::CMP),  //cmp1_i<cmp2_i
        // Output signals
        //result_o(cmp_o),
        .extension_bit_o(out_of_mode_interval_r[i])
    );


  end



endmodule
