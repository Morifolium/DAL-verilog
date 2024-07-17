`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/04 13:23:36
// Design Name: 
// Module Name: pipe_stage6
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

module pipe_stage6 #(
    localparam int unsigned WIDTH = 16,
    localparam parallel_size = 3,
    localparam para = 16,
    localparam tile_size = 128
) (
    input  logic clk_i,
    input  logic rst_i,
    output logic finished,

    input logic [parallel_size-1:0][tile_size-1:0][WIDTH-1:0] operandv_i,
    input logic [parallel_size-1:0][WIDTH-1:0] operand1_i,
    input logic [parallel_size-1:0][WIDTH-1:0] operand2_i,
    input logic [parallel_size-1:0][WIDTH-1:0] operand3_i,
    input logic [parallel_size-1:0][WIDTH-1:0] operand4_i,
    input logic [3:0][para-1:0] stage_boundary,

    input logic [parallel_size-1:0][tile_size-1:0][WIDTH-1:0] set_i,

    output logic mode,
    output logic [parallel_size-1:0][WIDTH-1:0] scale,
    output logic [parallel_size-1:0][tile_size-1:0][WIDTH-1:0] acc_o,
    output logic [4:0] stage

);




  logic [para-1:0] step;


  always_ff @(posedge clk_i or rst_i) begin
    if (rst_i) step = 0;
    else begin
      step <= step + 1;
      if (step < stage_boundary[0]) stage <= 0;
      else if (step < stage_boundary[1]) stage <= 1;
      else if (step < stage_boundary[2]) stage <= 2;
      else if (step < stage_boundary[3]) stage <= 3;
      else if (step < stage_boundary[4]) stage <= 4;
      else if (step < stage_boundary[5]) stage <= 5;
      else if (step < stage_boundary[6]) stage <= 6;
      else if (step < stage_boundary[7]) stage <= 7;
      else stage <= 8;
    end
  end


  assign finished = (stage == 8);

  logic [parallel_size-1:0][WIDTH-1:0] add3_o;
  logic [parallel_size-1:0][WIDTH-1:0] add2_o;
  logic [parallel_size-1:0][WIDTH-1:0] add1_o;
  logic [parallel_size-1:0][WIDTH-1:0] add3_i;
  logic [parallel_size-1:0][WIDTH-1:0] mul1_o;

  logic [parallel_size-1:0][tile_size:0][WIDTH-1:0] reduction_i;



  always_comb begin
    if (stage == 2) add3_i = add2_o;
    else add3_i = operand1_i;
  end

  always_comb begin
    if (stage == 0 || stage == 1) mode = 1;
    else mode = 0;
  end


  for (genvar i = 0; i < parallel_size; i++) begin
    fp16_add add1 (
        .operands_i({operand1_i[i], operand4_i[i]}),  // 2 operands
        .is_boxed_i(2'b11),  // 2 operands
        .rnd_mode_i(),
        // Output signals
        .result_o(alpha_t),
        .status_o()
    );

    fp16_add add2 (
        .operands_i({add1_o[i], {~mul1_o[i][15], mul1_o[i][14:0]}}),  // 2 operands
        .is_boxed_i(2'b11),  // 2 operands
        .rnd_mode_i(),
        // Output signals
        .result_o(add2_o[i]),
        .status_o()
    );

    fp16_add add3 (  //use for reduction
        .operands_i({acc_o[i][tile_size], operand3_i[i]}),  // 2 operands
        .is_boxed_i(2'b11),  // 2 operands
        .rnd_mode_i(),
        // Output signals
        .result_o(add3_o[i]),
        .status_o()
    );

    fp16_mul mul1 (
        .operands_i({operand2_i[i], operand3_i[i]}),  // 2 operands
        .is_boxed_i(2'b11),  // 2 operands
        .rnd_mode_i(),
        // Output signals
        .result_o(mul1_o[i]),
        .status_o()
    );

    assign reduction_i[i] = {operandv_i[i], add3_o[i]};
    assign scale[i]=add2_o;

  end


  reduction reduct (
      .CLK_i(clk_i),
      .RST_i(step==stage_boundary[1]|step==stage_boundary[4]|step==stage_boundary[5]|step==stage_boundary[6]),
      .set_reg_i(set_i),
      .operand_i(reduction_i),
      .reduction_o(acc_o)
  );

endmodule
