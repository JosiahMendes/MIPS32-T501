module divider_tb(
);

    logic clk;
    logic start;            // start signal
    logic [31:0] Dividend;    // dividend
    logic [31:0] Divisor;    // divisor
    logic [31:0] Quotient;    // quotient
    logic [31:0] Remainder;    // remainder
    logic done;             // done signal
    logic dbz;    
    logic reset;          // divide by zero flag

    mips_cpu_divider div_inst (.*);

    always #(10/ 2) clk = ~clk;

    initial begin
        $dumpfile("divider.vcd");
        $dumpvars(0, divider_tb);
                clk = 1;

        #100    Dividend = 4'b0000;
                Divisor = 4'b0010;
                start = 1;
        #10     start = 0;
        #320     $display("\t%d:\t%d /%d =%d (Remainder =%d) (DBZ=%b)", $time, Dividend, Divisor, Quotient, Remainder, dbz);
        #100    Dividend = 4'b0111;
                Divisor = 4'b0010;
                start = 1;
        #10     start = 0;
        #320     $display("\t%d:\t%d /%d =%d (Remainder =%d) (DBZ=%b)", $time, Dividend, Divisor, Quotient, Remainder, dbz);
                $finish;
    end

//     mips_cpu_divider inst(
//         .clk(clk), .start(start), .done(done), .dbz(dbz),
//         .x(x), .Divisor(Divisor), .Quotient(q), .r(r)
//     );
endmodule