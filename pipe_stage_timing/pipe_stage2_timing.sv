`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/02 11:14:03
// Design Name: 
// Module Name: pipe_stage2
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



module pipe_stage2 #(
    localparam n = 4096,
    localparam para = 8,
    localparam int  WIDTH = 16,
    localparam int parallel_size = 2 

) (
    input logic CLK_i,
    input logic RST_i,
    input logic stall_i,    //VPE 输入接入

    input logic [6:0][para-1:0] stage_boundary,

    input logic [parallel_size-1:0][WIDTH-1:0] operand_i,
    input logic [parallel_size-1:0][WIDTH-1:0] scale_i,    // scale or norm_pos
    //input logic [parallel_size-1:0][WIDTH-1:0] norm_n,
    input logic [parallel_size-1:0][WIDTH-1:0] pos,


    output logic finished,
    output logic [2:0] stage,

    output logic [parallel_size-1:0][WIDTH-1:0] operand1_o,
    output logic [parallel_size-1:0][WIDTH-1:0] operand2_o,


    output logic mode  //reconfigtile mode

);



  //maxscore 寄存器 max_norm normn

  logic [para-1:0] step;

  /*

  always_ff @(posedge CLK_i or posedge RST_i) begin
    if (RST_i) begin
      step  <= 0;
      stage <= 0;
    end else if (stall_i) step <= step;
    else begin
      step <= step + 1;
      if (step > stage_boundary[6]) stage <= 7;
      else if (step > stage_boundary[5]) stage <= 6;
      else if (step > stage_boundary[4]) stage <= 5;
      else if (step > stage_boundary[3]) stage <= 4;
      else if (step > stage_boundary[2]) stage <= 3;
      else if (step > stage_boundary[1]) stage <= 2;
      else if (step > stage_boundary[0]) stage <= 1;
      else stage <= 0;
    end
  end
  */

  always_ff @(posedge CLK_i or posedge RST_i) begin
    if (RST_i) step<=0;
    else step<=step+1;
  end

  always_comb begin
    if (step > stage_boundary[6]) stage = 7;
      else if (step > stage_boundary[5]) stage = 6;
      else if (step > stage_boundary[4]) stage = 5;
      else if (step > stage_boundary[3]) stage = 4;
      else if (step > stage_boundary[2]) stage = 3;
      else if (step > stage_boundary[1]) stage = 2;
      else if (step > stage_boundary[0]) stage = 1;
      else stage = 0;
  end



  assign finished = (stage == 7);


  //mode
  always_comb begin
    if (stage == 1) mode = 1'b0;
    else mode = 1'b1;
  end

  for (genvar i = 0; i < parallel_size; i++) begin

    logic [WIDTH-1:0] mul_o;
    logic [WIDTH-1:0] sqrt_o;
    logic [WIDTH-1:0] div_i;
    logic [WIDTH-1:0] div_o;
    logic [WIDTH-1:0] div_mul_o;

    logic [WIDTH-1:0] max_cos;
    logic [WIDTH-1:0] max_id;

    logic [WIDTH-1:0] float98;
    assign float98 = 16'b0011101111010111;

    logic [WIDTH-1:0] center_ids;
    logic [WIDTH-1:0] dnorm;

    logic [WIDTH-1:0] cmp1_i;
    logic [WIDTH-1:0] cmp2_i;
    logic cmp_o;
    //logic [WIDTH-1:0] norm_n_i;
    logic [WIDTH-1:0] norm_n_o;


    // div_i
    always_comb begin
      if (stage == 5) div_i = mul_o;
      else div_i = scale_i[i];
    end

    //operand_o
    always_comb begin
      if (stage == 5) operand1_o[i] = sqrt_o;
      else if (stage == 6) begin
        operand1_o[i] = center_ids;
        //operand2_o[i] = dnorm;
      end else if (stage == 4) operand1_o[i] = sqrt_o;
      else operand1_o[i] = div_mul_o;
    end

    assign operand2_o[i] = dnorm;




    fp16_Rom_div div (
        .operands(div_i),
        .result  (div_o)
    );


    fp16_mul mul (
        // Input signals
        .operands_i({scale_i[i], norm_n_o}),  // 2 operands
        .is_boxed_i(2'b11),  // 2 operands
        //.rnd_mode_i,
        // Output signals
        .result_o(mul_o)
        //.status_o
    );

    fp16_mul div_mul (
        // Input signals
        .operands_i({operand_i[i], div_o}),  // 2 operands
        .is_boxed_i(2'b11),  // 2 operands
        //.rnd_mode_i,
        // Output signals
        .result_o(div_mul_o)
        //.status_o
    );

    fp16_Rom_sqrt fp16_sqrt (
        .operands(operand_i[i]),
        .result  (sqrt_o)
    );

    always_comb begin
      if (stage == 5) begin
        cmp1_i = max_cos;
        cmp2_i = div_mul_o;
      end else if (stage == 6) begin
        cmp1_i = float98;
        cmp2_i = div_mul_o;
      end else begin
        cmp1_i = 0;
        cmp2_i = 0;
      end
    end


    fpnew_noncomp cmp1 (
        // Input signals
        .operands_i({cmp1_i, cmp2_i}),  // 2 operands
        .is_boxed_i(2'b11),  // 2 operands
        .op_i(fpnew_pkg::CMP),  //cmp1_i<cmp2_i
        // Output signals
        //result_o(cmp_o),
        .extension_bit_o(cmp_o)
    );

    //FFAR(max_cos, max_cos, (RST_i?0:div_mul_o), CLK_i, cmp_o|RST_i); //max_cos
    //FFAR(max_id,max_id, pos, CLK_i, cmp_o); //max_id
    /*
    FFReg Reg1 (
        .__q_o(max_cos),
        .__reset_value((RST_i ? 16'b0 : div_mul_o)),
        .__clk(CLK_i),
        .__arst_n(cmp_o | RST_i)
    );

    FFReg Reg2 (
        .__q_o(max_id),
        .__reset_value(pos[i]),
        .__clk(CLK_i),
        .__arst_n(cmp_o)
    );

    assign norm_n_i=sqrt_o;

    FFReg Reg3(
        .__q_o(norm_n_o),
        .__reset_value(RST_i ? 16'b0 :norm_n_i),
        .__clk(CLK_i),
        .__arst_n(RST_i||sep==stage_boundary[3])
    );
    */

    always_ff @(posedge CLK_i) begin : Reg1
      if (RST_i) max_cos <= 16'b0;
      else if (cmp_o) max_cos <= div_mul_o;
      else max_cos <= max_cos;
    end

    always_ff @(posedge CLK_i) begin : Reg2
      if (RST_i) max_id <= 16'b0;
      else if (cmp_o) max_id <= pos[i];
      else max_id <= max_id;
    end

    always_ff @(posedge CLK_i) begin : Reg3
      if (RST_i) norm_n_o <= 16'b0;
      else if (cmp_o) norm_n_o <= sqrt_o;
      else norm_n_o <= norm_n_o;
    end

    assign center_ids = cmp_o ? max_id : n;
    assign dnorm = cmp_o ? div_mul_o : 1;

  end



endmodule
