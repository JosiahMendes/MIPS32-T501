module mips_cpu_multiplieru(
    input logic [31:0] a, 
    input logic [31:0] b, 
    input logic  clk,
    output logic [63:0] out
);
    always_ff @(negedge clk) begin
        out <= $unsigned(a)*$unsigned(b);
    end
endmodule
