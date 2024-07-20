

module new_fp_16_add #(
    localparam WIDTH = 16,
    localparam EXP_BITS = 5,  //FP16 1-5-10
    localparam MAN_BITS = 10,
    localparam PRECISION_BITS = MAN_BITS + 1,
    localparam int unsigned BIAS = 15
) (
    input logic [1:0][WIDTH-1:0] operands_i,
    output logic [WIDTH-1:0] result_o  //c=a*b
);

  logic is_subnormal_a;
  logic is_subnormal_b;
  logic is_zero_a;
  logic is_zero_b;
  logic sign_a;
  logic sign_b;
  logic sign_c;
  logic [MAN_BITS-1:0] mantissa_a;
  logic [MAN_BITS-1:0] mantissa_b;
  logic [MAN_BITS-1:0] mantissa_c;
  logic [EXP_BITS-1:0] exponent_a;
  logic [EXP_BITS-1:0] exponent_b;
  logic [EXP_BITS-1:0] exponent_c;
  logic [EXP_BITS:0] exponent;

  assign sign_a = operands_i[1][15];
  assign exponent_a = operands_i[1][14:10];
  assign mantissa_a = operands_i[1][9:0];
  assign sign_b = operands_i[0][15];
  assign exponent_b = operands_i[0][14:10];
  assign mantissa_b = operands_i[0][9:0];

  assign is_subnormal_a = exponent_a == 5'b0 && mantissa_a != 10'b0;
  assign is_subnormal_b = exponent_b == 5'b0 && mantissa_b != 10'b0;

  //assign is_zero_a = exponent_a == 5'b0 && mantissa_a == 10'b0;
  //assign is_zero_b = exponent_b == 5'b0 && mantissa_b == 10'b0;

  logic [PRECISION_BITS-1:0] man_a;
  logic [PRECISION_BITS-1:0] man_b;

  assign man_a = is_subnormal_a ? {1'b0, mantissa_a} : {1'b1, mantissa_a};
  assign man_b = is_subnormal_b ? {1'b0, mantissa_b} : {1'b1, mantissa_b};

  always_comb begin
    if (is_zero_a || is_zero_b) result_o = 16'b0;
    else result_o = {sign_c, exponent_c, mantissa_c};
  end

  //assign sign_c = sign_a ^ sign_b;

  always_comb begin
    if (sign_a == sign_b) sign_c = sign_a;
    else begin
      sign_c=(exponent_a>exponent_b)||(exponent_a==exponent_b&&mantissa_a>mantissa_b)?sign_a:sign_b;
    end
  end


  logic [EXP_BITS:0] large_exp;
  logic [EXP_BITS:0] min_exp;
  logic [2*PRECISION_BITS-1:0] large_man;
  logic [2*PRECISION_BITS-1:0] min_man;

  always_comb begin
    if ((exponent_a > exponent_b) || (exponent_a == exponent_b && mantissa_a > mantissa_b)) begin
      large_exp = {1'b0,exponent_a};
      min_exp   = {1'b0,exponent_b};
      large_man = {~is_subnormal_a, mantissa_a};
      min_man   = {~is_subnormal_b, mantissa_b};
    end else begin
      large_exp = {1'b0,exponent_b};
      min_exp   = {1'b0,exponent_a};
      large_man = {~is_subnormal_b, mantissa_b};
      min_man   = {~is_subnormal_a, mantissa_a};
    end
  end




  logic [2*PRECISION_BITS-1:0] mantissa;

  always_comb begin
    if (sign_a ^ sign_b)
      mantissa = large_man << MAN_BITS - (min_man << MAN_BITS) >> (large_exp - min_exp);
    else mantissa = (large_man << MAN_BITS) + ((min_man << MAN_BITS) >> (large_exp - min_exp));
  end





  logic [5:0] lzc_result;
  logic [5:0] left_shift;
  logic is_zero;

  lzc #(
      .WIDTH(2 * PRECISION_BITS),
      .MODE(1),
      .CNT_WIDTH(6)
  ) u_lzc (
      .in_i(mantissa),
      .cnt_o(lzc_result),
      .empty_o(is_zero)
  );

  logic [2*PRECISION_BITS-1:0] shift_result;
  //assign shift_result = (mantissa >> left_shift);
  assign mantissa_c = shift_result[20:11];
  assign exponent   = large_exp - lzc_result+1;

  always_comb begin
    if (is_zero) begin
      exponent_c   = 5'b0;
      shift_result = 22'b0;
      left_shift=0;
    end else if (signed'(exponent) > 0) begin
      left_shift   = lzc_result;
      shift_result = mantissa << (lzc_result);
      exponent_c   = exponent[4:0];
    end else begin
      exponent_c   = 5'b0;
      left_shift   = -signed'(exponent);
      shift_result = (mantissa << lzc_result) >> left_shift;
    end
  end

endmodule
