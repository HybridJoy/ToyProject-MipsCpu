`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/10/22 20:30:34
// Design Name: 
// Module Name: pc
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

// pc trigger
module pc (clk,reset,enable,pcnext,pc);
	input wire [0:0]  clk;
	input wire [0:0]  reset;
	input wire [0:0]  enable;
	input wire [31:0] pcnext;
	output reg [31:0] pc;

	always @ (posedge clk or posedge reset) 
	begin
		if(reset)
		begin
			pc <= 32'hbfc00000;
		end
		else if(enable)
		begin
			pc <= pcnext;
		end
	end
endmodule

// flopr : simple D trigger  
module flopr #(parameter WIDTH = 4)(clk,reset,dnext,dnow);
	input wire             clk;
	input wire             reset;
	input wire [WIDTH-1:0] dnext;
	output reg [WIDTH-1:0] dnow;

	always @ (posedge clk or posedge reset) 
	begin
		if(reset) 
		begin
			dnow <= 0;
		end 
		else 
		begin
			dnow <= dnext;
		end
	end

endmodule

// floprc : include the clear signal(Pipeline Clearance Signal) 
module floprc #(parameter WIDTH = 4)(clk,reset,clear,dnext,dnow);
	input wire             clk;
	input wire             reset;
	input wire			   clear;
	input wire [WIDTH-1:0] dnext;
	output reg [WIDTH-1:0] dnow;

	always @ (posedge clk or posedge reset) 
	begin
		if(reset) 
		begin
			dnow <= 0;
		end
		else if(clear)
		begin
			dnow <= 0;
		end 
		else 
		begin
			dnow <= dnext;
		end
	end

endmodule

//floenr : include enable signal
module flopenr #(parameter WIDTH = 4)(clk,reset,enable,dnext,dnow);
	input wire             clk;
	input wire             reset;
	input wire			   enable;
	input wire [WIDTH-1:0] dnext;
	output reg [WIDTH-1:0] dnow;

	always @ (posedge clk or posedge reset) 
	begin
		// if(enable)
		// begin
		// 	if(reset) 
		// 	begin
		// 		dnow <= 0;
		// 	end
		// 	else 
		// 	begin
		// 		dnow <= dnext;
		// 	end
		// end
		if(reset)
		begin
			dnow <= 0;
		end
		else if(enable)
		begin
			dnow <= dnext;
		end
	end

endmodule

//flopenrc : include enable and clear signal
module flopenrc #(parameter WIDTH = 4)(clk,reset,enable,clear,dnext,dnow);
	input wire             clk;
	input wire             reset;
	input wire			   enable;
	input wire			   clear;
	input wire [WIDTH-1:0] dnext;
	output reg [WIDTH-1:0] dnow;

	always @ (posedge clk or posedge reset) 
	begin
		// if(enable)
		// begin
		// 	if(reset) 
		// 	begin
		// 		dnow <= 0;
		// 	end
		// 	else if(clear)
		// 	begin
		// 		dnow <= 0;
		// 	end
		// 	else 
		// 	begin
		// 		dnow <= dnext;
		// 	end
		// end
		if(reset)
		begin
			dnow <= 0;
		end
		else if(clear)
		begin
			dnow <= 0;
		end
		else if(enable)
		begin
			dnow <= dnext;
		end
	end

endmodule


