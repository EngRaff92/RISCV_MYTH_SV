//Verilog function to find square root of a 32 bit number.
//The output is 16 bit.
module sqrt_c(
    // Ports
    input logic [31:0] op_in,
    output logic [31:0] op_out
);

    // internal signals.
    logic [31:0] a;
    logic [15:0] q;
    logic [17:0] l,r,re;    
    integer i;

    // Main combo loop Max 16 multiplier but not clock
    always_comb begin
        //initialize all the variables.
        a       = op_in;
        q       = 0;
        i       = 0;
        l       = 0;    //input to adder/sub
        r       = 0;    //input to adder/sub
        re      = 0;    //remainder
        //run the calculations for 16 iterations.
        for(i=0;i<16;i=i+1) begin 
            r       = {q,re[17],1'b1};
            l       = {re[15:0],a[31:30]};
            a       = {a[29:0],2'b00};    //left shift by 2 bits.
            if (re[17] == 1) 
                //add if r is negative
                re = l + r;
            else    
                //subtract if r is positive
                re = l - r;
            // Result
            q = {q[14:0],!re[17]};       
        end
    end

    // final assignment of output.
    assign op_out = q;   
endmodule // sqrt_c