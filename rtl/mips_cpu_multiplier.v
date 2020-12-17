module mips_cpu_multiplier(
    input logic [31:0] a, //Using signed logic for now, until a problem with arises
    input logic [31:0] b,//Coudlnt use signed ports, had a port decleration error
    input logic sign, clk,
    output logic [63:0] out
);
    always_ff @(posedge clk) begin

        if(sign)begin out = $signed(a)*$signed(b); end
        else begin out =$unsigned(a)*$unsigned(b); end
    end
/*
       logic [1:0] temp;
       integer i;
       logic E1;
       logic [31:0] b1;
       always @ (a, b)
       begin
         out = 64'd0;
         E1 = 1'd0;
         for (i = 0; i < 32; i = i + 1)
         begin
           temp = {a[i], E1};
           b1 = - b;
             case (temp)
               2'd2 : out [63 : 32] = out [63 : 32] + b1;
               2'd1 : out [63 : 32] = out [63 : 32] + b;
               default : begin end
             endcase
               out = out >> 1;

               out[63] = out[62];


               E1 = a[i];
                   end

            //if(b[31]==1)
               if (b == 32'd2147483648)
               begin
                 out = - out;
          end

        end
*/
endmodule
