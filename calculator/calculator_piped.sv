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
		parameter DW 			= 32,
`ifdef COCOTB_SIM				
		parameter DUMP_NAME 	= "calculator_piped_dump",
`endif
		parameter N_OF_STAGES 	= 3,
		parameter IS_PIPED 		= 1,
		parameter IS_FULLY_PIPED= 1
	)
	(
		// Ports
		input logic 			calc_clock,	//
		input logic 			calc_rst,	//
`ifdef COCOTB_SIM		
		input cal_type_t		opcode,		//
		input logic 			different,
`else 		
		input logic [2:0]		opcode,		//
`endif
		input logic [DW-1:0] 	op_in1, 	//
		input logic [DW-1:0] 	op_in2, 	//
		input logic 			op_in_sel, 	//
		output logic [2*DW-1:0] result, 	//
		output logic 			valid_res	//
	);

`ifdef COCOTB_SIM	
	initial begin
		// Parameter checker
		assert(~((IS_PIPED == 1) & (N_OF_STAGES == 0))) else $error("If RTL is piped number of STAGES cannot be 0");
		assert(~((IS_FULLY_PIPED == 1) & (IS_PIPED == 0))) else $error("If RTL is not piped CANNOT be Fully Piped");
	end
`endif

	/** FIRST STAGE PIPELINE ON INPUTS */
	logic [DW-1:0] op_in1_pipe;
	logic [DW-1:0] op_in2_pipe;
	logic op_in_sel_pipe;
`ifdef COCOTB_SIM		
	cal_type_t	opcode_pipe;
`else 		
	logic [2:0] opcode_pipe;
`endif

generate
if((IS_PIPED == 1) & (N_OF_STAGES > 0) & (IS_FULLY_PIPED ==1)) begin: first_stage_pipe
	pipe_ff#(DW,32'h0) u_op_in1_pipe(
		.stage_clk  (calc_clock),
		.stage_rst  (calc_rst),
		.stage_in_d (op_in1),
		.stage_out_q(op_in1_pipe));
	pipe_ff#(DW,32'h0) u_op_in2_pipe(
		.stage_clk  (calc_clock),
		.stage_rst  (calc_rst),
		.stage_in_d (op_in2),
		.stage_out_q(op_in2_pipe));
	pipe_ff#(1,1'b0) u_op_in_sel_pipe(
		.stage_clk  (calc_clock),
		.stage_rst  (calc_rst),
		.stage_in_d (op_in_sel),
		.stage_out_q(op_in_sel_pipe));	
	pipe_ff#(3,3'h0) u_opcode_pipe(
		.stage_clk  (calc_clock),
		.stage_rst  (calc_rst),
		.stage_in_d (opcode),
		.stage_out_q(opcode_pipe));		
end else begin
	assign op_in1_pipe 		= op_in1;
	assign op_in2_pipe 		= op_in2;
	assign op_in_sel_pipe 	= op_in_sel;
	assign opcode_pipe		= opcode;
end
endgenerate

	/** Internal Logic Signals */
	logic [2*DW-1:0] place_h_res, sampled_res;
	logic overflow;
	logic [DW-1:0] root_out;

	/** Main logic is under a fully combo logic */
	always_comb begin // op_selector
		place_h_res = {2*DW{1'b0}};
		case(opcode_pipe)
			SUM		: begin {overflow,place_h_res[DW-1:0]} 	= (op_in1_pipe + op_in2_pipe); end	
			MULT 	: begin {overflow,place_h_res} 			= (op_in1_pipe * op_in2_pipe);end
			SUB 	: begin {overflow,place_h_res[DW-1:0]} 	= (op_in1_pipe - op_in2_pipe); end	
			SQRT 	: begin {overflow,place_h_res[DW-1:0]} 	= root_out_pipe; end	
			DIV 	: begin {overflow,place_h_res} 			= {1'b0,{2*DW{1'b0}}}; end
			default	: begin {overflow,place_h_res} 			= {1'b0,{2*DW{1'b0}}}; end
		endcase // opcode
	end
	
	/** SECOND STAGE PIPELINE ON INTERMEDIATE SIGNALS */
	logic [2*DW-1:0] place_h_res_pipe;
	logic overflow_pipe;
generate
if((IS_PIPED == 1) & (N_OF_STAGES > 1) & (IS_FULLY_PIPED ==1)) begin: second_stage_pipe
	pipe_ff#(2*DW,{2*DW{1'b0}}) u_place_h_res_pipe(
		.stage_clk  (calc_clock),
		.stage_rst  (calc_rst),
		.stage_in_d (place_h_res),
		.stage_out_q(place_h_res_pipe));
	pipe_ff#(1,1'b0) u_overflow_pipe(
		.stage_clk  (calc_clock),
		.stage_rst  (calc_rst),
		.stage_in_d (overflow),
		.stage_out_q(overflow_pipe));
end else begin
	assign place_h_res_pipe = place_h_res;
	assign overflow_pipe 	= overflow;
end
endgenerate

	/** Sqaure root combo logic Huge area due to Multiplier */
	sqrt_c u_sqrt_c(
		.op_in (((op_in_sel_pipe) ? op_in1_pipe : op_in2_pipe)),
		.op_out(root_out));

	/** THIRD STAGE PIPELINE ON SQRT */
	logic [DW-1:0] root_out_pipe;
generate	
if((IS_PIPED == 1) & (N_OF_STAGES > 2) & (IS_FULLY_PIPED ==1)) begin: third_stage_pipe	
	pipe_ff#(DW,{DW{1'b0}}) u_root_out_pipe(
		.stage_clk  (calc_clock),
		.stage_rst  (calc_rst | (opcode != SQRT)),
		.stage_in_d (root_out),
		.stage_out_q(root_out_pipe));
end else begin
	assign root_out_pipe = (opcode == SQRT) ? root_out : {DW{1'b0}};
end
endgenerate

	/** Sample result only if there is no overflow*/
	en_ff#((2*DW),1'b0,1'b1,{2*DW{1'b0}}) u_ff_sampling(
		.ff_clk      (calc_clock),
		.ff_rst      (calc_rst),
		.ff_en       (~overflow_pipe),
		.ff_in_d     (place_h_res_pipe),
		.ff_out_q    (sampled_res),
		.ff_out_not_q());

	/** Assign valid result */
	assign int_valid 	= (~overflow_pipe) ? 1'b1 : 1'b0;

	/** zeroout the tresult in case of not valid */
	assign result 		= int_valid ? sampled_res : {2*DW{1'b0}};

	/** Valid POrt */
	assign valid_res 	= int_valid;

`ifdef COCOTB_SIM
	initial begin
	    $dumpfile({DUMP_NAME,".vcd"});
	    $dumpvars(0, calculator_piped);
	end
`endif
endmodule // calculator_piped