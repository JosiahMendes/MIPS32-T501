`timescale 1ns/100ps

module mips_cpu_registers
    (
        input logic clk,
        input logic write,
        input logic reset,
        input logic [4:0] wrAddr,
        input logic [31:0] wrData,

        input logic [4:0] rdAddrA,
        output logic [31:0] rdDataA,

        input logic [4:0] rdAddrB,
        output logic [31:0] rdDataB,

        output logic [31:0] register_v0
    );

    reg [31:0] Register[0:31]; //declare 32 registers 32 bits wide

    assign rdDataA = (reset == 1) ? 0 : Register[rdAddrA]; //combinatorial read
    assign rdDataB = (reset == 1) ? 0 : Register[rdAddrB];
    assign register_v0 = Register[2];  // combinatorially puts register_v0 into an outputable entity

    initial begin
        Register[0] <= 0; //ensure that zero register is hardcoded to 0
    end

    integer i;
    always_ff@(posedge clk) begin
        if(reset) begin
            for( i = 0; i<32; i= i+1)begin
                Register[i] = 0; //set all registers to 0 when reset.
            end
        end else if (write && wrAddr == 0) begin // do nothing if attempt to write to 0 register
        end else if(write) begin
            Register[wrAddr] <= wrData; //write data to specified register.
        end
    end
endmodule
