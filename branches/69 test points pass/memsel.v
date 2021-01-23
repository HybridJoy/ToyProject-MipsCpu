`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/12 17:20:52
// Design Name: 
// Module Name: memsel
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

module memsel(opcode,dataaddr,writedata_dp,readdata_mem,
			  select,writedata,readdata,adel,ades);
	input wire [5:0]  opcode;
	input wire [31:0] dataaddr;
	input wire [31:0] writedata_dp;
	input wire [31:0] readdata_mem;
	output     [3:0]  select;
	output     [31:0] writedata;
	output     [31:0] readdata;
	output	   [0:0]  adel;
	output     [0:0]  ades;


	reg [3:0]  select;
	reg [31:0] writedata,readdata;
	reg [0:0]  adel,ades;

	always @ (*)
	begin
		case(opcode)
			`EXE_LB:  select <= 4'b0000;
			`EXE_LBU: select <= 4'b0000;
			`EXE_LH:  select <= 4'b0000;
			`EXE_LHU: select <= 4'b0000;
			`EXE_LW:  select <= 4'b0000;
			`EXE_SB:  begin case(dataaddr[1:0])
								2'b00: select <= 4'b0001;
								2'b01: select <= 4'b0010;
								2'b10: select <= 4'b0100;
								2'b11: select <= 4'b1000;
					  endcase end
			`EXE_SH:  begin case(dataaddr[1:0])
								2'b00: select <= 4'b0011;
								2'b10: select <= 4'b1100;
					  endcase end
			`EXE_SW:  select <= 4'b1111;
			default:  select <= 4'b0000;
		endcase
	end

	always @ (*) 
	begin
		case (opcode)
			`EXE_LB:  begin case(dataaddr[1:0])
								2'b00: readdata <= {{24{readdata_mem[7]}},readdata_mem[7:0]};
								2'b01: readdata <= {{24{readdata_mem[15]}},readdata_mem[15:8]};
								2'b10: readdata <= {{24{readdata_mem[23]}},readdata_mem[23:16]};
								2'b11: readdata <= {{24{readdata_mem[31]}},readdata_mem[31:24]};
					  endcase end
			`EXE_LBU: begin case(dataaddr[1:0])
								2'b00: readdata <= {{24{1'b0}},readdata_mem[7:0]};
								2'b01: readdata <= {{24{1'b0}},readdata_mem[15:8]};
								2'b10: readdata <= {{24{1'b0}},readdata_mem[23:16]};
								2'b11: readdata <= {{24{1'b0}},readdata_mem[31:24]};
					  endcase end
			`EXE_LH:  begin case(dataaddr[1:0])
								2'b00: readdata <= {{16{readdata_mem[15]}},readdata_mem[15:0]};
								2'b10: readdata <= {{16{readdata_mem[31]}},readdata_mem[31:16]};
					  endcase end
			`EXE_LHU: begin case(dataaddr[1:0])
								2'b00: readdata <= {{16{1'b0}},readdata_mem[15:0]};
								2'b10: readdata <= {{16{1'b0}},readdata_mem[31:16]};
					  endcase end
			`EXE_LW:  begin readdata  <= readdata_mem; end
			`EXE_SW:  begin writedata <= writedata_dp; end
			`EXE_SB:  begin case(dataaddr[1:0])
								2'b00: writedata <= {{24{writedata_dp[7]}},writedata_dp[7:0]};
								2'b01: writedata <= {{16{writedata_dp[7]}},writedata_dp[7:0],{8{1'b0}}};
								2'b10: writedata <= {{8{writedata_dp[7]}},writedata_dp[7:0],{16{1'b0}}};
								2'b11: writedata <= {writedata_dp[7:0],{24{1'b0}}};
					  endcase end
			`EXE_SH:  begin case(dataaddr[1:0])
								2'b00: writedata <= {{16{writedata_dp[15]}},writedata_dp[15:0]};
								2'b10: writedata <= {writedata_dp[15:0],{16{1'b0}}};
					  endcase end
			default:  begin readdata <= 32'h00000000; writedata <= 32'h00000000; end
		endcase
	end

	always @ (*)
	begin
		case(opcode)
			`EXE_LB,
			`EXE_LBU: begin adel <= 1'b0; end
			`EXE_LH,
			`EXE_LHU: begin if((dataaddr[1:0] == 2'b01) || (dataaddr[1:0] == 2'b11))
					  begin
					  		adel <= 1'b1;
					  end else begin
					  		adel <= 1'b0;
					  end end
			`EXE_LW:  begin if(dataaddr[1:0] == 2'b00)
					  begin
					  		adel <= 1'b0;
					  end else begin 
					  		adel <= 1'b1;
					  end end
			`EXE_SB:  begin ades <= 1'b0; end
			`EXE_SH:  begin if((dataaddr[1:0] == 2'b01) || (dataaddr[1:0] == 2'b11))
					  begin
					  		ades <= 1'b1;
					  end else begin
					  		ades <= 1'b0;
					  end end
			`EXE_SW:  begin if(dataaddr[1:0] == 2'b00)
					  begin
					  		ades <= 1'b0;
					  end else begin 
					  		ades <= 1'b1;
					  end end
			default:  begin adel <= 1'b0; ades <= 1'b0; end
		endcase
	end
	
endmodule
