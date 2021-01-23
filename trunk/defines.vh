/// global macro definition
`define RstEnable 			1'b1
`define RstDisable			1'b0
`define WriteEnable			1'b1
`define WriteDisable		1'b0
`define InterruptAssert 	1'b1
`define InterruptNotAssert 	1'b0
`define InDelaySlot 		1'b1
`define NotInDelaySlot 		1'b0
`define ZEROWORD			32'h00000000
`define ZeroWord			32'h00000000

//specific inst macro definition

`define R_TYPE  		6'b000000

// logic inst(9)
`define EXE_NOP			6'b000000
`define EXE_AND 		6'b100100
`define EXE_OR 			6'b100101
`define EXE_XOR 		6'b100110
`define EXE_NOR			6'b100111
`define EXE_ANDI		6'b001100
`define EXE_ORI			6'b001101
`define EXE_XORI		6'b001110
`define EXE_LUI			6'b001111

// shift inst(6)
`define EXE_SLL			6'b000000
`define EXE_SLLV		6'b000100
`define EXE_SRL 		6'b000010
`define EXE_SRLV 		6'b000110
`define EXE_SRA 		6'b000011
`define EXE_SRAV 		6'b000111

// move inst(4)
`define EXE_MFHI  		6'b010000
`define EXE_MTHI  		6'b010001
`define EXE_MFLO  		6'b010010
`define EXE_MTLO  		6'b010011

// arithmetic inst(14) 
`define EXE_SLT  		6'b101010
`define EXE_SLTU  		6'b101011
`define EXE_SLTI  		6'b001010
`define EXE_SLTIU  		6'b001011   
`define EXE_ADD  		6'b100000
`define EXE_ADDU  		6'b100001
`define EXE_SUB  		6'b100010
`define EXE_SUBU  		6'b100011
`define EXE_ADDI  		6'b001000
`define EXE_ADDIU  		6'b001001

`define EXE_MULT  		6'b011000
`define EXE_MULTU  		6'b011001
`define EXE_DIV  		6'b011010
`define EXE_DIVU  		6'b011011

// branch jump inst(12)
`define EXE_J  			6'b000010
`define EXE_JAL  		6'b000011
`define EXE_JALR  		6'b001001
`define EXE_JR  		6'b001000
`define EXE_BEQ  		6'b000100
`define EXE_BNE  		6'b000101
`define EXE_BGTZ  		6'b000111
`define EXE_BLEZ  		6'b000110

`define EXE_REGIMM_INST 6'b000001
`define EXE_BGEZ  		5'b00001
`define EXE_BGEZAL  	5'b10001
`define EXE_BLTZ  		5'b00000
`define EXE_BLTZAL  	5'b10000

// memory access inst(8)
`define EXE_LB  		6'b100000
`define EXE_LBU  		6'b100100
`define EXE_LH  		6'b100001
`define EXE_LHU  		6'b100101
`define EXE_LW  		6'b100011
`define EXE_SB  		6'b101000
`define EXE_SH  		6'b101001
`define EXE_SW  		6'b101011

// self trap inst(2)
`define EXE_SYSCALL 	6'b001100
`define EXE_BREAK 		6'b001101

// special inst(3)
`define EXE_SPECIAL		6'b010000
`define EXE_MTC0 		5'b00100
`define EXE_MFC0 		5'b00000	
`define EXE_ERET		6'b011000

// ALU OP()
`define R_TYPE_OP 		4'b1000

`define ANDI_OP 		4'b0000
`define XORI_OP 		4'b0001
`define ORI_OP  		4'b0010
`define LUI_OP  		4'b0011
`define ADDI_OP 		4'b0100
`define ADDIU_OP    	4'b0101
`define SLTI_OP     	4'b0110
`define SLTIU_OP    	4'b0111

`define MFC0_OP 		4'b1001
`define MTC0_OP 		4'b1010

// ALU CONTROL()
`define AND_CONTROL 	5'b00111
`define OR_CONTROL  	5'b00001
`define XOR_CONTROL 	5'b00010
`define NOR_CONTROL 	5'b00011
`define LUI_CONTROL 	5'b00100

`define SLL_CONTROL 	5'b01000
`define SRL_CONTROL 	5'b01001
`define SRA_CONTROL 	5'b01010
`define SLLV_CONTROL    5'b01011
`define SRLV_CONTROL    5'b01100
`define SRAV_CONTROL    5'b01101

`define ADD_CONTROL     5'b10000
`define ADDU_CONTROL    5'b10001
`define SUB_CONTROL     5'b10010
`define SUBU_CONTROL    5'b10011
`define SLT_CONTROL     5'b10100
`define SLTU_CONTROL    5'b10101

// `define MAX_CONTROL     5'b10110

`define MULT_CONTROL    5'b11000
`define MULTU_CONTROL   5'b11001
`define DIV_CONTROL     5'b11010
`define DIVU_CONTROL    5'b11011

`define MFHI_CONTROL  	5'b11100
`define MTHI_CONTROL  	5'b11101
`define MFLO_CONTROL  	5'b11110
`define MTLO_CONTROL  	5'b11111

`define MFC0_CONTROL 	5'b00101
`define MTC0_CONTROL 	5'b00110

//div

`define DivFree 			2'b00
`define DivByZero 			2'b01
`define DivOn 				2'b10
`define DivEnd 				2'b11
`define DivResultReady 		1'b1
`define DivResultNotReady 	1'b0
`define DivStart 			1'b1
`define DivStop 			1'b0


//regfiles macro definition
`define RegBus 				31:0

//CP0
`define CP0_REG_BADVADDR    5'b01000       
`define CP0_REG_COUNT    	5'b01001        
`define CP0_REG_COMPARE    	5'b01011      
`define CP0_REG_STATUS    	5'b01100       
`define CP0_REG_CAUSE    	5'b01101       
`define CP0_REG_EPC    		5'b01110          
`define CP0_REG_PRID    	5'b01111         
`define CP0_REG_CONFIG    	5'b10000 

