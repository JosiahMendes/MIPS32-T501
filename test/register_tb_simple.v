`timescale 1ns/100ps

module register_tb_simple();
    logic clk;
    logic write;
    logic reset;

    logic[31:0] wrData, rdDataA, rdDataB;
    logic[4:0] wrAddr, rdAddrA, rdAddrB;

    initial begin
        $timeformat(-9,1,"ns",20);
        $dumpfile("register_tb_simple.vcd");
        $dumpvars(0,register_tb_simple);

        clk = 0;
        reset = 1;
        write = 0;
        wrAddr = 0;
        wrData = 0;

        #5 clk = 1;
        #5 clk = 0;
        $display("A = %d, B = %d", rdDataA, rdDataB);
        assert(rdDataA==0);
        assert(rdDataB==0);

        reset = 0;
        rdAddrA = 1;
        rdAddrB = 25;
        wrAddr = 0;//try writing to 0 register
        wrData = 5;
        write = 1;

        #5 clk = 1;
        #5 clk = 0;
        $display("A = %d, B = %d", rdDataA, rdDataB);

        assert(rdDataA==0);
        assert(rdDataB==0);

        rdAddrA = 11;
        rdAddrB = 0;
        wrAddr = 10;
        wrData = 45;
        write = 1;

        #5 clk = 1;

        #5 clk = 0;

        $display("A = %d, B = %d", rdDataA, rdDataB);
        assert(rdDataA==0);
        assert(rdDataB==0);

        rdAddrA = 10;
        rdAddrB = 10;
        wrAddr = 12;
        wrData = 35;
        write = 1;

        #5 clk = 1;
        #5 clk = 0;
        $display("A = %d, B = %d", rdDataA, rdDataB);

        assert(rdDataA == 45);
        assert(rdDataB == 45);

        rdAddrA = 10;
        rdAddrB = 12;
        wrAddr = 12;
        wrData = 35;
        write = 1;

        #5 clk = 1;
        #5 clk = 0;
        $display("A = %d, B = %d", rdDataA, rdDataB);

        assert(rdDataA == 45);
        assert(rdDataB == 35);

        rdAddrA = 0;
        rdAddrB = 12;
        wrAddr = 12;
        wrData = 9;
        write = 0;
        

        #5 clk = 1;
        #5 clk = 0;
        $display("A = %d, B = %d", rdDataA, rdDataB);
        assert(rdDataA == 0);
        assert(rdDataB == 35);

    end

    mips_cpu_registers regs(
        .clk(clk),
        .write(write),
        .reset(reset),
        .wrAddr(wrAddr), .wrData(wrData),
        .rdAddrA(rdAddrA), .rdDataA(rdDataA), 
        .rdDataB(rdDataB), .rdAddrB(rdAddrB)
    );

endmodule