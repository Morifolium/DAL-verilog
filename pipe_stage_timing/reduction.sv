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


module reduction #(
    localparam int unsigned WIDTH = 16,
    localparam tile_size=129,
    localparam parallel_size=3
)
(
    input logic clk,
    input logic rst,
    [tile_size-1:0][WIDTH-1:0] set_reg_i,
    input logic [parallel_size-1:0][tile_size-1:0][WIDTH-1:0] operand_i,
    output logic [tile_size-1:0][WIDTH-1:0] reduction_o
);

logic [tile_size-1:0][WIDTH-1:0] acc;

logic [tile_size-1:0][WIDTH-1:0] add1_o;
logic [tile_size-1:0][WIDTH-1:0] add2_o;
logic [tile_size-1:0][WIDTH-1:0] add3_o;

for(genvar i=0;i<tile_size;i++) begin
    new_fp16_add add1(
    .operands_i({operand_i[0][i],operand_i[1][i]}), // 2 operands
    .result_o(add1_o[i])
    );

    new_fp16_add add2(
    .operands_i({operand_i[2][i],acc[i]}), // 2 operands
    .result_o(add2_o[i])
    );

    new_fp16_add add3(
    .operands_i({add2_o[i],add1_o[i]}), // 2 operands
    .result_o(add3_o[i])
    );



    always_ff@(posedge clk or posedge rst) begin
        if(rst) acc[i]<=set_reg_i[i];
        else acc[i]<=add3_o[i];
    end

end

assign reduction_o=acc;

endmodule
