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

    logic [31:0] exImmediate;
    assign exImmediate = {{16{I_instr_immediate[15]}}, I_instr_immediate};

    // J-format instruction sub-sections
    wire [25:0]  J_instr_addr        = instr[25:0];

    // Instruction opcode is enumerated
    typedef enum logic[7:0] {
        OPCODE_ADDIU = 8'b001001,
        OPCODE_R    = 8'b000000,
        OPCODE_LW    = 8'b100011,
        OPCODE_SW    = 8'b101011
        // ... rest added here
    } opcode_t;

    typedef enum logic[7:0] {
        FUNC_JR = 8'b001000,
        FUNC_SLL = 8'b00000
        // ... rest added here
    } func_t;

    typedef enum logic[2:0] {
        INSTR_FETCH = 3'b000,
        INSTR_DECODE = 3'b001,
        EXEC         = 3'b010,
        MEM          = 3'b011,
        WRITE_BACK   = 3'b100,
        HALTED       = 3'b111
    } state_t;

    // Statemachine -> MIPS uses a maximum of 5 states. Starting off with decimal state indexes (0-4)
    logic [2:0] state;
    logic active_next = 1;

    //PC
    logic [31:0] PC, PC_increment, PC_temp;
    assign PC_increment = PC+4;

    //HI LO
    logic[31:0] HI, LO;

    //Register Connections
    logic regReset;
    logic regWriteEn;
    logic [4:0]  regDest,     regRdA,     regRdB;
    logic [31:0] regDestData, regRdDataA, regRdDataB;

    logic regDestDataSel;

    //ALU Connections
    logic [4:0] ALUop;
    logic [31:0] ALUInA, ALUInB, ALUOut;
    logic ALUZero;
    logic ALUSrc;
    assign ALUSrc = (instr_opcode == OPCODE_ADDIU) ? 1:0;

    //Sign Extender
    logic [15:0] unextended;
    logic [31:0] extended;


    //Memory Control
    assign address = (state == INSTR_FETCH) ? PC : ALUOut;
    assign read = (state==INSTR_FETCH || (state == MEM && instr_opcode == OPCODE_LW)) ? 1 :0;
    assign byteenable = 4'b1111;//TODO Temp
    assign write = (state == MEM && instr_opcode == OPCODE_SW) ? 1 :0; //TODO Temp
    assign regDestDataSel = (instr_opcode == OPCODE_LW) ? 1 :0;

    //Branch Delay Slot Handling
    logic [2:0] branch;

    
    // This is the simple state machine. The state switching is just drafted, and will depend on the individual instructions
    always @(posedge clk) begin
        if (rst) begin
            $display("CPU Resetting");
            state <= INSTR_FETCH;
            regReset <= 1;
            PC <= 32'hBFC00000;
            active<=1;
            branch <=0;
        end
        if (state==INSTR_FETCH) begin
            $display("-------------------------------------------------------------------------------------------------------------PC = %h",PC);
            $display("CPU-FETCH,      Fetching instruction @ %h     branch status is ",address, branch);
            //state<=INSTR_DECODE;
            if(address == 32'h00000000) begin 
                active <= 0; state<=HALTED;
            end else begin state<=INSTR_DECODE; end
            regReset <= 0;
            regWriteEn<=0;
        end
        if (state==INSTR_DECODE) begin
            $display("                                              CPU: Register $v0 contains  %h",register_v0);
            $display("CPU-DECODE      Instruction Fetched is %h,    reading from registers %d and %d ", readdata, readdata[25:21], readdata[20:16] );
            state <= EXEC;
            regRdA <= readdata[25:21];
            regRdB <= readdata[20:16];
            instr <= readdata;
            //Done
        end
        if (state==EXEC) begin
            $display("CPU-EXEC,       Register %d (ALUInA) = %h,    Register %d (ALUInB0) = %h,     32'Imm (ALUInB1) is %h      shiftamount", regRdA, regRdDataA, regRdB, regRdDataB,exImmediate,R_instr_shamt);
            state <= MEM;
            ALUInA <= regRdDataA;
            ALUInB <= (ALUSrc) ? {{16{I_instr_immediate[15]}}, I_instr_immediate} : regRdDataB;
            case (instr_opcode)//Add case statements
                OPCODE_ADDIU: begin
                    ALUop <= 5'd2;
                end
                OPCODE_LW: begin
                    ALUop <= 5'd2;
                end
                OPCODE_SW: begin
                    ALUop <= 5'd2;
                    //just checking if my setup works ~M
                end
                OPCODE_R: begin
                    case(R_instr_func)
                        FUNC_JR: begin
                            branch <= 1;
                            PC_temp<=regRdDataA;
                        end
                        FUNC_SLL:begin
                            ALUop<=5'd6;
                        end
                    endcase
                end
            endcase
        end
        if (state==MEM) begin
            $display("CPU-DATAMEM     Rd/Wr MemAddr(ALUOut)= %h,    Write data  (ALUInB0) = %h      Mem WriteEn =  %d, ReadEn =%d",ALUOut, regRdDataB,write, read );
            state <= WRITE_BACK;
            //Done
        end
        if (state==WRITE_BACK) begin
            $display("CPU-WRITEBACK   Retrieved Memory     = %h,    Current ALUOut     =    %h,     Writing to Register %d..." ,readdata, ALUOut, I_instr_rt);
            state <= INSTR_FETCH;
            regDest <= I_instr_rt;
            regDestData <= (regDestDataSel) ? readdata : ALUOut;
            regWriteEn<=1;
            if (branch == 1) begin
                branch <=2;
                PC <= PC_increment;
            end else if (branch == 2)begin
                branch <= 0;
                PC<= PC_temp;
            end else begin
                branch <= 0;
                PC <= PC_increment;
            end 
            //Done
        end
        if(state == HALTED)begin
            $display("CPU HALTED");
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
        .result(ALUOut), .zero(ALUZero), .sa(R_instr_shamt)
    );

endmodule