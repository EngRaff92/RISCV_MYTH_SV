/* TABLE
|	ALU operations				          |	Instructions						            |
|-----------------------------------------------------------------------|
|	Addition (+)                    | ADD, ADDI, LW, SW, JALR, AUIPC, JAL	|
|-----------------------------------------------------------------------|
|	Subtraction (-)                 | SUB 									              |  
|-----------------------------------------------------------------------|
|	Shift left (<<)                 | SLL, SLLI 							            |
|-----------------------------------------------------------------------|
|	Logical Shift right (>>)        | SRL, SRLI 							            |
|-----------------------------------------------------------------------|
|	Arithmetic Shift right(>>>)	    | SRA, SRAI 							            |
|-----------------------------------------------------------------------|
|	Logical OR (|)				          | OR, ORI 								            |
|-----------------------------------------------------------------------|
|	Logical AND (&)				          | AND, ANDI 							            |
|-----------------------------------------------------------------------|
|	Logical XOR (^)                 | XOR, XORI 							            |
|-----------------------------------------------------------------------|
|	Equal to (==)	                  | BEQ, BNE, BLT 						          |
|-----------------------------------------------------------------------|
|	Less than (<)                   | BLTU, SLTU, SLTIU 					        |
|-----------------------------------------------------------------------|
|	Greater than (>)                | BGEU 									              |
|-----------------------------------------------------------------------|
|	Signed Less than (<)		        | BLT, SLT, SLTI 						          |
|-----------------------------------------------------------------------|
|	Signed Greater than (>)		      | BGEU									              |
|-----------------------------------------------------------------------|
*/

/** 
  The ALU would be a pure combinational unit and would give out result in the same cycle. 
  The ALU design should be straightforward with just a bit of care for the logic around 
  the signed and unsigned operations. Look at the interface requirements and the logic 
  on the right window pane.
*/

/** Arithmetic Logical Unit (ALU) */
module rv_alu (
    input   logic [31:0] opr_a_i,
    input   logic [31:0] opr_b_i,
    input   logic [9:0]  op_sel_i,
    output  logic [31:0] alu_res_o
);

    /**
      Use a `signed` version of the two operands as well. This would help in easily computing operations which
      operate on signed inputs (like SLT, SGT)
    */
    logic signed [31:0] sign_opr_a;
    logic signed [31:0] sign_opr_b;

    /** Declaring an internal signal to hold the ALU result. */
    logic [31:0] alu_res;

    /** Signed opeartions can simply be assigned to the current inputs. The `>>>` operator or the `>` operator would recognise these as signed numbers. */
    assign sign_opr_a = opr_a_i;
    assign sign_opr_b = opr_b_i;

    /** 
      The ALU result would depend on the value of the `op_sel` input to the ALU. It would be helpful to implement this
      as a case statement covering all the possible values for the `op_sel` input.
      It would be a good time to quickly review the operation performed by each of the instruction from the RISC-V
      ISA. See section "2.4 Integer Computational Instructions 
    */
    always_comb begin
      case (op_sel_i)
        `OP_ADD : alu_res = opr_a_i + opr_b_i;
        `OP_SUB : alu_res = opr_a_i - opr_b_i;
        `OP_OR  : alu_res = opr_a_i | opr_b_i;
        `OP_AND : alu_res = opr_a_i & opr_b_i;
        `OP_XOR : alu_res = opr_a_i ^ opr_b_i;
        `OP_SLL : alu_res = opr_a_i << opr_b_i[4:0];
        `OP_SRL : alu_res = opr_a_i >> opr_b_i[4:0];
        `OP_SRA : alu_res = sign_opr_a >>> sign_opr_b[4:0];
        `OP_SLTU: alu_res = {31'h0,(opr_a_i < opr_b_i)};
        `OP_SLT : alu_res = {31'h0,(sign_opr_a < sign_opr_b)};
        // These operations are not yet supproted
        // `OP_EQL : alu_res = {31'h0,(opr_a_i == opr_b_i)};
        // `OP_SGT : alu_res = {31'h0, sign_opr_a >= sign_opr_b};
        // `OP_UGT : alu_res = {31'h0,(opr_a_i > opr_b_i)};
        default : alu_res = 32'h0;
      endcase
    end
    
    /** Assign result */
    assign alu_res_o = alu_res;
endmodule