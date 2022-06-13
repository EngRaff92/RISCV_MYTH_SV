module instruction_fetch #(
    // Parameters Here
)
(
    // Ports Here
    /** Input Ports */
    input logic         fetch_rst,          /** */
    input logic         fetch_clk,          /** */
    input logic [31:0]  in_branch,          /** */
    input logic [31:0]  in_jump,            /** */
    input logic         is_jump,            /** */
    input logic         is_branch,          /** */
    /** Output Ports */ 
`ifdef RV32I_DEBUG    
    output logic [31:0] pc,                 /** */
`endif
    output logic        pc_error,           /** */
    output logic [31:0] instruction_fecthed /** */
);
    
    /** Internal signals */
    logic [31:0] pc_reg, pc_next, o_flow_4, o_flow_jmp, pc_plus_4, pc_jump;
    logic [31:0] inst;

    /** Assign the pc_reg to be used as main PC */
    en_ff#(32,0,1,32'h0) u_pc_incr_ff(
        .ff_en       (1),
        .ff_clk      (fetch_clk),
        .ff_rst      (fetch_rst),
        .ff_in_d     (pc_next),
        .ff_out_q    (pc_reg),
        .ff_out_not_q());

    /** Adder for PC + 4 */
    adder_rv#(32) u_pc_plus_4(
        .op1   (pc_reg),
        .op2   (32'h4),
        .sum_o (pc_plus_4),
        .o_flow(o_flow_4));

    /** Adder for PC + 4 */
    adder_rv#(32) u_pc_jump(
        .op1   (pc_reg),
        .op2   (in_jump),
        .sum_o (pc_jump),
        .o_flow(o_flow_jmp));

    /** Assign the next PC in case we have a valid JUMP ro BRANCH */
    assign pc_next  = (is_jump) ? pc_jump : (is_branch) ? in_branch : pc_plus_4;

    /** assign main Program Counter */
    assign pc = pc_reg;

    /** Assign the error port */
    assign pc_error = (is_jump) ? o_flow_jmp : (is_branch) ? 1'b0 : o_flow_4;

    /** Instruction memory Instance */
    instruction_memory#(10,10,32) u_instr_memory_unit(
        .i_addr    (pc_reg[31:2]),
        .i_data_out(inst));

    /** assign instruction */
    assign instruction_fecthed = (pc_error) ? 0 : inst;
endmodule

