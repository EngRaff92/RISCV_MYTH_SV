/**
It is a series of numbers, where the next number is found by adding up the 2 numbers before it.
Series: 0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144,…
*/

/** Timescale */
`timescale 1ns/1ns

/** Main Module */
module fibonacci_piped#(
		// Paramters
		parameter END_COUNT = 2, // end of the fibonacci Sequence
		parameter DUMP_NAME = "fibonacci_piped_dump"
	)(
		// Ports
		input logic 		clk,    // Clock
		input logic 		rst,  	// Asynchronous reset active high
		output logic 		done,	//
		output logic [31:0] result	//
	);

	// Start by genertaing internal signals
	logic [31:0] current_value;
	logic [31:0] prev_value;
	logic [31:0] result_pided;
	logic done_piped;
	logic gated_clk;

	// Main counter
	always_ff @(posedge clk or posedge rst) begin : proc_
		if(rst) begin
			current_value 	<= 32'h1;
			prev_value		<= 32'h0;
		end else begin
			prev_value 		<= current_value;
			current_value	<= (current_value == END_COUNT) ? current_value : current_value + prev_value;
		end
	end

	/** This is the only stage of Pipeline needed since the internal values are already flopped these are more like EN_FF */
	pipe_ff#(32,32'h0) result_pided_ff(
		.stage_clk  (gated_clk),
		.stage_rst  (~(current_value == END_COUNT)),
		.stage_in_d (current_value),
		.stage_out_q(result_pided));

	pipe_ff#(1,1'h0) done_piped_ff(
		.stage_clk  (gated_clk),
		.stage_rst  (~(current_value == END_COUNT)),
		.stage_in_d ((current_value == END_COUNT)),
		.stage_out_q(done_piped));

	/** Clock gating cell */
	clock_g clock_gating_cell(
		.clk_en   ((current_value == END_COUNT)),
		.clk_in   (clk),
		.clock_out(gated_clk));

	// assign the end once the counter has reaced the END point
	assign done = done_piped;

	// assign the result only once done
	assign result = result_pided;

`ifdef COCOTB_SIM
	initial begin
	    $dumpfile({DUMP_NAME,".vcd"});
	    $dumpvars(0, fibonacci_piped);
	end
`endif
endmodule // fibonacci_piped