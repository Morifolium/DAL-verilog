module pipe_stage5_timing #(
    localparam int unsigned WIDTH = 16,
    localparam interval_size = 8,
    localparam para = 8,
    localparam parallel_size = 2,
    localparam tile_size = 128
) (
    input logic clk,
    input logic rst,
    input logic [parallel_size-1:0][tile_size-1:0][WIDTH-1:0] Q,
    input logic [parallel_size-1:0][tile_size-1:0][WIDTH-1:0] K,
    input logic [parallel_size-1:0][WIDTH-1:0] V,

    input logic [interval_size-1:0][         para-1:0] interval_cnt_i,
    input logic [parallel_size-1:0][interval_size-1:0] mode_i,
    input logic [parallel_size-1:0][         para-1:0] max_cnt_i,
    input logic [parallel_size-1:0][        WIDTH-1:0] a_acc_i,
    input logic [parallel_size-1:0][        WIDTH-1:0] a_pos_i,
    input logic [parallel_size-1:0][        WIDTH-1:0] b_acc_i,
    input logic [parallel_size-1:0][        WIDTH-1:0] b_pos_i,
    input logic [         para-1:0]                    J_size,

    output logic [parallel_size-1:0][interval_size-1:0]           mode_o,
    output logic [interval_size-1:0][         para-1:0]           interval_cnt_o,
    output logic [parallel_size-1:0][         para-1:0]           max_cnt_o,
    output logic [parallel_size-1:0][        WIDTH-1:0]           alpha_o,
    output logic [parallel_size-1:0][        WIDTH-1:0]           _alpha_o,
    output logic [parallel_size-1:0][        WIDTH-1:0]           beta_o,
    output logic [parallel_size-1:0][interval_size-1:0][para-1:0] acc_interval_o,
    output logic [parallel_size-1:0]                              U_add,
    output logic                                                  finished,
    output logic [parallel_size-1:0][tile_size-1:0][WIDTH-1:0] K_o

);

  wire [parallel_size-1:0][WIDTH-1:0] acc_s;
  wire mode;

  pipe_stage5 u_pipe_stage5 (
      .clk           (clk),
      .rst           (rst),
      .acc_s         (acc_s),
      .interval_cnt_i(interval_cnt_i),
      .mode_i        (mode_i),
      .max_cnt_i     (max_cnt_i),
      .a_acc_i       (a_acc_i),
      .a_pos_i       (a_pos_i),
      .b_acc_i       (b_acc_i),
      .b_pos_i       (b_pos_i),
      .J_size        (J_size),

      .mode_o        (mode_o),
      .interval_cnt_o(interval_cnt_o),
      .max_cnt_o     (max_cnt_o),
      .alpha_o       (alpha_o),
      ._alpha_o      (_alpha_o),
      .beta_o        (beta_o),
      .acc_interval_o(acc_interval_o),
      .U_add         (U_add),
      .finished      (finished),
      .mode          (mode)

  );

  VPE u_VPE (
      .operand1_i(Q),
      .operand2_i(K),
      .operand3_i(V),
      .mode      ({mode, mode}),

      .Vec_o (K_o),
      .Scal_o(acc_s)
  );



endmodule
