/*
|   Instruction     |   Description                                         |
|---------------------------------------------------------------------------|
|    LB             |   Loads a byte from data memory                       |
|---------------------------------------------------------------------------|
|    LH             |   Loads a half-word (16-bits) from data memory        |
|---------------------------------------------------------------------------|
|    LW             |    Loads entire word (32-bits) from data memory       |
|---------------------------------------------------------------------------|
|    LBU            |    Loads a byte and zero-extends it to 32-bits        |
|---------------------------------------------------------------------------|
|    LHU            |    Loads a half-word and zero-extends it to 32-bits   |
|---------------------------------------------------------------------------|
|    SB             |    Stores a byte to data memory                       |
|---------------------------------------------------------------------------|
|    SH             |    Stores a half-word to data memory                  |
|---------------------------------------------------------------------------|
|    SW             |    Stores the entire word to data memory              |
|---------------------------------------------------------------------------|
*/

/* data memory used to store and load data value using Store and Load instructions*/
module data_memory #(
        // Parameters
        parameter N_WORD    = 1024,
        parameter ADDR_W    = 10,
        parameter DATA_LEN  = 32,
        parameter IS_CLOCKED= 1
    )(
        input logic                     d_clk,
        input logic                     d_rst,
        input logic [ADDR_W-1:0]        d_addr,
        input logic [DATA_LEN-1:0]      d_w_data,
        input logic                     d_rw_en,
        input logic                     d_cs,
        output logic [DATA_LEN-1:0]     d_r_data
    );
    
    // Declare the main Array
    logic [DATA_LEN-1:0] data_mem_array [N_WORD-1:0];
    int mem_i;

    // Main proces for single port data mememory shared between read and write
    generate
    if(IS_CLOCKED == 1) begin
        always_ff @(posedge d_clk or posedge d_rst) begin : proc_mem_op
            if(rst_n) begin
                for(mem_i = 0; mem_i < N_WORD; mem_i++) data_mem_array[mem_i] = {DATA_LEN{1'b0}};
            end else begin
                if(d_cs) begin // memory selected start
                    if(d_rw_en) begin   // Write
                        data_mem_array[d_addr]  <= d_w_data;
                        d_r_data                <= {DATA_LEN{1'bz}};
                    end else begin      // Read
                        d_r_data                <= data_mem_array[d_addr];
                    end 
                end            // memoery selected end
            end
        end
    end // if(IS_CLOCKED == 1)
    else begin
        always_comb begin
            if(d_cs) begin  // memory selected start            
                if(d_rw_en) begin
                    data_mem_array[d_addr] = d_w_data;
                    d_r_data               = {DATA_LEN{1'bz}};
                end else begin
                    d_r_data               = data_mem_array[d_addr];
                end
            end             // memoery selected end
        end // always_comb
    end // if(IS_CLOCKED == 0)
    endgenerate
endmodule // instruction_memory