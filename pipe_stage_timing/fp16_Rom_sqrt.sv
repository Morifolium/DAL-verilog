`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/07 14:05:50
// Design Name: 
// Module Name: fp16_Rom_sqrt
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

module fp16_Rom_sqrt#(
    
    localparam int unsigned WIDTH = 16
)
(
    //input logic mode, //0 div  1 muladd
    input logic [WIDTH-1:0] operands,
    //input  fpnew_pkg::operation_e     op_i,
    output logic [WIDTH-1:0] result
    );
logic [2:0]x1;
logic [6:0]x2;
logic [4:0]exponent;

assign exponent={operands[14:10]};
assign x1=operands[9:7];
assign x2=operands[6:0];


//ROM - C = (X1^-1/2-2^-m-2*X1^-3/2+ 5*2^-2m-6*X1^-5/2)    m=3 t=11
logic [10:0] C;
always_comb begin
    unique case ({exponent%2==0,x1})
        4'd7: C=11'b1101111110;
        4'd6: C=11'b1111100010;
        4'd5: C=11'b10001010000;
        4'd4: C=11'b10011001100;
        4'd3: C=11'b10101010111;
        4'd2: C=11'b10111110110;
        4'd1: C=11'b11010101110;
        4'd0: C=11'b11110000101;
        4'd15: C=11'b110001;
        4'd14: C=11'b1111010;
        4'd13: C=11'b11001010;
        4'd12: C=11'b100100100;
        4'd11: C=11'b110001010;
        4'd10: C=11'b111111110;
        4'd9: C=11'b1010000101;
        4'd8: C=11'b1100100011;
        default: C=0;
    endcase
end

logic [11:0]X;
always_comb begin 
    if(exponent%2==1) X={1'b1,x1,x2[6],~x2[6],x2[5:0]};
    else X={1'b1,x1,{{1'b0,x2[6:5]}+3'b1},x2[4:0]};
end
logic [23:0]mantissa_out;


assign mantissa_out={1'b1,C}*{X};

logic [9:0] mantissa_o;


always_comb begin
if(mantissa_out[23]==1'b1) mantissa_o=mantissa_out[22:13];
else mantissa_o=mantissa_out[21:12];
end

//assign mantissa_o=mantissa_out[22:13];

logic [4:0]exponent_o;
assign exponent_o=signed'(signed'(exponent-5'd15)>>>1)+signed'(5'd15);

assign result={1'b0,exponent_o,mantissa_o};

endmodule
