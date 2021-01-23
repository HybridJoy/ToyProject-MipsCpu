`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/11/13 20:42:59
// Design Name: 
// Module Name: signext
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


module signext(data_in,type,data_out); // change the input parameter(add the type)
	input  wire [15:0] data_in;
	output wire [1:0]  type;
	output wire [31:0] data_out;

	assign data_out = (type == 2'b11) ? {{16{1'b0}},data_in} :
					   					{{16{data_in[15]}},data_in};
endmodule
