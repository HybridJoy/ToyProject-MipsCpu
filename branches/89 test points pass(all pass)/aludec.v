`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/10/22 21:35:29
// Design Name: 
// Module Name: alu_decoder
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

module aludec(funct,aluop,alucontrol);
	input wire [5:0] funct;
	input wire [3:0] aluop; // change the bit from 2 to 4
	output reg [4:0] alucontrol; // change the bit from 3 to 5

	always @ (aluop or funct)
	begin
		case(aluop) // change the alucontrol assignment type from '=' to '<=' 
			// logic inst(imm)
			`ANDI_OP:   begin alucontrol <= `AND_CONTROL;  end // andi
			`XORI_OP:   begin alucontrol <= `XOR_CONTROL;  end // xori
			`ORI_OP:    begin alucontrol <= `OR_CONTROL;   end // ori
            `LUI_OP:    begin alucontrol <= `LUI_CONTROL;  end // lui
            // arithmetic inst(imm)
			`ADDI_OP:   begin alucontrol <= `ADD_CONTROL;  end // addi
			`ADDIU_OP:  begin alucontrol <= `ADDU_CONTROL; end // addiu
			`SLTI_OP:   begin alucontrol <= `SLT_CONTROL;  end // slti
			`SLTIU_OP:  begin alucontrol <= `SLTU_CONTROL; end // sltiu
			// special inst  // add the spceial inst about the cp0 operate
			`MTC0_OP:	begin alucontrol <= `MTC0_CONTROL; end // mtc0
			`MFC0_OP:	begin alucontrol <= `MFC0_CONTROL; end // mfc0

			// max inst (new add)
			`MAX_OP:	begin alucontrol <= `MAX_CONTROL;  end // max

	 		`R_TYPE_OP: begin case(funct)
						// logic inst
						`EXE_AND:   begin alucontrol <= `AND_CONTROL;   end // and
						`EXE_OR:    begin alucontrol <= `OR_CONTROL;    end // or
						`EXE_XOR:   begin alucontrol <= `XOR_CONTROL;   end // xor
						`EXE_NOR:   begin alucontrol <= `NOR_CONTROL;   end // nor
						// shift inst
						`EXE_SLL:   begin alucontrol <= `SLL_CONTROL;   end // sll
						`EXE_SLLV:  begin alucontrol <= `SLLV_CONTROL;  end // sllv
						`EXE_SRL:   begin alucontrol <= `SRL_CONTROL;   end // srl
						`EXE_SRLV:  begin alucontrol <= `SRLV_CONTROL;  end // srlv
						`EXE_SRA:   begin alucontrol <= `SRA_CONTROL;   end // sra
						`EXE_SRAV:  begin alucontrol <= `SRAV_CONTROL;  end // srav
						// move inst
						`EXE_MFHI:  begin alucontrol <= `MFHI_CONTROL;  end // mfhi
						`EXE_MTHI:  begin alucontrol <= `MTHI_CONTROL;  end // mthi
						`EXE_MFLO:  begin alucontrol <= `MFLO_CONTROL;  end // mflo
						`EXE_MTLO:  begin alucontrol <= `MTLO_CONTROL;  end // mtlo
						// arithmetic inst
						`EXE_SLT:   begin alucontrol <= `SLT_CONTROL;   end // slt
						`EXE_SLTU:  begin alucontrol <= `SLTU_CONTROL;  end // sltu
						`EXE_ADD:   begin alucontrol <= `ADD_CONTROL;   end // add
						`EXE_ADDU:  begin alucontrol <= `ADDU_CONTROL;  end // addu
						`EXE_SUB:   begin alucontrol <= `SUB_CONTROL;   end // sub
						`EXE_SUBU:  begin alucontrol <= `SUBU_CONTROL;  end // subu
						`EXE_MULT:  begin alucontrol <= `MULT_CONTROL;  end // mult
						`EXE_MULTU: begin alucontrol <= `MULTU_CONTROL; end // multu
						`EXE_DIV:	begin alucontrol <= `DIV_CONTROL;   end // div
						`EXE_DIVU:  begin alucontrol <= `DIVU_CONTROL;  end // divu	
						default:    begin alucontrol <= 5'b00000; 	   end
				   endcase end
			default: begin alucontrol <= 5'b00000; end
		endcase // aluop	
	end

	
endmodule
