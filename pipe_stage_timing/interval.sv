`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/03 15:01:07
// Design Name: 
// Module Name: interval
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


module interval #(
    localparam int unsigned WIDTH = 16,
    localparam num = 8
) (
    input logic [WIDTH-1:0] s_i,
    input logic [num-2:0][WIDTH-1:0] boundary,
    output logic [num-1:0] interval_o
);
  logic [num:0] result;
  assign result[0] = 1;
  assign result[8] = 0;

  for (genvar i = 0; i < num - 1; i++) begin
    new_fp16_cmp cmp (
        // Input signals
        .operands_i({s_i, boundary[i]}),  // 2 operands
        .result_o  (result[i+1])
    );

  end

  for (genvar i = 0; i < num; i++) assign interval_o[i] = result[i] ^ result[i+1];




endmodule
