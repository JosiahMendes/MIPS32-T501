module mips_cpu_bus_tb_memory
    (
        input logic clk,
        input logic read,
        input logic write,

        input logic [3:0] byteenable,
        input logic [15:0] addr,
        input logic [31:0] writedata,

        output logic waitrequest,
        output logic [31:0] readdata
    );

    timeunit 1ns/100ps;
    parameter RAM_INIT_FILE ="";

    reg[7:0] memory [0:32767];

    initial begin
        integer i;
        for (i = 0; i<32768; i++)begin
            memory[i] = 0;
        end
        if (RAM_INIT_FILE != "") begin
            $display("RAM : INIT : Loading RAM contents from %s", RAM_INIT_FILE);
            $readmemh(RAM_INIT_FILE, memory);
        end
    end

    always @(posedge clk) begin
        if(write && !read) begin
            $display("Writing %h to Memory Address %h", writedata, addr);
            readdata <= 32'bx;
            case(byteenable)
                4'b1111: begin
                    memory[addr]<=writedata[7:0];
                    memory[addr+1]<=writedata[15:8];
                    memory[addr+2]<=writedata[23:16];
                    memory[addr+3]<=writedata[31:24];
                end
                4'b0011: begin
                    memory[addr]<=writedata[7:0];
                    memory[addr+1]<=writedata[15:8];
                end
                4'b1100: begin
                    memory[addr]<=writedata[23:16];
                    memory[addr+1]<=writedata[31:24];
                end
                4'b0001:begin
                    memory[addr]<=writedata[7:0];
                end
                4'b0010:begin
                    memory[addr]<=writedata[15:8];
                end
                4'b0100:begin
                    memory[addr]<=writedata[23:16];
                end
                4'b1000:begin
                    memory[addr]<=writedata[31:24];
                end
                default: begin 
                end
            endcase
        end else if(read && !write)begin
            case(byteenable)
                4'b1111: begin
                    readdata[7:0]<=memory[addr];
                    readdata[15:8]<=memory[addr+1];
                    readdata[23:16]<=memory[addr+2];
                    readdata[31:24]<=memory[addr+3];
                end
                4'b0011: begin
                    readdata[7:0]<=memory[addr];
                    readdata[15:8]<=memory[addr+1];
                    readdata[31:16]<=0;
                end
                4'b1100: begin
                    readdata[23:16]<=memory[addr+2];
                    readdata[31:24]<=memory[addr+3];
                    readdata[15:0]<=0;
                end
                4'b0001:begin
                     readdata[7:0]<=memory[addr];
                     readdata[31:8]<=0;
                end
                4'b0010:begin
                    readdata[7:0]<=0;
                    readdata[15:8]<=memory[addr+1];
                    readdata[31:16]<=0;
                end
                4'b0100:begin
                    readdata[15:0]<=0;
                    readdata[23:16]<=memory[addr+2];
                    readdata[31:8]<=0;
                end
                4'b1000:begin
                    readdata[31:24]<=memory[addr+3];
                    readdata[23:0]<=0;
                end
                default: begin
                end
                endcase 
        end else begin
            readdata <= 32'bx;
        end

    end
endmodule