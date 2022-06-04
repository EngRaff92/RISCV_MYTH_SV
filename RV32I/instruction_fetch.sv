module instruction_fetch #(
    // Parameters Here
)
(
    // Ports Here
    input logic         reset,
    input logic         clk,
    input logic [31:0]  branch_loc,
    input logic [31:0]  jump_loc,
    input logic         is_jump_instr,
    input logic         is_branch_instr,
    output logic [31:0] pc
);

    // firstly assign the pc by using increments
    logic [31:0] pc_reg;
    always_ff @(posedge clk or negedge reset) begin: pc_incr
        if(reset)
            pc_reg <= '0;
        else 
            pc_reg <= pc_reg + 32'h4;
    end

    // Assign the next PC
    logic [31:0] pc_next
    assign pc_next = (is_jump_instr) ? jump_loc : (is_branch_instr) ? branch_loc : pc_reg;

    // assign the port
    assign pc = pc_next;
endmodule

