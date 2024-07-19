module adder_fp16 (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        mode,
    input  logic [15:0] op_a,
    input  logic [15:0] op_b,
    output logic        done,
    output logic [15:0] res_o
);
//  mode = 0: res_o = op_a + op_b;
//  mode = 1: res_o = op_a - op_b;

// configurable parameter
localparam fpnew_pkg::fp_format_e FpFormat    = fpnew_pkg::FP16;
localparam int unsigned NumPipeRegs = 2;
localparam fpnew_pkg::pipe_config_t PipeConfig = fpnew_pkg::BEFORE;

// configurable logic signals
logic [2:0] is_boxed = '{3'b111, 3'b111, 3'b111};    // 表征 数据格式
fpnew_pkg::roundmode_e rnd_mode = fpnew_pkg::RNE;    // 舍入模式
fpnew_pkg::operation_e op = fpnew_pkg::ADD;          // op_mode_ctrl_1
logic op_mod;                                 // op_mode_ctrl_2 : op_modifier_i
logic [1:0] reg_ena = 2'b11;                         // pipe_reg_en,启用所有寄存器

assign op_mod = mode;

// input and output data
logic [2:0][15:0] operands;
logic [15:0] result;
assign operands[0] = 16'h0;
assign operands[1] = op_a;
assign operands[2] = op_b;
assign res_o = result;


// handshake signals - free
// logic in_valid;
// logic out_valid;
logic in_ready;
logic out_ready;

fpnew_fma #(
    .FpFormat(FpFormat),
    .NumPipeRegs(NumPipeRegs),
    .PipeConfig(PipeConfig)
  ) u_fpnew_fma (
    .clk_i(clk),
    .rst_ni(rst_n),
    .operands_i(operands),
    .is_boxed_i(is_boxed),
    .rnd_mode_i(rnd_mode),
    .op_i(op),
    .op_mod_i(op_mod),
    .in_valid_i(1'b1),
    // .in_ready_o(in_ready),
    .result_o(result),
    .out_valid_o(done),
    // .out_ready_i(out_ready),
    .flush_i(1'b0),
    .reg_ena_i(reg_ena)
  );
endmodule