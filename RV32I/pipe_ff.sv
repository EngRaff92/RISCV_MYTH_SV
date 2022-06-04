/** Pipeline Flop*/
/** Main Module */
module pipe_ff#(
		// Params
		parameter FF_WIDTH 			= 32,
		parameter INITAL_VALUE		= 32'h0
	)
	(
		// Ports
		input 	logic stage_clk,
		input 	logic stage_rst,
		input 	logic [FF_WIDTH-1:0] stage_in_d,
		output 	logic [FF_WIDTH-1:0] stage_out_q
		);

`ifdef COCOTB_SIM
	// Asserts
	initial begin
		// Parameter checking
		assert(FF_WIDTH != 0) else $error("Flip Flop Data cannot be 0 FF_WIDTH");
	end
`endif

	// sample the output port
	logic [FF_WIDTH-1:0] q;
	always_ff @(posedge stage_clk or posedge stage_rst) begin : proc_stage
		if(stage_rst) begin
			q <= INITAL_VALUE;
		end else begin
			q <= stage_in_d;
		end
	end

	// Assign the not q data port
	assign stage_out_q = q;
endmodule