module pipe_stage6_timing #(
    localparam int unsigned WIDTH = 16,
    localparam parallel_size = 3,
    localparam para = 8,
    localparam tile_size = 128
) (
    input logic clk,
    input logic rst,
    input logic [parallel_size-1:0][WIDTH-1:0] operand1_i,
    input logic [parallel_size-1:0][WIDTH-1:0] operand2_i,
    input logic [parallel_size-1:0][WIDTH-1:0] operand3_i,
    input logic [parallel_size-1:0][WIDTH-1:0] operand4_i,
    input logic [7:0][para-1:0] stage_boundary,
    input logic [tile_size:0][WIDTH-1:0] set_i,
    input logic [parallel_size-1:0][tile_size-1:0][WIDTH-1:0] operandv1_i,
    input logic [parallel_size-1:0][tile_size-1:0][WIDTH-1:0] operandv2_i,


    output logic finished,
    output logic [parallel_size-1:0][tile_size-1:0][WIDTH-1:0] acc_o,
    output logic [parallel_size-1:0][WIDTH-1:0] Scal_o

);

  wire [parallel_size-1:0][tile_size-1:0][WIDTH-1:0] operandv_i;
  wire mode;
  wire [parallel_size-1:0][WIDTH-1:0] scale;


  pipe_stage6 u_pipe_stage6 (
      .clk           (clk),
      .rst           (rst),
      .operandv_i    (operandv_i),
      .operand1_i    (operand1_i),
      .operand2_i    (operand2_i),
      .operand3_i    (operand3_i),
      .operand4_i    (operand4_i),
      .stage_boundary(stage_boundary),
      .set_i         (set_i),

      .finished(finished),
      .mode    (mode),
      .scale   (scale),
      .acc_o   (acc_o),
      .stage   ()
  );

  VPE_pipe_stage6 u_VPE_pipe_stage6 (
      .operand1_i(operandv1_i),
      .operand2_i(operandv2_i),
      .operand3_i(scal),
      .mode      ({mode, mode, mode}),

      .Vec_o (operandv_i),
      .Scal_o(Scal_o)
  );

endmodule
