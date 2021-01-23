`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/06 22:20:34
// Design Name: 
// Module Name: top
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


module top(
	input wire clk,rst,
	output wire[31:0] writedata,dataadr,
	output wire memen, // add the mem enable signal
	output wire[3:0] memwrite,
	output wire [39:0] ascii
    );

	wire[31:0] pc,instr,readdata;

	mips mips(clk,rst,pc,instr,memwrite,memen,dataadr,writedata,readdata); // add the mem enable signal

	// inst_mem imem(~clk,pc[8:2],instr);
	// data_mem dmem(~clk,memwrite,dataadr,writedata,readdata);
	// assign memen = 1'b1;
	inst_mem imem(.clka(~clk),.addra(pc[9:2]),.douta(instr));
	data_mem dmem(.clka(clk),.ena(memen),.wea(memwrite),.addra(dataadr),.dina(writedata),.douta(readdata));
	instdec instd(.instr(instr),.ascii(ascii));
endmodule

