/* Instruction memory used to store the binaries instructions to be fecthed */
module instruction_memory #(
        // Parameters
        parameter N_WORD    = 1024,
        parameter ADDR_W    = 10,
        parameter INSTR_LEN = 32
    )(
        input logic [ADDR_W-1:0]        i_addr,
        output logic [INSTR_LEN-1:0]    i_data_out
    );
    
    initial begin
`ifdef RV32I_DEBUG
        foreach (instr_mem_array[i]) instr_mem_array[i] = {INSTR_LEN{1'b0}};
`else 
        $readmemh("./memory.hex");
`endif
    end

    /** Declare the main Array */
    logic [INSTR_LEN-1:0] instr_mem_array [N_WORD-1:0];

    /** Drive Output assumig the Program Counter is already Cutshorted */
    assign i_data_out = instr_mem_array[i_addr];

`ifdef RV32I_DEBUG
    /** Main function used to inject instruction in case of debug opened */
    function void set_instruction(  input bit [ADDR_W-1:0] memory_index     = 0,
                                    input bit [INSTR_LEN-1:0] memory_inst   = 0);
        /** set */
        instruction_memory[memory_index] = memory_inst;
    endfunction // set_instruction

    /** Main function used to get instruction in case of debug opened */
    function void get_instruction(  input bit [ADDR_W-1:0] memory_index = 0,
                                    output bit [INSTR_LEN-1:0] current_instruction);
        /** get */
        current_instruction = instruction_memory[memory_index];
    endfunction // get_instruction
`endif
endmodule // instruction_memory
