`timescale 1ns/1ps
module CPU_tb;

    // Testbench signals
    reg clk;
    reg reset;
    
    // Debug ports for the NEW Top Level
    reg [3:0] debug_addr;
    reg toggle_switch;
    reg ALU_view_switch;
    
    wire [6:0] HEX0, HEX1, HEX2, HEX3;

    integer pass_count = 0;
    integer fail_count = 0;

    // Instantiate the Top-Level Processor using the updated ports
    Single_Cycle_ARM_CPU DUT (
        .clk(clk),
        .reset(reset),
        .debug_addr(debug_addr),
        .toggle_switch(toggle_switch),
        .ALU_view_switch(ALU_view_switch),
        .HEX0(HEX0),
        .HEX1(HEX1),
        .HEX2(HEX2),
        .HEX3(HEX3)
    );

    // Clock generation (10ns period -> 100MHz)
    always #5 clk = ~clk;

    // -----------------------------
    // Tasks: Expected vs Actual Checks
    // -----------------------------
    task check_reg;
        input [31:0] actual;
        input [31:0] expected;
        input [255:0] msg;
        begin
            if (actual === expected) begin
                $display("PASS: %s | Expected: %08h | Actual: %08h", msg, expected, actual);
                pass_count = pass_count + 1;
            end else begin
                $display("FAIL: %s | Expected: %08h | Actual: %08h", msg, expected, actual);
                fail_count = fail_count + 1;
            end
        end
    endtask

    task check_mem;
        input [7:0] actual;
        input [7:0] expected;
        input [255:0] msg;
        begin
            if (actual === expected) begin
                $display("PASS: %s | Expected: %02h | Actual: %02h", msg, expected, actual);
                pass_count = pass_count + 1;
            end else begin
                $display("FAIL: %s | Expected: %02h | Actual: %02h", msg, expected, actual);
                fail_count = fail_count + 1;
            end
        end
    endtask

    // -----------------------------
    // Execution Trace Logger
    // -----------------------------
    always @(posedge clk) begin
        if (!reset) begin
            $display("Time: %0t | PC: %08h | Instr: %08h | ALUOut: %08h | HEX displays outputting...", 
                     $time, DUT.u2_datapath.PC, DUT.u2_datapath.Instr, DUT.u2_datapath.ALUResult);
        end
    end

    // -----------------------------
    // Main Simulation Block
    // -----------------------------
    initial begin
        // 1. Initialize Inputs
        clk = 0;
        reset = 1;
        debug_addr = 4'd0;
        toggle_switch = 0;   // View lower 16 bits
        ALU_view_switch = 0; // View Register File

        $display("==================================================");
        $display("   STARTING PROGRAM EXECUTION TRACE");
        $display("==================================================");

        // 2. Apply Reset
        #15; 
        reset = 0;

        // 3. Let the processor execute the hex file
        #300; 
        
        $display("\n==================================================");
        $display("   EXECUTING AUTOMATED INSTRUCTION CHECKS");
        $display("==================================================");

        // --- VERIFYING DATA PROCESSING INSTRUCTIONS ---
        check_reg(DUT.u2_datapath.u2_RF.regs[1], 32'h0000_0013, "[0x00] MOV R1");
        check_reg(DUT.u2_datapath.u2_RF.regs[2], 32'h0000_0026, "[0x04] ADD R2");
        check_reg(DUT.u2_datapath.u2_RF.regs[3], 32'h0000_0002, "[0x08] AND R3");
        check_reg(DUT.u2_datapath.u2_RF.regs[4], 32'h0000_004C, "[0x14] LSL R4");
        check_reg(DUT.u2_datapath.u2_RF.regs[5], 32'h0000_000A, "[0x18] SUB/LSR R5");
        check_reg(DUT.u2_datapath.u2_RF.regs[6], 32'h8000_0002, "[0x1C] ORR/ROR R6");
        check_reg(DUT.u2_datapath.u2_RF.regs[7], 32'hFFFF_FFF8, "[0x20] ASR R7");
        
        // --- VERIFYING MEMORY INSTRUCTIONS ---
        check_reg(DUT.u2_datapath.u2_RF.regs[8], 32'h0000_0026, "[0x28] LDR R8");
        check_mem(DUT.u2_datapath.u6_mem.memory_block[8'h68], 8'h26, "[0x24] STR R2");

        // --- VERIFYING FUNCTION CALLS (BL & BX) ---
        check_reg(DUT.u2_datapath.u2_RF.regs[14], 32'h0000_0040, "[0x3C] BL +1: Link Register (R14)");
        check_reg(DUT.u2_datapath.u2_RF.regs[0],  32'h0000_0330, "[0x44] BX Return: MOV R0");

        $display("----------------------------------");
        if (fail_count == 0)
            $display("FINAL RESULT: CPU IS FULLY OPERATIONAL \n");
        else
            $display("FINAL RESULT: CPU FAILED \n");

        #10;
        $stop;
    end

endmodule