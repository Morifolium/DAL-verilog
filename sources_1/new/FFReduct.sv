`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/15 17:37:11
// Design Name: 
// Module Name: FFReduct
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


module FFReduct #(
    localparam WIDTH = 16
)
(
    input logic [WIDTH-1:0] d,
    input logic [WIDTH-1:0] reset_value,
    input logic clk,
    input logic rst,
    output logic q_o
    );
logic [WIDTH-1:0] q;

  always_ff @(posedge (clk) or posedge (rst)) begin 
    if (rst) begin                                    
      q <= (reset_value);                            
    end else begin                                       
      q <= (d);                                      
    end                                                  
  end

  assign q_o=q;
endmodule
