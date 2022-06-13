/** */

/** DEFINES */
`define i_type 7'b000_0011
`define i_type 7'b001_0011
`define i_type 7'b110_0111
`define r_type 7'b011_0011
`define s_type 7'b010_0011
`define b_type 7'b110_0011
`define j_type 7'b110_1111
`define u_type 7'b011_0111
`define u_type 7'b001_0111

/** OPCODE bit number from 6 to 0 */
`define opcode 6:0
`define func3 14:12
`define func7 31:25

/** ALU operations based on TABLE below*/
/** TABLE for ALU operations format 
 *  operation	func7		func3
 	ADD  		0000000 	000		
	SUB  		0100000 	000	
	SLL  		0000000 	001	
	SLT  		0000000 	010		
	SLTU 		0000000 	011	
	XOR  		0000000 	100		
	SRL  		0000000 	101	
	SRA  		0100000 	101	
	OR 	 		0000000 	110
	AND  		0000000 	111
	the value below are computed appending the func7[5] to the top of the 
	opcode or simply by concatenating in case of Immediate support*/
// Simple Math operations
`define OP_ADD  10'b0000000000
`define OP_SUB  10'b0100000000
// SLT is Set Less Then (signed and Unsigned)
`define OP_SLT  10'b0000000010
`define OP_SLTU 10'b0000000011
// Logical operations
`define OP_XOR  10'b0000000100
`define OP_OR 	10'b0000000110
`define OP_AND  10'b0000000111
// SRL and SLL are Shift (right left) logical
`define OP_SRL  10'b0000000101
`define OP_SLL  10'b0000000001
// SRA is Shift Right Arithmetical
`define OP_SRA  10'b0100000101
// Operations not yet supported 
// `define OP_EQL   
// `define OP_ULT   
// `define OP_UGT   
// `define OP_SGT  

/** OPCODE definitions per instructions */
`define REG_OP 	7'b0110011
`define MEM_LOP 7'b0000011
`define MEM_SOP	7'b0100011
`define IMM_OP 	0
`define BRAN_OP 0
`define JMP_OP 	0

/** Sub opcode for Memory opoerations using FUNC3*/
`define SW 3'b010
`define LW 3'b010
/** Typdefs */
typedef logic [31:0] logic32;