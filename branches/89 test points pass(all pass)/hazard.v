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

module hazard(stallF,flushF,rsD,rtD,branchD,balD,forwardaD,forwardbD,stallD,flushD,
			  alucontrolE,rsE,rtE,rdE,writeregE,writecp0E,regwriteE,memtoregE,
			  stall_divE,forwardaE,forwardbE,forwardhE,forwardcp0E,flushE,stallE,
			  writeregM,writecp0M,regwriteM,cp0writeM,memtoregM,hilowriteM,flushM,
			  excepttypeM,cp0_epcM,newpcM,writeregW,regwriteW,hilowriteW,cp0writeW,flushW);
	
	// fetch stage
	output wire [0:0] stallF;
	output wire [0:0] flushF;

	// decode stage
	input wire  [4:0] rsD;
	input wire  [4:0] rtD;
	input wire  [0:0] branchD;
	input wire  [0:0] balD; // add the bal signal
	output reg  [1:0] forwardaD;
	output reg  [1:0] forwardbD;
	output wire	[0:0] stallD;
	output wire [0:0] flushD; // D clear siganl

	// execute stage
	input wire  [4:0] alucontrolE;
	input wire  [4:0] rsE;
	input wire  [4:0] rtE;
	input wire  [4:0] rdE;
	input wire  [4:0] writeregE;
	input wire  [4:0] writecp0E; // write into cp0 register
	input wire  [0:0] regwriteE;
	input wire  [0:0] memtoregE;
	input wire  [0:0] stall_divE; // div stall signal
	output reg  [1:0] forwardaE;
	output reg  [1:0] forwardbE;
	output reg  [1:0] forwardhE;
	output reg  [1:0] forwardcp0E; // hilo reg data forward
	output wire [0:0] flushE;
	output wire [0:0] stallE; // E stall signal

	// mem stage
	input wire  [4:0]  writeregM;
	input wire  [4:0]  writecp0M;
	input wire  [0:0]  regwriteM;
	input wire  [0:0]  cp0writeM; // cp0 write signal
	input wire  [0:0]  memtoregM;
	input wire  [0:0]  hilowriteM;
	output wire [0:0]  flushM; // M clear signal
	input wire  [31:0] excepttypeM; // except type
	input wire  [31:0] cp0_epcM;
	output reg  [31:0] newpcM;

	// write back stage
	input wire  [4:0] writeregW;
	input wire  [0:0] regwriteW;
	input wire  [0:0] hilowriteW;
	input wire  [0:0] cp0writeW;
	output wire [0:0] flushW; // W clear signal

	// === data push forward logic === //

	// == decode stage == //

	// Operand srca 
	always @ (*) 
	begin
		if((rsD != 5'b00000) && (rsD == writeregE) && regwriteE)
		begin
			forwardaD <= 2'b01;
		end
		else if((rsD != 5'b00000) && (rsD == writeregM) && regwriteM)
		begin
			forwardaD <= 2'b10;
		end
		else
		begin
			forwardaD <= 2'b00;
		end
	end

	// Operand srcb
	always @ (*) 
	begin
		if((rtD != 5'b00000) && (rtD == writeregE) && regwriteE)
		begin
			forwardbD <= 2'b01;
		end
		else if((rtD != 5'b00000) && (rtD == writeregM) && regwriteM)
		begin
			forwardbD <= 2'b10;
		end
		else
		begin
			forwardbD <= 2'b00;
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

	// forwardhiloE
	always @ (*)
	begin
		if(hilowriteM)
		begin
			forwardhE <= 2'b10;
		end
		else if(hilowriteW)
		begin
			forwardhE <= 2'b01;
		end
		else
		begin
			forwardhE <= 2'b00;
		end
	end

	// forwardcp0E
	always @ (*)
	begin
		if((rdE != 5'b0) && (rdE == writeregM) && cp0writeM)
		begin
			forwardcp0E <= 2'b10;
		end
		else if((rdE != 5'b0) && (rdE == writeregW) && cp0writeW)
		begin
			forwardcp0E <= 2'b01;
		end
		else
		begin
			forwardcp0E <= 2'b00;
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

	wire flush_except;
	assign flush_except = (excepttypeM !=32'b0);

	// assign stallF  = lwstall || branchstall;
	// assign stallD  = lwstall || branchstall;
	// assign flushE  = lwstall || branchstall;
	assign stallF  = ((lwstall | branchstall | stall_divE) & (~ balD)) & (~flush_except);
	assign stallD  = (lwstall | branchstall | stall_divE) & (~ balD);
	assign flushE  = ((lwstall | branchstall) & (~ balD)) | flush_except;
	assign stallE  = stall_divE;
	// assign stallM  = stall_divE; // add the M stall
	assign flushF  = flush_except;
	assign flushD  = flush_except;
	assign flushM  = flush_except;
	assign flushW  = flush_except;

	//assign forwardhE = ((alucontrolE == `MFHI_CONTROL || alucontrolE == `MFLO_CONTROL) && hilowriteM == 1'b1)? 1'b1:1'b0;

	//assign forwardcp0E = ((rdE != 0) && rdE == writecp0M && cp0writeM) ?1'b1: 1'b0;

	always @(*) 
	begin
        if(excepttypeM != 32'b0) 
        begin
            case (excepttypeM)
                32'h00000001:begin 
                    newpcM <= 32'hBFC00380;
                end
                32'h00000004:begin 
                    newpcM <= 32'hBFC00380;
                end
                32'h00000005:begin 
                    newpcM <= 32'hBFC00380;
                end
                32'h00000008:begin 
                    newpcM <= 32'hBFC00380;
                end
                32'h00000009:begin 
                    newpcM <= 32'hBFC00380;
                end
                32'h0000000a:begin 
                    newpcM <= 32'hBFC00380;
                end
                32'h0000000c:begin 
                    newpcM <= 32'hBFC00380;
                end
                32'h0000000e:begin 
                    newpcM <= cp0_epcM;
                end
                default : ;
            endcase
        end
    end

	
endmodule
