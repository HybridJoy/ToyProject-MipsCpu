`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/11 19:38:52
// Design Name: 
// Module Name: hilo_reg
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


module hilo_reg(
    input wire clk,rst,en,
    input wire [31:0] hi,lo,
    output reg [31:0] hi_o,lo_o
    );
    
    always @ (negedge clk)
    begin
    if(rst) begin
        hi_o <= 0;
        lo_o <= 0;
    end else if (en) begin
        hi_o <= hi;
        lo_o <= lo;
    end
    end
endmodule
