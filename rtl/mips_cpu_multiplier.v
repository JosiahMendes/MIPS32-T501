module mips_cpu_multiplier
    (
    input logic [31:0] a, 
    input logic [31:0] b,
    input logic  clk, sign, reset,
    output logic [63:0] out
    );
	 
	  always_ff @(posedge clk) begin
        if (reset) begin
            out <=0;
        end else begin
            if(sign)begin 
                out = $signed(a)*$signed(b); 
            end
            else begin 
                out =$unsigned(a)*$unsigned(b); 
            end
        end
    end

endmodule