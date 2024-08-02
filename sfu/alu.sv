module alu #(
    parameter int data_width = 16,
    parameter int dim_size   = 128
) (
    input clk,
    input rst,
    
    input  logic [data_width-1:0]  a_vec[dim_size-1:0],
    input  logic [data_width-1:0]  b_vec[dim_size-1:0],
    input  logic                   op,
    output logic                   valid_o,
    output logic [data_width-1:0] res_o[dim_size-1:0]
);
    // op = 0, add
    // op = 1, sub

  genvar i;
  generate
    for(i = 0; i < dim_size; i++) begin
        new_fp16_add inst_adder(
            .operands_i({a_vec[i],b_vec[i]}),
            .result_o(res_o[i])
        );
    end
  endgenerate 

    assign valid_o=1'b1;
endmodule