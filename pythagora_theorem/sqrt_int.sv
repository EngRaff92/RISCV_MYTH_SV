/** ALGORITHM for a no FP computation
 *      1  0  1  1     Our answer: one digit for each pair of digits in the radicand
    ———————————
   √01 11 10 01     Our radicand

    01              Bring down the most significant pair
  - 01              Subtract 01
    ——
    00              Our answer is NOT negative, so our first answer digit is 1

    00 11           Bring down the next pair of digits and append to previous result
  - 01 01           Append 01 to our existing answer, 1, and subtract it
    —————
    11 00           Our result is negative, so our second answer digit is 0
                    We discard the result because it's negative

    00 11 10        Keep the existing digits, 00 11, and append the next pair
  -    10 01        Append 01 to our existing answer, 10, and subtract it
    ————————
       01 01        Our answer is NOT negative, so our next answer digit is 1

       01 01 01     Bring down the next pair of digits and append to previous result
    -  01 01 01     Append 01 to our existing answer, 101, and subtract it
       ————————
             00     Our answer is NOT negative, so our next answer digit is 1
*/

/** Main Module */
module sqrt_int #(
    parameter WIDTH = 8              // width of radicand
) (
    input   logic clk,
    input   logic start,             // start signal
    output  logic busy,              // calculation in progress
    output  logic valid,             // root and rem are valid
    input   logic [WIDTH-1:0] rad,   // radicand
    output  logic [WIDTH-1:0] root,  // root
    output  logic [WIDTH-1:0] rem    // remainder
);

    logic [WIDTH-1:0] x, x_next;    // radicand copy
    logic [WIDTH-1:0] q, q_next;    // intermediate root (quotient)
    logic [WIDTH+1:0] ac, ac_next;  // accumulator (2 bits wider)
    logic [WIDTH+1:0] test_res;     // sign test result (2 bits wider)

    localparam ITER = WIDTH >> 1;   // iterations are half radicand width
    logic [$clog2(ITER)-1:0] i;     // iteration counter

    always_comb begin
        test_res = ac - {q, 2'b01};
        if (test_res[WIDTH+1] == 0) begin  // test_res ≥0? (check MSB)
            {ac_next, x_next} = {test_res[WIDTH-1:0], x, 2'b0};
            q_next = {q[WIDTH-2:0], 1'b1};
        end else begin
            {ac_next, x_next} = {ac[WIDTH-1:0], x, 2'b0};
            q_next = q << 1;
        end
    end

    always_ff @(posedge clk) begin
        if (start) begin
            busy <= 1;
            valid <= 0;
            i <= 0;
            q <= 0;
            {ac, x} <= {{WIDTH{1'b0}}, rad, 2'b0};
        end else if (busy) begin
            if (i == ITER-1) begin  // we're done
                busy <= 0;
                valid <= 1;
                root <= q_next;
                rem <= ac_next[WIDTH+1:2];  // undo final shift
            end else begin  // next iteration
                i <= i + 1;
                x <= x_next;
                ac <= ac_next;
                q <= q_next;
            end
        end
    end
endmodule