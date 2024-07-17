`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2024/07/15 15:16:43
// Design Name:
// Module Name: memory_controler
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


module sram_controler #(
    parameter BITWIDTH = 256,
    parameter WIDTH=16
)(
    input logic CKL_i,
    input logic RST_i,
    input logic [WIDTH-1:0]ADDR_in, // 一次读取BITWIDTH*WIDTH的数据
    input logic [WIDTH-1:0]ADDR_out,
    input logic [BITWIDTH-1:0][WIDTH-1:0] SRAM_i,
    output logic [BITWIDTH-1:0][WIDTH-1:0] SRAM_o
);

assign SRAM_o=SRAM_i;


endmodule
