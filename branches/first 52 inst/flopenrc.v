`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/06 23:15:37
// Design Name: 
// Module Name: flopenrc
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


module flopenrc #(parameter WIDTH=32)
              (input clk,reset,enable,clear,
               input [WIDTH-1:0] d,
               output reg [WIDTH-1:0] q);
   
    always @(posedge clk,posedge reset)
    begin
    if(reset) q<=0;
    else if(clear) q<=0;
    else if(enable) q<=d;
    end
endmodule
