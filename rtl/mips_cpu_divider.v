module mips_cpu_divider 
    (
    input  logic clk,
    input  logic start,          // start signal
    input  logic [31:0] Dividend,  // dividend
    input  logic [31:0] Divisor,  // divisor
    input  logic reset,
    input  logic sign,

    output     logic [31:0] Quotient,  // quotient
    output     logic [31:0] Remainder,  // remainder
    output     logic done,           // done signal
    output     logic dbz             // divide by zero flag
    );

    wire [31:0] Dividend_in,Divisor_in,Quotient_out, Remainder_out;
    assign Dividend_in = (sign) ? (Dividend[31]) ? -Dividend :Dividend :Dividend;
    assign Divisor_in = (sign) ? (Divisor[31]) ? -Divisor :Divisor :Divisor;
    assign Quotient = (sign) ? (Divisor[31]==Dividend[31]) ? Quotient_out : -Quotient_out : Quotient_out;
    assign Remainder = (sign) ? (Dividend[31]) ? -Remainder_out : Remainder_out : Remainder_out;

    mips_cpu_divideru inst(
        .clk(clk), .start(start), .Dividend(Dividend_in), .Divisor(Divisor_in), .reset(reset), .done(done), .dbz(dbz),
        .Quotient(Quotient_out), .Remainder(Remainder_out)
    );

endmodule