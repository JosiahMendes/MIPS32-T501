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

    mips_cpu_divideru div_inst (.*);

    //always #(10/ 2) clk = ~clk;

    initial begin
        $dumpfile("divider.vcd");
        $dumpvars(0, divider_tb);
                clk = 0;

        #5;

        repeat (10000000000) begin
            #5 clk = !clk;
        end

        $finish;
    end

    initial begin 
            Dividend = 1;
            Divisor  = 1;

                repeat (1000) begin
                    @(posedge clk);
                    #1
                    start = 1;

                    @(posedge clk);
                    #1
                    start = 0;

                    while (done == 0) begin
                        @(posedge clk);
                        #1;
                    end
                    $display("\t%d:\t%d /%d =%d (Remainder =%d) (DBZ=%b)", $time, Dividend, Divisor, Quotient, Remainder, dbz);

                    Dividend = $urandom_range(10000);
                    Divisor = $urandom_range(10000,1); 
                end
                repeat (100000) begin
                    @(posedge clk);
                    #1
                    start = 1;

                    @(posedge clk);
                    #1
                    start = 0;

                    while (done == 0) begin
                        @(posedge clk);
                        #1;
                    end
                    $display("\t%d:\t%d /%d =%d (Remainder =%d) (DBZ=%b)", $time, Dividend, Divisor, Quotient, Remainder, dbz);
                    assert(Dividend/Divisor == Quotient) else $fatal(1,"Quotient is wrong should be %d",Dividend/Divisor);
                    assert(Dividend%Divisor == Remainder) else $fatal(1,"Remainder is wrong should be %d", Dividend%Divisor);
                    Divisor = $urandom;
                    Dividend = $urandom_range;
                end
                $display("Finished. Total time = %t", $time);
                $finish;
    end
       /* #100    Dividend = 4'b0000;
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
*/
//     mips_cpu_divider inst(
//         .clk(clk), .start(start), .done(done), .dbz(dbz),
//         .x(x), .Divisor(Divisor), .Quotient(q), .r(r)
//     );
endmodule