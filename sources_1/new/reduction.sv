`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/10 16:55:26
// Design Name: 
// Module Name: reduction
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


module reduction #(
    localparam fpnew_pkg::fp_format_e   FpFormat    = fpnew_pkg::fp_format_e'(3),
    localparam int unsigned WIDTH = fpnew_pkg::fp_width(FpFormat),
    localparam tile_size=129,
    localparam parallel_size=3
)
(
    input logic CLK_i,
    input logic RST_i,
    [tile_size-1:0][WIDTH-1:0] set_reg_i,
    input logic [parallel_size-1:0][tile_size-1:0][WIDTH-1:0] operand_i,
    output logic [tile_size-1:0][WIDTH-1:0] reduction_o
);

logic [tile_size-1:0][WIDTH-1:0] acc;

logic [tile_size-1:0][WIDTH-1:0] add1_o;
logic [tile_size-1:0][WIDTH-1:0] add2_o;
logic [tile_size-1:0][WIDTH-1:0] add3_o;

for(genvar i=0;i<tile_size;i++) begin
    fp16_add add1(
    .operands_i({operand_i[0][i],operand_i[1][i]}), // 2 operands
    .is_boxed_i(2'b11), // 2 operands
    .rnd_mode_i(),
    // Output signals
    .result_o(add1_o[i]),
    .status_o()
    );

    fp16_add add2(
    .operands_i({operand_i[2][i],acc}), // 2 operands
    .is_boxed_i(2'b11), // 2 operands
    .rnd_mode_i(),
    // Output signals
    .result_o(add2_o[i]),
    .status_o()
    );

    fp16_add add3(
    .operands_i({add2_o[i],add1_o[i]}), // 2 operands
    .is_boxed_i(2'b11), // 2 operands
    .rnd_mode_i(),
    // Output signals
    .result_o(add3_o[i]),
    .status_o()
    );

    // Flip-Flop with asynchronous active-high reset
    // __q: Q output of FF
    // __d: D input of FF
    // __reset_value: value assigned upon reset
    // __clk: clock input
    // __arst: asynchronous reset
    //`define FFAR(__q, __d, __reset_value, __clk, __arst)
    //FFAR(acc[i],add3_o[i], set_reg_i[i], CLK_i, RST_i);

    FFReduct ReductReg1(
    .d(add3_o[i]),
    .reset_value(set_reg_i[i]),
    .clk(CLK_i),
    .rst(RST_i),
    .q_o(acc[i])
    );
end

assign reduction_o=acc;

endmodule
