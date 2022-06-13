/* RISC-V: Instruction Decode

  Designing the instruction decode unit for RISC-V core
  capable of decoding all the six types of instructions:
    - R Type
    - I Type
    - S Type
    - B Type
    - U Type
    - J Type
  The decode should be able to decode and return needed
  information about the instruction in the same cycle */

/** Main Module */
module opcode_decoder (
    input   logic [31:0]  instr_i,
    output  logic [4:0]   rs1_o,
    output  logic [4:0]   rs2_o,
    output  logic [4:0]   rd_o,
    output  logic [6:0]   op_o,
    output  logic [9:0]   alu_op_sel_0,
`ifdef RV32I_DEBUG   
    output  logic [2:0]   funct3_o,
    output  logic         r_type_d,
    output  logic         i_type_d,
    output  logic         s_type_d,
    output  logic         b_type_d,
    output  logic         u_type_d,
    output  logic         j_type_d,
    output  logic         illegal_d,
`endif    
    output  logic [19:0]  instr_imm_o,
    output  logic [9:0]   memory_address 
);
    
    /** Internal Signals */
    logic r_type;
    logic i_type;
    logic s_type;
    logic b_type;
    logic u_type;
    logic j_type;
    logic illegal;
    logic [19:0] immediate;

    /*  Decoding Registers
        This information can be obtained from page 16 of the RISC-V Specifications. Refer to Figure 2.3 which details
        the information on how the six types of instructions are encoded. Some highliths here:
        1. destination register is not decoded in S and B type instructions
        2. source_1 register is not decoded in U and J type instructions 
        2. source_2 register is not decoded in I, J and U type instructions
    */
    assign rd_o  = (s_type| b_type)             ? 0 : instr_i[11:7];
    assign rs1_o = (u_type | j_type)            ? 0 : instr_i[19:15];
    assign rs2_o = (i_type | j_type | u_type)   ? 0 : instr_i[24:20];

    /** Decoder Immediate unit with debug */
    immediate_unit u_immediate_unit(
      .instr_i        (instr_i), 
      .r_type_instr_o (r_type),
      .i_type_instr_o (i_type),
      .s_type_instr_o (s_type),
      .b_type_instr_o (b_type),
      .u_type_instr_o (u_type),
      .j_type_instr_o (j_type),
      .illegal_instr_o(illegal),
      .instr_imm_o    (immediate));

    /** Assign all other ports some highligths here:
     *  1. FUNC3 field is not decoded for J and U type instructions
     *  2. FUCN7 field is not decoded for R type instructions */
    assign op_o	        = instr_i[`opcode];    
    assign alu_op_sel_0 = (r_type | s_type) ? {instr_i[`func7], instr_i[`func3]} : 0;

    /** Generating Memory Address according to the LW and SW:
        The LW instruction loads a 32-bit value from memory into rd. LH loads a 16-bit value from memory, then sign-extends to 32-bits before storing in rd.
        LHU loads a 16-bit value from memory but then zero extends to 32-bits before storing in rd. LB and LBU are defined analogously for 8-bit values. 
        The SW, SH, and SB instructions store 32-bit, 16-bit, and 8-bit values from the low bits of register rs2 to memory. 
        Load and store instructions transfer a value between the registers and memory. Loads are encoded in the I-type format and stores are S-type. 
        The effective address is obtained by adding register rs1 to the sign-extended 12-bit offset. Loads copy a value from memory to register rd. 
        Stores copy the value in register rs2 to memory.*/
    assign memory_address = (i_type | s_type) ? ({15'b0,instr_i[19:15]} + immediate) : 0;

    /** Assigne the immediate value */
    assign instr_imm_o = immediate;

`ifdef RV32I_DEBUG
    /** Assign debug ports */
    assign funct3_o     = (j_type | u_type) ? 0 : instr_i[`func3];
    assign r_type_d     = r_type;
    assign i_type_d     = i_type;
    assign s_type_d     = s_type;
    assign b_type_d     = b_type;
    assign u_type_d     = u_type;
    assign j_type_d     = j_type;
    assign illegal_d    = illegal;
`endif
endmodule