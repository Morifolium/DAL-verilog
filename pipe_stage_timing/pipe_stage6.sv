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


module pipe_stage6 #(
    localparam int unsigned WIDTH = 16,
    localparam parallel_size = 3,
    localparam para = 8,
    localparam tile_size = 128
) (
    input  logic clk,
    input  logic rst,
    output logic finished,

    input logic [parallel_size-1:0][tile_size-1:0][WIDTH-1:0] operandv_i,
    input logic [parallel_size-1:0][WIDTH-1:0] operand1_i,
    input logic [parallel_size-1:0][WIDTH-1:0] operand2_i,
    input logic [parallel_size-1:0][WIDTH-1:0] operand3_i,
    input logic [parallel_size-1:0][WIDTH-1:0] operand4_i,
    input logic [7:0][para-1:0] stage_boundary,

    input logic [tile_size:0][WIDTH-1:0] set_i,

    output logic mode,
    output logic [parallel_size-1:0][WIDTH-1:0] scale,
    output logic [parallel_size-1:0][tile_size-1:0][WIDTH-1:0] acc_o,
    input logic [4:0] stage

);




  logic [para-1:0] step;


  always_ff @(posedge clk or posedge rst) begin
    if (rst) step <= 0;
    else begin
      step <= step + 1;
    end
  end



  assign finished = (stage == 8);

  logic [parallel_size-1:0][WIDTH-1:0] add3_o;
  logic [parallel_size-1:0][WIDTH-1:0] add2_o;
  logic [parallel_size-1:0][WIDTH-1:0] add1_o;
  logic [parallel_size-1:0][WIDTH-1:0] add3_i;
  logic [parallel_size-1:0][WIDTH-1:0] mul1_o;

  logic [parallel_size-1:0][tile_size:0][WIDTH-1:0] reduction_i;
  logic [tile_size:0][WIDTH-1:0] reduction_o;

  assign acc_o = reduction_o;



  always_comb begin
    if (stage == 2) add3_i = add2_o;
    else add3_i = operand1_i;
  end

  always_comb begin
    if (stage == 0 || stage == 1) mode = 1;
    else mode = 0;
  end


  for (genvar i = 0; i < parallel_size; i++) begin
    new_fp16_add add1 (
        .operands_i({operand1_i[i], operand4_i[i]}),  // 2 operands
        .result_o  (add1_o[i])
    );

    new_fp16_add add2 (
        .operands_i({add1_o[i], {~mul1_o[i][15], mul1_o[i][14:0]}}),  // 2 operands
        .result_o  (add2_o[i])
    );

    new_fp16_add add3 (  //use for reduction
        .operands_i({reduction_o[tile_size], add2_o[i]}),  // 2 operands
        .result_o  (add3_o[i])
    );

    new_fp16_mul mul1 (
        .operands_i({operand2_i[i], operand3_i[i]}),  // 2 operands
        .result_o  (mul1_o[i])
    );

    assign reduction_i[i] = {operandv_i[i], add3_o[i]};
    assign scale[i] = add2_o[i];

  end

  reduction reduct (
      .clk(clk),
      .rst(step==stage_boundary[1]|step==stage_boundary[4]|step==stage_boundary[5]|step==stage_boundary[6]),
      .set_reg_i(set_i),
      .operand_i(reduction_i),
      .reduction_o(reduction_o)
  );





endmodule
