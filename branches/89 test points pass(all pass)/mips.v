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
	input wire  [5:0] int_i,
	// inst_mem
	output wire [31:0] pcF,
	input  wire [31:0] instrF,
	// data_mem
	output wire [0:0]  memenM,
	output wire [3:0]  memwrite,
	output wire [31:0] aluoutM,writedata,
	input  wire [31:0] readdata,
	// debug
	output wire [31:0] debug_pcW,  // add the instr output
	output wire [3:0]  debug_rwW,  // add the regwrite signal output
	output wire [4:0]  debug_wnumW, // add the write register number output
	output wire [31:0] debug_resultW // add the write into register data 
    );
	
	wire [5:0] opD,functD;
	wire [4:0] rsD,rtD; // add the controller input parameter rs, rt
	wire regdstE,alusrcE,pcsrcD,memtoregE,memtoregM,memtoregW,
			regwriteE,regwriteM,regwriteW;
	wire hilowriteE,hilowriteM,hilowriteW; // add the hilo register write signal
	wire cp0writeE,cp0writeM,cp0writeW;	// add the cp0 write signal
	wire [4:0] alucontrolD,alucontrolE; // change the bit from 3 to 5
	wire flushE,equalD;
	wire jalD,jrD,balD,jalE,jrE,balE; // add the jal, jr, bal signals
	wire [31:0] writedataM,readdataM; // add
	wire [5:0] opM; // add the memsel parameter op
	wire overflowE; // add the overflow signal
    wire stallE;
    wire memwriteM;
    wire adel_rdM,adesM; // add adel and ades input(readdata and writedata dataadr mistake)
    wire flushM,flushW;

	controller c(
		.clk(clk),
		.rst(rst),
		//decode stage
		.opD(opD),
		.functD(functD),
		.rsD(rsD),
		.rtD(rtD), // add the controller input parameter rs, rt
		.pcsrcD(pcsrcD),
		.branchD(branchD),
		.equalD(equalD),
		.jumpD(jumpD),
		.jalD(jalD),
		.jrD(jrD),
		.balD(balD), // add the ouput jal, bal, jr signals
		.alucontrolD(alucontrolD),

		//execute stage
		.flushE(flushE),
		.stallE(stallE),
		.overflowE(overflowE),
		.memtoregE(memtoregE),
		.alusrcE(alusrcE),
		.regdstE(regdstE),
		.regwriteE(regwriteE),	
		.alucontrolE(alucontrolE),
		.jalE(jalE),
		.jrE(jrE),
		.balE(balE), // add the output parameter jal,jr,bal
		.hilowriteE(hilowriteE), // add the hilo register write signal
		.cp0writeE(cp0writeE),	// add the cp0 write signal

		//mem stage
		.flushM(flushM),
		.memtoregM(memtoregM),
		.memwriteM(memwriteM),
		.regwriteM(regwriteM),
		.memenM(memenM), // add the mem enable signal
		.hilowriteM(hilowriteM), // add the hilo register write signal
		.cp0writeM(cp0writeM),	// add the cp0 write signal

		//write back stage
		.flushW(flushW),
		.memtoregW(memtoregW),
		.regwriteW(regwriteW),
		.hilowriteW(hilowriteW), // add the hilo register write signal
		.cp0writeW(cp0writeW)	// add the cp0 write signal
		);
	
	datapath dp(
		.clk(clk),
		.rst(rst),
		.int_i(int_i), // add the interrupt,high active
		//fetch stage
		.pcF(pcF),
		.instrF(instrF),

		//decode stage
		.pcsrcD(pcsrcD),
		.branchD(branchD),
		.jumpD(jumpD),
		.jalD(jalD),
		.jrD(jrD),
		.balD(balD), // add the datapath input parameter bal, jr, jal
		.equalD(equalD),
		.opD(opD),
		.functD(functD),
		.rsD(rsD),
		.rtD(rtD), // add the datapath output parameter rs,rt
		.alucontrolD(alucontrolD),

		//execute stage
		.memtoregE(memtoregE),
		.alusrcE(alusrcE),
		.regdstE(regdstE),
		.regwriteE(regwriteE),
		// hilowriteE, // add the hilo register write signal
		// cp0writeE, 	// add the cp0 write signal
		.alucontrolE(alucontrolE),
		.jalE(jalE),
		.jrE(jrE),
		.balE(balE), // add the input parameter jal, jr, bal
		.flushE(flushE),
		.overflowE(overflowE),
		.stallE(stallE),

		//mem stage
		.memtoregM(memtoregM),
		.regwriteM(regwriteM),
		.hilowriteM(hilowriteM), // add the hilo register write signal
		.cp0writeM(cp0writeM),  // add the cp0 write signal
		.aluoutM(aluoutM),
		.writedataM(writedataM),
		.readdataM(readdataM),
		.opM(opM), // add the memsel parameter op
		.flushM(flushM), // add the flush signal
		.adel_rdM(adel_rdM),
		.adesM(adesM),	// add adel and ades input(readdata and writedata dataadr mistake)

		//writeback stage
		.memtoregW(memtoregW),
		.regwriteW(regwriteW),
		.hilowriteW(hilowriteW), // add the hilo register write signal
		.cp0writeW(cp0writeW),	// add the cp0 write signal
		.flushW(flushW), // add the flush signal

		// debug
		.pcW(debug_pcW),		// add the instr output
		.writeregW(debug_wnumW),  // add the write register number output
		.resultW(debug_resultW) // add the write into register data
	    );

	// debug test signal
	// assign debug_rwW = ((regwriteW == 1'b1) && ((~ stallE) | (stallE & flushW))) ? 4'b1111 : 4'b0000;
	assign debug_rwW = 4'b0000;

	memsel msl(
			  	.opcode(opM),
				.dataaddr(aluoutM),
				.writedata_dp(writedataM),
				.readdata_mem(readdata),
				.select(memwrite),
				.writedata(writedata),
				.readdata(readdataM),
				.adel(adel_rdM),
				.ades(adesM)
			  );
	
endmodule


