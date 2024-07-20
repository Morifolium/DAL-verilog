module new_fp16_cmp #(
    localparam WIDTH = 16,
    localparam EXP_BITS=5,
    localparam MAN_BITS=10
) (
    input logic [1:0][WIDTH-1:0] operands_i,
    output logic result_o
);

logic sign_a;
logic sign_b;
logic [MAN_BITS-1:0]mantissa_a;
logic [MAN_BITS-1:0]mantissa_b;
logic [EXP_BITS-1:0]exponent_a;
logic [EXP_BITS-1:0]exponent_b;


assign sign_a=operands_i[1][15];
assign exponent_a=operands_i[1][14:10];
assign mantissa_a=operands_i[1][9:0];
assign sign_b=operands_i[0][15];
assign exponent_b=operands_i[0][14:10];
assign mantissa_b=operands_i[0][9:0];

logic unsign_result;
assign unsign_result=(exponent_a>exponent_b)||((exponent_a==exponent_b)&&(mantissa_a>mantissa_b));

always_comb begin
    if(sign_a<sign_b) result_o=1'b1;
    else if(sign_a>sign_b) result_o=1'b0;
    else result_o=~(unsign_result^sign_a);
end
    
endmodule