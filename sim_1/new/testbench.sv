`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/15 09:10:35
// Design Name: 
// Module Name: testbench
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


module testbench(

    );
    logic [15:0]A;
    logic [15:0]B;
    logic [15:0]C;

fp16_add add(
  // Input signals
.operands_i({A,B}), // 2 operands
.is_boxed_i(3'b111), // 2 operands
.rnd_mode_i(),
  // Output signals
.result_o(C),
.status_o()
);

initial begin
    A=16'b0011111000000000;
    B=16'b0100000110100111;
    #10
    $finish;
end
endmodule
