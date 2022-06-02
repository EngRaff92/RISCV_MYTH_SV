/** */

/** Timescale */
`timescale 1ns/1ns

/** Opcode supported 
 * -> operations supported are:
 * SUM - MULT - SUB - SQRT - DIV*/
`ifdef COCOTB_SIM
	typedef enum logic [2:0] {
		SUM 	= 1,
		MULT 	= 2,
		SUB 	= 3,
		SQRT 	= 4,
		DIV 	= 5
	}cal_type_t;
`else 
	parameter SUM 	= 1;
	parameter MULT 	= 2;
	parameter SUB 	= 3;
	parameter SQRT 	= 4;
	parameter DIV 	= 5;
`endif 

/** Main Module */
module calculator_piped#(
		// Parameters
`ifdef COCOTB_SIM				
		parameter DW = 32,
		parameter DUMP_NAME = "calculator_dump"
`else 
		parameter DW = 32
`endif
	)
	(
		// Ports
		input logic 			calc_clock,	//
		input logic 			calc_rst,	//
`ifdef COCOTB_SIM		
		input cal_type_t		opcode,		//
`else 		
		input logic [2:0]		opcode,		//
`endif
		input logic [DW-1:0] 	op_in1, 	//
		input logic [DW-1:0] 	op_in2, 	//
		input logic 			op_in_sel, 	//
		output logic [2*DW-1:0] result, 	//
		output logic 			valid_res	//
	);

	/** Internal Logic Signals */
	logic [2*DW-1:0] place_h_res;
	logic overflow;
	logic [DW-1:0] root_out;

	/** Main logic is under a fully combo logic */
	always_comb begin // op_selector
		place_h_res = {2*DW{1'b0}};
		case(opcode)
			SUM		: begin {overflow,place_h_res[DW-1:0]} 	= (op_in2 + op_in1); end	
			MULT 	: begin {overflow,place_h_res} 			= (op_in2 * op_in1);end
			SUB 	: begin {overflow,place_h_res[DW-1:0]} 	= (op_in2 - op_in1); end	
			SQRT 	: begin {overflow,place_h_res[DW-1:0]} 	= root_out; end	
			DIV 	: begin {overflow,place_h_res} 			= {1'b0,{2*DW{1'b0}}}; end
			default	: begin {overflow,place_h_res} 			= {1'b0,{2*DW{1'b0}}}; end
		endcase // opcode
	end

	/** Sqaure root combo logic Huge area due to Multiplier */
	sqrt_c u_sqrt_c(
		.op_in (op_in_sel ? op_in1 : op_in2),
		.op_out(root_out));

	/** Sample result only if there is no overflow*/
	en_ff#(2*DW,1'b0,1'b1,32'h0) u_ff_sampling(
		.ff_clk      (calc_clock),
		.ff_rst      (calc_rst),
		.ff_en       (~overflow),
		.ff_in_d     (place_h_res),
		.ff_out_q    (sampled_res),
		.ff_out_not_q());

	/** Assign valid result */
	assign int_valid = (~overflow) ? 1'b1 : 1'b0;

	/** zeroout the tresult in case of not valid */
	assign result = int_valid ? sampled_res : {2*DW{1'b0}};

	/** Valid POrt */
	assign valid_res = int_valid;

`ifdef COCOTB_SIM
	initial begin
	    $dumpfile({DUMP_NAME,".vcd"});
	    $dumpvars(0, calculator_piped);
	end
`endif
endmodule // calculator_piped