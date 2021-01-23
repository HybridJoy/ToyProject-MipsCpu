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
    input wire  [31:0] num1;
    input wire  [31:0] num2;
    input wire  [4:0]  alucontrol; // change the bit from 3 to 5
    input wire  [4:0]  sa;
    input wire  [31:0] hi_i;
    input wire  [31:0] lo_i;
    output wire [31:0] hi_o;
    output wire [31:0] lo_o;
    output reg  [31:0] result;
    output reg  [0:0]  overflow; // change the wire type to reg type
    output wire [0:0]  stall_div;//
    input wire  [31:0] cp0Data2E;//

    wire sltflag;
    wire [31:0] mult_a;
    wire [31:0] mult_b;
    wire [63:0] hilo_temp; //save mult result
    wire [63:0] div_result; //save div result
    wire [0:0]  div_signed; // unsigned or signed 
    wire [0:0]  div_start; // whether to start div
    //wire div_annul; // whether to finish div 
    wire [0:0]  div_ready; // whether is div finished     0 represents not finished
    // output zero;
    
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
          `ADD_CONTROL :  result = num1 + num2; //include add addi
          `ADDU_CONTROL : result = num1 + num2; //include add addiu
          `SUB_CONTROL :  result = num1 + (~ num2 + 32'b1); 
          `SUBU_CONTROL : result = num1 + (~ num2 + 32'b1);
          `SLT_CONTROL :  result = sltflag; //include slt slti
          `SLTU_CONTROL : result = (num1 < num2) ? 32'h1 : 32'h0; //include sltu sltiu
          //privileged inst
          `MTC0_CONTROL : result = num2;
          `MFC0_CONTROL : result = cp0Data2E;
          // max inst(new add)
          `MAX_CONTROL: result = ($signed(num1) < $signed(num2)) ? num2 : num1;
          default : result = 32'h0;
      endcase // alucontrol
    end

    // assign zero = (result == 32'h0);

    assign sltflag = ((alucontrol==`SLT_CONTROL) &&
    (((num1[31]==1)&&(num2[31]==0)) || ((num1[31]==1)&&(num2[31]==1)&&(num1 < num2)) || // change there
    ((num1[31]==0)&&(num2[31]==0)&&(num1<num2)))) ?32'h1 : 32'h0;

    // assign overflow = (alucontrol == `ADD_CONTROL || alucontrol == `SUB_CONTROL) && ((num1[31] & num2[31] & ~result[31]) || (~num1[31] & ~num2[31] & result[31]))? 1'b1:1'b0;
    // assign overflow = 0;

    always @ (*)
    begin
        case(alucontrol)
          `ADD_CONTROL: begin 
                  if((num1[31] == 1'b0) && (num2[31] == 1'b0) && (result[31] == 1'b1))
                  begin overflow <= 1'b1; end
                  else if((num1[31] == 1'b1) && (num2[31] == 1'b1) && (result[31] == 1'b0))
                  begin overflow <= 1'b1; end
                  else begin overflow <= 1'b0; end end
          `SUB_CONTROL: begin
                  if((num1[31] == 1'b0) && (num2[31] == 1'b1) && (result[31] == 1'b1))
                  begin overflow <= 1'b1; end
                  else if((num1[31] == 1'b1) && (num2[31] == 1'b0) && (result[31] == 1'b0))
                  begin overflow <= 1'b1; end
                  else begin overflow <= 1'b0; end end
          default: begin overflow <= 1'b0; end
        endcase
    end

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
   

    //div
    assign div_signed = (alucontrol == `DIV_CONTROL)? 1'b1 : 1'b0;
   
    assign div_start = ((alucontrol == `DIV_CONTROL || alucontrol == `DIVU_CONTROL) & (~div_ready)) ? 1'b1 : 1'b0; 
    assign stall_div = ((alucontrol == `DIV_CONTROL || alucontrol == `DIVU_CONTROL) & (~div_ready)) ? 1'b1 : 1'b0; 
    
    wire [31:0] diva,divb;
    // assign diva = (stall_div == 1'b0) ? num1 : diva;
    // assign divb = (stall_div == 1'b0) ? num2 : divb; 
    assign diva = num1;
    assign divb = num2;
    
    div di(clk,rst,div_signed,diva,divb,div_start,1'b0,div_result,div_ready);

endmodule







