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
	// inst_mem
	output wire[31:0] pcF,
	input wire[31:0] instrF,
	// data_mem
	output wire memenM,
	output wire[3:0] memwrite,
	output wire[31:0] aluoutM,writedata,
	input wire[31:0] readdata,
	// debug
	output wire [31:0] debug_pcW,  // add the instr output
	output wire [3:0]  debug_rwW,  // add the regwrite signal output
	output wire [4:0]  debug_wnumW, // add the write register number output
	output wire [31:0] debug_resultW // add the write into register data 
    );
	
	wire [5:0] opD,functD;
	wire [4:0] rsD,rtD; // add the controller input parameter rs, rt
	//wire [4:0] alucontrolD;
	wire regdstE,alusrcE,pcsrcD,memtoregE,memtoregM,memtoregW,
			regwriteE,regwriteM,regwriteW;
	wire hilowriteE,hilowriteM,hilowriteW; // add the hilo register write signal
	wire cp0writeE,cp0writeM,cp0writeW;	// add the cp0 write signal
	wire [4:0] alucontrolE; // change the bit from 3 to 5
	wire flushE,equalD;
	wire jalD,jrD,balD,jalE,jrE,balE; // add the jal, jr, bal signals
	wire [31:0] writedataM,readdataM; // add
	wire [5:0] opM; // add the memsel parameter op
	wire overflowE; //
    wire stallE;
    wire memwriteM;
    wire adel_rdM,adesM; // add adel and ades input(readdata and writedata dataadr mistake)
    wire flushM,flusM;

	controller c(
		clk,rst,
		//decode stage
		opD,functD,rsD,rtD, // add the controller input parameter rs, rt
		pcsrcD,branchD,equalD,jumpD,
		jalD,jrD,balD, // add the ouput jal, bal, jr signals

		//execute stage
		flushE,
		stallE,
		overflowE,
		memtoregE,alusrcE,
		regdstE,regwriteE,	
		alucontrolE,
		jalE,jrE,balE, // add the output parameter jal,jr,bal
		hilowriteE, // add the hilo register write signal
		cp0writeE,	// add the cp0 write signal

		//mem stage
		flushM,
		memtoregM,memwriteM,
		regwriteM,memenM, // add the mem enable signal
		hilowriteM, // add the hilo register write signal
		cp0writeM,	// add the cp0 write signal

		//write back stage
		flushW,
		memtoregW,regwriteW,hilowriteW, // add the hilo register write signal
		cp0writeW	// add the cp0 write signal
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
		opD,functD,rsD,rtD, // add the datapath output parameter rs,rt
		//alucontrolD,

		//execute stage
		memtoregE,
		alusrcE,regdstE,
		regwriteE,
		// hilowriteE, // add the hilo register write signal
		// cp0writeE, 	// add the cp0 write signal
		alucontrolE,
		jalE,jrE,balE, // add the input parameter jal, jr, bal
		flushE,
		overflowE,
		stallE,

		//mem stage
		memtoregM,
		regwriteM,
		hilowriteM, // add the hilo register write signal
		cp0writeM,  // add the cp0 write signal
		aluoutM,writedataM,
		readdataM,
		opM, // add the memsel parameter op
		flusM, // add the flush signal
		adel_rdM,adesM,	// add adel and ades input(readdata and writedata dataadr mistake)

		//writeback stage
		memtoregW,
		regwriteW,
		hilowriteW, // add the hilo register write signal
		cp0writeW,	// add the cp0 write signal
		flushW, // add the flush signal

		// debug
		debug_pcW,		// add the instr output
		debug_wnumW,  // add the write register number output
		debug_resultW // add the write into register data
	    );

	assign debug_rwW = (regwriteW == 1'b1) ? 4'b1111 : 4'b0000;

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


