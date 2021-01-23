`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/06 23:44:16
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


`include "defines.vh"
module hazard(stallF,rsD,rtD,branchD,balD,jumpD,forwardaD,forwardbD,stallD,alucontrolE,
			  rsE,rtE,writeregE,regwriteE,memtoregE,stall_divE,forwardaE,forwardbE,forwardhE,flushE,stallE,writeregM,regwriteM,memtoregM,hilowriteM,writeregW,regwriteW,hilowriteW);
	
	// fetch stage
	output     [0:0] stallF;

	// decode stage
	input wire [4:0] rsD;
	input wire [4:0] rtD;
	input wire [0:0] branchD;
	input wire [0:0] balD; // add the bal signal
	input wire [0:0] jumpD; // add the jump signal
	output reg [0:0] forwardaD;
	output reg [0:0] forwardbD;
	output 	   [0:0] stallD;

	// execute stage
	input wire [4:0] alucontrolE;
	input wire [4:0] rsE;
	input wire [4:0] rtE;
	input wire [4:0] writeregE;
	input wire [0:0] regwriteE;
	input wire [0:0] memtoregE;
	input wire stall_divE;//
	output reg [1:0] forwardaE;
	output reg [1:0] forwardbE;
	output wire forwardhE;
	output wire [0:0] flushE;
	output wire stallE;//

	// mem stage
	input wire [4:0] writeregM;
	input wire [0:0] regwriteM;
	input wire [0:0] memtoregM;
	input wire hilowriteM;

	// write back stage
	input wire [4:0] writeregW;
	input wire [0:0] regwriteW;
	input wire hilowriteW;

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
	assign stallF  = lwstall | branchstall | stall_divE;
	assign stallD  = lwstall | branchstall | stall_divE;
	assign flushE  = (lwstall | branchstall) & (~ balD);
	assign stallE  = stall_divE;

	assign forwardhE = ((alucontrolE == `MFHI_CONTROL || alucontrolE == `MFLO_CONTROL) && hilowriteM == 1'b1)? 1'b1:1'b0;
	
endmodule
