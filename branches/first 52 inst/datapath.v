`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/06 16:26:52
// Design Name: 
// Module Name: datapath
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


module datapath(
	input wire clk,rst,
	//fetch stage
	output wire[31:0] pcF,
	input wire[31:0] instrF,
	//decode stage
	input wire pcsrcD,branchD,
	input wire jumpD,jalD,jrD,balD, // add the input parameter jal, jr, bal
	output wire equalD,
	output wire[5:0] opD,functD,
	output wire[4:0] rtD, // add the ouput parameter rt
	//input wire [4:0] alucontrolD,
	//execute stage
	input wire memtoregE,
	input wire alusrcE,regdstE,
	input wire regwriteE,
	input wire[4:0] alucontrolE, // change the bit from 3 to 5 
	input wire jalE,jrE,balE, // add the input parameter jal, jr, bal
	output wire flushE,
	output wire overflowE,//
	output wire stallE,
	//mem stage
	input wire memtoregM,
	input wire regwriteM,
	input wire hilowriteM,
	output wire[31:0] aluoutM,writedataM,
	input wire[31:0] readdataM,
	input wire memenM, // add the mem enable signal
	output wire[5:0] opM, // add the memsel parameter op
	//writeback stage
	input wire memtoregW,
	input wire regwriteW,
	input wire hilowriteW
    );
	
	//fetch stage
	wire stallF;
	//FD
	wire [31:0] pcnextFD,pcnextbrFD,pcplus4F,pcbranchD;
	wire [31:0] pcnextFD2; // add the final pcnext address
	//decode stage
	wire [31:0] pcplus4D,instrD;
	wire forwardaD,forwardbD;
	wire [4:0] rsD,rdD,saD; // add the alu parameter imm sa
	wire flushD,stallD; 
	wire [31:0] signimmD,signimmshD;
	wire [31:0] srcaD,srca2D,srcbD,srcb2D;
	wire [63:0] hilo_oD;
	//execute stage
	wire [5:0] opE; // add op
	wire [31:0] pcplus4E,pcplus8E; // add the pcplus4E,pcplus8E
	wire [1:0] forwardaE,forwardbE;
	wire forwardhE;// 
	wire [4:0] rsE,rtE,rdE,saE; // add the alu parameter imm sa
	wire [4:0] writeregE,writereg2E; // add the writereg2E
	wire [31:0] signimmE;
	wire [31:0] srcaE,srca2E,srcbE,srcb2E,srcb3E;
	wire [31:0] aluoutE,aluout2E; // add the aluout2E
	wire [63:0] hilo_iE,hilo_i2E; // add the hilo_iE,hilo_i2E
	wire [63:0] hilo_oE;
	wire stall_divE;
	//wire [4:0] alucontrolE;//

	//mem stage
	wire [4:0] writeregM;
	wire [63:0] hilo_oM;
	//writeback stage
	wire [4:0] writeregW;
	wire [31:0] aluoutW,readdataW,resultW;
	wire [63:0] hilo_oW;

	//hazard detection
	hazard h(
		//fetch stage
		stallF,
		//decode stage
		rsD,rtD,
		branchD,balD,jumpD,
		forwardaD,forwardbD,
		stallD,
		//execute stage
		alucontrolE,
		rsE,rtE,
		writeregE,
		regwriteE,
		memtoregE,
		stall_divE,
		forwardaE,forwardbE,
		forwardhE,
		flushE,
		stallE,
		//mem stage
		writeregM,
		regwriteM,
		memtoregM,
		hilowriteM,
		//write back stage
		writeregW,
		regwriteW,
		hilowriteW
		);

	//next PC logic (operates in fetch an decode)
	mux2 #(32) pcbrmux(pcplus4F,pcbranchD,pcsrcD,pcnextbrFD);
	mux2 #(32) pcmux(pcnextbrFD,
		{pcplus4D[31:28],instrD[25:0],2'b00},
		jumpD | jalD ,pcnextFD); // add the jalD as the select signs
	mux2 #(32) pcmux2(pcnextFD,srca2D,jrD,pcnextFD2); // to select the next pc whether the rs register value

	//regfile (operates in decode and writeback)
	regfile rf(clk,regwriteW,rsD,rtD,writeregW,resultW,srcaD,srcbD);

	//hilo_reg 
	hilo_reg hilo(clk,rst,hilowriteW,hilo_oW[63:32],hilo_oW[31:0],hilo_oD[63:32],hilo_oD[31:0]);

	//fetch stage logic
	flopenr #(32) pcreg(clk,rst,~stallF,pcnextFD2,pcF);
	adder pcadd1(pcF,32'b100,pcplus4F);
	//decode stage
	flopenr #(32) r1D(clk,rst,~stallD,pcplus4F,pcplus4D);
	flopenrc #(32) r2D(clk,rst,~stallD,flushD,instrF,instrD);
	signext se(instrD[15:0],instrD[29:28],signimmD); // change the input parameter
	sl2 immsh(signimmD,signimmshD);
	adder pcadd2(pcplus4D,signimmshD,pcbranchD);
	mux2 #(32) forwardamux(srcaD,aluoutM,forwardaD,srca2D);
	mux2 #(32) forwardbmux(srcbD,aluoutM,forwardbD,srcb2D);
	eqcmp comp(srca2D,srcb2D,opD,rtD,equalD); // add the opD and rtD as parameter

	assign opD = instrD[31:26];
	assign functD = instrD[5:0];
	assign rsD = instrD[25:21];
	assign rtD = instrD[20:16];
	assign rdD = instrD[15:11];
	assign saD = instrD[10:6]; // add the alu parameter imm sa

	//execute stage
	flopenrc #(32) r1E(clk,rst,~stallE,flushE,srcaD,srcaE);
	flopenrc #(32) r2E(clk,rst,~stallE,flushE,srcbD,srcbE);
	flopenrc #(32) r3E(clk,rst,~stallE,flushE,signimmD,signimmE);
	flopenrc #(5) r4E(clk,rst,~stallE,flushE,rsD,rsE);
	flopenrc #(5) r5E(clk,rst,~stallE,flushE,rtD,rtE);
	flopenrc #(5) r6E(clk,rst,~stallE,flushE,rdD,rdE);
	flopenrc #(5) r7E(clk,rst,~stallE,flushE,saD,saE); // add the alu parameter imm sa
	flopenrc #(32) r8E(clk,rst,~stallE,flushE,pcplus4D,pcplus4E); // add the trigger
	flopenrc #(6) r9E(clk,rst,~stallE,flushE,opD,opE); // add the memsel parameter op
	flopenrc #(64) r10E(clk,rst,~stallE,flushE,hilo_oD,hilo_iE);//
	//flopenrc #(5) r11E(clk,rst,~stallE,flushE,alucontrolD,alucontrolE);//

	adder pcadd3(pcplus4E,32'b100,pcplus8E); // get the pcplus8E
	mux3 #(32) forwardaemux(srcaE,resultW,aluoutM,forwardaE,srca2E);
	mux3 #(32) forwardbemux(srcbE,resultW,aluoutM,forwardbE,srcb2E);
	mux2 #(64) forwardhemux(hilo_iE,hilo_oM,forwardhE,hilo_i2E);//
	mux2 #(32) srcbmux(srcb2E,signimmE,alusrcE,srcb3E);
	alu alu(clk,rst,srca2E,srcb3E,alucontrolE,saE,hilo_i2E[63:32],hilo_i2E[31:0],hilo_oE[63:32],hilo_oE[31:0],aluoutE,overflowE,stall_divE);// 
	mux2 #(5) wrmux(rtE,rdE,regdstE,writeregE); // add the alu parameter imm sa
	mux2 #(5) wrmux2(writeregE,5'b11111,jalE | balE,writereg2E); // to select whether write to 31 register
	mux2 #(32) wrmux3(aluoutE,pcplus8E,jalE | jrE | balE,aluout2E); // to select whether write data pc + 8 

	//mem stage
	flopenr #(32) r1M(clk,rst,~stallE,srcb2E,writedataM);
	flopenr #(32) r2M(clk,rst,~stallE,aluout2E,aluoutM);
	flopenr #(5) r3M(clk,rst,~stallE,writereg2E,writeregM);
	flopenr #(6) r4M(clk,rst,~stallE,opE,opM); // add the memsel parameter op
	flopenr #(64) r5M(clk,rst,~stallE,hilo_oE,hilo_oM);

	//writeback stage
	flopenr #(32) r1W(clk,rst,~stallE,aluoutM,aluoutW);
	flopenr #(32) r2W(clk,rst,~stallE,readdataM,readdataW);
	flopenr #(5) r3W(clk,rst,~stallE,writeregM,writeregW);
	mux2 #(32) resmux(aluoutW,readdataW,memtoregW,resultW);
	flopenr #(64) r4W(clk,rst,~stallE,hilo_oM,hilo_oW);
endmodule


