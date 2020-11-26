module mips_cpu_memory_bus
    (
        input logic clk,
        input logic read,
        input logic write,

        input logic [3:0] byteenable,
        input logic [31:0] address,
        input logic [31:0] writedata,

        output logic waitrequest,
        output logic [31:0] readdata
    );

    timeunit 1ns/10ps;
    parameter RAM_INIT_FILE ="";

    reg[7:0] memory [4294967295:0];

    initial begin
        integer i;
        for (i = 0; i<4294967296; i++)begin
            memory[i] = 0;
        end
        if (RAM_INIT_FILE != "") begin
            $display("RAM : INIT : Loading RAM contents from %s", RAM_INIT_FILE);
            $readmemh(RAM_INIT_FILE, memory);
        end
    end


    always_ff @(posedge clk) begin
        if(write) begin
            case(byteenable)
                4'b1111: begin
                    memory[addr]<=writedata[0:7];
                    memory[addr+1]<=writedata[8:15];
                    memory[addr+2]<=writedata[16:23];
                    memory[addr+3]<=writedata[24:31];
                end
                4'b0011: begin
                    memory[addr]<=writedata[0:7];
                    memory[addr+1]<=writedata[8:15];
                end
                4'b1100: begin
                    memory[addr+2]<=writedata[0:7];
                    memory[addr+3]<=writedata[8:15];
                end
                4'b0001:begin
                    memory[addr]<=writedata[0:7];
                end
                4'b0010:begin
                    memory[addr+1]<=writedata[0:7];
                end
                4'b0100:begin
                    memory[addr+2]<=writedata[0:7];
                end
                4'b1000:begin
                    memory[addr+3]<=writedata[0:7];
                end
                default: begin 
                end
            endcase
        end
        if(read)begin
            case(byteenable)
                4'b1111: begin
                    readdata[0:7]<=memory[addr];
                    readdata[8:15]<=memory[addr+1];
                    readdata[16:23]<=memory[addr+2];
                    readdata[24:31]<=memory[addr+3];
                end
                4'b0011: begin
                    memory[addr]<=writedata[0:7];
                    memory[addr+1]<=writedata[8:15];
                end
                4'b1100: begin
                    memory[addr]<=writedata[16:23];
                    memory[addr+1]<=writedata[24:31];
                end
                4'b0001:begin
                    memory[addr]<=writedata[0:7];
                end
                4'b0010:begin
                    memory[addr]<=writedata[8:15];
                end
                4'b0100:begin
                    memory[addr]<=writedata[16:23];
                end
                4'b1000:begin
                    memory[addr]<=writedata[24:31];
                end
                default: begin
                end
                endcase 
        end
    end
endmodule