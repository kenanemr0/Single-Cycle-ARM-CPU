`timescale 1ns/1ps

module controller_tb;

    reg clk;
    reg reset;
    reg [31:0] Instr;
    reg [3:0] Flags;

    wire [1:0] PCSrc;
    wire RegWrite;
    wire MemWrite;
    wire MemtoReg;
    wire ALUSrc;
    wire [1:0] ImmSrc;
    wire [1:0] RegSrc;
    wire [1:0] ALUControl;
    wire BL, BX;

    integer pass_count = 0;
    integer fail_count = 0;

    // DUT
    top_level_control_unit DUT (
        .clk(clk),
        .reset(reset),
        .Instr(Instr),
        .Flags(Flags),
        .PCSrc(PCSrc),
        .RegWrite(RegWrite),
        .MemWrite(MemWrite),
        .MemtoReg(MemtoReg),
        .ALUSrc(ALUSrc),
        .ImmSrc(ImmSrc),
        .RegSrc(RegSrc),
        .ALUControl(ALUControl),
        .BL(BL),
        .BX(BX)
    );

    // Clock
    always #5 clk = ~clk;

    // -----------------------------
    // Task: Check
    // -----------------------------
    task check;
        input cond;
        input [255:0] msg;
        begin
            if (cond) begin
                $display("PASS: %s", msg);
                pass_count = pass_count + 1;
            end else begin
                $display("FAIL: %s", msg);
                fail_count = fail_count + 1;
            end
        end
    endtask

    // -----------------------------
    // Test sequence
    // -----------------------------
    initial begin
        clk = 0;
        reset = 1;
        Instr = 0;
        Flags = 4'b0000;

        #10;
        reset = 0;

        //----------------------------------
        // 1. ADD (AL condition)
        //----------------------------------
        // Cond=1110, Op=00, CMD=0100 (ADD), S=0
        Instr = {4'b1110, 2'b00, 6'b001000, 20'b0};
        #10;

        check(RegWrite == 1, "ADD: RegWrite should be 1");
        check(PCSrc == 2'b00, "ADD: PCSrc sequential");

        //----------------------------------
        // 2. CMP (no RegWrite)
        //----------------------------------
        // Op=00, CMD=1010, S=1 -> Funct = 010101
        Instr = {4'b1110, 2'b00, 6'b010101, 20'b0};
        #10;

        check(RegWrite == 0, "CMP: RegWrite should be 0");

        //----------------------------------
        // 3. LDR
        //----------------------------------
        // Op=01, L=1 -> Funct[0] = 1 (Using 000001)
        Instr = {4'b1110, 2'b01, 6'b000001, 20'b0};
        #10;

        check(RegWrite == 1, "LDR: RegWrite");
        check(MemtoReg == 1, "LDR: MemtoReg");

        //----------------------------------
        // 4. STR
        //----------------------------------
        // Op=01, L=0 -> Funct[0] = 0
        Instr = {4'b1110, 2'b01, 6'b000000, 20'b0};
        #10;

        check(MemWrite == 1, "STR: MemWrite");

        //----------------------------------
        // 5. Branch
        //----------------------------------
        Instr = {4'b1110, 2'b10, 6'b000000, 20'b0};
        #10;

        check(PCSrc == 2'b01, "B: PCSrc branch");

        //----------------------------------
        // 6. BX
        //----------------------------------
        // Op=00, CMD=1001, I=0 -> Funct = 010010
        Instr = {4'b1110, 2'b00, 6'b010010, 20'b0};
        #10;

        check(BX == 1, "BX detected");
        check(PCSrc == 2'b10, "BX: PCSrc register");

        //----------------------------------
        // 7. Condition fail: EQ (requires Z=1, we give Z=0)
        //----------------------------------
        Instr = {4'b1110, 2'b00, 6'b010101, 20'b0}; // CMP (AL)
        Flags = 4'b0000; // Z = 0
        #10; 
        
        Instr = {4'b0000, 2'b00, 6'b001000, 20'b0}; // EQ ADD
        #10;
        check(RegWrite == 0, "EQ fail: RegWrite suppressed");

        //----------------------------------
        // 8. Condition pass: EQ (requires Z=1, we give Z=1)
        //----------------------------------
        Instr = {4'b1110, 2'b00, 6'b010101, 20'b0}; // CMP (AL)
        Flags = 4'b0100; // Z = 1
        #10; 

        Instr = {4'b0000, 2'b00, 6'b001000, 20'b0}; // EQ ADD
        #10;
        check(RegWrite == 1, "EQ pass: RegWrite active");

        //----------------------------------
        // 9. Condition fail: NE (requires Z=0, we give Z=1)
        //----------------------------------
        Instr = {4'b1110, 2'b00, 6'b010101, 20'b0}; // CMP (AL)
        Flags = 4'b0100; // Z = 1
        #10; 

        Instr = {4'b0001, 2'b00, 6'b001000, 20'b0}; // NE ADD
        #10;
        check(RegWrite == 0, "NE fail: RegWrite suppressed (Z=1)");

        //----------------------------------
        // 10. Condition fail: MI (requires N=1, we give N=0)
        //----------------------------------
        Instr = {4'b1110, 2'b00, 6'b010101, 20'b0}; // CMP (AL)
        Flags = 4'b0000; // N = 0
        #10; 

        Instr = {4'b0100, 2'b00, 6'b001000, 20'b0}; // MI ADD
        #10;
        check(RegWrite == 0, "MI fail: RegWrite suppressed (N=0)");

        //----------------------------------
        // 11. Condition fail: STR VS (requires V=1, we give V=0)
        //----------------------------------
        Instr = {4'b1110, 2'b00, 6'b010101, 20'b0}; // CMP (AL)
        Flags = 4'b0000; // V = 0
        #10; 

        Instr = {4'b0110, 2'b01, 6'b000000, 20'b0}; // VS STR
        #10;
        check(MemWrite == 0, "VS fail: MemWrite suppressed for STR");

        //----------------------------------
        // 12. Condition fail: ADDS EQ (Verifying Flag Protection)
        //----------------------------------
        // Step A: Latch a distinct flag state (N=1, Z=0)
        Instr = {4'b1110, 2'b00, 6'b010101, 20'b0}; // CMP (AL)
        Flags = 4'b1000; // N=1, Z=0, C=0, V=0
        #10;
        
        // Step B: Execute ADDS EQ. Since Z=0, this should FAIL.
        // It has S=1 (Funct=001001), so it *wants* to write flags.
        Instr = {4'b0000, 2'b00, 6'b001001, 20'b0}; 
        Flags = 4'b0000; // Pretend the datapath ALU output is N=0, Z=0
        #10;
        check(RegWrite == 0, "EQ fail on ADDS: RegWrite suppressed");
        
        // Step C: Execute MI ADD (requires N=1). 
        // If Step B mistakenly overwrote our flags, N would be 0 and this would fail.
        Instr = {4'b0100, 2'b00, 6'b001000, 20'b0}; 
        #10;
        check(RegWrite == 1, "EQ fail on ADDS: Flags were protected (N is still 1)");

        //----------------------------------
        // FINAL REPORT
        //----------------------------------
        $display("----------------------------------");
        $display("TOTAL PASS: %0d", pass_count);
        $display("TOTAL FAIL: %0d", fail_count);
        $display("----------------------------------");

        if (fail_count == 0)
            $display("FINAL RESULT: PASS");
        else
            $display("FINAL RESULT: FAIL");

        $stop;
    end

endmodule