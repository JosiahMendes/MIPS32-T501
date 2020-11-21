module cpu_bus (
    input logic clk;
    input logic rst;

    output logic active;
    output logic[31:0] register_v0;

    /* Avalon memory mapped bus controller (master) */
    output logic[31:0] address,
    output logic write,
    output logic read,
    input logic waitrequest,
    output logic[31:0] writedata,
    output logic[3:0] byteenable,
    input logic[31:0] readdata
);