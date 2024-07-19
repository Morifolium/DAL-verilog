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

`include "registers.svh"

module interval#(
    localparam fpnew_pkg::fp_format_e   FpFormat    = fpnew_pkg::fp_format_e'(2),
    localparam int unsigned WIDTH = fpnew_pkg::fp_width(FpFormat),
    localparam num=8
)
(
    input logic [WIDTH-1:0] s_i,
    output logic [num-1:0] interval_o
    );
logic [num-2:0][WIDTH-1:0] boundary;
logic [num:0] result;

assign boundary=112'b0;

assign result[0]=1;
assign result[8]=0;

for(genvar i=0;i<num-1;i++)begin
    fpnew_noncomp  cmp(
    // Input signals
    .operands_i({s_i,boundary[i]}), // 2 operands
    .is_boxed_i(2'b11), // 2 operands
    .op_i(fpnew_pkg::CMP),
    // Output signals
    .extension_bit_o(result[i+1])
);

end

for(genvar i=0;i<num;i++)
    assign interval_o[i]=result[i]^result[i+1];




endmodule
