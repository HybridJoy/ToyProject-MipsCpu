`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/11/13 20:25:20
// Design Name: 
// Module Name: mux2
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


module mux2 #(parameter N = 32)(data1,data2,select,data_o);
	input wire [N-1:0] data1;
	input wire [N-1:0] data2;
	input wire         select;
	output reg [N-1:0] data_o;

	always @(*)
	begin
		case (select)
			0 : data_o = data1;
			1 : data_o = data2;
		endcase // select
	end

endmodule
