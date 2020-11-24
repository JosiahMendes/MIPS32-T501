module ALU_harvard_tb;
    timeunit 1ns / 10ps;

    logic clk;

    logic[31:0] a;
    logic[31:0] b;
    logic[31:0] r;
    logic[2:0] ALUsel;

    ALU_harvard test_unit(
            a,b,  // ALU 32-bit Inputs
            ALUsel,// ALU Selection
            r // ALU 32-bit Output
    );

    initial begin
        $dumpfile("alu_harvard_tb.vcd");
        $dumpvars(0, alu_harvard_tb);

        clk = 0;
        #5;
        forever begin
            #5 clk = 1;
            #5 clk = 0;
        end
    end

    integer i;
    localparam integer STEPS_addu = 10000;

    initial begin
        ALUsel = 010; //alu control input for addition
        a = 0;
        b = 0;

        repeat (STEPS_addu) begin
            @(posedge clk) #9;
            a = a+32'h23456789;
            b = b+32'h34567891;
        end
        #9;
        a = 32'hffff;
        b = 32'hffff;
    end

    logic[31:0] a_d1, b_d1;
    logic[31:0] a_d2, b_d2;

    //delay inputs by two cycles
    always_ff @(posedge clk) begin
        a_d1 <= a;
        b_d1 <= b;
        a_d2 <= a_d1;
        b_d2 <= b_d1;
    end

    // check output of ALU
    intial begin
      @(posedge clk);

      repeat (STEPS_addu) begin
          @(posedge clk)
          #1;
          $display("a=%d, b=%d, r=%d",a,b,r);
          assert(r == a_d2+b_d2) else $fatal(2,"Wrong output");
      end
      $finish;
    end


endmodule
