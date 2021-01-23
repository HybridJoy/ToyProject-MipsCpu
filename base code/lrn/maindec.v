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


module maindec(
    input wire [5:0] op,
    output memtoreg,
    output memwrite,
    output branch,alusrc,
    output regdst,regwrite,
    output jump,
    output [1:0] aluop
    );
    reg [8:0] control;
    assign {regwrite,regdst,alusrc,branch,memwrite,memtoreg,jump,aluop}=control;
    always @ (*)
    case(op)
    6'b000000: control <= 9'b110000010; //RTYPE
    6'b100011: control <= 9'b101001000; //LW
    6'b101011: control <= 9'b001010000; //SW
    6'b000100: control <= 9'b000100001; //BEQ
    6'b001000: control <= 9'b101000000; //ADDI
    6'b000010: control <= 9'b000000100; //J
    default:control<=9'b000000000;
    endcase
endmodule