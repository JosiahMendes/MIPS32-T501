module mips_cpu_multiplier(
    input logic [31:0] a,
    input logic [31:0] b,
    input logic sign,
    output logic [63:0] out
);
    always_comb begin
        
        if(sign)begin out = $signed(a)*$signed(b); end
        else begin out =$unsigned(a)*$unsigned(b); end
    end

endmodule