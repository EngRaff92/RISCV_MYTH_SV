/* Instruction memory used to store the binaries instructions to be fecthed */

module instruction_memory #(
        // Parameters
        parameter N_WORD    = 1024,
        parameter ADDR_W    = 10,
        parameter INSTR_LEN = 32
    )(
        input logic [ADDR_W-1:0] i_addr,
        output logic [INSTR_LEN-1:0] i_data_out
    );
    
    // Declare the main Array
    logic [INSTR_LEN-1:0] instr_mem_array [N_WORD-1:0];

    // Drive Output assumig the Program Counter is already Cutshorted
    assign i_data_out = instr_mem_array[i_addr];
endmodule // instruction_memory
