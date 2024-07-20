`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/07 14:05:50
// Design Name: 
// Module Name: fp16_Rom_div
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

module fp16_Rom_div #(
    localparam int unsigned WIDTH = 16
)
(
    //input logic mode, //0 div  1 muladd
    input logic [WIDTH-1:0] operands,
    //input  fpnew_pkg::operation_e     op_i,
    output logic [WIDTH-1:0] result
    );

logic [9:0]mantissa;
logic [4:0] exponent;
logic sign;

assign sign=operands[15];
assign mantissa=operands[9:0];
assign exponent=operands[14:10];

//ROM - C = X1^-2-2^-m*X1^-3+7*2^-2m-3*X1^-4   m=5 t=11
logic [10:0] C;
logic [4:0] man_case;
assign man_case=mantissa[9:5];
always_comb begin
    unique case (man_case) //�?要反�?
        5'd31: C=11'b100000;
        5'd30: C=11'b1100011;
        5'd29: C=11'b10101001;
        5'd28: C=11'b11110011;
        5'd27: C=11'b101000001;
        5'd26: C=11'b110010011;
        5'd25: C=11'b111101001;
        5'd24: C=11'b1001000011;
        5'd23: C=11'b1010100011;
        5'd22: C=11'b1100001000;
        5'd21: C=11'b1101110010;
        5'd20: C=11'b1111100011;
        5'd19: C=11'b10001011010;
        5'd18: C=11'b10011011001;
        5'd17: C=11'b10101011111;
        5'd16: C=11'b10111101110;
        5'd15: C=11'b11010000110;
        5'd14: C=11'b11100100111;
        5'd13: C=11'b11111010100;
        5'd12: C=11'b1000110;
        5'd11: C=11'b10101000;
        5'd10: C=11'b100010010;
        5'd9: C=11'b110000011;
        5'd8: C=11'b111111101;
        5'd7: C=11'b1010000000;
        5'd6: C=11'b1100001101;
        5'd5: C=11'b1110100110;
        5'd4: C=11'b10001001100;
        5'd3: C=11'b10100000000;
        5'd2: C=11'b10111000100;
        5'd1: C=11'b11010011001;
        5'd0: C=11'b11110000011;
        default: C=11'b0;
    endcase
end

logic [11:0] X;
assign X={1'b1,mantissa[9:5],~mantissa[4],~mantissa[3],~mantissa[2],~mantissa[1],~mantissa[0]};

logic [22:0]mantissa_out;
assign mantissa_out=unsigned'(X)*unsigned'({1'b1,C});

logic [9:0]mantissa_o;

//*
always_comb begin
    if(mantissa_out[22]==1'b1)
        mantissa_o=mantissa_out[21:12];
    else
        mantissa_o=mantissa_out[20:11];
end
//*/

//assign mantissa_o=mantissa_out[20:11];

logic [4:0] exponent_o;

assign exponent_o=-signed'(exponent)-2;

assign result={sign,exponent_o,mantissa_o};

endmodule
