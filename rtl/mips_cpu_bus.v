module mips_cpu_bus(

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
    typedef enum logic[5:0] {
        OPCODE_ADDIU = 6'b001001,
        OPCODE_ANDI  = 6'b001100,
        OPCODE_ORI    = 6'b001101,
        OPCODE_XORI   = 6'b001110,

        OPCODE_BEQ    = 6'b000100,//TODO
        //OPCODE_BGEZ   = 6'b000001,//TODO
        //OPCODE_BGEZAL = 6'b000001,//TODO
        OPCODE_BLEZ   = 6'b000110,//TODO
        OPCODE_BGTZ   = 6'b000111,
        //OPCODE_BLTZ   = 6'b000001,//TODO
        //OPCODE_BLTZAL = 6'b000001,//TODO
        OPCODE_BNE    = 6'b000101,//TODO
        OPCODE_SLTI   = 6'b001010,//TODO

        OPCODE_LB     = 6'b100000,//TODO
        OPCODE_LBU    = 6'b100100,//TODO
        OPCODE_LHU    = 6'b100101,//TODO
        OPCODE_LH     = 6'b100001,
        OPCODE_LUI    = 6'b001111,//TODO
        OPCODE_LW     = 6'b100011,//TODO
        OPCODE_LWL    = 6'b100010,//TODO
        OPCODE_LWR    = 6'b100110,//TODO

        OPCODE_SB     = 6'b101000,//TODO
        OPCODE_SH     = 6'b101001,//TODO
        OPCODE_SW     = 6'b101011,//TODO

        OPCODE_J      = 6'b000010,//TODO
        OPCODE_JAL    = 6'b000011,//TODO

        OPCODE_R    = 6'b000000

    } opcode_t;

    typedef enum logic[5:0] {
        FUNC_JR = 6'b001000,
        FUNC_JALR = 6'b001001,//TODO

        FUNC_ADDU = 6'b100001,
        FUNC_SUBU = 6'b100011,
        FUNC_XOR  = 6'b100110,
        FUNC_AND  = 6'b100100,
        FUNC_OR   = 6'b100101,

        FUNC_DIV  = 6'b011010,//TODO
        FUNC_DIVU = 6'b011011,//TODO
        FUNC_MULT = 6'b011000,//TODO
        FUNC_MULTU= 6'b011001,//TODO

        FUNC_MFHI = 6'b010000,//TODO
        FUNC_MFLO = 6'b010010,//TODO
        FUNC_MTHI = 6'b010001,//TODO
        FUNC_MTLO = 6'b010011,//TODO

        FUNC_SLT  = 6'b101010,//TODO
        FUNC_SLTU = 6'b101011,//TODO

        FUNC_SLL  = 6'b000000,
        FUNC_SLLV = 6'b000100,
        FUNC_SRA  = 6'b000011,
        FUNC_SRAV = 6'b000111,
        FUNC_SRL  = 6'b000010,
        FUNC_SRLV = 6'b000110

    } func_t;

    typedef enum logic[2:0] {
        INSTR_FETCH = 3'b000,
        INSTR_DECODE = 3'b001,
        EXEC         = 3'b010,
        MEM          = 3'b011,
        WRITE_BACK   = 3'b100,
        HALTED       = 3'b111
    } state_t;

    typedef enum logic[4:0]{
        ALU_AND = 5'd0,
        ALU_OR = 5'd1,
        ALU_ADD = 5'd2,
        ALU_SUB = 5'd3,
        ALU_SLT = 5'd4,
        ALU_XOR = 5'd5,
        ALU_SLL = 5'd6,
        ALU_SRL = 5'd7,
        ALU_SRA = 5'd8,
        ALU_SLLV = 5'd9,
        ALU_SRLV = 5'd10,
        ALU_SRAV = 5'd11,
        ALU_LUI  = 5'd12
    }aluop_t;

    // Statemachine -> MIPS uses a maximum of 5 states. Starting off with decimal state indexes (0-4)
    logic [2:0] state;
    logic active_next = 1;

    //PC
    logic [31:0] PC, PC_increment, PC_temp, PC_link;
    assign PC_increment = PC+4;
    assign PC_link = PC+8;

    //HI LO
    logic[31:0] HI, LO;

    //Register Connections
    logic regReset;
    logic regWriteEn;
    logic [4:0]  regDest,     regRdA,     regRdB;
    logic [31:0] regDestData, regRdDataA, regRdDataB;

    logic regWriteEnable;
    logic [2:0] regDestDataSel;

    assign regDestDataSel = (instr_opcode == OPCODE_LWR||instr_opcode == OPCODE_LHU
                            ||instr_opcode == OPCODE_LBU||instr_opcode == OPCODE_LW
                            ||instr_opcode == OPCODE_LWL||instr_opcode == OPCODE_LH
                            ||instr_opcode == OPCODE_LB) ? 1 :0;

    assign regWriteEnable = !(instr_opcode == OPCODE_R && (R_instr_func == FUNC_MTLO ||R_instr_func == FUNC_MTHI 
                                                        ||R_instr_func == FUNC_JR ||R_instr_func == FUNC_MULT 
                                                        ||R_instr_func == FUNC_MULTU ||R_instr_func == FUNC_DIV 
                                                        ||R_instr_func == FUNC_DIVU ) 
                                                        || instr_opcode == 6'b000001 || instr_opcode == OPCODE_J 
                                                        || instr_opcode == OPCODE_BEQ || instr_opcode == OPCODE_BNE 
                                                        || instr_opcode == OPCODE_BLEZ ||  instr_opcode == OPCODE_BGTZ 
                                                        || instr_opcode == OPCODE_SB || instr_opcode == OPCODE_SH 
                                                        || instr_opcode == OPCODE_SW);

    //ALU Connections
    logic [4:0] ALUop;
    logic [31:0] ALUInA, ALUInB, ALUOut;
    logic ALUZero;
    logic ALUSrc;
    assign ALUSrc = (instr_opcode == OPCODE_R || instr_opcode == OPCODE_J || instr_opcode == OPCODE_JAL)? 0:1;

    //Multiplier Connections
    logic [63:0] MultOut;
    logic MultSign;

    //Sign Extender
    logic [15:0] unextended;
    logic [31:0] extended;


    //Memory Control
    assign address = (state == INSTR_FETCH) ? PC : ALUOut;
    assign read =   (state==INSTR_FETCH || (state == MEM && 
                                        (instr_opcode == OPCODE_LWR||instr_opcode == OPCODE_LHU
                                        ||instr_opcode == OPCODE_LBU||instr_opcode == OPCODE_LW
                                        ||instr_opcode == OPCODE_LWL||instr_opcode == OPCODE_LH
                                        ||instr_opcode == OPCODE_LB))
                    ) ? 1 : 0;
    assign byteenable = (state==INSTR_FETCH || (state == MEM && (instr_opcode == OPCODE_LW || instr_opcode == OPCODE_SW))) ? 4'b1111 
                        : (state == MEM && (instr_opcode == OPCODE_LB || instr_opcode == OPCODE_LBU || instr_opcode == OPCODE_SB)) ? 4'b0001
                        : (state == MEM && (instr_opcode == OPCODE_LH || instr_opcode == OPCODE_LHU || instr_opcode == OPCODE_SH)) ? 4'b0011
                        : 4'b0000;//TODO Temp
    assign write =  (state == MEM &&    (instr_opcode == OPCODE_SW || instr_opcode == OPCODE_SB
                                        ||instr_opcode == OPCODE_SH)
                    ) ? 1 :0; //TODO Temp
    assign writedata = regRdDataB;

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
            HI <= 0;
            LO <= 0;
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
                    ALUop <= ALU_ADD;
                end
                OPCODE_ANDI:begin
                    ALUop<=ALU_AND;
                end
                OPCODE_ORI:begin
                    ALUop<=ALU_OR;
                end
                OPCODE_XORI: begin
                    ALUop<=ALU_XOR;
                end

                OPCODE_LW: begin
                    ALUop <= ALU_ADD;
                end
                OPCODE_LB: begin
                    ALUop <= ALU_ADD;
                end
                OPCODE_LBU: begin
                    ALUop <= ALU_ADD;
                end
                OPCODE_LH: begin
                    ALUop <= ALU_ADD;
                end
                OPCODE_LHU: begin
                    ALUop <= ALU_ADD;
                end
                OPCODE_LUI: begin
                    ALUop <=ALU_LUI;
                end

                OPCODE_SW: begin
                    ALUop <= ALU_ADD;
                end
                OPCODE_SH: begin
                    ALUop <= ALU_ADD;
                end
                OPCODE_SB: begin
                    ALUop <= ALU_ADD;
                end

                OPCODE_J :begin
                    branch <= 1;
                    PC_temp <= {PC[31:28],J_instr_addr, 2'd0};
                end
                OPCODE_JAL: begin
                    branch <=1;
                    PC_temp <= {PC[31:28],J_instr_addr, 2'd0};
                end
                OPCODE_R: begin
                    case(R_instr_func)
                        FUNC_JR: begin
                            branch <= 1;
                            PC_temp<=regRdDataA;
                        end
                        FUNC_JALR:begin
                            branch <=1;
                            PC_temp<=regRdDataA;
                        end

                        FUNC_SLL:begin
                            ALUop<=ALU_SLL;
                        end
                        FUNC_SRL: begin
                            ALUop<=ALU_SRL;
                        end
                        FUNC_SRA: begin
                            ALUop<=ALU_SRA;
                        end
                        FUNC_SLLV: begin
                            ALUop <= ALU_SLLV;
                        end
                        FUNC_SRLV: begin
                            ALUop <= ALU_SRLV;
                        end
                        FUNC_SRAV: begin
                            ALUop <= ALU_SRAV;
                        end

                        FUNC_ADDU:begin
                            ALUop<=ALU_ADD;
                        end
                        FUNC_SUBU:begin
                            ALUop<=ALU_SUB;
                        end
                        FUNC_XOR:begin
                            ALUop<=ALU_XOR;
                        end
                        FUNC_AND: begin
                            ALUop <=ALU_AND;
                        end
                        FUNC_OR: begin
                            ALUop <= ALU_OR;
                        end
                        FUNC_MULT: begin
                            MultSign <=1;
                        end
                        FUNC_MULTU: begin
                            MultSign <=0;
                        end

                        FUNC_MTHI: begin
                            ALUop <= ALU_ADD;
                        end
                        FUNC_MTLO: begin
                            ALUop <= ALU_ADD;
                        end

                    endcase
                end
            endcase
        end
        if (state==MEM) begin
            $display("CPU-DATAMEM     Rd/Wr MemAddr(ALUOut)= %h,    Write data  (ALUInB0) = %h      Mem WriteEn =  %d, ReadEn =%d, ByteEn = %b, Mult = %h",ALUOut, regRdDataB,write, read, byteenable, MultOut);
            state <= WRITE_BACK;
            //Done
        end
        if (state==WRITE_BACK) begin
            $display("CPU-WRITEBACK   Retrieved Memory     = %h,    Current ALUOut     =    %h,     Writing to Register %d..., HI = %h, LO = %h" ,readdata, ALUOut, I_instr_rt, HI, LO);
            state <= INSTR_FETCH;
            regDest <= (instr_opcode == OPCODE_JAL || (instr_opcode == OPCODE_R && R_instr_func == FUNC_JALR && R_instr_rd == 0)) ? 5'd31
                        :(instr_opcode == OPCODE_R) ? R_instr_rd
                        :I_instr_rt;
            regDestData <=  (instr_opcode == OPCODE_LB)   ? {{24{readdata[7]}},readdata[7:0]} 
                            :(instr_opcode == OPCODE_LBU) ? {{24'd0,readdata[7:0]}}
                            :(instr_opcode == OPCODE_LH)  ? {{16{readdata[15]}},readdata[15:0]}
                            :(instr_opcode == OPCODE_LHU) ? {{16'd0,readdata[15:0]}} 
                            :(instr_opcode == OPCODE_LW)  ? readdata
                            :(instr_opcode == OPCODE_JAL||(instr_opcode == OPCODE_R && R_instr_func == FUNC_JALR)) ? PC+8
                            :(instr_opcode == OPCODE_R && R_instr_func == FUNC_MFHI) ? HI
                            :(instr_opcode == OPCODE_R && R_instr_func == FUNC_MFLO) ? LO
                            :ALUOut;
            regWriteEn<= (regWriteEnable) ? 1 : 0;
            if(instr_opcode == OPCODE_R && (R_instr_func == FUNC_MULT || R_instr_func == FUNC_MULTU)) begin
                HI <= MultOut[63:32];
                LO <= MultOut[31:0];
            end else if(instr_opcode == OPCODE_R && R_instr_func == FUNC_MTHI)  begin
                HI <= ALUOut;
            end else if(instr_opcode == OPCODE_R && R_instr_func == FUNC_MTLO)  begin
                LO <= ALUOut;
            end
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
    mips_cpu_multiplier MultInst(
        .a(ALUInA), .b(ALUInB), .out(MultOut), .sign(MultSign)
    );

endmodule
