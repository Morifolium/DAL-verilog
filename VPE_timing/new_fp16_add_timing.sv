module new_fp16_add_timing #(
    localparam WIDTH = 16
) (
    input clk,
    input logic [1:0][WIDTH-1:0] operands_i,
    output logic [WIDTH-1:0] add_reg
);

  logic [WIDTH-1:0] result_o;
  new_fp16_add u_new_fp16_add (
      .operands_i(operands_i),
      .result_o  (result_o)
  );

  always_ff @(posedge clk) begin
    add_reg <= result_o;
  end
endmodule
