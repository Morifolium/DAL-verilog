`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/06/26 13:14:28
// Design Name: 
// Module Name: fp8_div
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


module fp8_div(
        input logic[7:0] operand_a,    //return a/b
        input logic[7:0] operand_b,
        output logic[7:0] result_o
    );

    logic [7:0] reciprocal;
    
    logic [3:0] exponent_b;
    logic[2:0] mantissa_b;
    assign exponent_b=operand_b[6:3];
    assign mantissa_b=operand_b[2:0];

    logic [3:0] exponent_r;
    logic[2:0] mantissa_r;
    logic ext_bit; 

    always_comb begin
        unique case(mantissa_b)
        3'b0:begin assign mantissa_r=0;assign ext_bit=0; end
        default:begin assign mantissa_r=0;assign ext_bit=0; end
        endcase
    end

    assign reciprocal={operand_b[7],mantissa_r,exponent_r};

    assign exponent_r=2*7-1-exponent_b+ext_bit;

    fp8_mul  i_fma (
          .clk_i,
          .rst_ni,
          .operands_i      ( {operand_a,reciprocal}               ),
          .is_boxed_i      ( {3'b111} ),
          .rnd_mode_i,
          .result_o(result_o)
        );




    
endmodule
