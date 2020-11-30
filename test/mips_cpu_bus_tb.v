module mips_cpu_bus_tb;
    timeunit 1ns / 10ps;

    parameter RAM_INIT_FILE = "...";  // RAM INITIALISATION insert file between " "
    parameter TIMEOUT_CYCLES = 10000; // TIME OUT PROGRAM AT 10000 CYCLES

    logic clk;
    logic reset;

    logic active;

    logic[31:0] address;
    logic write;
    logic read;
    logic[31:0] writedata;
    logic[31:0] readdata;
    logic[31:0] register_v0;

    //RAM_16x4096_del31y1 #(RAM_INIT_FILE) ramInst(.clk(clk), .address(address), .write(write), .read(read), .writedata(writedata), .readdata(readdata)); //would initialise a ram module

    //CPU_MU0_delay1 cpuInst(.clk(clk), .reset(reset), .active(active), .address(address), .write(write), .read(read), .writedata(writedata), .readdata(readdata), register_v0); // initialise a mips cpu module

    // Generate clock
    initial begin
        clk=0;

        repeat (TIMEOUT_CYCLES) begin
            #10;
            clk = !clk;
            #10;
            clk = !clk;
        end

        $fatal(2, "Simulation did not finish within %d cycles.", TIMEOUT_CYCLES);
    end

    initial begin
        reset <= 0;

        @(posedge clk);
        reset <= 1;

        @(posedge clk);
        reset <= 0;

        @(posedge clk);
        assert(active==1)
        else $display("TB : CPU did not set active=1 after reset.");

        while (active) begin
            @(posedge clk);
        end

        $display("TB : finished; active=0");

        $finish;

    end



endmodule
