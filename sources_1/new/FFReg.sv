`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/15 12:33:30
// Design Name: 
// Module Name: FFReg
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


module FFReg #(
    localparam WIDTH = 16
)
(
output logic[WIDTH-1:0]__q_o,
input logic [WIDTH-1:0] __reset_value,
input logic __clk,
input logic __arst_n
);
    logic [WIDTH-1:0]__q;    
  always_ff @(posedge (__clk) or negedge (__arst_n)) begin 
    if (!__arst_n) begin                                  
      __q <= (__reset_value);                              
    end else begin                                         
      __q <= (__q);                                        
    end                                                    
  end
  assign __q_o=__q;
endmodule
