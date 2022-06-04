/* TABLE
|	ALU operations				|	Instructions						|
|-----------------------------------------------------------------------|
|	Addition (+)				| ADD, ADDI, LW, SW, JALR, AUIPC, JAL	|
|-----------------------------------------------------------------------|
|	Subtraction (-)				| SUB 									|
|-----------------------------------------------------------------------|
|	Shift left (<<)				| SLL, SLLI 							|
|-----------------------------------------------------------------------|
|	Logical Shift right (>>)	| SRL, SRLI 							|
|-----------------------------------------------------------------------|
|	Arithmetic Shift right(>>>)	| SRA, SRAI 							|
|-----------------------------------------------------------------------|
|	Logical OR (|)				| OR, ORI 								|
|-----------------------------------------------------------------------|
|	Logical AND (&)				| AND, ANDI 							|
|-----------------------------------------------------------------------|
|	Logical XOR (^)				| XOR, XORI 							|
|-----------------------------------------------------------------------|
|	Equal to (==)				| BEQ, BNE, BLT 						|
|-----------------------------------------------------------------------|
|	Less than (<)				| BLTU, SLTU, SLTIU 					|
|-----------------------------------------------------------------------|
|	Greater than (>)			| BGEU 									|
|-----------------------------------------------------------------------|
|	Signed Less than (<)		| BLT, SLT, SLTI 						|
|-----------------------------------------------------------------------|
|	Signed Greater than (>)		| BGEU									|
|-----------------------------------------------------------------------|
*/

/** 
The ALU would be a pure combinational unit and would give out result in the same cycle. 
The ALU design should be straightforward with just a bit of care for the logic around 
the signed and unsigned operations. Look at the interface requirements and the logic 
on the right window pane.
*/

// --------------------------------------------------------
// RISC-V: Arithmetic Logical Unit
//
// Designing the ALU for the RV32I based RISC-V processor.
// The ALU should be able to perform all the arithmetic
// operations necessary to execute the RV32I subset of the
// instructions.
// --------------------------------------------------------

// --------------------------------------------------------
// Arithmetic Logical Unit (ALU)
// --------------------------------------------------------
module rv_alu (
  input   wire [31:0] opr_a_i,
  input   wire [31:0] opr_b_i,
  input   wire [3:0]  op_sel_i,
  output  wire [31:0] alu_res_o
);

  // --------------------------------------------------------
  // Local parameters
  // These parameters define the encodings of the `op_sel_i`
  // input to the ALU. Using parameters is better as it eases
  // debugging and helps in maintaining the code.
  // --------------------------------------------------------
  localparam OP_ADD = 4'b0000;
  localparam OP_SUB = 4'b0001;
  localparam OP_SLL = 4'b0010;
  localparam OP_LSR = 4'b0011;
  localparam OP_ASR = 4'b0100;
  localparam OP_OR  = 4'b0101;
  localparam OP_AND = 4'b0110;
  localparam OP_XOR = 4'b0111;
  localparam OP_EQL = 4'b1000;
  localparam OP_ULT = 4'b1001;
  localparam OP_UGT = 4'b1010;
  localparam OP_SLT = 4'b1011;
  localparam OP_SGT = 4'b1100;

  // --------------------------------------------------------
  // Use a `signed` version of the two operands as well.
  // This would help in easily computing operations which
  // operate on signed inputs (like SLT, SGT)
  // --------------------------------------------------------
  logic signed [31:0] sign_opr_a;
  logic signed [31:0] sign_opr_b;

  // --------------------------------------------------------
  // Declaring an internal signal to hold the ALU result.
  // This would be later assigned to the actual output
  // --------------------------------------------------------
  logic [31:0] alu_res;

  // --------------------------------------------------------
  // Signed opeartions can simply be assigned to the current
  // inputs. The `>>>` operator or the `>` operator would
  // recognise these as signed numbers.
  // --------------------------------------------------------
  assign sign_opr_a = opr_a_i;
  assign sign_opr_b = opr_b_i;

  // --------------------------------------------------------
  // The ALU result would depend on the value of the `op_sel`
  // input to the ALU. It would be helpful to implement this
  // as a case statement covering all the possible values for
  // the `op_sel` input.
  // It would be a good time to quickly review the operation
  // performed by each of the instruction from the RISC-V
  // ISA. See section "2.4 Integer Computational Instructions"
  // --------------------------------------------------------
  always@(*) begin
    case (op_sel_i)
      OP_ADD : alu_res = opr_a_i + opr_b_i;
      OP_SUB : alu_res = opr_a_i - opr_b_i;
      OP_SLL : alu_res = opr_a_i << opr_b_i[4:0];
      OP_SGT : alu_res = {31'h0, sign_opr_a >= sign_opr_b};
      OP_LSR : alu_res = opr_a_i >> opr_b_i[4:0];
      OP_ASR : alu_res = sign_opr_a >>> sign_opr_b[4:0];
      OP_OR  : alu_res = opr_a_i | opr_b_i;
      OP_AND : alu_res = opr_a_i & opr_b_i;
      OP_XOR : alu_res = opr_a_i ^ opr_b_i;
      OP_EQL : alu_res = {31'h0,(opr_a_i == opr_b_i)};
      OP_ULT : alu_res = {31'h0,(opr_a_i < opr_b_i)};
      OP_UGT : alu_res = {31'h0,(opr_a_i > opr_b_i)};
      OP_SLT : alu_res = {31'h0,(sign_opr_a < sign_opr_b)};
      default: alu_res = 32'h0;
    endcase
  end

  // --------------------------------------------------------
  // Output assignment
  // --------------------------------------------------------
  assign alu_res_o = alu_res;
endmodule