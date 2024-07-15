`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/03 17:47:07
// Design Name: 
// Module Name: pipe_stage5
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


module pipe_stage5
#(
    localparam fpnew_pkg::fp_format_e   FpFormat    = fpnew_pkg::fp_format_e'(3),
    localparam int unsigned WIDTH = 16,
    localparam interval_size=8,
    localparam para=16
)
(
    input logic CLK_i,
    input logic RST_i,
    input logic [WIDTH-1:0] acc_s,
    input logic [interval_size-1:0][para-1:0] interval_cnt_i,
    input logic [interval_size-1:0] mode_i,
    output logic [interval_size-1:0] mode_o,
    output logic [interval_size-1:0][para-1:0] interval_cnt_o,

    input logic [para-1:0] max_cnt_i,
    output logic [para-1:0] max_cnt_o,

    output logic [WIDTH-1:0] alpha_o,
    output logic [WIDTH-1:0] _alpha_o,
    output logic [WIDTH-1:0] beta_o,

    output logic [interval_size-1:0] acc_interval_o, 

    input logic [WIDTH-1:0] a_acc_i,
    input logic [WIDTH-1:0] a_pos_i,
    input logic [WIDTH-1:0] b_acc_i,
    input logic [WIDTH-1:0] b_pos_i,
    output logic U_add,


    input [para-1:0]J_size,
    output logic finished,

    output logic mode
    //VPE always 1

    );

    assign mode=1;

    logic [interval_size-1:0]acc_interval;

interval check_int
(
    .s_i(acc_s),
    .interval_o(acc_interval)
);

assign acc_interval_o=acc_interval;

logic [para-1:0] current_cnt;

always_comb begin
    unique case (acc_interval)
        8'b00000001: current_cnt=interval_cnt_i[0]+1;
        8'b00000010: current_cnt=interval_cnt_i[1]+1;
        8'b00000100: current_cnt=interval_cnt_i[2]+1;
        8'b00001000: current_cnt=interval_cnt_i[3]+1;
        8'b00010000: current_cnt=interval_cnt_i[4]+1;
        8'b00100000: current_cnt=interval_cnt_i[5]+1;
        8'b01000000: current_cnt=interval_cnt_i[6]+1;
        8'b10000000: current_cnt=interval_cnt_i[7]+1;
        default: current_cnt=interval_cnt_i[0]+1;
    endcase
end


for(genvar i=0;i<interval_size;i++) begin
    always_comb begin
        interval_cnt_o[i]=(acc_interval[i]&(1<<i))?current_cnt:interval_cnt_i[i];
    end
end

logic [WIDTH-1:0] alpha_t;
logic [WIDTH-1:0] _alpha_t;
logic [WIDTH-1:0] beta_t;


fp16_add add1(
.operands_i({a_acc_i,{~a_pos_i[15],a_pos_i[14:0]}}), // 2 operands
.is_boxed_i(2'b11), // 2 operands
//.rnd_mode_i,
  // Output signals
.result_o(alpha_t)
//.status_o
);

fp16_add add2(
.operands_i({b_acc_i,{~b_pos_i[15],b_pos_i[14:0]}}), // 2 operands
.is_boxed_i(2'b11), // 2 operands
//.rnd_mode_i,
  // Output signals
.result_o(beta_t)
//.status_o
);

fp16_mul mul1(
.operands_i({alpha_t,acc_s}), // 2 operands
.is_boxed_i(2'b11), // 2 operands
//.rnd_mode_i
  // Output signals
.result_o(_alpha_t)
//.status_o
);


assign alpha_o=acc_interval==mode_i?0:alpha_t;
assign _alpha_o=acc_interval==mode_i?0:_alpha_t;
assign beta_o=acc_interval==mode_i?0:beta_t;


assign U_add=current_cnt>max_cnt_i;
always_comb begin
    if(U_add) begin
        mode_o=acc_interval;
        max_cnt_o=current_cnt;
    end
end

logic [para-1:0] step;

always_ff @(posedge CLK_i or RST_i)begin
    if(RST_i) step=0;
    else step=step+1;
end

assign finished=(step>=J_size);

endmodule
