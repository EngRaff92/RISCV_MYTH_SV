/**
 * Clock gating is a way reducing dynamic Power dissipation by temporary turning-off clock of the Flops on certain parts of the logic or by turning-off 
 * enable on gated Flops. In other words, Flops are turned-on only if there is valid information to be stored or transferred. 
 * The accuracy with which these clocks are Turned-off is captured by clock gating efficiency
 */

/** Main Cell */
module clock_g (
	input 	logic clk_in,    	// Clock
	input 	logic clk_en, 		// Clock Enable
	output 	logic clock_out  	// Asynchronous reset active low
);
	// Internal signals
	logic clock_enable;
	// Start by stopping at the negedge
	always_latch  begin
 		if(~clk_in) 
    		clock_enable = clk_en;
	end
   	
   	// Gating without glitches
	assign clock_out = clk_in & clock_enable;
endmodule // clock_g