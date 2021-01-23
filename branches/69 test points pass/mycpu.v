`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/18 13:05:39
// Design Name: 
// Module Name: mycpu
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


module mycpu(clk,resetn,int,
			 // inst_sram
			 inst_sram_en,
			 inst_sram_wen,
			 inst_sram_addr,
			 inst_sram_wdata,
			 inst_sram_rdata,
			 // data_sram
			 data_sram_en,
			 data_sram_wen,
			 data_sram_addr,
			 data_sram_wdata,
			 data_sram_rdata,
			 // debug
			 debug_wb_pc,
			 debug_wb_rf_wen,
			 debug_wb_rf_wnum,
			 debug_wb_rf_wdata);

	input wire  [0:0]  clk;
	input wire  [0:0]  resetn;
	input wire  [5:0]  int;
	// inst_sram
	output wire [0:0]  inst_sram_en;
	output wire [3:0]  inst_sram_wen;
	output wire [31:0] inst_sram_addr;
	output wire [31:0] inst_sram_wdata;
	input  wire [31:0] inst_sram_rdata;
	// data_sram
	output wire [0:0]  data_sram_en;
	output wire [3:0]  data_sram_wen;
	output wire [31:0] data_sram_addr;
	output wire [31:0] data_sram_wdata;
	input  wire [31:0] data_sram_rdata;
	// debug
	output wire [31:0] debug_wb_pc;
	output wire [3:0]  debug_wb_rf_wen;
	output wire [4:0]  debug_wb_rf_wnum;
	output wire [31:0] debug_wb_rf_wdata;

	assign inst_sram_en    = 1'b1;
	assign inst_sram_wen   = 4'b0000;
	assign inst_sram_wdata = 32'h00000000;

	mips mips(.clk(clk),.rst(resetn),
			  .int_i(int),
			  // inst_sram
			  .pcF(inst_sram_addr),
			  .instrF(inst_sram_rdata),
			  // data_sram
			  .memenM(data_sram_en),
			  .memwrite(data_sram_wen),
			  .aluoutM(data_sram_addr),
			  .writedata(data_sram_wdata),
			  .readdata(data_sram_rdata),
			  // debug
			  .debug_pcW(debug_wb_pc),
			  .debug_rwW(debug_wb_rf_wen),
			  .debug_wnumW(debug_wb_rf_wnum),
			  .debug_resultW(debug_wb_rf_wdata)
			 );


endmodule
