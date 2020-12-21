module mips_cpu_multiplier
    (
    input logic [31:0] a, //Using signed logic for now, until a problem with arises
    input logic [31:0] b,//Coudlnt use signed ports, had a port decleration error
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
	 
	 /*

    wire [31:0] Multiplicand,Multiplier;
    wire [63:0] Product;
    assign Multiplicand = (sign) ? (a[31]) ? -a :a :a;
    assign Multiplier = (sign) ? (b[31]) ? -b :b :b;
    assign out = (sign) ? (b[31]==a[31]) ? Product : -Product : Product;

    mips_cpu_multiplieru inst(
        .clk(clk), .a(Multiplicand), .b(Multiplier), .out(Product)
    ); */

endmodule