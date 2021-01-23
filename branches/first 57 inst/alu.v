`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/06 21:27:46
// Design Name: 
// Module Name: alu
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

module alu(clk,rst,num1,num2,alucontrol,sa,hi_i,lo_i,hi_o,lo_o,result,overflow,stall_div,cp0Data2E);
    input wire clk;
    input wire rst;
    input wire [31:0] num1;
    input wire [31:0] num2;
    input wire [4:0]  alucontrol; // change the bit from 3 to 5
    input wire [4:0]  sa;
    input wire [31:0] hi_i;
    input wire [31:0] lo_i;
    output wire [31:0] hi_o;
    output wire [31:0] lo_o;
    output reg [31:0] result;
    output wire overflow;
    output wire stall_div;//
    input wire [31:0] cp0Data2E;//

    wire sltflag;
    wire [31:0] mult_a;
    wire [31:0] mult_b;
    wire [63:0] hilo_temp; //save mult result
    wire [63:0] div_result; //save div result
    wire div_signed; // unsigned or signed 
    wire div_start; // whether to start div
    //wire div_annul; // whether to finish div 
    wire div_ready; // whether is div finished     0 represents not finished
    // output zero;
    
    // wire [31:0] temp_slt;
    // assign temp_slt = (num1 < num2) ? 32'h1 : 32'h0;

    // assign result   = (op == 3'b000) ? num1 & num2 :
    //                   (op == 3'b001) ? num1 | num2 :
    //                   (op == 3'b010) ? num1 + num2 :
    //                   //(op == 3'b011) ?  not used !
    //                   (op == 3'b100) ? num1 & (~ num2) : 
    //                   (op == 3'b101) ? num1 | (~ num2) :
    //                   (op == 3'b110) ? num1 - num2 :
    //                   (op == 3'b111) ? temp_slt :
    //                   32'h0;

    always @(*)
    begin
      case(alucontrol)
          //logic inst
          `AND_CONTROL : result = num1 & num2;
          `OR_CONTROL  : result = num1 | num2;
          `XOR_CONTROL : result = num1 ^ num2;
          `NOR_CONTROL : result = ~(num1 | num2);
          `LUI_CONTROL : result = {num2[15:0],num2[31:16]};
          //shift inst
          `SLL_CONTROL : result = num2 << sa;
          `SRL_CONTROL : result = num2 >> sa;
          `SRA_CONTROL : result = ({32{num2[31]}} << (6'd32-{1'b0,sa})) | (num2 >> sa);
          `SLLV_CONTROL : result = num2 << num1[4:0];
          `SRLV_CONTROL : result = num2 >> num1[4:0];
          `SRAV_CONTROL : result = ({32{num2[31]}} << (6'd32-{1'b0,num1[4:0]})) | (num2 >> num1[4:0]);
          //data move inst
          `MFHI_CONTROL : result = hi_i; //translate hi to rd    mfhi rd
          `MFLO_CONTROL : result = lo_i; //translate lo to rd    mflo rd
          //`MTHI_CONTROL : hi_o = num1; // translate rs to hi     mthi rs
          //`MTLO_CONTROL : lo_o = num1; // translate rs to lo     mtlo rs
          //arithmetic inst
          `ADD_CONTROL : result = num1 + num2; //include add addi
          `ADDU_CONTROL : result = num1 + num2; //include add addiu
          `SUB_CONTROL : result = num1 - num2; 
          `SUBU_CONTROL : result = num1 - num2;
          `SLT_CONTROL : result = sltflag; //include slt slti
          `SLTU_CONTROL : result = (num1 < num2) ? 32'h1 : 32'h0; //include sltu sltiu
          //privileged inst
          `MTC0_CONTROL : result = num2;
          `MFC0_CONTROL : result = cp0Data2E;
          default : result = 32'h0;
      endcase // alucontrol
    end

    assign sltflag = ((alucontrol==`SLT_CONTROL) &&
    (((num1[31]==1)&&(num2[31]==0)) || ((num1[31]==1)&&(num2[31]==1)&&(num1>num2)) ||
    ((num1[31]==0)&&(num2[31]==0)&&(num1<num2)))) ?32'h1 : 32'h0;

    assign overflow = (alucontrol == `ADD_CONTROL || alucontrol == `SUB_CONTROL) && ((num1[31] & num2[31] & ~result[31]) || (~num1[31] & ~num2[31] & result[31]))? 1'b1:1'b0;

    //mult
    assign mult_a = ((alucontrol == `MULT_CONTROL) && (num1[31] == 1'b1)) ? (~num1 + 1) : num1;
    assign mult_b = ((alucontrol == `MULT_CONTROL) && (num2[31] == 1'b1)) ? (~num2 + 1) : num2;

    assign hilo_temp  = ((alucontrol == `MULT_CONTROL) && (num1[31] ^ num2[31] == 1'b1)) ? (~(mult_a * mult_b) + 1) : mult_a * mult_b;

    assign hi_o = (alucontrol == `MULT_CONTROL || alucontrol == `MULTU_CONTROL) ? hilo_temp[63:32]:
                (alucontrol == `DIV_CONTROL || alucontrol == `DIVU_CONTROL) ? div_result[63:32]:
                (alucontrol == `MTHI_CONTROL) ? num1 : 32'h00000000;
    assign lo_o = (alucontrol == `MULT_CONTROL || alucontrol == `MULTU_CONTROL) ? hilo_temp[31:0]:
                (alucontrol == `DIV_CONTROL || alucontrol == `DIVU_CONTROL) ? div_result[31:0]:
                (alucontrol == `MTLO_CONTROL) ? num1 : 32'h00000000;
    // assign zero = (result == 32'h0);

    //div
    assign div_signed = (alucontrol == `DIV_CONTROL)? 1'b1 : 1'b0;
    //assign div_signed = 1'b1;
    assign div_start = ((alucontrol == `DIV_CONTROL || alucontrol == `DIVU_CONTROL) & (~div_ready)) ? 1'b1 : 1'b0; 
    assign stall_div = ((alucontrol == `DIV_CONTROL || alucontrol == `DIVU_CONTROL) & (~div_ready)) ? 1'b1 : 1'b0; 
    div di(clk,rst,div_signed,num1,num2,div_start,1'b0,div_result,div_ready);

endmodule







