`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/04 14:31:36
// Design Name: 
// Module Name: pipe_fp16_sqrt
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


module pipe_fp16_divsqrt
    #(
  localparam fpnew_pkg::fmt_logic_t   FpFmtConfig  = 5'b00100,
  // FPU configuration
  localparam int unsigned             NumPipeRegs = 0,
  localparam fpnew_pkg::pipe_config_t PipeConfig  = fpnew_pkg::AFTER,
  localparam type                     TagType     = logic,
  localparam type                     AuxType     = logic,
  localparam fp16_div_cycle=5,
  // Do not change
  localparam int unsigned WIDTH       = fpnew_pkg::max_fp_width(FpFmtConfig),
  localparam int unsigned NUM_FORMATS = fpnew_pkg::NUM_FP_FORMATS,
  localparam int unsigned ExtRegEnaWidth = NumPipeRegs == 0 ? 1 : NumPipeRegs

)
(
    input logic CLK_i,
    input logic RST_i,
    input [WIDTH-1:0]operand_i,
    input  fpnew_pkg::operation_e       OP_i,
    output [WIDTH-1:0]RESULT_o,
    output logic ready_o

);

logic [2:0] step;
always_ff @(posedge CLK_i or RST_i)begin
    if(RST_i) step=0;
    else step=step+1;
end

logic [fp16_div_cycle-1:0][WIDTH-1:0] in2sqrt;

always_comb begin
    unique case (step%5)
        0:in2sqrt[0]=operand_i;
        1:in2sqrt[1]=operand_i;
        2:in2sqrt[2]=operand_i;
        3:in2sqrt[3]=operand_i;
        4:in2sqrt[4]=operand_i;
        default: in2sqrt[0]=operand_i;
    endcase
end

for( genvar i=0;i<fp16_div_cycle;i++)begin

fpnew_divsqrt_multi fp16_sqrt(
.clk_i(CLK_i),
.rst_ni(RST_i),
  // Input signals
.operands_i(in2sqrt[i]), // 2 operands
.is_boxed_i(2'b11), // 2 operands
.rnd_mode_i,
.op_i(OP_i),
.dst_fmt_i(fpnew_pkg::fp_format_e'(3)),
  // Input Handshake
.in_valid_i(1'b1),
  // Output signals
.result_o(RESULT_o)
);

end


endmodule
