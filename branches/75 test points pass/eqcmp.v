`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/23 22:57:01
// Design Name: 
// Module Name: eqcmp
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

`include "defines.vh"

module eqcmp(num1,num2,opcode,rt,result); // add opcode and rt as parameter
	input  wire [31:0] num1;
	input  wire [31:0] num2;
	input  wire [5:0]  opcode;
	input  wire [4:0]  rt;
	output wire [0:0]  result;

	assign result = (opcode == `EXE_BEQ)  ? (num1 == num2) :
					(opcode == `EXE_BNE)  ? (num1 != num2) :
					(opcode == `EXE_BGTZ) ? (num1[31] == 1'b0) && (num1 != `ZEROWORD) : // corret the mistake logic
					(opcode == `EXE_BLEZ) ? (num1[31] == 1'b1) || (num1 == `ZEROWORD) :
					(opcode == `EXE_REGIMM_INST) && ((rt == `EXE_BGEZ) || (rt == `EXE_BGEZAL)) ?
											(num1[31] == 1'b0) || (num1 == `ZEROWORD) :
					(opcode == `EXE_REGIMM_INST) && ((rt == `EXE_BLTZ) || (rt == `EXE_BLTZAL)) ?
											(num1[31] == 1'b1) : 1'b0;
endmodule
