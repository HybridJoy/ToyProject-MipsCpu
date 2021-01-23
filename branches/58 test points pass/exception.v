`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/17 14:57:39
// Design Name: 
// Module Name: exception
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


module exception(
	input wire rst,
	input wire[7:0] except,
	input wire adel,ades,
	input wire[31:0] cp0_status,cp0_cause,
	output reg[31:0] excepttype
    );

	always @(*) begin
		if(rst) begin
			excepttype <= 32'b0;
		end else begin 
			excepttype <= 32'b0;
			//interrupt
			if(((cp0_cause[15:8] & cp0_status[15:8]) != 8'h00) &&
				 	(cp0_status[1] == 1'b0) && (cp0_status[0] == 1'b1)) begin
				excepttype <= 32'h00000001;
		    // read data or fetch inst
			end else if(except[7] == 1'b1 || adel) begin
				excepttype <= 32'h00000004;
			//write data
			end else if(ades) begin
				excepttype <= 32'h00000005;
			//sys
			end else if(except[6] == 1'b1) begin
				excepttype <= 32'h00000008;
			//Bp
			end else if(except[5] == 1'b1) begin
				excepttype <= 32'h00000009;
			
			end else if(except[4] == 1'b1) begin
				excepttype <= 32'h0000000e;
			//RI
			end else if(except[3] == 1'b1) begin
				excepttype <= 32'h0000000a;
			//Ov
			end else if(except[2] == 1'b1) begin
				excepttype <= 32'h0000000c;
			end
		end
	
	end
	
endmodule

