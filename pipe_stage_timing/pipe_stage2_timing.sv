`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/02 11:14:03
// Design Name: 
// Module Name: pipe_stage2
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



module pipe_stage2_timing #(
    localparam n = 4096,
    localparam para = 8,
    localparam int WIDTH = 16,
    localparam int parallel_size = 2,
    localparam tile_size = 128

) (
    input logic clk_i,
    input logic rst_i,

    input logic [6:0][para-1:0] stage_boundary,

    input logic [parallel_size-1:0][WIDTH-1:0] operand_i,
    input logic [parallel_size-1:0][WIDTH-1:0] scale_i,    // scale or norm_pos
    //input logic [parallel_size-1:0][WIDTH-1:0] norm_n,
    input logic [parallel_size-1:0][WIDTH-1:0] pos,


    output logic finished,
    output logic [2:0] stage,

    output logic [parallel_size-1:0][WIDTH-1:0] operand1_o,
    output logic [parallel_size-1:0][WIDTH-1:0] operand2_o,
    input logic [1:0][parallel_size-1:0][tile_size-1:0][WIDTH-1:0] vec_i,
    input logic [parallel_size-1:0][WIDTH-1:0] no_vec_i,
    output logic [parallel_size-1:0][tile_size-1:0][WIDTH-1:0] vec_o
);


  logic [parallel_size-1:0][WIDTH-1:0] Scal_wire;
  logic  mode_wire;
  pipe_stage2 U_pip2 (
      .clk_i(clk_i),
      .rst_i(rst_i),
      .stage_boundary(stage_boundary),
      .operand_i(Scal_wire),
      .scale_i(scale_i),  // scale or norm_pos
      //input logic [parallel_size-1:0][WIDTH-1:0] norm_n,
      .pos(pos),
      .finished(finish),
      .stage(stage),
      .operand1_o(operand1_o),
      .operand2_o(operand2_o),
      .mode(mode_wire)  //reconfigtile mode

  );

  VPE pip2_VPE (
      .operand1_i(vec_i[0]),
      .operand2_i(vec_i[1]),
      .operand3_i(no_vec_i),
      .mode({mode_wire,mode_wire}),
      .Vec_o(vec_o),
      .Scal_o(Scal_wire)

  );


endmodule
