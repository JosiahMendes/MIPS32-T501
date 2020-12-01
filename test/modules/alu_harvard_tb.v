module ALU_harvard_tb();

    logic clk;

    logic ALUmux = 0;
    logic[31:0] a;
    logic[31:0] b;
    logic[31:0] c = 0;
    logic[31:0] ALUout;
    logic[3:0] ALUop;
    logic ALUzero;

    initial begin
        $dumpfile("test/modules/alu_harvard_tb.vcd");
        $dumpvars(0, ALU_harvard_tb);

        clk = 0;
        #5;
        forever begin
            #5 clk = 1;
            #5 clk = 0;
        end
    end

    localparam integer STEPS = 10000;

    initial begin
        ALUop = 4'b0010; //alu control input for addition
        a = 0;
        b = 0;
        @(posedge clk) #9;

        repeat (STEPS) begin
            a = a+32'h23456789;
            b = b+32'h34567891;
            @(posedge clk) #9;
        end

        a = 32'hffffffff;
        b = 32'hffffffff;
        @(posedge clk) #9;

        ALUop = 4'b0011;//alu control input for subtraction
        a = 0;
        b = 0;
        @(posedge clk) #9;

        repeat (STEPS) begin
            a = a+32'h23456789;
            b = b+32'h34567891;
            @(posedge clk) #9;
        end

        a = 32'hffffffff;
        b = 32'hffffffff;
        @(posedge clk) #9;

        ALUop = 4'b0000;//alu control input for AND
        a = 0;
        b = 0;
        @(posedge clk) #9;

        repeat (STEPS) begin
            a = a+32'h23456789;
            b = b+32'h34567891;
            @(posedge clk) #9;
        end

        a = 32'hffffffff;
        b = 32'hffffffff;
        @(posedge clk) #9;

        ALUop = 4'b0001;//alu control input for OR
        a = 0;
        b = 0;
        @(posedge clk) #9;

        repeat (STEPS) begin
            a = a+32'h23456789;
            b = b+32'h34567891;
            @(posedge clk) #9;
        end

        a = 32'hffffffff;
        b = 32'hffffffff;
        @(posedge clk) #9;

        ALUop = 4'b0101;//alu control input for XOR
        a = 0;
        b = 0;
        @(posedge clk) #9;

        repeat (STEPS) begin
            a = a+32'h23456789;
            b = b+32'h34567891;
            @(posedge clk) #9;
        end

        a = 32'hffffffff;
        b = 32'hffffffff;
        @(posedge clk) #9;

    end

    // check output of ALU
    initial begin
        $display("Testing addition");

        repeat (STEPS+2) begin
            @(posedge clk) #1;
            assert(ALUout == a+b) else $fatal(2,"a=%d, b=%d, r=%d",a,b,ALUout);
        end

        $display("Testing subtraction");

        repeat (STEPS+2) begin
            @(posedge clk) #1;
            assert(ALUout == a-b) else $fatal(2,"a=%d, b=%d, r=%d",a,b,ALUout);
        end

        $display("Testing AND");

        repeat (STEPS+2) begin
            @(posedge clk) #1;
            assert(ALUout == a&b) else $fatal(2,"a=%d, b=%d, r=%d",a,b,ALUout);
        end

        $display("Testing OR");

        repeat (STEPS+2) begin
            @(posedge clk) #1;
            assert(ALUout == a|b) else $fatal(2,"a=%d, b=%d, r=%d",a,b,ALUout);
        end

        $display("Testing XOR");

        repeat (STEPS+2) begin
            @(posedge clk) #1;
            assert(ALUout == a^b) else $fatal(2,"a=%d, b=%d, r=%d",a,b,ALUout);
        end

        $display("Working as expected");
        $finish;
    end

    mux_ALU test_unit(
            .ALUmux(ALUmux),
            .ALUop(ALUop),
            .a(a), .b(b), .c(c), // ALU 32-bit Inputs
            .ALUout(ALUout), // ALU 32-bit Output
            .ALUzero(ALUzero)
    );

endmodule
