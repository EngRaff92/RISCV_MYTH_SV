/** Enable Flop*/
/** Main Module */
module en_ff#(
		// Params
		parameter FF_WIDTH 			= 32,
		parameter NEGEDGE_SAMPLING 	= 0,
		parameter POSEDGE_SAMPLING 	= 1,
		parameter INITAL_VALUE		= 32'h0
	)
	(
		// Ports
		input logic ff_clk,
		input logic ff_rst,
		input logic ff_en,
		input logic [FF_WIDTH-1:0] ff_in_d,
		output logic [FF_WIDTH-1:0] ff_out_q,
		output logic [FF_WIDTH-1:0] ff_out_not_q
		);

`ifdef COCOTB_SIM
	// Asserts
	initial begin
		// Parameter checking
		assert(FF_WIDTH != 0) else $error("Flip Flop Data cannot be 0 FF_WIDTH");
		assert((NEGEDGE_SAMPLING ^ POSEDGE_SAMPLING) == 1) else $error("Cannot have a double EDGE sampling FF or a 0 edge sampling FF");
	end
`endif

	// Internal clocks
	logic l_clk;
	assign l_clk = (NEGEDGE_SAMPLING) ? ~ff_clk : ((POSEDGE_SAMPLING) ? ff_clk : 1'b0);

	// sample the output port
	logic [FF_WIDTH-1:0] q;
	always_ff @(posedge l_clk or posedge ff_rst) begin : proc_ip_calculation
		if(ff_rst) begin
			q <= INITAL_VALUE;
		end else if(ff_en) begin
			q <= ff_in_d;
		end
	end

	// Assign the not q data port
	assign ff_out_not_q = ~(q);
	assign ff_out_q 	= q;
endmodule