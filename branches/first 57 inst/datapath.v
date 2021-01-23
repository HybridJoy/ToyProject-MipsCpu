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
	output wire[4:0] rsD,rtD, // add the ouput parameter rs, rt
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
	input wire cp0writeM,//
	output wire[31:0] aluoutM,writedataM,
	input wire[31:0] readdataM,
	//input wire memenM, // add the mem enable signal
	output wire[5:0] opM, // add the memsel parameter op
	output wire flushM,//
	input wire adel_rdM,adesM,//
	//writeback stage
	input wire memtoregW,
	input wire regwriteW,
	input wire hilowriteW,
	output wire flushW,//
	//cp0
	input wire cp0writeW
    );
	
	//fetch stage
	wire stallF;
	wire flushF;
	//FD
	wire [31:0] pcnextFD,pcnextbrFD,pcplus4F,pcbranchD;
	wire [31:0] pcnextFD2; // add the final pcnext address
	wire [31:0] pcNewFD; // add the pcnewFD
	wire [31:0] pcnextjrD;//
	//decode stage
	wire [31:0] pcplus4D,instrD;
	wire forwardaD,forwardbD;
	wire [1:0] forwardjrD;
	wire [4:0] rdD,saD; // add the alu parameter imm sa
	wire flushD,stallD; 
	wire [31:0] signimmD,signimmshD;
	wire [31:0] srcaD,srca2D,srcbD,srcb2D;
	wire [63:0] hilo_oD;
	wire [4:0] writecp0D;//
	//execute stage
	wire [5:0] opE; // add op
	wire [31:0] pcplus4E,pcplus8E; // add the pcplus4E,pcplus8E
	wire [1:0] forwardaE,forwardbE;
	wire [1:0] forwardhE;// 
	wire [4:0] rsE,rtE,rdE,saE; // add the alu parameter imm sa
	wire [4:0] writeregE,writereg2E; // add the writereg2E
	wire [4:0] writecp0E; // add the writecp0E
	wire [31:0] signimmE;
	wire [31:0] srcaE,srca2E,srcbE,srcb2E,srcb3E;
	wire [31:0] aluoutE,aluout2E; // add the aluout2E
	wire [63:0] hilo_iE,hilo_i2E; // add the hilo_iE,hilo_i2E
	wire [63:0] hilo_oE;
	wire stall_divE;
	//wire [4:0] alucontrolE;//

	//mem stage
	wire [4:0] writeregM;
	wire [4:0] writecp0M;//
	wire [63:0] hilo_oM;
	//writeback stage
	wire [4:0] writeregW;
	wire [4:0] writecp0W;
	wire [31:0] aluoutW,readdataW,resultW;
	wire [63:0] hilo_oW;

	wire [7:0] exceptF,exceptD,exceptE,exceptM,exceptW;
	wire [31:0] pcplus8M,pcplus8W;//

	//cp0
	wire [1:0] forwardcp0E;
    wire [31:0] cp0DataE,cp0Data2E;
    wire syscallD,breakD,eretD;
	wire [31:0] excepttypeM,excepttypeW;
    wire [31:0] newpcW;
    wire [31:0] bad_addr_M,bad_addr_W;
    wire [31:0] data_o,count_o,compare_o,status_o,cause_o,epc_o, config_o,prid_o,badvaddr;
    wire timer_int_o;
    wire is_in_slotF,is_in_slotD,is_in_slotE,is_in_slotM,is_in_slotW;
    wire [5:0] int_i;
    wire [4:0] rdM,rdW;
	
	//hazard detection
	hazard h(
		//fetch stage
		stallF,
		flushF,
		//decode stage
		rsD,rtD,
		branchD,balD,jumpD,
		forwardaD,forwardbD,
		forwardjrD,
		stallD,
		flushD,
		//execute stage
		alucontrolE,
		rsE,rtE,rdE,
		writeregE,
		writecp0E,
		regwriteE,
		memtoregE,
		stall_divE,
		forwardaE,forwardbE,
		forwardhE,
		forwardcp0E,
		flushE,
		stallE,
		//mem stage
		writeregM,
		writecp0M,
		regwriteM,
		cp0writeM,
		memtoregM,
		hilowriteM,
		flushM,
		//write back stage
		excepttypeW,
		epc_o,
		newpcW,
		writeregW,
		regwriteW,
		hilowriteW,
		cp0writeW,
		flushW
		);

	//next PC logic (operates in fetch an decode)
	mux2 #(32) pcbrmux(pcplus4F,pcbranchD,pcsrcD,pcnextbrFD);
	mux2 #(32) pcmux(pcnextbrFD,
		{pcplus4D[31:28],instrD[25:0],2'b00},
		jumpD | jalD ,pcnextFD); // add the jalD as the select signs
	mux3 #(32) forwardjrmux(srcaD,aluoutM,aluout2E,forwardjrD,pcnextjrD);
	mux2 #(32) pcmux2(pcnextFD,pcnextjrD,jrD,pcnextFD2); // to select the next pc whether the rs register value
	mux2 #(32) pcNewmux(pcnextFD2,newpcW,flushF,pcNewFD);//


	//regfile (operates in decode and writeback)
	regfile rf(clk,regwriteW,rsD,rtD,writeregW,resultW,srcaD,srcbD);

	//hilo_reg 
	hilo_reg hilo(clk,rst,hilowriteW,hilo_oW[63:32],hilo_oW[31:0],hilo_oD[63:32],hilo_oD[31:0]);

	//fetch stage logic
	flopenr #(32) pcreg(clk,rst,~stallF,pcNewFD,pcF);// change pcnextFD2 to pcNewFD
	adder pcadd1(pcF,32'b100,pcplus4F);
	assign exceptF = (pcF[1:0] == 2'b00) ? 8'b00000000: 8'b10000000;//
	assign is_in_slotF = (jumpD|jalD|jrD|branchD|balD);//

	//decode stage
	flopenrc #(32) r1D(clk,rst,~stallD,flushD,pcplus4F,pcplus4D);
	flopenrc #(32) r2D(clk,rst,~stallD,flushD,instrF,instrD);
	flopenrc #(8)  r3D(clk,rst,~stallD,flushD,exceptF,exceptD);
	flopenrc #(1)  r4D(clk,rst,~stallD,flushD,is_in_slotF,is_in_slotD);
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
	assign writecp0D = instrD[15:11]; // add the writecp0D
	assign breakD = (opD == 6'b000000 && functD == 6'b001101);
	assign syscallD = (opD == 6'b000000 && functD == 6'b001100);
	assign eretD = (instrD == 32'b01000010000000000000000000011000);

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
	flopenrc #(5)  r11E(clk,rst,~stallE,flushE,writecp0D,writecp0E);
	flopenrc #(8)  r12E(clk,rst,~stallE,flushE,
            {exceptD[7],syscallD,breakD,eretD,1'b0,exceptD[2:0]},
            exceptE);
    flopenrc #(1)  r13E(clk,rst,~stallE,flushE,is_in_slotD,is_in_slotE);
    assign cp0DataE = data_o;

	adder pcadd3(pcplus4E,32'b100,pcplus8E); // get the pcplus8E
	mux3 #(32) forwardaemux(srcaE,resultW,aluoutM,forwardaE,srca2E);
	mux3 #(32) forwardbemux(srcbE,resultW,aluoutM,forwardbE,srcb2E);
	mux3 #(64) forwardhemux(hilo_iE,hilo_oW,hilo_oM,forwardhE,hilo_i2E);
	mux3 #(32) forwardcp0mux(cp0DataE,aluoutW,aluoutM,forwardcp0E,cp0Data2E);

	//mux2 #(64) forwardhemux(hilo_iE,hilo_oM,forwardhE,hilo_i2E);//
	mux2 #(32) srcbmux(srcb2E,signimmE,alusrcE,srcb3E);
	//mux2 #(32) cp0mux(cp0DataE,aluoutM,forwardcp0E,cp0Data2E);//
	alu alu(clk,rst,srca2E,srcb3E,alucontrolE,saE,hilo_i2E[63:32],hilo_i2E[31:0],hilo_oE[63:32],hilo_oE[31:0],aluoutE,overflowE,stall_divE,cp0Data2E);// 
	mux2 #(5) wrmux(rtE,rdE,regdstE,writeregE); // add the alu parameter imm sa
	mux2 #(5) wrmux2(writeregE,5'b11111,jalE | balE,writereg2E); // to select whether write to 31 register
	mux2 #(32) wrmux3(aluoutE,pcplus8E,jalE | jrE | balE,aluout2E); // to select whether write data pc + 8 

	//mem stage
	flopenrc #(32) r1M(clk,rst,~stallE,flushM,srcb2E,writedataM);
	flopenrc #(32) r2M(clk,rst,~stallE,flushM,aluout2E,aluoutM);
	flopenrc #(5) r3M(clk,rst,~stallE,flushM,writereg2E,writeregM);
	flopenrc #(6) r4M(clk,rst,~stallE,flushM,opE,opM); // add the memsel parameter op
	flopenrc #(64) r5M(clk,rst,~stallE,flushM,hilo_oE,hilo_oM);
	flopenrc #(5)  r6M(clk,rst,~stallE,flushM,writecp0E,writecp0M);
	flopenrc #(8)  r7M(clk,rst,~stallE,flushM,{exceptE[7:3],overflowE,exceptE[1:0]},exceptM);
	flopenrc #(32) r8M(clk,rst,~stallE,flushM,pcplus8E,pcplus8M);
	exception exception(rst,exceptM,adel_rdM,adesM,status_o,cause_o,excepttypeM);
	flopenrc #(1)  r9M(clk,rst,~stallE,flushM,is_in_slotE,is_in_slotM);
	flopenrc #(5) r10M(clk,rst,~stallE,flushM,rdE,rdM);

	//writeback stage
	flopenrc #(32) r1W(clk,rst,~stallE,flushW,aluoutM,aluoutW);
	flopenrc #(32) r2W(clk,rst,~stallE,flushW,readdataM,readdataW);
	flopenrc #(5) r3W(clk,rst,~stallE,flushW,writeregM,writeregW);
	mux2 #(32) resmux(aluoutW,readdataW,memtoregW,resultW);
	flopenrc #(64) r4W(clk,rst,~stallE,flushW,hilo_oM,hilo_oW);
	flopenrc #(32) r5W(clk,rst,~stallE,flushW,bad_addr_M,bad_addr_W);
	flopenrc #(5)  r6w(clk,rst,~stallE,flushW,writecp0M,writecp0W);
	flopenrc #(32) r7W(clk,rst,~stallE,flushW,excepttypeM,excepttypeW);
	flopenrc #(32) r8W(clk,rst,~stallE,flushW,pcplus8M,pcplus8W);
	flopenrc #(32) r9W(clk,rst,~stallE,flushW,exceptM,exceptW);
	flopenrc #(1)  r10W(clk,rst,~stallE,flushW,is_in_slotM,is_in_slotW);
	flopenrc #(5) r11W(clk,rst,~stallE,flushW,rdM,rdW);

	//cp0
	cp0_reg cp0reg(clk,rst,cp0writeW,writecp0W,rdW,resultW,int_i,
        excepttypeW,pcplus8W-8,is_in_slotW,bad_addr_W,
        data_o,count_o,compare_o,status_o,cause_o,epc_o,config_o,prid_o,
        badvaddr,timer_int_o);
endmodule