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

    // Statemachine -> MIPS uses a maximum of 5 states. Starting off with decimal state indexes (0-4)
    logic [2:0] state;

    // This is the simple state machine. The state switching is just drafted, and will depend on the individual instructions
    always @(posedge clk) begin
        if (rst) begin
            state <= 4'd0;
        end
        if (state==4'd0) begin
            state <= 4'd1;
        end
        if (state==4'd1) begin
            state <= 4'd2;
        end
        if (state==4'd2) begin
            state <= 4'd3;
        end
        if (state==4'd3) begin
            state <= 4'd4;
        end
        if (state==4'd4) begin
            state <= 4'd0;
        end
    end

endmodule
