module mips_cpu_divideru
    (
    input  logic clk,
    input  logic start,          // start signal
    input  logic [31:0] Dividend,  // dividend
    input  logic [31:0] Divisor,  // divisor
    input  logic reset,
    output     logic [31:0] Quotient,  // quotient
    output     logic [31:0] Remainder,  // remainder
    output     logic done,           // done signal
    output     logic dbz             // divide by zero flag
    );

    logic [31:0] y1;            // copy of divisor
    logic [31:0] q1, q1_next;   // intermediate quotient
    logic [31:0] ac, ac_next;   // accumulator
    logic [5:0] i;   // dividend bit counter

    always@(*) begin
        if (ac >= y1) begin
            ac_next = ac - y1;
            {ac_next, q1_next} = {ac_next[30:0], q1, 1'b1};
        end else begin
            {ac_next, q1_next} = {ac, q1} << 1;
        end
    end

    always_ff @(posedge clk) begin
        if (reset) begin
            Quotient <= 0;
            Remainder <= 0;
            done <= 0;
            dbz <= 0;
        end else if (start) begin
            if (Divisor == 0) begin  // catch divide by zero
                dbz <= 1;
                done <= 1;
                Quotient <= 0;
                Remainder <= 0;
            end else if(Dividend == 0) begin
                done <= 1;
                Quotient <= 0;
                Remainder <= 0;
            end else if (Divisor > Dividend) begin
                done <= 1;
                Quotient <= 0;
                Remainder <= Dividend;
            end else begin  // initialize values
                dbz <= 0;
                done <= 0;
                i <= 0;
                y1 <= Divisor;
                {ac, q1} <= {{31{1'b0}}, Dividend, 1'b0};
            end
        end else if (!done) begin
            if (i == 31) begin  // we're done
                done <= 1;
                Quotient <= q1_next;
                Remainder <= ac_next >> 1;  // undo final shift
            end else begin  // next iteration
                i <= i + 6'd1;
                ac <= ac_next;
                q1 <= q1_next;
            end
        end
    end
endmodule