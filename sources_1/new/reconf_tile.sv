`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/06/24 12:36:37
// Design Name: 
// Module Name: reconf_tile
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

logic [tile_size-1:0][mul_width-1:0] mulsrc1;
logic [tile_size-1:0][mul_width-1:0] mulsrc2;
logic [tile_size-1:0][mul_width-1:0] muldst;


for(genvar i=0;i<tile_size;i++)begin
    always_comb begin
        if(control==0) mulsrc2[i]=vec2[i];
        else mulsrc2[i]=scal;
    end
end



for(genvar i=0;i<tile_size;i++)begin
    fp16_mul mul(
    // Input signals
    .operands_i({mulsrc1[i],mulsrc2[i]}),  // 2 operands
    .is_boxed_i(2'b11),          // 2 operands
    .rnd_mode_i,

    // Output signals
    .result_o(muldst[i]),
    .status_o
    );
end

assign o_vec=muldst;






//adder tree

logic  [tile_size-1:0][mul_width-1:0] addsrc1;
logic [tile_size-1:0][mul_width-1:0] addsrc2;
logic [tile_size-1:0][mul_width-1:0] adddst;



for (genvar i=0;i<tile_size;i=i+2)begin
    assign addsrc1[i]={muldst[i]};
    assign addsrc2[i]={muldst[i+1]};
end
for(genvar i=2;i<(tile_size);i=i*2)begin
    for(genvar j=i-1;j<tile_size;j+=i)begin
        assign addsrc1[i]={adddst[j-i/2]};
        assign addsrc2[i]={adddst[j+i/2]};
    end
end

assign o_scal=adddst[1];


for(genvar i=0;i<tile_size;i++)begin
    fp16_add add(
    // Input signals
    .operands_i({addsrc1[i],addsrc2[i]}),  // 2 operands
    .is_boxed_i(2'b11),                  // 2 operands
    .rnd_mode_i,
    // Output signals
    .result_o(adddst[i]),
    .status_o
);
end

endmodule
