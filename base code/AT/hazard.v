`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/03 23:32:38
// Design Name: 
// Module Name: hazard
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


module hazard(stallF,rsD,rtD,branchD,forwardaD,forwardbD,stallD,
			  rsE,rtE,writeregE,regwriteE,memtoregE,forwardaE,forwardbE,flushE,
			  writeregM,regwriteM,memtoregM,writeregW,regwriteW);
	
	// fetch stage
	output     [0:0] stallF;

	// decode stage
	input wire [4:0] rsD;
	input wire [4:0] rtD;
	input wire [0:0] branchD;
	output reg [0:0] forwardaD;
	output reg [0:0] forwardbD;
	output 	   [0:0] stallD;

	// execute stage
	input wire [4:0] rsE;
	input wire [4:0] rtE;
	input wire [4:0] writeregE;
	input wire [0:0] regwriteE;
	input wire [0:0] memtoregE;
	output reg [1:0] forwardaE;
	output reg [1:0] forwardbE;
	output     [0:0] flushE;

	// mem stage
	input wire [4:0] writeregM;
	input wire [0:0] regwriteM;
	input wire [0:0] memtoregM;

	// write back stage
	input wire [4:0] writeregW;
	input wire [0:0] regwriteW;

	// === data push forward logic === //

	// == decode stage == //

	// Operand srca 
	always @ (*) 
	begin
		if((rsD != 5'b00000) && (rsD == writeregM) && regwriteM)
		begin
			forwardaD <= 1'b1;
		end
		else
		begin
			forwardaD <= 1'b0;
		end
	end

	// Operand srcb
	always @ (*) 
	begin
		if((rtD != 5'b00000) && (rtD == writeregM) && regwriteM)
		begin
			forwardbD <= 1'b1;
		end
		else
		begin
			forwardbD <= 1'b0;
		end
	end

	// == execute stage == //

	// Operand srca 
	always @ (*) 
	begin
		if((rsE != 5'b00000) && (rsE == writeregM) && regwriteM)
		begin
			forwardaE <= 2'b10;
		end
		else if((rsE != 5'b00000) && (rsE == writeregW) && regwriteW)
		begin
			forwardaE <= 2'b01;
		end
		else
		begin
			forwardaE <= 2'b00;
		end
	end

	// Operand srcb
	always @ (*) 
	begin
		if((rtE != 5'b00000) && (rtE == writeregM) && regwriteM)
		begin
			forwardbE <= 2'b10;
		end
		else if((rtE != 5'b00000) && (rtE == writeregW) && regwriteW)
		begin
			forwardbE <= 2'b01;
		end
		else
		begin
			forwardbE <= 2'b00;
		end
	end 

	// === pipeline pause logic === //

	// lw stall
	wire lwstall;
	// assign lwstall = ((rsD == rtE) || (rtD == rtE)) && memtoregE;
	assign lwstall = ((rsD == rtE) | (rtD == rtE)) & memtoregE;

	// branch stall
	wire branchstall;
	// assign branchstall = (branchD && regwriteE && 
	// 					  ((writeregE == rsD) || (writeregE == rtD)))
	// 				  || (branchD && memtoregM &&
	// 				  	  ((writeregM == rsD) || (writeregM == rtD)));
	assign branchstall = branchD & regwriteE & 
						  ((writeregE == rsD) | (writeregE == rtD))
					   | branchD & memtoregM &
					  	  ((writeregM == rsD) | (writeregM == rtD));

	// assign stallF  = lwstall || branchstall;
	// assign stallD  = lwstall || branchstall;
	// assign flushE  = lwstall || branchstall;
	assign stallF  = lwstall | branchstall;
	assign stallD  = lwstall | branchstall;
	assign flushE  = lwstall | branchstall;
endmodule
