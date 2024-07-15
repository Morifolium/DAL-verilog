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


module simtest(

    );

logic clk;
logic rst;
logic stall;
logic boundary;
logic operand_i; 
logic scale_i; // scale or norm_pos
logic norm_n;
logic pos;
logic finished;
logic stage;
logic operand1;
logic operand2;
logic mode;    //reconfigtile mode


    pipe_stage2 p2
    (
    .CLK_i(clk),
    .RST_i(rst),
    .stall_i(stall),
    .stage_boundary(boundary),
    .operand_i(operand_i), 
    .scale_i(scale_i), // scale or norm_pos
    .norm_n(norm_n),
    .pos(pos),
    .finished(finished),
    .stage(stage),
    .operand1_o(operand1),
    .operand2_o(operand2),
    .mode(mode)    //reconfigtile mode
    );

    initial begin
        clk=0;
        rst=0;
        #10
        $finish;
    end

    


endmodule
