`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/10/22 21:23:39
// Design Name: 
// Module Name: main_decoder
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



 module maindec(opcode,memtoreg,memwrite,branch,alusrc,regdst,regwrite,jump,aluop);
	input wire [5:0] opcode;
	output reg [0:0] memtoreg;
	output reg [0:0] memwrite;
	output reg [0:0] branch;
	output reg [0:0] alusrc;
	output reg [0:0] regdst;
	output reg [0:0] regwrite;
	output reg [0:0] jump;
 	output reg [1:0] aluop;

	// signs : memtoreg + memwrite + branch + alusrc + regdst + regwrite + jump 

	always @(opcode) 
	begin
		case(opcode)
			6'b0000_00: begin 
				{memtoreg,memwrite,branch,alusrc,regdst,regwrite,jump,aluop} = 9'b0000_110_10; 
				 	 	end  // R-type
			6'b1000_11: begin 
				{memtoreg,memwrite,branch,alusrc,regdst,regwrite,jump,aluop} = 9'b1001_010_00; 
						end  // lw
			6'b1010_11: begin 
				{memtoreg,memwrite,branch,alusrc,regdst,regwrite,jump,aluop} = 9'b0101_000_00; 
					 	end  // sw
			6'b0001_00: begin 
				{memtoreg,memwrite,branch,alusrc,regdst,regwrite,jump,aluop} = 9'b0010_000_01; 
						end  // beq
			6'b0010_00: begin 
				{memtoreg,memwrite,branch,alusrc,regdst,regwrite,jump,aluop} = 9'b0001_010_00; 
				 		end  // addi
			6'b0000_10: begin 
				{memtoreg,memwrite,branch,alusrc,regdst,regwrite,jump,aluop} = 9'b0000_001_00; 
				 		end  // j
			default:    begin 
				{memtoreg,memwrite,branch,alusrc,regdst,regwrite,jump,aluop} = 9'b0000_000_00; 
			 			end
		endcase // opcode
	end
endmodule
