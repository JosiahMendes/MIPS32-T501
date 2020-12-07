`timescale 1ns/100ps
module memory_tb_simple();
    logic clk;
    logic write;
    logic read;
    logic waitrequest;

    logic[31:0] wrData, rdData;
    logic[24-1:0] addr;
    logic[3:0] byteenable;

    mips_cpu_bus_tb_memory mem(
        .clk(clk),
        .write(write),
        .read(read),
        .byteenable(byteenable), 
        .addr(addr),
        .writedata(wrData), 
        .waitrequest(waitrequest), 
        .readdata(rdData)
    );


    initial begin
        $timeformat(-9,1,"ns",20);
        $dumpfile("memory_tb_simple.vcd");
        $dumpvars(0,memory_tb_simple);

        clk = 0;
        write = 0;
        read = 1;
        addr = 0;
        wrData = 0;
        byteenable = 4'b1111;

        #5 clk = 1;
        #5 clk = 0;
        $display("The data read from  location %d is %h with bytes %b selected", addr, rdData,byteenable);
        assert(rdData==0);
        write = 1;
        read = 0;
        addr = 20;
        wrData = 32'hffff;
        byteenable = 4'b1111;

        #5 clk = 1;
        #5 clk = 0;
        $display("The data written to location %d is %h with bytes %b selected", addr, wrData,byteenable);

        write = 0;
        read = 1;
        addr = 20;
        wrData = 0;
        byteenable = 4'b1111;

        #5 clk = 1;
        #5 clk = 0;
        $display("The data read from  location %d is %h with bytes %b selected", addr, rdData,byteenable);
        assert(rdData==32'hffff);

        write = 1;
        read = 0;
        addr = 24;
        wrData = 32'hffff;
        byteenable = 4'b0011;

        #5 clk = 1;
        #5 clk = 0;
        $display("The data written to location %d is %h with bytes %b selected", addr, wrData,byteenable);

        write = 0;
        read = 1;
        addr = 24;
        wrData = 0;
        byteenable = 4'b1111;

        #5 clk = 1;
        #5 clk = 0;
        $display("The data read from  location %d is %h with bytes %b selected", addr, rdData,byteenable);
        assert(rdData==32'h0000ffff);

        write = 1;
        read = 0;
        addr = 24;
        wrData = 32'habcd12ff;
        byteenable = 4'b1111;

        #5 clk = 1;
        #5 clk = 0;
        $display("The data written to location %d is %h with bytes %b selected", addr, wrData,byteenable);

        write = 0;
        read = 1;
        addr = 24;
        wrData = 0;
        byteenable = 4'b1000;

        #5 clk = 1;
        #5 clk = 0;
        $display("The data read from  location %d is %h with bytes %b selected", addr, rdData,byteenable);
        assert(rdData==32'h000000ab);

        write = 0;
        read = 1;
        addr = 24;
        wrData = 0;
        byteenable = 4'b0100;

        #5 clk = 1;
        #5 clk = 0;
        $display("The data read from  location %d is %h with bytes %b selected", addr, rdData,byteenable);
        assert(rdData==32'h000000cd);

        write = 0;
        read = 1;
        addr = 24;
        wrData = 0;
        byteenable = 4'b0010;

        #5 clk = 1;
        #5 clk = 0;
        $display("The data read from  location %d is %h with bytes %b selected", addr, rdData,byteenable);
        assert(rdData==32'h00000012);

        write = 0;
        read = 1;
        addr = 24;
        wrData = 0;
        byteenable = 4'b0001;

        #5 clk = 1;
        #5 clk = 0;
        $display("The data read from  location %d is %h with bytes %b selected", addr, rdData,byteenable);
        assert(rdData==32'h000000ff);

        write = 0;
        read = 1;
        addr = 25;
        wrData = 0;
        byteenable = 4'b0001;

        #5 clk = 1;
        #5 clk = 0;
        $display("The data read from  location %d is %h with bytes %b selected", addr, rdData,byteenable);
        assert(rdData==32'h00000012);

        write = 0;
        read = 1;
        addr = 26;
        wrData = 0;
        byteenable = 4'b0001;

        #5 clk = 1;
        #5 clk = 0;
        $display("The data read from  location %d is %h with bytes %b selected", addr, rdData,byteenable);
        assert(rdData==32'h000000cd);

        write = 0;
        read = 1;
        addr = 27;
        wrData = 0;
        byteenable = 4'b0001;

        #5 clk = 1;
        #5 clk = 0;
        $display("The data read from  location %d is %h with bytes %b selected", addr, rdData,byteenable);
        assert(rdData==32'h000000ab);
        

    end

endmodule