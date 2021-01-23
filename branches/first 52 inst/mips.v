`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/06 16:31:29
// Design Name: 
// Module Name: mips
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


module mips(
	input wire clk,rst,
	output wire[31:0] pcF,
	input wire[31:0] instrF,
	output wire[3:0] memwrite,
	output wire memenM,
	output wire[31:0] aluoutM,writedata,
	input wire[31:0] readdata 
    );
	
	wire [5:0] opD,functD;
	wire [4:0] rtD; // add the controller input parameter rt
	//wire [4:0] alucontrolD;
	wire regdstE,alusrcE,pcsrcD,memtoregE,memtoregM,memtoregW,
			regwriteE,regwriteM,regwriteW;
	wire hilowriteE,hilowriteM,hilowriteW; // add the hilo register write signal
	wire [4:0] alucontrolE; // change the bit from 3 to 5
	wire flushE,equalD;
	wire jalD,jrD,balD,jalE,jrE,balE; // add the jal, jr, bal signals
	wire [31:0] writedataM,readdataM; // add
	wire [5:0] opM; // add the memsel parameter op
	wire overflowE; //
    wire stallE;
    wire memwriteM;


	controller c(
		clk,rst,
		//decode stage
		opD,functD,rtD, // add the controller input parameter rt
		pcsrcD,branchD,equalD,jumpD,
		jalD,jrD,balD, // add the ouput jal, bal, jr signals

		//execute stage
		flushE,
		stallE,
		memtoregE,alusrcE,
		regdstE,regwriteE,	
		alucontrolE,
		jalE,jrE,balE, // add the output parameter jal,jr,bal
		hilowriteE, // add the hilo register write signal

		//mem stage
		memtoregM,memwriteM,
		regwriteM,memenM, // add the mem enable signal
		hilowriteM, // add the hilo register write signal

		//write back stage
		memtoregW,regwriteW,hilowriteW // add the hilo register write signal
		);
	datapath dp(
		clk,rst,
		//fetch stage
		pcF,
		instrF,

		//decode stage
		pcsrcD,branchD,
		jumpD,jalD,jrD,balD, // add the datapath input parameter bal, jr, jal
		equalD,
		opD,functD,rtD, // add the datapath output parameter rt
		//alucontrolD,

		//execute stage
		memtoregE,
		alusrcE,regdstE,
		regwriteE,
		alucontrolE,
		jalE,jrE,balE, // add the input parameter jal, jr, bal
		flushE,
		overflowE,
		stallE,

		//mem stage
		memtoregM,
		regwriteM,
		hilowriteM, // add the hilo register write signal
		aluoutM,writedataM,
		readdataM,memenM, // add the mem enable signal
		opM, // add the memsel parameter op

		//writeback stage
		memtoregW,
		regwriteW,
		hilowriteW // add the hilo register write signal
	    );

		memsel msl(
			.opcode(opM),
			.dataaddr(aluoutM),
			.writedata_dp(writedataM),
			.readdata_mem(readdata),
			.select(memwrite),
			.writedata(writedata),
			.readdata(readdataM)
			);
	
endmodule


