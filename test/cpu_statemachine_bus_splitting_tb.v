// This test is based on the following commit: 2e249fd2105625e70fbf9e32d2a4fa76f951f4dd

module cpu_statemachine_bus_splitting_tb (

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


    ///////////// Inline test code, as the internal signals in the CPU are being tested, there is no external testbench possible.

    logic rst;
    logic clk;


    parameter TIMEOUT_CYCLES = 15;

    // Generate clock
    initial begin
        clk=0;
        rst=1;

        repeat (TIMEOUT_CYCLES) begin
            #10;
            clk = !clk;
            #10;
            clk = !clk;
        end

        $fatal(2, "Simulation did not finish within %d cycles.", TIMEOUT_CYCLES);
    end

    always @(posedge clk) begin
        #1
        $display(state);
        instr <= 32'b00100100000111110000011111000000; // uncomment to test R-type
        //instr <= 32'b11111100000111110000000000000000; // uncomment to test I-type
        //instr <= 32'b11111100000000000000000000000000; // uncomment to test J-type
        $display("Whole instruction:    %b", instr);
        $display("opcode:               %b", instr_opcode);

        $display("R_instr_rs:           %b", R_instr_rs);
        $display("R_instr_rt:           %b", R_instr_rt);
        $display("R_instr_rd:           %b", R_instr_rd);
        $display("R_instr_shamt:        %b", R_instr_shamt);
        $display("R_instr_func:         %b", R_instr_func);

        $display("I_instr_rs:           %b", I_instr_rs);
        $display("I_instr_rt:           %b", I_instr_rt);
        $display("I_instr_immediate:    %b", I_instr_immediate);

        $display("J_instr_addr:         %b", J_instr_addr);


    end


    /////////////

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
            $finish; // For testing only:
        end
    end

endmodule
