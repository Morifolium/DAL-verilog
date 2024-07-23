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

module reconf_tile #(
    localparam     tile_size = 128,
    localparam int mul_width = 16,
    localparam int add_width = 16



) (
    input logic clk,
    input logic [tile_size-1:0][mul_width-1:0] vec1,
    input logic [tile_size-1:0][mul_width-1:0] vec2,
    input logic [mul_width-1:0] scal,
    input logic control,  // 1:scal  0:vec
    output [add_width-1:0] o_scal,
    output [tile_size-1:0][mul_width-1:0] o_vec

);

  logic [tile_size-1:0][mul_width-1:0] mulsrc1;
  logic [tile_size-1:0][mul_width-1:0] mulsrc2;
  logic [tile_size-1:0][mul_width-1:0] muldst;

  assign mulsrc1 = vec1;
  for (genvar i = 0; i < tile_size; i++) begin
    always_comb begin
      if (control == 0) mulsrc2[i] = vec2[i];
      else mulsrc2[i] = scal;
    end
  end



  for (genvar i = 0; i < tile_size; i++) begin
    new_fp16_mul mul (
        .operands_i({mulsrc1[i], mulsrc2[i]}),  // 2 operands
        .result_o  (muldst[i])
    );
  end

  assign o_vec = muldst;






  //adder tree

  logic [tile_size-1:0][mul_width-1:0] addsrc1;
  logic [tile_size-1:0][mul_width-1:0] addsrc2;
  logic [tile_size-1:0][mul_width-1:0] adddst;



  for (genvar i = 0; i < tile_size; i = i + 2) begin
    assign addsrc1[i] = {muldst[i]};
    assign addsrc2[i] = {muldst[i+1]};
  end

  for (genvar i = 2; i <= (tile_size); i = i * 2) begin //128 64 / 32 16 8/ 4 2 1/
    for (genvar j = i - 1; j < tile_size - 1; j += 2 * i) begin
      if (i == 2) begin
        reg [add_width-1:0] add_reg1;
        reg [add_width-1:0] add_reg2;
        always_ff @(posedge clk) begin
          add_reg1 <= adddst[j-i/2];
          add_reg2 <= adddst[j+i/2];
        end
        assign addsrc1[j] = add_reg1;
        assign addsrc2[j] = add_reg2;
      end else if (i == 16) begin
        reg [add_width-1:0] add_reg1;
        reg [add_width-1:0] add_reg2;
        always_ff @(posedge clk) begin
          add_reg1 <= adddst[j-i/2];
          add_reg2 <= adddst[j+i/2];
        end
        assign addsrc1[j] = add_reg1;
        assign addsrc2[j] = add_reg2;
      end else begin
        assign addsrc1[j] = {adddst[j-i/2]};
        assign addsrc2[j] = {adddst[j+i/2]};
      end
    end
  end

  assign o_scal = adddst[63];


  for (genvar i = 0; i < tile_size - 1; i++) begin
    new_fp16_add add (
        .operands_i({addsrc1[i], addsrc2[i]}),  // 2 operands
        .result_o  (adddst[i])
    );
  end

endmodule
