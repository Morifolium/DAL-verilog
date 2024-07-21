`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/02 09:41:32
// Design Name: 
// Module Name: VPE
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


module VPE_pipe_stage6 #(
    localparam parallel_size = 1,
    localparam pipe_stage = 3,
    localparam tile_size = 128,
    localparam int mul_width = 16,
    localparam int add_width = 16
) (
    input logic [pipe_stage-1:0][tile_size-1:0][mul_width-1:0] operand1_i,
    input logic [pipe_stage-1:0][tile_size-1:0][mul_width-1:0] operand2_i,
    input logic [pipe_stage-1:0][mul_width-1:0] operand3_i,
    input logic [pipe_stage-1:0] mode,
    output logic [pipe_stage-1:0][tile_size-1:0][mul_width-1:0] Vec_o,
    output logic [pipe_stage-1:0][mul_width-1:0] Scal_o

);


  for (genvar j = 0; j < pipe_stage; j++) begin
    reconf_tile VPE_tile (
        .vec1(operand1_i[j]),
        .vec2(operand2_i[j]),
        .scal(operand3_i[j]),
        .control(mode[j]),  //
        .o_vec(Vec_o[j]),
        .o_scal(Scal_o[j])
    );
  end

endmodule


/*
module VPE
    #(
        localparam parallel_size = 1,
        localparam pipe_stage=2,
        localparam tile_size=128,
        localparam int mul_width=16,
        localparam int add_width=16
    )
    (
        input [parallel_size-1:0][pipe_stage-1:0][tile_size-1:0][mul_width-1:0] operand1_i,
        input [parallel_size-1:0][pipe_stage-1:0][tile_size-1:0][mul_width-1:0] operand2_i,
        input [parallel_size-1:0][pipe_stage-1:0][mul_width-1:0] operand3_i,
        input logic [parallel_size-1:0][pipe_stage-1:0]mode,
        output [parallel_size-1:0][pipe_stage-1:0][tile_size-1:0][mul_width-1:0] Vec_o,
        output [parallel_size-1:0][pipe_stage-1:0][mul_width-1:0] Scal_o
        
    );

    for(genvar i=0;i<parallel_size;i++)begin
        for(genvar j=0;j<pipe_stage;j++)begin
            reconf_tile VPE_tile(
            .vec1(operand1_i[i][j]),
            .vec2(operand2_i[i][j]),
            .scal(operand3_i[i][j]),
            .control(mode[i][j]),  //
            .o_vec(Vec_o[i][j]),
            .o_scal(Scal_o[i][j])
            );
        end
    end
endmodule
/*

// VPE+ vec1_改为寄存器  


/*
module reconf_tile #(
 localparam tile_size=128,
 localparam fpnew_pkg::fp_format_e       mul_fmt=fpnew_pkg::fp_format_e'(3),
 localparam fpnew_pkg::fp_format_e       add_fmt=fpnew_pkg::fp_format_e'(3),
 localparam int mul_width=fpnew_pkg::fp_width(mul_fmt),
 localparam int add_width=fpnew_pkg::fp_width(add_fmt)
)
(
    input logic [tile_size-1:0][mul_width-1:0]vec1,
    input logic [tile_size-1:0][mul_width-1:0]vec2,
    input logic [mul_width-1:0]scal,
    input logic control,  // 1:scal  0:vec
    output [add_width-1:0]  o_scal,
    output [tile_size-1:0][mul_width-1:0] o_vec

);
*/
