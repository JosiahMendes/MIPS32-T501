module mips_cpu_bus(

    input logic clk,
    input logic reset,

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


    // This wire holds the whole instruction
    logic[32-1:0] instr;

    wire [5:0]  instr_opcode    = instr[31:26]; // This is common to all instruction formats

    // The remaining parts of the instruction depend on the type (R,I,J)

    // R-format instruction sub-sections
    //wire [4:0]  R_instr_rs          = instr[25:21];
    //wire [4:0]  R_instr_rt          = instr[20:16];
    wire [4:0]  R_instr_rd          = instr[15:11];
    wire [4:0]  R_instr_shamt       = instr[10:6];
    wire [5:0]  R_instr_func        = instr[5:0];

    // I-format instruction sub-sections
    //wire [4:0]  I_instr_rs          = instr[25:21];
    wire [4:0]  I_instr_rt          = instr[20:16];
    wire [15:0] I_instr_immediate   = instr[15:0];

    logic [31:0] exImmediate, zeroImmediate;
	 
	logic [4:0] shiftamount;
    

    // J-format instruction sub-sections
    wire [25:0]  J_instr_addr        = instr[25:0];

    // Instruction opcode is enumerated
    typedef enum logic[5:0] {
        OPCODE_ADDIU = 6'b001001,
        OPCODE_ANDI  = 6'b001100,
        OPCODE_ORI    = 6'b001101,
        OPCODE_XORI   = 6'b001110,

        OPCODE_REGIMM = 6'b000001,

        OPCODE_BEQ    = 6'b000100,
        OPCODE_BLEZ   = 6'b000110,
        OPCODE_BGTZ   = 6'b000111,
        OPCODE_BNE    = 6'b000101,
        OPCODE_SLTI   = 6'b001010,
        OPCODE_SLTIU = 6'b001011, 

        OPCODE_LB     = 6'b100000,
        OPCODE_LBU    = 6'b100100,
        OPCODE_LHU    = 6'b100101,
        OPCODE_LH     = 6'b100001,
        OPCODE_LUI    = 6'b001111,
        OPCODE_LW     = 6'b100011,
        OPCODE_LWL    = 6'b100010,
        OPCODE_LWR    = 6'b100110,

        OPCODE_SB     = 6'b101000,
        OPCODE_SH     = 6'b101001,
        OPCODE_SW     = 6'b101011,

        OPCODE_J      = 6'b000010,
        OPCODE_JAL    = 6'b000011,

        OPCODE_R    = 6'b000000

    } opcode_t;

    typedef enum logic[5:0] {
        FUNC_JR = 6'b001000,
        FUNC_JALR = 6'b001001,

        FUNC_ADDU = 6'b100001,
        FUNC_SUBU = 6'b100011,
        FUNC_XOR  = 6'b100110,
        FUNC_AND  = 6'b100100,
        FUNC_OR   = 6'b100101,

        FUNC_DIV  = 6'b011010,
        FUNC_DIVU = 6'b011011,
        FUNC_MULT = 6'b011000,
        FUNC_MULTU= 6'b011001,

        FUNC_MFHI = 6'b010000,
        FUNC_MFLO = 6'b010010,
        FUNC_MTHI = 6'b010001,
        FUNC_MTLO = 6'b010011,

        FUNC_SLT  = 6'b101010,
        FUNC_SLTU = 6'b101011,

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

    typedef enum logic[3:0]{
        ALU_AND = 4'd0,
        ALU_OR =  4'd1,
        ALU_ADD = 4'd2,
        ALU_SUB = 4'd3,
        ALU_SLT = 4'd4,
        ALU_XOR = 4'd5,
        ALU_SLL = 4'd6,
        ALU_SRL = 4'd7,
        ALU_SRA = 4'd8,
        ALU_SLLV = 4'd9,
        ALU_SRLV = 4'd10,
        ALU_SRAV = 4'd11,
        ALU_LUI  = 4'd12,
        ALU_SLTU = 4'd13,
        ALU_A    = 4'd14
    }aluop_t;

    typedef enum logic[4:0]{
        BGEZ  = 5'b00001,
        BGEZAL =5'b10001, //TODO
        BLTZ   =5'b00000,
        BLTZAL =5'b10000 //TODO
    }branchop_t;

    // Statemachine -> MIPS uses a maximum of 5 states. Starting off with decimal state indexes (0-4)
    logic [2:0] state;

    //PC
    logic [31:0] PC, PC_increment, PC_temp;
    assign PC_increment = PC+4;

    //HI LO
    logic[31:0] HI, LO;

    //Register Connections
    logic regReset;
    logic regWriteEn;
    logic [4:0]  regDest;
    logic  [4:0] regRdA,     regRdB;
    reg [31:0] regDestData, regRdDataA, regRdDataB;

    logic regWriteEnable;

    assign regWriteEnable = !(instr_opcode == OPCODE_R && (R_instr_func == FUNC_MTLO ||R_instr_func == FUNC_MTHI
                                                        ||R_instr_func == FUNC_JR ||R_instr_func == FUNC_MULT
                                                        ||R_instr_func == FUNC_MULTU ||R_instr_func == FUNC_DIV
                                                        ||R_instr_func == FUNC_DIVU )
                            ||(instr_opcode == OPCODE_REGIMM && (I_instr_rt == BGEZ || I_instr_rt == BLTZ)) || instr_opcode == OPCODE_J
                            || instr_opcode == OPCODE_BEQ || instr_opcode == OPCODE_BNE|| instr_opcode == OPCODE_BLEZ ||  instr_opcode == OPCODE_BGTZ
                            || instr_opcode == OPCODE_SB || instr_opcode == OPCODE_SH|| instr_opcode == OPCODE_SW
                            || ((instr_opcode == OPCODE_LH||instr_opcode == OPCODE_LHU) &&  ALUOut[0] != 0) 
                            || (instr_opcode == OPCODE_LW && !(ALUOut[0] == 0 && ALUOut[1] == 0)));

    //ALU Connections
    logic [3:0] ALUop;
    logic [31:0] ALUInA, ALUInB;
    reg [31:0] ALUOut;
    reg ALUZero;
    logic [2:0] ALUSrc;
    assign ALUSrc = (instr_opcode == OPCODE_ORI ||  instr_opcode == OPCODE_XORI || instr_opcode == OPCODE_ANDI) ? 2'b00
                    :(instr_opcode == OPCODE_R || instr_opcode == OPCODE_J || instr_opcode == OPCODE_JAL || instr_opcode == OPCODE_BEQ || instr_opcode == OPCODE_BNE || instr_opcode == OPCODE_REGIMM)? 2'b01
                    : 2'b11;
    assign ALUInB = (ALUSrc == 2'b00) ? zeroImmediate
                    :(ALUSrc == 2'b01) ? regRdDataB
                    : exImmediate;
    assign ALUInA = regRdDataA;
    //Multiplier Connections
    reg [63:0] MultOut;
    logic MultSign;

    //Divider Connections
    logic [31:0] DivQuotient, DivRemainder;
    logic DivStart, DivDone, DivDbz, DivReset, DivSign;

    assign DivSign = (instr_opcode == OPCODE_R && R_instr_func == FUNC_DIV) ? 1'b1 :1'b0;


    //Memory Control
    assign address =    (state == INSTR_FETCH) ? PC
                        :(state == MEM && instr_opcode == OPCODE_LWL) ? {ALUOut[31:2],2'd0}
                        : ALUOut;
    assign read =   (state==INSTR_FETCH || (state == MEM &&
                                        (((instr_opcode == OPCODE_LH||instr_opcode == OPCODE_LHU) &&  ALUOut[0] == 0)
                                        ||(instr_opcode == OPCODE_LW && ALUOut[0] == 0 && ALUOut[1] == 0)
                                        ||instr_opcode == OPCODE_LWL||instr_opcode == OPCODE_LWR
                                        ||instr_opcode == OPCODE_LB||instr_opcode == OPCODE_LBU))
                    ) ? 1'b1 : 1'b0;
    assign byteenable = (state==INSTR_FETCH || (state == MEM && (instr_opcode == OPCODE_LW ||  instr_opcode == OPCODE_LWL || instr_opcode == OPCODE_LWR ||instr_opcode == OPCODE_SW))) ? 4'b1111
                        : (state == MEM && (instr_opcode == OPCODE_LB || instr_opcode == OPCODE_LBU || instr_opcode == OPCODE_SB)) ? 4'b0001
                        : (state == MEM && (instr_opcode == OPCODE_LH || instr_opcode == OPCODE_LHU || instr_opcode == OPCODE_SH)) ? 4'b0011
                        : 4'b0000;
    assign write =  (state == MEM &&    (instr_opcode == OPCODE_SW || instr_opcode == OPCODE_SB
                                        ||instr_opcode == OPCODE_SH)
                    ) ? 1'b1 :1'b0;
    assign writedata = regRdDataB;

    //Branch Delay Slot Handling
    logic [2:0] branch;


    // This is the simple state machine. The state switching is just drafted, and will depend on the individual instructions
    always @(posedge clk) begin
        if (reset) begin
            $display("CPU Resetting");
            state <= INSTR_FETCH;
            regReset <= 1;
            PC <= 32'hBFC00000;
            active<=1;
            branch <=0;
            HI <= 0;
            LO <= 0;
            DivReset <=1;
        end
        if (state==INSTR_FETCH) begin
            $display("-------------------------------------------------------------------------------------------------------------PC = %h",PC);
            $display("CPU-FETCH,      Fetching instruction @ %h     branch status is ",address, branch);
            if(address == 32'h00000000) begin
                active <= 0; state<=HALTED;
            end else if(waitrequest) begin
            end else begin state<=INSTR_DECODE; end
            regReset <= 0;
            DivReset <=0;
            regWriteEn<=0;
            
        end
        if (state==INSTR_DECODE) begin
            $display("                                              CPU: Register $v0 contains  %h",register_v0);
            $display("CPU-DECODE      Instruction Fetched is %h,    reading from registers %d and %d ", readdata, readdata[25:21], readdata[20:16] );
            state <= EXEC;
            instr <= readdata;
            regRdA <= readdata[25:21];
            regRdB <= readdata[20:16];
            exImmediate <= {{16{readdata[15]}}, readdata[15:0]};
            zeroImmediate<={16'b0, readdata[15:0]};
            shiftamount <= readdata[10:6];
            ALUop <=  (readdata[31:26] == OPCODE_ANDI    || (readdata[31:26] == OPCODE_R && readdata[5:0] == FUNC_AND)) ? ALU_AND
                    : (readdata[31:26] == OPCODE_ORI   || (readdata[31:26] == OPCODE_R && readdata[5:0] == FUNC_OR)) ? ALU_OR
                    : (readdata[31:26] == OPCODE_XORI  || (readdata[31:26] == OPCODE_R && readdata[5:0] == FUNC_XOR)) ? ALU_XOR
                    : (readdata[31:26] == OPCODE_SLTI  || (readdata[31:26] == OPCODE_R && readdata[5:0] == FUNC_SLT)) ? ALU_SLT
                    : (readdata[31:26] == OPCODE_SLTIU || (readdata[31:26] == OPCODE_R && readdata[5:0] == FUNC_SLTU)) ? ALU_SLTU
                    : (readdata[31:26] == OPCODE_BLEZ  || readdata[31:26] == OPCODE_BGTZ || (readdata[31:26] == OPCODE_REGIMM && (readdata[20:16] == BGEZ || readdata[20:16] == BGEZAL || readdata[20:16] == BLTZ || readdata[20:16] == BLTZAL))) ? ALU_A
                    : (readdata[31:26] == OPCODE_BEQ   || (readdata[31:26] == OPCODE_R && readdata[5:0] == FUNC_SUBU) || readdata[31:26] == OPCODE_BNE ) ? ALU_SUB
                    : (readdata[31:26] == OPCODE_LUI) ? ALU_LUI
                    : (readdata[31:26] == OPCODE_R && readdata[5:0] == FUNC_SRAV) ? ALU_SRAV
                    : (readdata[31:26] == OPCODE_R && readdata[5:0] == FUNC_SRLV) ? ALU_SRLV
                    : (readdata[31:26] == OPCODE_R && readdata[5:0] == FUNC_SLLV) ? ALU_SLLV
                    : (readdata[31:26] == OPCODE_R && readdata[5:0] == FUNC_SRA) ? ALU_SRA
                    : (readdata[31:26] == OPCODE_R && readdata[5:0] == FUNC_SLL) ? ALU_SLL
                    : (readdata[31:26] == OPCODE_R && readdata[5:0] == FUNC_SRL) ? ALU_SRL
                    : (
                        readdata[31:26] == OPCODE_ADDIU || readdata[31:26] == OPCODE_LW  || readdata[31:26] == OPCODE_LB  || readdata[31:26] == OPCODE_LBU 
                        || readdata[31:26] == OPCODE_LH || readdata[31:26] == OPCODE_LHU || readdata[31:26] == OPCODE_LWL || readdata[31:26] == OPCODE_LWR
                        || readdata[31:26] == OPCODE_SW || readdata[31:26] == OPCODE_SH  || readdata[31:26] == OPCODE_SB  || 
                        (
                            readdata[31:26] == OPCODE_R && (readdata[5:0] == FUNC_ADDU || readdata[5:0] == FUNC_MTHI || readdata[5:0] == FUNC_MTLO)
                        )
                    ) ? ALU_ADD 
                    : 4'b1111;

        end
        if (state==EXEC) begin
            $display("CPU-EXEC,       Register %d (ALUInA) = %h,    Register %d (ALUInB0) = %h,     32'Imm (ALUInB1) is %h      shiftamount", regRdA, regRdDataA, regRdB, regRdDataB,exImmediate,R_instr_shamt);
            state <= MEM;
            case (instr_opcode)//Add case statements

                OPCODE_J :begin
                    branch <= 1;
                    PC_temp <= {PC_increment[31:28],J_instr_addr, 2'd0};
                end
                OPCODE_JAL: begin
                    branch <=1;
                    PC_temp <= {PC_increment[31:28],J_instr_addr, 2'd0};
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

                        FUNC_MULT:  begin MultSign <=1;  end
                        FUNC_MULTU: begin MultSign <=0;  end

                        FUNC_DIVU:  begin DivStart <= 1; end
                        FUNC_DIV:   begin DivStart <= 1; end

                        default: begin end
                    endcase
                end
                default: begin end
            endcase
        end
        if (state==MEM) begin
            $display("CPU-DATAMEM     Rd/Wr MemAddr(ALUOut)= %h,    Write data  (ALUInB0) = %h      Mem WriteEn =  %d, ReadEn =%d, ByteEn = %b, DivDone = %b",ALUOut, regRdDataB,write, read, byteenable, DivDbz,DivDone);
            if (waitrequest || (!DivDone && instr_opcode == OPCODE_R && (R_instr_func == FUNC_DIVU||R_instr_func == FUNC_DIV)) ) begin 
                DivStart <=0;
            end
            else begin state <= WRITE_BACK; end

            if(instr_opcode == OPCODE_BEQ && ALUZero) begin 
                branch <= 1;
                PC_temp <= PC_increment + {{14{I_instr_immediate[15]}},I_instr_immediate, 2'd0};
            end else if(instr_opcode == OPCODE_BNE && !ALUZero) begin 
                branch <= 1;
                PC_temp <= PC_increment + {{14{I_instr_immediate[15]}},I_instr_immediate, 2'd0};
            end else if(instr_opcode == OPCODE_BGTZ && ALUOut[31] == 0 && !ALUZero) begin 
                branch <= 1;
                PC_temp <= PC_increment + {{14{I_instr_immediate[15]}},I_instr_immediate, 2'd0};
            end else if(instr_opcode == OPCODE_BLEZ && (ALUOut[31] == 1 || ALUZero)) begin
                branch <= 1;
                PC_temp <= PC_increment + {{14{I_instr_immediate[15]}},I_instr_immediate, 2'd0};
            end else if(instr_opcode == OPCODE_REGIMM) begin
                if((I_instr_rt == BGEZ || I_instr_rt == BGEZAL) && ALUOut[31] == 0)begin
                    branch <= 1;
                    PC_temp <= PC_increment + {{14{I_instr_immediate[15]}},I_instr_immediate, 2'd0};
                end else if((I_instr_rt == BLTZ || I_instr_rt == BLTZAL) && ALUOut[31] == 1)begin
                    branch <= 1;
                    PC_temp <= PC_increment + {{14{I_instr_immediate[15]}},I_instr_immediate, 2'd0};
                end
            end
        end
        if (state==WRITE_BACK) begin
            $display("CPU-WRITEBACK   Retrieved Memory     = %h,    Current ALUOut     =    %h,     Writing to Register %d..., HI = %h, LO = %h" ,readdata, ALUOut, I_instr_rt, HI, LO);
            state <= INSTR_FETCH;
            regDest <= (instr_opcode == OPCODE_JAL || (instr_opcode == OPCODE_R && R_instr_func == FUNC_JALR && R_instr_rd == 0)||(instr_opcode == OPCODE_REGIMM && (I_instr_rt == BLTZAL || I_instr_rt == BGEZAL) )) ? 5'd31
                        :(instr_opcode == OPCODE_R) ? R_instr_rd
                        :I_instr_rt;
            regDestData <=  (instr_opcode == OPCODE_LB)   ? {{24{readdata[7]}},readdata[7:0]}
                            :(instr_opcode == OPCODE_LBU) ? {{24'd0,readdata[7:0]}}
                            :(instr_opcode == OPCODE_LH)  ? {{16{readdata[15]}},readdata[15:0]}
                            :(instr_opcode == OPCODE_LHU) ? {{16'd0,readdata[15:0]}}
                            :(instr_opcode == OPCODE_LW)  ? readdata
                            :(instr_opcode == OPCODE_LWL && ALUOut[1:0] == 0) ? {readdata[7:0],regRdDataB[23:0]}
                            :(instr_opcode == OPCODE_LWL && ALUOut[1:0] == 1) ? {readdata[15:0],regRdDataB[15:0]}
                            :(instr_opcode == OPCODE_LWL && ALUOut[1:0] == 2) ? {readdata[23:0],regRdDataB[7:0]}
                            :(instr_opcode == OPCODE_LWL && ALUOut[1:0] == 3) ? readdata
                            :(instr_opcode == OPCODE_LWR && ALUOut[1:0] == 0) ? readdata
                            :(instr_opcode == OPCODE_LWR && ALUOut[1:0] == 1) ? {regRdDataB[31:24],readdata[31:8]}
                            :(instr_opcode == OPCODE_LWR && ALUOut[1:0] == 2) ? {regRdDataB[31:16],readdata[31:16]}
                            :(instr_opcode == OPCODE_LWR && ALUOut[1:0] == 3) ? {regRdDataB[31:8],readdata[31:24]}
                            :(instr_opcode == OPCODE_JAL||(instr_opcode == OPCODE_R && R_instr_func == FUNC_JALR ||(instr_opcode == OPCODE_REGIMM && (I_instr_rt == BLTZAL || I_instr_rt == BGEZAL) ))) ? PC+8
                            :(instr_opcode == OPCODE_R && R_instr_func == FUNC_MFHI) ? HI
                            :(instr_opcode == OPCODE_R && R_instr_func == FUNC_MFLO) ? LO
                            :ALUOut;
            regWriteEn<= (regWriteEnable) ? 1'b1 : 1'b0;
            if(instr_opcode == OPCODE_R && (R_instr_func == FUNC_MULT || R_instr_func == FUNC_MULTU)) begin
                HI <= MultOut[63:32];
                LO <= MultOut[31:0];
            end else if(instr_opcode == OPCODE_R && R_instr_func == FUNC_MTHI)  begin
                HI <= ALUOut;
            end else if(instr_opcode == OPCODE_R && R_instr_func == FUNC_MTLO)  begin
                LO <= ALUOut;
            end else if(instr_opcode == OPCODE_R && (R_instr_func == FUNC_DIV || R_instr_func == FUNC_DIVU)) begin
                HI <= DivRemainder;
                LO <= DivQuotient;
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
        end
        if(state == HALTED)begin
            $display("CPU HALTED");
        end
    end

    mips_cpu_registers registerInst(
        .clk(clk), .write(regWriteEn), .reset(regReset),
        .wrAddr(regDest), .wrData(regDestData),
        .rdAddrA(readdata[25:21]), .rdDataA(regRdDataA),
        .rdAddrB(readdata[20:16]), .rdDataB(regRdDataB),
        .register_v0(register_v0)
    );
    mips_cpu_ALU ALUInst(
        .op(ALUop), .a(ALUInA), .b(ALUInB),
        .result(ALUOut), .zero(ALUZero), .sa(shiftamount), .clk(clk)
    );
    mips_cpu_multiplier MultInst(
        .a(regRdDataA), .b(regRdDataB), .out(MultOut), .sign(MultSign), .clk(clk)
    );
    mips_cpu_divider DivInst(
        .clk(clk), .start(DivStart), .sign(DivSign),
        .Dividend(regRdDataA), .Divisor(regRdDataB), 
        .Quotient(DivQuotient), .Remainder(DivRemainder), 
        .done(DivDone), .dbz(DivDbz), .reset(DivReset)
    );

endmodule