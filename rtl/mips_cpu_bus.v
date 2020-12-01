module cpu_bus(

    input logic clk,
    input logic rst,

    output logic active,
    output logic[31:0] register_v0,

    /* Avalon memory mapped bus controller (master) */
    output logic[31:0] address,
    output logic write,
    output logic read,
    input logic waitrequest,
    output logic[31:0] writedata,
    output logic[3:0] byteenable,
    input logic[31:0] readdata
);
        timeunit 1ns / 10ps;

    // This wire holds the whole instruction
    logic[32-1:0] instr;

    wire [5:0]  instr_opcode    = instr[31:26]; // This is common to all instruction formats

    // The remaining parts of the instruction depend on the type (R,I,J)

    // R-format instruction sub-sections
    wire [4:0]  R_instr_rs          = instr[25:21];
    wire [4:0]  R_instr_rt          = instr[20:16];
    wire [4:0]  R_instr_rd          = instr[15:11];
    wire [4:0]  R_instr_shamt       = instr[10:6];
    wire [5:0]  R_instr_func        = instr[5:0];

    // I-format instruction sub-sections
    wire [4:0]  I_instr_rs          = instr[25:21];
    wire [4:0]  I_instr_rt          = instr[20:16];
    wire [15:0] I_instr_immediate   = instr[15:0];

    // J-format instruction sub-sections
    wire [25:0]  J_instr_addr        = instr[25:0];

    // Instruction opcode is enumerated
    typedef enum logic[8-1:0] {
        OPCODE_ADDIU = 8'b001001,
        OPCODE_JR = 8'b000000,
        OPCODE_LW = 8'b100011
        // ... rest added here
    } opcode_t;

    typedef enum logic[2:0] {
        INSTR_FETCH = 3'b000,
        INSTR_DECODE = 3'b001,
        EXEC         = 3'b010,
        MEM          = 3'b011,
        WRITE_BACK   = 3'b100
    } state_t;

    // Statemachine -> MIPS uses a maximum of 5 states. Starting off with decimal state indexes (0-4)
    logic [2:0] state;

    //PC
    logic [31:0] PC, PC_increment;
    assign PC_increment = PC+4;

    //HI LO
    logic[31:0] HI, LO;

    //Register Connections
    logic regReset;
    logic regWriteEn;
    logic [4:0]  regDest,     regRdA,     regRdB;
    logic [31:0] regDestData, regRdDataA, regRdDataB;

    //ALU Connections
    logic [3:0] ALUop;
    logic [31:0] ALUInA, ALUInB, ALUOut;
    logic ALUZero;

    //reg [31:0] ALUTemp;

    //Memory Control
    assign address = (state == INSTR_FETCH) ? PC : ALUOut;
    assign read = (state==INSTR_FETCH) ? 1 :0;
    assign byteenable = 4'b1111;
    assign write = 0;

 

    
    // This is the simple state machine. The state switching is just drafted, and will depend on the individual instructions
    always @(posedge clk) begin
        if (rst) begin
            $display("CPU Resetting");
            state <= INSTR_FETCH;
            regReset <= 1;
            PC <= 32'hBFC00000;
            active<=1;
        end
        if (state==INSTR_FETCH) begin
            $display("CPU 1, fetching instruction @ %h",address);
            state <= INSTR_DECODE;
            if(address == 32'hbfc00004) begin active <= 0; end
            regReset <= 0;

        end
        if (state==INSTR_DECODE) begin
            $display("CPU 2 input= %h, reading from reg %h", readdata, I_instr_rs);
            state <= EXEC;
            regRdA <= readdata[25:21];
            regRdB<=0;
            instr <= readdata;
            
        end
        if (state==EXEC) begin
            $display("CPU 3, regA out=%h, regB out = %h", regRdDataA, regRdDataB);
            state <= MEM;
            ALUop <= 4'd2;
            ALUInA <= regRdDataA;
            ALUInB <= I_instr_immediate[15] ? {16'hFFFF, I_instr_immediate} : {16'h0000,I_instr_immediate};
            PC<=PC_increment;
        end
        if (state==MEM) begin
            $display("CPU 4 ALUa = %h, ALUb= %h, instr_im =%h, ALUOut = %h, lol",ALUInA, ALUInB, I_instr_immediate, ALUOut);
            state <= WRITE_BACK;
        end
        if (state==WRITE_BACK) begin
            $display("CPU 5 ALUOut = %h, rs = %d, trying to write to %d" ,ALUOut, I_instr_rt,regDest);
            state <= INSTR_FETCH;
            regDest <= I_instr_rt;
            regDestData<=ALUOut;
            regWriteEn<=1;
        end
    end

    mips_cpu_registers registerInst(
        .clk(clk), .write(regWriteEn), .reset(regReset),
        .wrAddr(regDest), .wrData(regDestData),
        .rdAddrA(regRdA), .rdDataA(regRdDataA),
        .rdAddrB(regRdB), .rdDataB(regRdDataB),
        .register_v0(register_v0)
    );
    mips_cpu_ALU ALUInst(
        .op(ALUop), .a(ALUInA), .b(ALUInB),
        .result(ALUOut), .zero(ALUZero)
    );

endmodule