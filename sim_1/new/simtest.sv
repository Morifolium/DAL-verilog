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

logic A;
logic B;


pipe_stage2 p2
    (
    .CLK_i(A),
    .RST_i(B),
    .stall_i,

    .stage_boundary,

    .operand_i, 
    .scale_i, // scale or norm_pos
    .norm_n,
    .pos,


    .finished,
    .stage,
    
    .operand1_o,
    .operand2_o,


    .mode    //reconfigtile mode

    );

    initial
    begin
    A=1;
    B=0;
    
    #10
    $finish;
    
    end


endmodule
