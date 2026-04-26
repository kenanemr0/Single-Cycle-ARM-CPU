(* preserve *) module Single_Cycle_ARM_CPU (
    input clk,
    input reset,
    
    // Debug ports for the FPGA switches and 7-segment display
    input [3:0] debug_addr,
    input toggle_switch,
	 input ALU_view_switch,
	 
	 output [6:0] HEX0,
	 output [6:0] HEX1,
	 output [6:0] HEX2,
	 output [6:0] HEX3 
);

    // ---------------- Internal Interconnect Wires ----------------
    
    // Instruction and Flags (Datapath -> Controller)
    wire [31:0] Instr;
    wire [3:0] Flags;
    
    // Control Signals (Controller -> Datapath)
    wire [1:0] PCSrc;
    wire RegWrite;
    wire MemWrite;
    wire MemtoReg;
    wire ALUSrc;
    wire [1:0] ImmSrc;
    wire [1:0] RegSrc;
    wire [1:0] ALUControl;
    wire BL;
    wire BX;

	 // Wire for Catching the CPU Out
	 wire [31:0] internal_debug_out;
	 
    // ---------------- Module Instantiations ----------------

    // Instantiate the Control Unit
    top_level_control_unit u1_control_unit (
        .clk(clk),
        .reset(~reset),
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

    // Instantiate the Datapath
    datapath u2_datapath (
        .clk(clk),
        .reset(~reset),
        .PCSrc(PCSrc),
        .RegWrite(RegWrite),
        .MemWrite(MemWrite),
        .MemtoReg(MemtoReg),
        .ALUSrc(ALUSrc),
        .ImmSrc(ImmSrc),
        .RegSrc(RegSrc),
        .ALUControl(ALUControl),
        .BL(BL),
        .BX(BX),
        .Instr(Instr),
        .Flags(Flags),
        .debug_addr(debug_addr),
		  .ALU_view_switch(ALU_view_switch),
        .debug_out(internal_debug_out)
    );

	 // Display Logic for DE1-SoC FPGA
	 // Toggle Switch Controls Whether Upper 16 or Lower 16 would be Displayed
	 // ALU View Switch Controls If ALU is shown or the Register Out
	 
	 wire [15:0] display_data;
	 
	 // 2-to-1 Mux for Display Selection
	 
	 assign display_data = toggle_switch ? internal_debug_out[31:16] : internal_debug_out[15:0];
	 
	 seven_seg_display digit0_display (
		.data_in(display_data[3:0]),
		.HEX(HEX0)
		);
		
		seven_seg_display digit1_display (
		.data_in(display_data[7:4]),
		.HEX(HEX1)
		);
		
		seven_seg_display digit2_display (
		.data_in(display_data[11:8]),
		.HEX(HEX2)
		);
		
		seven_seg_display digit3_display (
		.data_in(display_data[15:12]),
		.HEX(HEX3)
		);
	 
endmodule

