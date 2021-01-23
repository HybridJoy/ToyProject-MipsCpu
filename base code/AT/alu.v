`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/10/11 19:18:03
// Design Name: 
// Module Name: test
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


module alu(num1,num2,op,result);
    input wire [31:0] num1;
    input wire [31:0] num2;
    input wire [2:0]  op;
    output reg [31:0] result;
    // output            overflow;
    // output            zero;
    
    wire [31:0] temp_slt;
    assign temp_slt = (num1 < num2) ? 32'h1 : 32'h0;

    // assign result   = (op == 3'b000) ? num1 & num2 :
    //                   (op == 3'b001) ? num1 | num2 :
    //                   (op == 3'b010) ? num1 + num2 :
    //                   //(op == 3'b011) ?  not used !
    //                   (op == 3'b100) ? num1 & (~ num2) : 
    //                   (op == 3'b101) ? num1 | (~ num2) :
    //                   (op == 3'b110) ? num1 - num2 :
    //                   (op == 3'b111) ? temp_slt :
    //                   32'h0;

    always @(*)
    begin
      case(op)
          3'b000 : result = num1 & num2;
          3'b001 : result = num1 | num2;
          3'b010 : result = num1 + num2;
          //3'b011 ： not used！
          3'b100 : result = num1 & (~ num2);
          3'b101 : result = num1 | (~ num2);
          3'b110 : result = num1 - num2;
          3'b111 : result = temp_slt;
          default : result = 32'h0;
      endcase // op
    end

  // assign overflow = 0;
  // assign zero = (result == 32'h0);

endmodule
