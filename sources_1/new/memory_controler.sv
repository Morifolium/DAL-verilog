`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/15 15:16:43
// Design Name: 
// Module Name: memory_controler
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


module memory_controler #(
    localparam WIDTH = 16,
    localparam parallel_size = 6,
    localparam pipe_stage = 7,
    localparam tile_size = 128,
    localparam interval = 8
) (
    input logic CLK_i,
    input logic RST_i,
    input [parallel_size-1:0][pipe_stage:0][tile_size-1:0][WIDTH-1:0] HBM_i,  //hbm2e
    output [parallel_size-1:0][pipe_stage:0][tile_size-1:0][WIDTH-1:0] HBM_o

);

  logic [parallel_size-1:0] finish;
  logic [parallel_size-1:0][pipe_stage-1:0][tile_size-1:0][WIDTH-1:0] VPE_v_o;
  logic [parallel_size-1:0][pipe_stage-1:0] mode;
  logic [parallel_size-1:0][pipe_stage-1:0][WIDTH-1:0] VPE_s_o;
  logic [1:0][interval-1:0][WIDTH-1:0] rom_o;
  logic [parallel_size-1:0][pipe_stage-1:0][tile_size-1:0][WIDTH-1:0] VPE_v1_i;
  logic [parallel_size-1:0][pipe_stage-1:0][tile_size-1:0][WIDTH-1:0] VPE_v2_i;
  logic [parallel_size-1:0][pipe_stage-1:0][WIDTH-1:0] VPE_s1_i;



  Rom_Interval u_Rom_Interval (.Rom_o(rom_o));

  VPE New_VPE (
      .operand1_i(VPE_v1_i),
      .operand2_i(VPE_v2_i),
      .operand3_i(VPE_s1_i),
      .mode(mode),
      .Vec_o(VPE_v_o),
      .Scal_o(VPE_s_o)

  );

  for (genvar i = 0; i < parallel_size; i++) begin
    logic [255:0][WIDTH-1:0] sram8_i;
    logic [255:0][WIDTH-1:0] sram7_i;
    logic [255:0][WIDTH-1:0] sram6_i;
    logic [255:0][WIDTH-1:0] sram5_i;
    logic [255:0][WIDTH-1:0] sram4_i;
    logic [255:0][WIDTH-1:0] sram3_i;
    logic [255:0][WIDTH-1:0] sram2_i;
    logic [255:0][WIDTH-1:0] sram1_i;

    logic [255:0][WIDTH-1:0] sram8_o;
    logic [255:0][WIDTH-1:0] sram7_o;
    logic [255:0][WIDTH-1:0] sram6_o;
    logic [255:0][WIDTH-1:0] sram5_o;
    logic [255:0][WIDTH-1:0] sram4_o;
    logic [255:0][WIDTH-1:0] sram3_o;
    logic [255:0][WIDTH-1:0] sram2_o;
    logic [255:0][WIDTH-1:0] sram1_o;

    logic [3:0] mode_o;
    logic [3:0] finish_o;
    assign sram1_i = HBM_i[i][0];
    assign sram2_i = HBM_i[i][1];
    assign sram3_i = HBM_i[i][2];
    assign sram4_i = HBM_i[i][3];

    assign sram1_o = HBM_o[i][0];
    assign sram2_o = HBM_o[i][1];
    assign sram3_o = HBM_o[i][2];
    assign sram4_o = HBM_o[i][3];
    assign sram5_o = HBM_o[i][5];
    assign sram6_o = HBM_o[i][6];
    assign sram7_o = HBM_o[i][7];
    assign sram8_o = HBM_o[i][8];




    pipe_stage2 u_pipe_stage2 (
        .CLK_i         (CLK_i),
        .RST_i         (RST_i),
        //.stall_i       (),
        .stage_boundary(),
        .operand_i     ({VPE_s_o[i][0], VPE_s_o[i][1]}),  //from VPE
        .scale_i       (sram8_o[1:0]),                    //from SRAM 7
        .norm_n        (sram8_o[3:2]),                    //from SRAM 7
        .pos           (sram8_o[5:4]),                    //from SRAM 0/1
        .finished      (finish_o[0]),
        .stage         (),
        .operand1_o    (sram8_o[7:6]),                    //to SRAM7
        .operand2_o    (sram8_o[9:7]),                    //to SRAM7
        .mode          (mode_o[0])
    );

    assign mode[i][0] = mode_o[0];
    assign mode[i][1] = mode_o[0];
    assign VPE_v1_i[i][0] = sram1_o;
    assign VPE_v2_i[i][1] = sram2_o;


    pipe_stage3 u_pipe_stage3 (
        .interval_lb   (rom_o[0]),
        .interval_ub   (rom_o[1]),
        .mode          (sram8_o[21:10]),  //from SRAM7
        .interval_cnt_i(sram8_o[43:21]),  //from SRAM7
        .max_score     (sram8_o[44]),     //from SRAM7
        .s_i           (sram8_o[56:45]),  //from SRAM7

        .out_of_mode_interval(),                                           //to SRAM4/5/6
        .interval_cnt_o      ({sram5_i[3:0], sram6_i[3:0], sram7_i[3:0]})  //to SRAM4/5/6
    );

    pipe_stage5 u_pipe_stage5 (
        .CLK_i         (CLK_i),
        .RST_i         (RST_i),
        .acc_s         ({VPE_s_o[i][2], VPE_s_o[i][3]}),  //to interval
        .interval_cnt_i(sram8_o[63:57]),                  //from SRAM7
        .mode_i        ({sram8_o[65:64]}),                // need to fix
        .max_cnt_i     (sram8_o[67:66]),
        .a_acc_i       ({sram3_o[0], sram4_o[0]}),        // from SRAM2/3
        .a_pos_i       ({sram3_o[1], sram4_o[1]}),        // from SRAM2/3
        .b_acc_i       ({sram3_o[2], sram4_o[2]}),        // from SRAM2/3
        .b_pos_i       ({sram3_o[3], sram4_o[3]}),        // from SRAM2/3
        .J_size        (sram8_o[68]),
        .mode_o        ({sram8_i[65:64]}),
        .interval_cnt_o(sram8_i[63:57]),
        .max_cnt_o     (sram8_i[65:54]),
        .alpha_o       ({sram5_i[4], sram6_i[4]}),        // to SRAM4/5/6
        ._alpha_o      ({sram5_i[5], sram6_i[5]}),        // to SRAM4/5/6
        .beta_o        ({sram5_i[6], sram6_i[6]}),        // to SRAM4/5/6
        .acc_interval_o({sram5_i[7], sram6_i[7]}),        // to SRAM4/5/6
        .U_add         (),                                // to SRAM4/5/6
        .finished      (finish_o[2]),
        .mode          (mode_o[2])
    );
    assign mode[i][2] = mode_o[2];
    assign mode[i][3] = mode_o[2];
    assign VPE_v1_i[i][2] = sram2_o;
    assign VPE_v2_i[i][3] = sram3_o;


    logic [2:0][WIDTH-1:0] scale_wire;
    logic [parallel_size-1:0][tile_size-1:0][WIDTH-1:0] acc_o;
    pipe_stage6 u_pipe_stage6 (
        .clk_i         (CLK_i),
        .rst_i         (RST_i),
        .operandv_i    ({VPE_v_o[i][4], VPE_v_o[i][5], VPE_v_o[i][6]}),
        .operand1_i    ({VPE_s_o[i][4], VPE_s_o[i][5], VPE_s_o[i][6]}),
        .operand2_i    (sram8_o[70:68]),
        .operand3_i    (sram8_o[73:71]),
        .operand4_i    (sram8_o[76:74]),
        .stage_boundary(),
        .set_i         (0),
        .scale         (scale_wire),
        .finished      (finish_o[3]),
        .mode          (mode_o[3]),
        .acc_o         (acc_o)                                                //to SRAM
    );
    assign sram8_i[255:128]=acc_o;

    assign mode[i][4] = mode_o[3];
    assign mode[i][5] = mode_o[3];
    assign mode[i][6] = mode_o[3];

    assign VPE_v1_i[i][4] = sram5_o;
    assign VPE_v2_i[i][5] = sram6_o;
    assign VPE_v1_i[i][6] = sram7_o;

    assign VPE_s1_i[i][6:4] = scale_wire;

    assign finish[i] = |finish_o;

    sram_controler #(
        .BITWIDTH(256),
        .WIDTH   (16)
    ) u_sram_controler1 (
        .CKL_i(CKL_i),
        .RST_i(RST_i),
        .ADDR_in(),
        .ADDR_out(),
        .SRAM_i(sram1_i),
        .SRAM_o(sram1_o)
    );

    sram_controler #(
        .BITWIDTH(256),
        .WIDTH   (16)
    ) u_sram_controler2 (
        .CKL_i(CKL_i),
        .RST_i(RST_i),
        .ADDR_in(),
        .ADDR_out(),
        .SRAM_i(sram2_i),
        .SRAM_o(sram2_o)
    );

    sram_controler #(
        .BITWIDTH(256),
        .WIDTH   (16)
    ) u_sram_controler3 (
        .CKL_i(CKL_i),
        .RST_i(RST_i),
        .ADDR_in(),
        .ADDR_out(),
        .SRAM_i(sram3_i),
        .SRAM_o(sram3_o)
    );

    sram_controler #(
        .BITWIDTH(256),
        .WIDTH   (16)
    ) u_sram_controler4 (
        .CKL_i(CKL_i),
        .RST_i(RST_i),
        .ADDR_in(),
        .ADDR_out(),
        .SRAM_i(sram4_i),
        .SRAM_o(sram4_o)
    );

    sram_controler #(
        .BITWIDTH(256),
        .WIDTH   (16)
    ) u_sram_controler5 (
        .CKL_i(CKL_i),
        .RST_i(RST_i),
        .ADDR_in(),
        .ADDR_out(),
        .SRAM_i(sram5_i),
        .SRAM_o(sram5_o)
    );

    sram_controler #(
        .BITWIDTH(256),
        .WIDTH   (16)
    ) u_sram_controler6 (
        .CKL_i(CKL_i),
        .RST_i(RST_i),
        .ADDR_in(),
        .ADDR_out(),
        .SRAM_i(sram6_i),
        .SRAM_o(sram6_o)
    );

    sram_controler #(
        .BITWIDTH(256),
        .WIDTH   (16)
    ) u_sram_controler7 (
        .CKL_i(CKL_i),
        .RST_i(RST_i),
        .ADDR_in(),
        .ADDR_out(),
        .SRAM_i(sram7_i),
        .SRAM_o(sram7_o)
    );

    sram_controler #(
        .BITWIDTH(256),
        .WIDTH   (16)
    ) u_sram_controler8 (
        .CKL_i(CKL_i),
        .RST_i(RST_i),
        .ADDR_in(),
        .ADDR_out(),
        .SRAM_i(sram8_i),
        .SRAM_o(sram8_o)
    );


  end



endmodule
