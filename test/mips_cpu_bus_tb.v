module mips_cpu_bus_tb;
    timeunit 1ns / 10ps;

    parameter RAM_INIT_FILE = "...";  // RAM INITIALISATION insert file between " "
    parameter TIMEOUT_CYCLES = 1000; // TIME OUT PROGRAM AT 10000 CYCLES

    logic clk;
    logic reset;

    logic active;

    logic write;
    logic read;
    logic waitrequest;
    logic[31:0] writedata;
    logic[31:0] readdata;
    logic[31:0] register_v0;
    logic[3:0] byteenable;
    logic[31:0] CPUaddress;
    logic[15:0] RAMaddress;

    assign RAMaddress = CPUaddress - 32'hBFC00000;

    mips_cpu_bus_tb_memory #(RAM_INIT_FILE) ramInst(.clk(clk), .write(write), .read(read), 
        .writedata(writedata), .addr(RAMaddress), .byteenable(byteenable),
        .waitrequest(waitrequest), .readdata(readdata)
    ); //would initialise a ram module

    mips_cpu_bus cpuInst(.clk(clk), .reset(reset), .active(active), .waitrequest(waitrequest),
        .address(CPUaddress), .write(write), .read(read), 
        .writedata(writedata), .readdata(readdata), .byteenable(byteenable),
        .register_v0(register_v0)
    ); // initialise a mips cpu module

    // Generate clock
    initial begin
        $display("Simulation Starting");
        $dumpfile("Simulation.vcd");
        $dumpvars(0, mips_cpu_bus_tb);
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
            if((CPUaddress<32'hBFC00000 || CPUaddress > 32'hBFC07FFF ) && (write||read) && CPUaddress != 32'b0) begin
                $fatal(2, "Test accessed memory address %h outside of range", CPUaddress);
            end
            @(posedge clk)begin
            end
        end

        #10
        $display("TB : Register V0 has %h",register_v0);
        $display("TB : finished; active=0");
        

        $finish;

    end



endmodule
