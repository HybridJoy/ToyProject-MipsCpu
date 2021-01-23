`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/06 21:16:51
// Design Name: 
// Module Name: controller
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


module controller(
	input wire clk,rst,
	//decode stage
	input wire[5:0] opD,functD,
	input wire[4:0] rtD, // add the input parameter rt
	output wire pcsrcD,branchD,
	input wire  equalD,
	output wire jumpD,
	output wire jalD,jrD,balD, // add the jal, jr, bal signal

	//execute stage
	input wire flushE,
	input wire stallE,
	output wire memtoregE,alusrcE,
	output wire regdstE,regwriteE,	
	output wire[4:0] alucontrolE, // change the bit from 3 to 5
	output wire jalE,jrE,balE, // add the jal, jr, bal signals
	output wire hilowriteE, // add the hilo register write signal

	//mem stage
	output wire memtoregM,memwriteM,
				regwriteM,memenM, // add the mem enable signal
				hilowriteM, // add the hilo register write signal

	//write back stage
	output wire memtoregW,regwriteW,
				hilowriteW // add the hilo register write signal

    );
	
	//decode stage
	wire[3:0] aluopD; // change the bit from 2 to 4
	wire memtoregD,memwriteD,alusrcD,
		regdstD,regwriteD;
	wire[4:0] alucontrolD; // change the bit from 3 to 5
	wire memenD,memenE; // add the mem enable signal
	wire hilowriteD; // add the hilo register write signal

	//execute stage
	wire memwriteE;

	maindec md(
		.opcode(opD),
		.funct(functD),
		.rt(rtD),
		.memtoreg(memtoregD),
		.memwrite(memwriteD),
		.branch(branchD),
		.alusrc(alusrcD),
		.regdst(regdstD),
		.regwrite(regwriteD),
		.jump(jumpD),
		.jal(jalD),
		.jr(jrD),
		.bal(balD),
		.memen(memenD),
		.hilowrite(hilowriteD),
		.aluop(aluopD)
		);
	aludec ad(functD,aluopD,alucontrolD);

	assign pcsrcD = branchD & equalD;

	//pipeline registers
	flopenrc #(15) regE( // change the bit from 14 to 15
		clk,
		rst,
		~stallE,
		flushE,
		{memtoregD,memwriteD,alusrcD,regdstD,regwriteD,jalD,jrD,balD,memenD,hilowriteD,alucontrolD},
		{memtoregE,memwriteE,alusrcE,regdstE,regwriteE,jalE,jrE,balE,memenE,hilowriteE,alucontrolE}
		);
	flopr #(8) regM(
		clk,rst,
		{memtoregE,memwriteE,memenE,regwriteE,hilowriteE},
		{memtoregM,memwriteM,memenM,regwriteM,hilowriteM} // add the mem enable signal
		);
	flopr #(8) regW(
		clk,rst,
		{memtoregM,regwriteM,hilowriteM},
		{memtoregW,regwriteW,hilowriteW} // add the hilo register write signal
		);
endmodule


