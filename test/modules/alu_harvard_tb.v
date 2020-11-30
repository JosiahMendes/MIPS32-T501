module ALU_harvard_tb();

    logic clk;

    logic[31:0] a;
    logic[31:0] b;
    logic[31:0] r;
    logic[2:0] ALUsel;

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
        ALUsel = 3'b010; //alu control input for addition
        a = 0;
        b = 0;

        repeat (STEPS) begin
            @(posedge clk) #9;
            a = a+32'h23456789;
            b = b+32'h34567891;
        end
        #9;
        a = 32'hffffffff;
        b = 32'hffffffff;

        ALUsel = 3'b011; //alu control input for subtraction
        a = 0;
        b = 0;

        repeat (STEPS) begin
            @(posedge clk) #9;
            a = a+32'h23456789;
            b = b+32'h34567891;
        end
        #9;
        a = 32'hffffffff;
        b = 32'hffffffff;

        ALUsel = 3'b000; //alu control input for AND
        a = 0;
        b = 0;

        repeat (STEPS) begin
            @(posedge clk) #9;
            a = a+32'h23456789;
            b = b+32'h34567891;
        end
        #9;
        a = 32'hffffffff;
        b = 32'hffffffff;

        ALUsel = 3'b001; //alu control input for OR
        a = 0;
        b = 0;

        repeat (STEPS) begin
            @(posedge clk) #9;
            a = a+32'h23456789;
            b = b+32'h34567891;
        end
        #9;
        a = 32'hffffffff;
        b = 32'hffffffff;
    end

    // check output of ALU
    initial begin
        @(posedge clk);

        repeat (STEPS) begin
            @(posedge clk) #1;
            assert(r == a+b) else $fatal(2,"Wrong output");
        end

        repeat (STEPS) begin
            @(posedge clk) #1;
            assert(r == a-b) else $fatal(2,"Wrong output");
        end

        repeat (STEPS) begin
            @(posedge clk) #1;
            assert(r == a&b) else $fatal(2,"Wrong output");
        end

        repeat (STEPS) begin
            @(posedge clk) #1;
            assert(r == a|b) else $fatal(2,"Wrong output");
        end

        $display("Working as expected");
        $finish;
    end

    ALU test_unit(
            .op(ALUsel),
            .a(a), .b(b),  // ALU 32-bit Inputs
            .result(r) // ALU 32-bit Output
    );

endmodule
