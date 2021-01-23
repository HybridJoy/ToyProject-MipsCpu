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
	input wire  clk,rst,
	input wire  [5:0]  int_i,
	// fetch stage
	output wire [31:0] pcF,
	input  wire [31:0] instrF,
	// decode stage
	input wire  [0:0]  pcsrcD,branchD,
	input wire  [0:0]  jumpD,jalD,jrD,balD, // add the input parameter jal, jr, bal
	output wire [0:0]  equalD,
	output wire [5:0]  opD,functD,
	output wire [4:0]  rsD,rtD, // add the ouput parameter rs, rt
	input  wire [4:0]  alucontrolD,
	// execute stage
	input wire  [0:0]  memtoregE,
	input wire  [0:0]  alusrcE,regdstE,
	input wire  [0:0]  regwriteE,
	input wire  [4:0]  alucontrolE, // change the bit from 3 to 5 
	input wire  [0:0]  jalE,jrE,balE, // add the input parameter jal, jr, bal
	output wire [0:0]  flushE,
	output wire [0:0]  overflowE, // add the overflow signal
	output wire [0:0]  stallE,
	// mem stage
	input wire  [0:0]  memtoregM,
	input wire  [0:0]  regwriteM,
	input wire  [0:0]  hilowriteM,
	input wire  [0:0]  cp0writeM, // add the cp0 write signal
	output wire [31:0] aluoutM,writedataM,
	input  wire [31:0] readdataM,
	output wire [5:0]  opM, // add the memsel parameter op
	output wire [0:0]  flushM, // add the clear signal
	input  wire [0:0]  adel_rdM,adesM, // add the mistake dataadr signal when load or store with mem
	// writeback stage
	input wire  [0:0]  memtoregW,
	input wire  [0:0]  regwriteW,
	input wire  [0:0]  hilowriteW,
	input wire  [0:0]  cp0writeW, // add the cp0 write signal
	output wire [0:0]  flushW, // add the clear signal
	// debug
	output wire [31:0] pcW,
	output wire [4:0]  writeregW,
	output wire [31:0] resultW
    );
	
	//fetch stage
	wire [0:0]  stallF;
	wire [0:0]  flushF;
	//FD
	wire [31:0] pcnextFD,pcnextbrFD,pcplus4F,pcbranchD;
	wire [31:0] pcnextFD2; // add the final pcnext address
	wire [31:0] pcNewFD; // add the pcnewFD
	//decode stage
	wire [31:0] pcplus4D,instrD,pcD;
	wire [1:0]  forwardaD,forwardbD;
	wire [4:0]  rdD,saD; // add the alu parameter imm sa
	wire [0:0]  flushD,stallD; 
	wire [31:0] signimmD,signimmshD;
	wire [31:0] srcaD,srca2D,srcbD,srcb2D;
	wire [63:0] hilo_oD;
	wire [4:0]  writecp0D; // write into cp0 register 
	//execute stage
	wire [5:0]  opE; // add op
	wire [31:0] pcplus4E,pcplus8E,pcE; // add the pcplus4E,pcplus8E
	wire [1:0]  forwardaE,forwardbE;
	wire [1:0]  forwardhE; // hilo data forward
	wire [4:0]  rsE,rtE,rdE,saE; // add the alu parameter imm sa
	wire [4:0]  writeregE,writereg2E; // add the writereg2E
	wire [4:0]  writecp0E; // write into cp0 register
	wire [31:0] signimmE;
	wire [31:0] srcaE,srca2E,srcbE,srcb2E,srcb3E;
	wire [31:0] aluoutE,aluout2E; // add the aluout2E
	wire [63:0] hilo_iE,hilo_i2E; // add the hilo_iE,hilo_i2E
	wire [63:0] hilo_oE;
	wire [0:0]  stall_divE;

	//mem stage
	wire [31:0] pcM;
	wire [4:0]  writeregM;
	wire [4:0]  writecp0M; // write into cp0 register
	wire [63:0] hilo_oM;
	//writeback stage
	wire [4:0]  writecp0W;
	wire [31:0] aluoutW,readdataW;
	wire [63:0] hilo_oW;

	wire [7:0]  exceptF,exceptD,exceptE,exceptM,exceptW;
	wire [31:0] pcplus8M,pcplus8W; // pcplus8

	//cp0
	wire [1:0]  forwardcp0E;
    wire [31:0] cp0DataE,cp0Data2E;
    wire [0:0]  syscallD,breakD,eretD;
	wire [31:0] excepttypeM,excepttypeW;
    wire [31:0] newpcM;
    wire [31:0] bad_addr_M,bad_addr_W;
    wire [31:0] data_o,count_o,compare_o,status_o,cause_o,epc_o, config_o,prid_o,badvaddr;
    wire [0:0]  timer_int_o;
    wire [0:0]  is_in_slotF,is_in_slotD,is_in_slotE,is_in_slotM,is_in_slotW;
    wire [4:0]  rdM,rdW;
	
	wire [31:0] memadr_mis; // mistake dataadr when load or store 
	wire [0:0]  invalidinstD;

	// hazard detection
	hazard h(
		//fetch stage
		.stallF(stallF),
		.flushF(flushF),
		//decode stage
		.rsD(rsD),
		.rtD(rtD),
		.branchD(branchD),
		.balD(balD),
		.forwardaD(forwardaD),
		.forwardbD(forwardbD),
		.stallD(stallD),
		.flushD(flushD),
		//execute stage
		.alucontrolE(alucontrolE),
		.rsE(rsE),
		.rtE(rtE),
		.rdE(rdE),
		.writeregE(writeregE),
		.writecp0E(writecp0E),
		.regwriteE(regwriteE),
		.memtoregE(memtoregE),
		.stall_divE(stall_divE),
		.forwardaE(forwardaE),
		.forwardbE(forwardbE),
		.forwardhE(forwardhE),
		.forwardcp0E(forwardcp0E),
		.flushE(flushE),
		.stallE(stallE),
		//mem stage
		.writeregM(writeregM),
		.writecp0M(writecp0M),
		.regwriteM(regwriteM),
		.cp0writeM(cp0writeM),
		.memtoregM(memtoregM),
		.hilowriteM(hilowriteM),
		.flushM(flushM),
		.excepttypeM(excepttypeM),
		.cp0_epcM(epc_o),
		.newpcM(newpcM),
		//write back stage
		.writeregW(writeregW),
		.regwriteW(regwriteW),
		.hilowriteW(hilowriteW),
		.cp0writeW(cp0writeW),
		.flushW(flushW)
		);

	//next PC logic (operates in fetch an decode)
	mux2 #(32) pcbrmux(pcplus4F,pcbranchD,pcsrcD,pcnextbrFD);
	mux2 #(32) pcmux(pcnextbrFD,
		{pcplus4D[31:28],instrD[25:0],2'b00},
		jumpD | jalD ,pcnextFD); // add the jalD as the select signs
	mux2 #(32) pcmux2(pcnextFD,srca2D,jrD,pcnextFD2); // to select the next pc whether the rs register value
	mux2 #(32) pcNewmux(pcnextFD2,newpcM,flushF,pcNewFD); // whether exception occurr


	//regfile (operates in decode and writeback)
	regfile rf(clk,regwriteW,rsD,rtD,writeregW,resultW,srcaD,srcbD);

	//hilo_reg 
	hilo_reg hilo(clk,rst,hilowriteW,hilo_oW[63:32],hilo_oW[31:0],hilo_oD[63:32],hilo_oD[31:0]);

	//fetch stage logic
	pc pcreg(clk,rst,~stallF,pcNewFD,pcF); // change pcnextFD2 to pcNewFD
	adder pcadd1(pcF,32'b100,pcplus4F);
	assign exceptF = (pcF[1:0] == 2'b00) ? 8'b00000000: 8'b10000000; //
	assign is_in_slotF = (jumpD | jalD | jrD | branchD | balD); //
	assign invalidinstD = (alucontrolD == 5'b00000) ? 1'b1 : 1'b0;

	//decode stage
	flopenrc #(32) r1D(clk,rst,~stallD,flushD,pcplus4F,pcplus4D);
	flopenrc #(32) r2D(clk,rst,~stallD,flushD,instrF,instrD);
	flopenrc #(8)  r3D(clk,rst,~stallD,flushD,exceptF,exceptD);
	flopenrc #(1)  r4D(clk,rst,~stallD,flushD,is_in_slotF,is_in_slotD);
	flopenrc #(32) r5D(clk,rst,~stallD,flushD,pcF,pcD);

	signext se(instrD[15:0],instrD[29:28],signimmD); // change the input parameter
	sl2 immsh(signimmD,signimmshD);
	adder pcadd2(pcplus4D,signimmshD,pcbranchD);
	// mux2 #(32) forwardamux(srcaD,aluoutM,forwardaD,srca2D);
	// mux2 #(32) forwardbmux(srcbD,aluoutM,forwardbD,srcb2D);
	mux3 #(32) forwardamux(srcaD,aluoutE,aluoutM,forwardaD,srca2D);
	mux3 #(32) forwardbmux(srcbD,aluoutE,aluoutM,forwardbD,srcb2D);// change the mux2 to mux3
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
	flopenrc #(5)  r4E(clk,rst,~stallE,flushE,rsD,rsE);
	flopenrc #(5)  r5E(clk,rst,~stallE,flushE,rtD,rtE);
	flopenrc #(5)  r6E(clk,rst,~stallE,flushE,rdD,rdE);
	flopenrc #(5)  r7E(clk,rst,~stallE,flushE,saD,saE); // add the alu parameter imm sa
	flopenrc #(32) r8E(clk,rst,~stallE,flushE,pcplus4D,pcplus4E); // add the trigger
	flopenrc #(6)  r9E(clk,rst,~stallE,flushE,opD,opE); // add the memsel parameter op
	flopenrc #(64) r10E(clk,rst,~stallE,flushE,hilo_oD,hilo_iE); //
	flopenrc #(5)  r11E(clk,rst,~stallE,flushE,writecp0D,writecp0E);
	flopenrc #(8)  r12E(clk,rst,~stallE,flushE,
            {exceptD[7],syscallD,breakD,eretD,invalidinstD,exceptD[2:0]},
            exceptE);
    flopenrc #(1)  r13E(clk,rst,~stallE,flushE,is_in_slotD,is_in_slotE);
    flopenrc #(32) r14E(clk,rst,~stallE,flushE,pcD,pcE);

    assign cp0DataE = data_o;
	adder pcadd3(pcplus4E,32'b100,pcplus8E); // get the pcplus8E
	mux3 #(32) forwardaemux(srcaE,resultW,aluoutM,forwardaE,srca2E);
	mux3 #(32) forwardbemux(srcbE,resultW,aluoutM,forwardbE,srcb2E);
	mux3 #(64) forwardhemux(hilo_iE,hilo_oW,hilo_oM,forwardhE,hilo_i2E);
	mux3 #(32) forwardcp0mux(cp0DataE,aluoutW,aluoutM,forwardcp0E,cp0Data2E);
	mux2 #(32) srcbmux(srcb2E,signimmE,alusrcE,srcb3E);
	alu alu(clk,rst,srca2E,srcb3E,alucontrolE,saE,hilo_i2E[63:32],hilo_i2E[31:0],
		    hilo_oE[63:32],hilo_oE[31:0],aluoutE,overflowE,stall_divE,cp0Data2E);// 
	mux2 #(5) wrmux(rtE,rdE,regdstE,writeregE); // add the alu parameter imm sa
	mux2 #(5) wrmux2(writeregE,5'b11111,jalE | balE,writereg2E); // to select whether write to 31 register
	mux2 #(32) wrmux3(aluoutE,pcplus8E,jalE | jrE | balE,aluout2E); // to select whether write data pc + 8 

	//mem stage
	flopenrc #(32) r1M(clk,rst,~stallE,flushM,srcb2E,writedataM);
	flopenrc #(32) r2M(clk,rst,~stallE,flushM,aluout2E,aluoutM);
	flopenrc #(5)  r3M(clk,rst,~stallE,flushM,writereg2E,writeregM);
	flopenrc #(6)  r4M(clk,rst,~stallE,flushM,opE,opM); // add the memsel parameter op
	flopenrc #(64) r5M(clk,rst,~stallE,flushM,hilo_oE,hilo_oM);
	flopenrc #(5)  r6M(clk,rst,~stallE,flushM,writecp0E,writecp0M);
	flopenrc #(8)  r7M(clk,rst,~stallE,flushM,{exceptE[7:3],overflowE,exceptE[1:0]},exceptM);
	flopenrc #(32) r8M(clk,rst,~stallE,flushM,pcplus8E,pcplus8M);
	flopenrc #(1)  r9M(clk,rst,~stallE,flushM,is_in_slotE,is_in_slotM);
	flopenrc #(5)  r10M(clk,rst,~stallE,flushM,rdE,rdM);
	flopenrc #(32) r11M(clk,rst,~stallE,flushM,pcE,pcM);
    
    assign memadr_mis = ((adel_rdM == 1'b1) || (adesM == 1'b1)) ? aluoutM : 32'h00000000;
    mux2 #(32) bad_addrmux(memadr_mis,pcM,exceptM[7],bad_addr_M);
	exception exception(rst,exceptM,adel_rdM,adesM,status_o,cause_o,excepttypeM);
    
    cp0_reg cp0reg(clk,rst,cp0writeM,writecp0M,rdE,aluoutM,int_i,
            excepttypeM,pcplus8M-8,is_in_slotM,bad_addr_M,
            data_o,count_o,compare_o,status_o,cause_o,epc_o,config_o,prid_o,
            badvaddr,timer_int_o);
            
	//writeback stage
	flopenrc #(32) r1W(clk,rst,~stallE,flushW,aluoutM,aluoutW);
	flopenrc #(32) r2W(clk,rst,~stallE,flushW,readdataM,readdataW);
	flopenrc #(6)  r3W(clk,rst,~stallE,flushW,writeregM,writeregW);
	flopenrc #(64) r4W(clk,rst,~stallE,flushW,hilo_oM,hilo_oW);
	// flopenrc #(32) r5W(clk,rst,~stallE,flushW,bad_addr_M,bad_addr_W);
	// flopenrc #(5)  r6W(clk,rst,~stallE,flushW,writecp0M,writecp0W);
	// flopenrc #(32) r7W(clk,rst,~stallE,flushW,excepttypeM,excepttypeW);
	// flopenrc #(32) r8W(clk,rst,~stallE,flushW,pcplus8M,pcplus8W);
	// flopenrc #(8)  r9W(clk,rst,~stallE,flushW,exceptM,exceptW);
	// flopenrc #(1)  r10W(clk,rst,~stallE,flushW,is_in_slotM,is_in_slotW);
	// flopenrc #(5)  r11W(clk,rst,~stallE,flushW,rdM,rdW);
	flopenrc #(32) r12W(clk,rst,~stallE,flushW,pcM,pcW);

	mux2 #(32) resmux(aluoutW,readdataW,memtoregW,resultW);

endmodule