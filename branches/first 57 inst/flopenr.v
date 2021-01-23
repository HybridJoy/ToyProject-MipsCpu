`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/06 23:13:05
// Design Name: 
// Module Name: flopenr
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


module flopenr #(parameter WIDTH=32)
              (input clk,reset,enable,
               input [WIDTH-1:0] d,
               output reg [WIDTH-1:0] q);
   
    always @(posedge clk,posedge reset)
    begin
    if(reset) q<=0;
    else if(enable) q<=d;
    end
endmodule
