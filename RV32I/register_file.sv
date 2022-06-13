/*
 * This is the Register file for RV32I made in SV and verified using Iverilog
 * Please Refer to the README file for info.
 */
 module register_file
    #(
        // Parameters
        parameter REG_DATA_W = 32,          // RV32I
        parameter ADDR_WIDTH = $clog2(32)   // Based on ISA
    )(
        // Input ports
        // clock and reset
        input logic                     rf_clk,
        input logic                     rf_ares,
        // decoder addresses
        input logic [ADDR_WIDTH-1:0]    rw_dec,
        input logic [ADDR_WIDTH-1:0]    ra_dec,
        input logic [ADDR_WIDTH-1:0]    rb_dec,
        input logic [REG_DATA_W-1:0]    w_data_in,
        // write enable
        input logic                     wr_en,
        // Chip select
        input logic                     rf_cs,
        // Output ports
        output logic [REG_DATA_W-1:0]   qa_out,
        output logic [REG_DATA_W-1:0]   qb_out
 );

        // Total number of REGISTERS is 32 based on ISA
        localparam REG_NUMBER = 32;

        // main register file and init variable 
        logic [REG_DATA_W-1:0] regfile[REG_NUMBER-1:0];
        int i;

        // Sets of registers using the RV32I names usefull for debug
`ifdef RV32I_DEBUG
        logic [REG_DATA_W-1:0] zero;
        logic [REG_DATA_W-1:0] ra;
        logic [REG_DATA_W-1:0] sp;
        logic [REG_DATA_W-1:0] gp;
        logic [REG_DATA_W-1:0] tp;
        logic [REG_DATA_W-1:0] t0;
        logic [REG_DATA_W-1:0] t1, t2;
        logic [REG_DATA_W-1:0] s0;
        logic [REG_DATA_W-1:0] s1;
        logic [REG_DATA_W-1:0] a0, a1;
        logic [REG_DATA_W-1:0] a2, a3, a4, a5, a6, a7;
        logic [REG_DATA_W-1:0] s2, s3, s4, s5, s6, s7, s8, s9, s10, s11;
        logic [REG_DATA_W-1:0] t3, t4, t5, t6;    

        // Debug assign
        assign zero = regfile['d0];
        assign ra = regfile['d1 ];
        assign sp = regfile['d2 ];
        assign gp = regfile['d3 ];
        assign tp = regfile['d4 ];
        assign t0 = regfile['d5 ];
        assign t1 = regfile['d6 ];
        assign t2 = regfile['d7 ];
        assign s0 = regfile['d8 ];
        assign s1 = regfile['d9 ];
        assign a0 = regfile['d10];
        assign a1 = regfile['d11];
        assign a2 = regfile['d12];
        assign a3 = regfile['d13];
        assign a4 = regfile['d14];
        assign a5 = regfile['d15];
        assign a6 = regfile['d16];
        assign a7 = regfile['d17];
        assign t3 = regfile['d18];
        assign t4 = regfile['d19];
        assign t5 = regfile['d20];
        assign t6 = regfile['d21];
        assign s2 = regfile['d22];
        assign s3 = regfile['d23];
        assign s4 = regfile['d24];
        assign s5 = regfile['d25];
        assign s6 = regfile['d26];
        assign s7 = regfile['d27];
        assign s8 = regfile['d28];
        assign s9 = regfile['d29];
        assign s10= regfile['d30];
        assign s11= regfile['d31];
`endif 

        // Write Process and reset stage
        always_ff @(posedge rf_clk or posedge rf_ares) begin: write_reset_stage
            if(rf_ares) begin
                for(i = 0; i <= (REG_NUMBER-1); i++)  regfile[i] <= '0;
            end else if(wr_en & rf_cs) begin
                    regfile[rw_dec] = (rw_dec == 0) ? {REG_DATA_W{1'b0}} : w_data_in;
            end
        end

        // Read State should be resolved in the same cycle not under reset
        assign qa_out = (rf_cs & (~wr_en)) ? regfile[ra_dec] : {REG_DATA_W{1'b0}};
        assign qb_out = (rf_cs & (~wr_en)) ? regfile[rb_dec] : {REG_DATA_W{1'b0}};
 endmodule // register_file