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


module hazard(
		//fetch stage
		output wire stallF,
		//decode stage
		input wire[4:0] rsD,rtD,
		input wire branchD,
		output wire forwardaD,forwardbD,
		output wire stallD,
		//execute stage
		input wire[4:0] rsE,rtE,
		input wire[4:0] writeregE,
		input wire regwriteE,
		input wire memtoregE,
		output wire [1:0]forwardaE,forwardbE,
		output wire flushE,
		//mem stage
		input wire[4:0] writeregM,
		input wire regwriteM,
		input wire memtoregM,
		//write back stage
		input wire[4:0] writeregW,
		input wire regwriteW
		);
		wire lwstall;
		wire branchstall;
		
		assign forwardaE = ((rsE!=0)&(rsE==writeregM)&(regwriteM))? 2'b10:((rsE!=0)&(rsE==writeregW)&(regwriteW))? 2'b01:2'b00;
        assign forwardbE = ((rtE!=0)&(rtE==writeregM)&(regwriteM))? 2'b10:((rtE!=0)&(rtE==writeregW)&(regwriteW))? 2'b01:2'b00;
           
        assign forwardaD = (rsD!=0)&(rsD==writeregM)&(regwriteM);
        assign forwardbD = (rtD!=0)&(rtD==writeregM)&(regwriteM);
        
        assign lwstall = ((rsD==rtE)|(rtD==rtE))&memtoregE;
        assign branchstall = (branchD&regwriteE&(writeregE==rsD|writeregE==rtD))|(branchD&memtoregM&(writeregM==rsD|writeregM==rtD));
           
        assign stallF = (lwstall|branchstall);
        assign stallD = (lwstall|branchstall);
        assign flushE = (lwstall|branchstall);

endmodule
