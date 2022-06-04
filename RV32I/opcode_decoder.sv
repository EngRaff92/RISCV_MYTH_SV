// --------------------------------------------------------
// RISC-V: Instruction Decode
//
// Designing the instruction decode unit for RISC-V core
// capable of decoding all the six types of instructions:
//    - R Type
//    - I Type
//    - S Type
//    - B Type
//    - U Type
//    - J Type
//
// The decode should be able to decode and return needed
// information about the instruction in the same cycle
// --------------------------------------------------------
module opcode_decoder (
  input   wire [31:0]  instr_i,
  output  wire [4:0]   rs1_o,
  output  wire [4:0]   rs2_o,
  output  wire [4:0]   rd_o,
  output  wire [6:0]   op_o,
  output  wire [2:0]   funct3_o,
  output  wire [6:0]   funct7_o,
  output  wire         r_type_instr_o,
  output  wire         i_type_instr_o,
  output  wire         s_type_instr_o,
  output  wire         b_type_instr_o,
  output  wire         u_type_instr_o,
  output  wire         j_type_instr_o,
  output  wire         illegal_instr_o,
  output  wire [19:0]  instr_imm_o
);
  logic[11:0]  i_type_imm;      // Immediate for I-type instr
  logic[19:0]  j_type_imm;      // Immediate for J-type instr
  logic        r_type;          // Current instr is R-type
  logic        i_type;          // Current instr is I-type
  logic        s_type;          // Current instr is S-type
  logic        b_type;          // Current instr is B-type
  logic        u_type;          // Current instr is U-type
  logic        j_type;          // Current instr is J-type
  logic        illegal_instr;   // Current instr is illegal
  // Add more signals here:
  logic [11:0] s_type_imm;		// Immediate for S-type instr
  logic [11:0] b_type_imm;		// Immediate for B-type inst
  logic [19:0] u_type_imm;		// Immediate for U-type inst
  logic [6:0]  i_op;

  // --------------------------------------------------------
  // Decoding Registers
  // This information can be obtained from page 16 of the
  // RISC-V Specifications. Refer to Figure 2.3 which details
  // the information on how the six types of instructions are
  // encoded.
  // --------------------------------------------------------
  assign rd_o = instr_i[11:7];
  // Similarly for other needed registers and sideband signals
  assign rs1_o = instr_i[19:15];
  assign rs2_o = instr_i[24:20];

  // --------------------------------------------------------
  // Decoding Instruction Immediates
  // This information can be obtained from page 16 of the
  // RISC-V Specifications. Refer to Figure 2.3 which details
  // the information on how the six types of instructions are
  // encoded. Be careful as the immediate values are slightly
  // different for each type.
  // Here is an example of the immediate value for I-type &
  // J-type instructions.
  // --------------------------------------------------------
  assign i_type_imm = instr_i[31:20];
  assign j_type_imm = {instr_i[31], instr_i[19:12],
                       instr_i[20], instr_i[30:21]};
  // Similarly decode the imm values for other types
  assign s_type_imm = {instr_i[31:25],instr_i[11:7]};
  assign b_type_imm = {instr_i[31],instr_i[7],
                       instr_i[30:25],instr_i[11:8]};
  assign u_type_imm = instr_i[31:12];
  
  // Once all the imm signals are ready, we can assign the
  // output using a mux. Keep in mind that the imm should
  // be '0 for an R-type instruction since it doesn't have
  // any immediate operand.
  
  assign instr_imm_o =  r_type ? 20'h0              :
                        i_type ? {8'h0, i_type_imm} :
                        j_type ?        j_type_imm  :
                        // Add remaining types here
                        u_type ? u_type_imm		   :
    		  		          b_type ? {8'h0, b_type_imm} :
    				            s_type ? {8'h0, s_type_imm} :
    			              20'h0;

  // --------------------------------------------------------
  // Decoding Instruction Types
  // The instruction type can be inferred using the `op` field
  // decoded earlier. The `op` field can help us distiguish
  // each of the six instruction types. To obtain the values
  // of the `op` field for each instruction type, we would
  // use the information given in Chapter 24 of the RISC-V
  // spec. Refer to the table titled RV32I Base Instruction
  // Set at page 130 of the specifications.
  // Using information from the table you can decode the `op`
  // field for each type. Here is an example for R and I type
  // --------------------------------------------------------
  assign i_op = instr_i[6:0];
  always_comb begin
    r_type = 1'b0;
    i_type = 1'b0;
    s_type = 1'b0;
    b_type = 1'b0;
    u_type = 1'b0;
    j_type = 1'b0;
    illegal_instr = 1'b0;
    case (i_op)
      7'b000_0011:  i_type = 1'b1;
      7'b001_0011:  i_type = 1'b1;
      7'b110_0111:  i_type = 1'b1;
	    7'b011_0011:  r_type = 1'b1;
      7'b010_0011:  s_type = 1'b1;
      7'b110_0011:  b_type = 1'b1;
      7'b110_1111:  j_type = 1'b1;
      7'b011_0111:  u_type = 1'b1;
	    7'b001_0111:  u_type = 1'b1;
      // Complete the case statement for other instr types
      default:      illegal_instr = 1'b1;
    endcase
  end

  // -------------------------------------------------------
  // Assign output ports
  // --------------------------------------------------------
  assign r_type_instr_o   = r_type;
  assign i_type_instr_o   = i_type;
  assign s_type_instr_o   = s_type;
  assign b_type_instr_o   = b_type;
  assign u_type_instr_o   = u_type;
  assign j_type_instr_o   = j_type;
  assign illegal_instr_o  = illegal_instr;
  assign op_o			        = i_op;
  assign funct3_o		      = instr_i[14:12];
  assign funct7_o         = instr_i[31:25];
endmodule