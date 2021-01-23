`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/06 21:30:32
// Design Name: 
// Module Name: maindec
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

 module maindec(opcode,funct,rs,rt,
 				memtoreg,memwrite,branch,alusrc,
 				regdst,regwrite,jump,
 				jal,jr,bal,memen,hilowrite,cp0write,aluop);
	input wire [5:0] opcode;
	input wire [5:0] funct;
	// add the rs as the input parameter
	input wire [4:0] rs;
	input wire [4:0] rt; 
	output 	   [0:0] memtoreg;
	output     [0:0] memwrite;
	output     [0:0] branch;
	output     [0:0] alusrc;
	output     [0:0] regdst;
	output     [0:0] regwrite;
	output     [0:0] jump;
	// add three signals 
	output	   [0:0] jal;
	output     [0:0] jr;
	output	   [0:0] bal;
	// add a mem enable signal
	output	   [0:0] memen;
	// add a hilo register write signal
	output	   [0:0] hilowrite;
	// add a cp0 write signal
	output	   [0:0] cp0write;
 	output     [3:0] aluop; // change the bit from 2 to 4

 	
	// signs : memtoreg + memwrite + branch + alusrc  	4
	//			        + regdst + regwrite + jump   	3
	//					+ jal + jr + bal 				3
	//					+ memen 						1
	//					+ hilowrite						1
	//					+ cp0write						1
	reg [16:0] control_signs; // change the bit from 16 to 17
	assign {memtoreg,memwrite,branch,alusrc,
			regdst,regwrite,jump,
			jal,jr,bal,
			memen,hilowrite,
			cp0write,aluop} = control_signs;

	always @(*) 
	begin
		case(opcode) // change the control_signs assignment type from '<=' to '<<='
			// logic inst
			`EXE_ANDI:  	begin control_signs <= 17'b0001_010_000_0_0_0_0000; end  // andi
			`EXE_XORI:  	begin control_signs <= 17'b0001_010_000_0_0_0_0001; end  // xori
			`EXE_LUI:		begin control_signs <= 17'b0001_010_000_0_0_0_0011; end  // lui
			`EXE_ORI:		begin control_signs <= 17'b0001_010_000_0_0_0_0010; end  // ori
			// arithmetic inst
			`EXE_ADDI: 		begin control_signs <= 17'b0001_010_000_0_0_0_0100; end  // addi
			`EXE_ADDIU: 	begin control_signs <= 17'b0001_010_000_0_0_0_0101; end  // addiu
			`EXE_SLTI:		begin control_signs <= 17'b0001_010_000_0_0_0_0110; end  // slti
			`EXE_SLTIU:		begin control_signs <= 17'b0001_010_000_0_0_0_0111; end  // sltiu
			// branch jump inst
			`EXE_J: 		begin control_signs <= 17'b0000_001_000_0_0_0_0100; end  // j
			`EXE_JAL:		begin control_signs <= 17'b0000_010_100_0_0_0_0100; end  // jal
			`EXE_BEQ: 		begin control_signs <= 17'b0010_000_000_0_0_0_0000; end  // beq
			`EXE_BGTZ:		begin control_signs <= 17'b0010_000_000_0_0_0_0000; end  // bgtz
			`EXE_BLEZ:  	begin control_signs <= 17'b0010_000_000_0_0_0_0000; end  // blez
			`EXE_BNE:		begin control_signs <= 17'b0010_000_000_0_0_0_0000; end  // bne
			// memory access inst
			`EXE_LB:		begin control_signs <= 17'b1001_010_000_1_0_0_0100; end  // Lb
			`EXE_LBU:		begin control_signs <= 17'b1001_010_000_1_0_0_0100; end  // lbu
			`EXE_LH:		begin control_signs <= 17'b1001_010_000_1_0_0_0100; end  // lh
			`EXE_LHU:		begin control_signs <= 17'b1001_010_000_1_0_0_0100; end  // lhu
			`EXE_LW: 		begin control_signs <= 17'b1001_010_000_1_0_0_0100; end  // lw
			`EXE_SB:		begin control_signs <= 17'b0101_000_000_1_0_0_0100; end  // sb
			`EXE_SH:		begin control_signs <= 17'b0101_000_000_1_0_0_0100; end  // sh
			`EXE_SW: 		begin control_signs <= 17'b0101_000_000_1_0_0_0100; end  // sw
			
			 
			// special inst
			
			`R_TYPE: 	begin case(funct)
							// jump inst
							`EXE_JR:   		begin control_signs <= 17'b0000_001_010_0_0_0_0100; end  // jr
							`EXE_JALR: 		begin control_signs <= 17'b0000_110_010_0_0_0_0100; end  // jalr
							// move inst		
							`EXE_MTHI: 		begin control_signs <= 17'b0000_110_000_0_1_0_1000; end  // mthi
							`EXE_MTLO: 		begin control_signs <= 17'b0000_110_000_0_1_0_1000; end  // mtlo
							// arithmetic inst
							`EXE_MULT:  	begin control_signs <= 17'b0000_110_000_0_1_0_1000; end  // mult
							`EXE_MULTU: 	begin control_signs <= 17'b0000_110_000_0_1_0_1000; end  // multu
							`EXE_DIV:  		begin control_signs <= 17'b0000_110_000_0_1_0_1000; end  // div
							`EXE_DIVU:		begin control_signs <= 17'b0000_110_000_0_1_0_1000; end  // divu
							// self trap inst	
							`EXE_BREAK:  	begin control_signs <= 17'b0000_001_000_0_0_0_0100; end  // break
							`EXE_SYSCALL:	begin control_signs <= 17'b0000_001_000_0_0_0_0100; end  // syscall
							default:    	begin control_signs <= 17'b0000_110_000_0_0_0_1000; end  // R-type
							endcase end
			`EXE_REGIMM_INST: begin case(rt)
							`EXE_BGEZ: 	 begin control_signs <= 17'b0010_000_000_0_0_0_0000; end // bgez
							`EXE_BGEZAL: begin control_signs <= 17'b0010_010_001_0_0_0_0000; end // bgezal
							`EXE_BLTZ:	 begin control_signs <= 17'b0010_000_000_0_0_0_0000; end // bltz
							`EXE_BLTZAL: begin control_signs <= 17'b0010_010_001_0_0_0_0000; end // bltzal
							endcase end
			`EXE_SPECIAL:	begin case(rs)
							`EXE_MTC0:	begin control_signs <= 17'b0000_000_000_0_0_1_1010; end // mtc0
							`EXE_MFC0:	begin control_signs <= 17'b0000_010_000_0_0_0_1001; end // mfc0
							endcase case(funct)
							`EXE_ERET:	begin control_signs <= 17'b0000_000_000_0_0_0_0000; end // eret
							endcase end
			default:    begin control_signs <= 17'b0000_000_000_0_0_0_0000; end
		endcase // opcode
	end
endmodule


