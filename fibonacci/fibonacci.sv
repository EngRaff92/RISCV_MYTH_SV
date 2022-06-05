/**
It is a series of numbers, where the next number is found by adding up the 2 numbers before it.
Series: 0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144,…
*/

/** Timescale */
`timescale 1ns/1ns

/** Main Module */
module fibonacci#(
		// Paramters
		parameter END_COUNT = 2, // end of the fibonacci Sequence
		parameter DUMP_NAME = "fibonacci_dump"
	)(
		// Ports
		input logic 		clk,    // Clock
		input logic 		rst,  	// Asynchronous reset active high
		output logic 		done,	//
		output logic [31:0] result	//
	);

	// Start by genertaing internal signals
	logic [31:0] current_value, prev_value;

	// Main counter
	always_ff @(posedge clk or posedge rst) begin : proc_
		if(rst) begin
			current_value 	<= 'd1;
			prev_value		<= 'd0;
		end else begin
			prev_value 		<= current_value;
			current_value	<= (current_value == END_COUNT) ? current_value : current_value + prev_value;
		end
	end

	// assign the end once the counter has reaced the END point
	assign done = (current_value == END_COUNT);

	// assign the result only once done
	assign result = (current_value)&({32{done}});

`ifdef COCOTB_SIM
	initial begin
	    $dumpfile({DUMP_NAME,".vcd"});
	    $dumpvars(0, fibonacci);
	end
`endif
endmodule // fibonacci