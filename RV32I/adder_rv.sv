/** Simple adder with Overflow capability and Parameter for operands and sum*/
module adder_rv#(
	// Parameters
	parameter OP_W = 32
	) (
	// input ports 
	input logic [OP_W-1:0] op1,
	input logic [OP_W-1:0] op2,
	// output ports
	output logic [OP_W-1:0] sum_o,
	output logic 			o_flow);

	// Body
	always_comb begin
		{o_flow,sum_o} = (op1 + op2);
	end
endmodule // adder_rv