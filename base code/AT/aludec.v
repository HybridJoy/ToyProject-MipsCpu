`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/10/22 21:35:29
// Design Name: 
// Module Name: alu_decoder
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


module aludec(funct,aluop,alucontrol);
	input wire [5:0] funct;
	input wire [1:0] aluop;
	output reg [2:0] alucontrol;

	always @ (aluop or funct)
	begin
		case(aluop)
			2'b00: begin alucontrol = 3'b010; end // lw or sw
			2'b01: begin alucontrol = 3'b110; end // beq
			2'b10: begin case(funct)
						6'b1000_00: begin alucontrol = 3'b010; end // add
						6'b1000_10: begin alucontrol = 3'b110; end // sub
						6'b1001_00: begin alucontrol = 3'b000; end // and
						6'b1001_01: begin alucontrol = 3'b001; end // or
						6'b1010_10: begin alucontrol = 3'b111; end // slt (set on less than)
						default:    begin alucontrol = 3'b101; end
				   endcase end
			default: begin alucontrol = 3'b101; end
		endcase // aluop	
	end

	
endmodule
