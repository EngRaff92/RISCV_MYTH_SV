/** Main Control unit
 * 	by a given instruction it will give out:
 * 	1. Memory address if is a memory operation
 * 	2. Memory RD - WR command along with Chip select
 *  3. Register file Chip select is a R type operation
 * 	4. Register file RD - WR operation
 *  4. write back command in case of Store operation*/

module opcode_control_unit(
	// Input ports
	input  logic[`opcoce] in_opcode,
	// Output ports
	output logic 	reg_file_w_r_en,
	output logic 	memory_r_w_en,
	output logic 	reg_file_cs,
	output logic 	memory_cs,
	output logic 	write_back,
	output logic32	memory_address,
	output logic 	is_jump_flag,
	output logic 	is_branch_flag);

	/** Main */
	always_comb begin: control_process
		case(in_opcode)
			`REG_OP  	: begin reg_file_cs = 1; end
			`MEM_LOP 	: begin end
			`MEM_SOP 	: begin end
			`IMM_OP   	: begin end 
			`BRAN_OP  	: begin end
			`JMP_OP  	: begin end
			default		: begin end
		endcase
	end
endmodule // opcode_control_unit