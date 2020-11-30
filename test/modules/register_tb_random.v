`timescale 1ns/100ps

module register_tb_random(
);
    logic clk;
    logic reset;

    logic[4:0] wrAddr, rdAddrA, rdAddrB;
    logic[31:0] wrData, rdDataA, rdDataB;
    logic write;

    /* The number of cycles we want to actually test. Increasing the number will make the test-bench
        take longer, but may also uncover edge-cases. */
    localparam TEST_CYCLES = 100;

    /* Constant used to track how many cycles we want to run for before declarating a timeout. */
    localparam TIMEOUT_CYCLES = TEST_CYCLES + 10;

    /* Clock generation process. Starts at the beginning of simulation. */
    initial begin
        $timeformat(-9, 1, " ns", 20);
        $dumpfile("register_tb_random.vcd");
        $dumpvars(0, register_tb_random);

        /* Send clock low right at the start of the simulation. */
        clk = 0;

        /* Delay by 5 timeunits (5ns) -> hold clock low for 5 timeunits */
        #5;

        /* Generate clock for at most TIMEOUT_CYCLES cycles. */
        repeat (2*TIMEOUT_CYCLES) begin
            /* Delay by 5 timeunits (5ns) then toggle clock -> 10ns = 100MHz clock. */
            #5 clk = !clk;
        end

        $fatal(1, "Testbench timed out rather than exiting gracefully.");
    end

    /* Shadow copy of what we _expect_ the register file to contain. We will update this
        as necessary in order to keep track of how the entries are expected to change. */
    logic[31:0] shadow[0:31];

    /* Input stimulus and checking process. This starts at the beginning of time, and   
        is synchronised to the same clock as DUT. */
    integer i;
    initial begin

        reset = 0;

        @(posedge clk)
        #1;
        /* Pulse the reset for one cycle, in order to get register file into known state. */
        reset=1;

        @(posedge clk)
        #1;

        /* reset==1 -> Initialise shadow copy to all zeros. */
        for(i=0; i<32; i++) begin
            shadow[i]=0;
        end


        /* Run as many test cycles as were requested. */
        repeat (TEST_CYCLES) begin
            /* Generate random samplings of input to apply in next cycle. */
            wrAddr = $urandom_range(0,31);
            wrData = $urandom();
            write = $urandom_range(0,1);     /* Write enable is toggled randomly. */
            rdAddrA = $urandom_range(0,31);
            rdAddrB = $urandom_range(0,31);
            reset = $urandom_range(0,100)==0;       /* 1% chance of reset in each cycle. */

            @(posedge clk)
            #1;

            /* Update the shadow regsiters according to the commands given to the register file. */
            if (reset==1) begin
                for(i=0; i<31; i++) begin
                    shadow[i]=0;
                end
            end else if (write==1 && wrAddr == 0) begin 
            end else if (write == 1) begin
                    shadow[wrAddr] = wrData;
            end

            /* Verify the returned results against the expected output from the shadow registers. */
            if (reset==1) begin
                assert (rdDataA==0) else $error("rdDataA not zero during reset.");
                assert (rdDataB==0) else $error("rdDataB not zero during reset.");
            end
            else begin
                assert( rdDataA == shadow[rdAddrA] )
                else $error("At time %t, read_indexA=%d, got=%h, ref=%h", $time, rdAddrA, rdDataA, shadow[rdAddrA]);
                assert( rdDataB == shadow[rdAddrB] )
                else $error("At time %t, read_indexB=%d, got=%h, ref=%h", $time, rdAddrB, rdDataB, shadow[rdAddrB]);
            end
        end

        /* Exit successfully. */
        $finish;
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