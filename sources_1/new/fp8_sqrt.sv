`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/06/27 14:26:30
// Design Name: 
// Module Name: fp8_sqrt
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


module fp8_sqrt(
    input logic [7:0] operand_i,
    output logic [7:0] result_o
    );

    logic [3:0] exponent;logic[2:0]norm_exponent;logic[6:0]sub_result;
    logic [2:0] mantissa;logic[2:0]norm_mantissa;

    assign exponent=operand_i[6:3];
    assign mantissa=operand_i[2:0];

    logic [2:0] norm__o;

    logic is_subnormal,is_zero;
    assign is_subnormal=mantissa!=0&&exponent==0;
    assign is_zero=mantissa==0&&exponent==0;



    always_comb begin                           //lookup table for normal fp8 2^4*3
        unique case ({mantissa,exponent[0]}) 
            4'b0:   assign  norm_mantissa=3'b1;
            default: assign norm_mantissa=3'b0;
        endcase 
    end

    always_comb begin                           //lookup table for subnormal fp8  2^3*7
        unique case ({mantissa}) 
            3'b0:   assign  sub_result=7'b1;
            default: assign sub_result=7'b0;
        endcase 
    end

    assign norm_exponent=unsigned'(exponent)>>2+3+exponent[0];

    always_comb begin
        if(is_zero) begin
            result_o={8'b0};
        end
        else if(is_subnormal) begin
            result_o=sub_result;
        end
        else begin
            result_o={1'b0,norm_exponent,norm_mantissa};
        end
    end


endmodule
