/** This module by the given instruction will give you back the immediate value to be use. Is fully combo
 * 	there is no plan to register the output since it will only result in a performance degradation */

/** Include defines needed */
`include "rv32i_defines_params.sv"

/** Main Module */
module immediate_unit(
	input   logic32			instr_i,
`ifdef RV32I_DEBUG
    output  logic       	r_type_instr_o,
    output  logic       	i_type_instr_o,
    output  logic       	s_type_instr_o,
    output  logic       	b_type_instr_o,
    output  logic       	u_type_instr_o,
    output  logic       	j_type_instr_o,
    output  logic       	illegal_instr_o,
`endif    
	output  logic [19:0]	instr_imm_o
);
	
	/** Internla signals to decode what type of instruction we have*/
	logic        r_type;        // Current instr is R-type	
    logic        i_type;        // Current instr is I-type
    logic        s_type;        // Current instr is S-type
    logic        b_type;		// Current instr is B-type
    logic        u_type;        // Current instr is U-type
    logic        j_type;        // Current instr is J-type
    logic        illegal_instr;	// Current instr is illegal
    logic [11:0] s_type_imm;	// Immediate for S-type instr
    logic [11:0] b_type_imm;	// Immediate for B-type inst
    logic [19:0] u_type_imm;	// Immediate for U-type inst
    logic [11:0] i_type_imm;    // Immediate for I-type instr
    logic [19:0] j_type_imm;    // Immediate for J-type instr

    /* 	Decoding Instruction Immediates
    	This information can be obtained from page 16 of the RISC-V Specifications. Refer to Figure 2.3 which details
      	the information on how the six types of instructions are encoded. Be careful as the immediate values are slightly
      	different for each type.
    */
    assign i_type_imm = instr_i[31:20];
    assign j_type_imm = {instr_i[31], instr_i[19:12], instr_i[20], instr_i[30:21]};
    assign s_type_imm = {instr_i[31:25], instr_i[11:7]};
    assign b_type_imm = {instr_i[31], instr_i[7], instr_i[30:25],instr_i[11:8]};
    assign u_type_imm = instr_i[31:12];

    /** Decoding Instruction Types
      The instruction type can be inferred using the `op` field decoded earlier. The `op` field can help us distiguish
      each of the six instruction types. To obtain the values of the `op` field for each instruction type, we would
      use the information given in Chapter 24 of the RISC-V spec. Refer to the table titled RV32I Base Instruction
      Set at page 130 of the specifications. Using information from the table you can decode the `op` field for each type. 
    */
    always_comb begin: instruction_decoder
    	r_type 			= 1'b0;
      	i_type 			= 1'b0;
      	s_type 			= 1'b0;
      	b_type 			= 1'b0;
      	u_type 			= 1'b0;
    	j_type 			= 1'b0;
      	illegal_instr 	= 1'b0;
      	case (instr_i[`opcode])
        	`i_type:  i_type = 1'b1;
	        `i_type:  i_type = 1'b1;
	        `i_type:  i_type = 1'b1;
	  	    `r_type:  r_type = 1'b1;
	        `s_type:  s_type = 1'b1;
	        `b_type:  b_type = 1'b1;
	        `j_type:  j_type = 1'b1;
	        `u_type:  u_type = 1'b1;
	  	    `u_type:  u_type = 1'b1;
	        default:  illegal_instr = 1'b1;
     	endcase
    end

    /*
    	Once all the imm signals are ready, we can assign the output using a mux. Keep in mind that the immediate should
      	be '0 for an R-type instruction since it doesn't have any immediate operand. 
    */
    assign instr_imm_o = 	r_type ? 20'h0              :
                          	i_type ? {8'h0, i_type_imm} :
                          	j_type ?        j_type_imm  :
                          	// Add remaining types here
                          	u_type ? u_type_imm		   	:
      		  		    	b_type ? {8'h0, b_type_imm} :
      				        s_type ? {8'h0, s_type_imm} :
      			            20'h0;
endmodule // immediate_unit
