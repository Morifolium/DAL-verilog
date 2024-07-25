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

  logic valid[dim_size-1:0];
  genvar i;
  generate
    for(i = 0; i < dim_size; i++) begin
        adder_fp16 inst_adder (
            .clk    (clk),
            .rst  (rst),
            .mode   (op),
            .op_a   (a_vec[i]),
            .op_b   (b_vec[i]),
            .done   (valid[i]),
            .res_o  (res_o[i])
        );
    end
  endgenerate 

    assign valid_o=1'b1;
endmodule