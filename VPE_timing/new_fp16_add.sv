

module new_fp16_add_nolzc #(
    localparam WIDTH = 16,
    localparam EXP_BITS = 5,  //FP16 1-5-10
    localparam MAN_BITS = 10,
    localparam PRECISION_BITS = MAN_BITS + 1,
    localparam ADD_PRECISION = PRECISION_BITS + 1,
    localparam int unsigned BIAS = 15
) (
    input logic [1:0][WIDTH-1:0] operands_i,
    output logic [WIDTH-1:0] result_o  //c=a*b
);

  logic is_subnormal_a;
  logic is_subnormal_b;
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
  logic effect_sub;

  assign sign_a = operands_i[1][15];
  assign exponent_a = operands_i[1][14:10];
  assign mantissa_a = operands_i[1][9:0];
  assign sign_b = operands_i[0][15];
  assign exponent_b = operands_i[0][14:10];
  assign mantissa_b = operands_i[0][9:0];

  assign is_subnormal_a = exponent_a == 5'b0 && mantissa_a != 10'b0;
  assign is_subnormal_b = exponent_b == 5'b0 && mantissa_b != 10'b0;

  assign effect_sub = sign_a ^ sign_b;

  logic sgn;
  assign sgn = exponent_a > exponent_b;

  assign sign_c = sgn ? sign_a : sign_b;



  logic [EXP_BITS-1:0] large_exp;
  logic [EXP_BITS-1:0] diff_exp;
  logic [ADD_PRECISION-1:0] large_man;
  logic [ADD_PRECISION-1:0] min_man;


  always_comb begin
    if (sgn) begin
      large_exp <= {exponent_a};
      diff_exp  <= {exponent_a - exponent_b};
      large_man <= {~is_subnormal_a, mantissa_a};
      min_man   <= {~is_subnormal_b, mantissa_b};
    end else begin
      large_exp <= {exponent_b};
      diff_exp  <= {exponent_b - exponent_a};
      large_man <= {~is_subnormal_b, mantissa_b};
      min_man   <= {~is_subnormal_a, mantissa_a};
    end
  end




  logic [ADD_PRECISION-1:0] mantissa;

  always_comb begin
    if (effect_sub) mantissa = large_man - (min_man) >> (diff_exp);
    else mantissa = (large_man) + ((min_man) >> (diff_exp));
  end





  logic [2:0] lzc_result;
  logic [2:0] left_shift;
  logic is_zero;

  add_lzc #(
      .WIDTH(7),
      .MODE(1),
      .CNT_WIDTH(3)
  ) u_lzc (
      .in_i(mantissa[11:5]),
      .cnt_o(lzc_result),
      .empty_o(is_zero)
  );

  logic [ADD_PRECISION-1:0] shift_result;
  logic [ADD_PRECISION-1:0] shift_result1;
  //assign shift_result = (mantissa >> left_shift);
  assign mantissa_c = shift_result[10:1];
  assign exponent = large_exp - lzc_result + 1;
  assign shift_result1 = mantissa << (lzc_result);

  assign left_shift = -signed'(exponent);
  always_comb begin
    if (is_zero) begin
      exponent_c   = 5'b0;
      shift_result = 12'b0;
    end else if (exponent[5] == 1'b0) begin
      shift_result = shift_result1;
      exponent_c   = exponent[4:0];
    end else begin
      exponent_c   = 5'b0;
      shift_result = shift_result1 >> left_shift;
    end
  end
  /*
  always_comb begin
    if (is_zero) begin
      exponent_c   = 5'b0;
      shift_result = 12'b0;
      left_shift   = 0;
    end else if (exponent[5] == 1'b0) begin
      left_shift   = lzc_result;
      shift_result = mantissa << (lzc_result);
      exponent_c   = exponent[4:0];
    end else begin
      exponent_c   = 5'b0;
      left_shift   = -signed'(exponent);
      shift_result = (mantissa << lzc_result) >> left_shift;
    end
  end
  */

  assign result_o = {effect_sub && mantissa[11] ? sign_c : ~sign_c, exponent_c, mantissa_c};

endmodule
