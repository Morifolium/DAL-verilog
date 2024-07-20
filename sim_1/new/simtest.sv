`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/14 21:07:14
// Design Name: 
// Module Name: simtest
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


module simtest ();

  logic clk;
  logic rst;
  logic stall;
  logic boundary;
  logic operand_i;
  logic scale_i;  // scale or norm_pos
  logic norm_n;
  logic pos;
  logic finished;
  logic stage;
  logic operand1;
  logic operand2;
  logic mode;  //reconfigtile mode
  logic [100:0][15:0] op;
  logic [100:0][15:0] new_op;

  //*
  pipe_stage2 p2 (
      .CLK_i(clk),
      .RST_i(rst),
      .stall_i(stall),
      .stage_boundary(boundary),
      .operand_i(operand_i),
      .scale_i(scale_i),  // scale or norm_pos
      .pos(pos),
      .finished(finished),
      .stage(stage),
      .operand1_o(operand1),
      .operand2_o(operand2),
      .mode(mode)  //reconfigtile mode
  );
  //*/
  /*
    pipe_stage3 stage_3
    (
  .interval_lb(clk),
  .interval_ub(rst),
  .mode(stall),
  .interval_cnt_i(boundary),
  .max_score(operand_i),
  .s_i(scale_i),
  .out_of_mode_interval(norm_n),
  .interval_cnt_o(mode)
);
*/


  /*
  pipe_stage5 pip5 (
      .CLK_i(op[0]),
      .RST_i(op[1]),
      .acc_s(32'b0),
      .interval_cnt_i(256'b0),
      .mode_i(op[4]),
      .mode_o(op[5]),
      .interval_cnt_o(op[6]),

      .max_cnt_i(op[7]),
      .max_cnt_o(op[8]),

      .alpha_o (op[9]),
      ._alpha_o(op[10]),
      .beta_o  (op[11]),

      .acc_interval_o(new_op[15:0]),

      .a_acc_i(op[13]),
      .a_pos_i(op[14]),
      .b_acc_i(op[15]),
      .b_pos_i(op[16]),
      .U_add  (op[17]),


      .J_size  (op[18]),
      .finished(op[19]),

      .mode(op[20])
      //VPE always 1
  );

  //*/
  /*
pipe_stage6 ppe6
(
.clk_i(op[0][0]),
.rst_i(op[1][0]),
.finished(op[2][0]),
.operandv_i(op[3]),
.operand1_i(op[4]),
.operand2_i(op[5]),
.operand3_i(op[6]),
.operand4_i(op[7]),
.stage_boundary(op[8]),
.set_i(op[9]),
.mode(op[10][0]),
.acc_o(op[11])
);
*/
  /*
  memory_controler u_memory_controler (
      .CLK_i(),
      .RST_i(),
      .HBM_i(),

      .HBM_o()
  );

*/


  initial begin
    op[0] = 0;
    op[1] = 0;
    #10 $finish;
  end




endmodule
