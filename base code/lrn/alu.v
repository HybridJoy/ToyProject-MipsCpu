`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/06 21:27:46
// Design Name: 
// Module Name: alu
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


module alu(
    input wire [31:0] num1,
    input wire [31:0] num2,
    input wire [2:0] op,
    output [31:0] result
    //output zero
    );
    
    assign result = (op == 3'b000)?num1 & num2:
                     (op == 3'b001)?num1 | num2:
                     (op == 3'b010)?num1 + num2:
                     (op == 3'b100)?num1 & ~num2:
                     (op == 3'b101)?num1 | ~num2:
                     (op == 3'b110 )?num1 - num2:
                     (op == 3'b111 && num1 < num2)? 32'h00000001: 32'h00000000;
    //assign zero=(result==0);
endmodule
