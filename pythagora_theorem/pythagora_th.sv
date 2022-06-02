/** Module:
 * For a right-angled triangle, the area of the square of the hypotenuse is equal to the sum of the areas of the squares on the other two sides.
 */


/** Time scale */
`timescale 1us/1ns

/** Main Module*/
module pythagora_th#(
		// Parameters
		parameter DW = 32
	)
	(
		// Ports
		input logic 	py_clock,		//
		input logic 	py_rst,			//
		input logic 	py_start,		//
		input logic [DW-1:0] py_s0,		//
		input logic [DW-1:0] py_s1,		//
		output logic [DW-1:0] py_hyp,	//
		output logic py_valid);			//

	/** Internal logic signals */
	logic en_condition;
	logic [DW-1:0] sum_in;
	logic [DW-1:0] int_reminder;
	logic [DW-1:0] int_root;
	logic [DW-1:0] sampled_root;
	logic qualified_start;
	logic overflow;
	logic int_busy;
	logic int_valid;
	logic gated_clock;

	/** Assign the sum of each side power of 2 */
	assign {overflow,sum_in} = ((py_s0*py_s0) + (py_s1*py_s1));

	/** Assign the qualified start which must be 0 if we overflow so that the SQRT doesn't start */
	assign qualified_start = py_start & (~overflow);

	/** SQRT istance */
	sqrt_int#(DW) u_sqrt(
		.clk  (py_clock),
		.start(qualified_start),
		.busy (int_busy),
		.valid(int_valid),
		.rad  (sum_in),
		.root (int_root),
		.rem  (int_reminder)); 

	/** Evaluate the enabling clock condition 
	 * Enable clock if:
	 * -> we are not overflowing
	 * -> each side must be different from 0
	 * -> we are not under reset
	 * -> the SQRT logic is no busy
	 * */
	assign en_condition = (~overflow) & ((|py_s0) != 1'b0) & ((|py_s1) != 1'b0) & (~py_rst) & (~int_busy);

	/** Clock Gating Cell for sampling clock*/
	clock_g u_clock_gating_cell(
		.clk_in   (py_clock),
		.clk_en   (en_condition),
		.clock_out(gated_clock));

	/** Sampling logic */
	en_ff#(DW,1'b0,1'b1,32'h0) u_hypo_sampling(
			.ff_clk      (gated_clock),
			.ff_rst      (py_rst),
			.ff_en       (int_valid),
			.ff_in_d     (int_root),
			.ff_out_q    (sampled_root),
			.ff_out_not_q());

	/** Assign the output */
	assign py_hyp = sampled_root;

	/** Assign Valid signal */
	assign py_valid = int_valid;
	
`ifdef COCOTB_SIM
	initial begin
	  $dumpfile ("dump.vcd");
	  $dumpvars (0, pythagora_th);
	end
`endif	
endmodule // pythagora_th
