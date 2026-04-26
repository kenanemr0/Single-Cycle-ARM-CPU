module top_level_control_unit (
	input clk,
	input reset,
	
	// From Instruction
	input [31:0] Instr,
	
	// From ALU
	input [3:0] Flags,
	
	//--------To the Datapath--------
	
	output [1:0] PCSrc,
	output RegWrite,
	output MemWrite,
	output MemtoReg,
	output ALUSrc,
	
	output [1:0] ImmSrc,
	output [1:0] RegSrc,
	output [1:0] ALUControl,
	
	//--------Branch Signals--------
	
	output BL,
	output BX
	);
	
	// Extract the Instruction Field
	wire [3:0] Cond = Instr[31:28];
	wire [1:0] Op = Instr[27:26];
	wire [5:0] Funct = Instr[25:20];
	wire [3:0] Rd = Instr[15:12];
	
	// Internal Wire Connections
	wire [1:0] PCS;
	wire [1:0] FlagW;
	wire RegW;
	wire MemW;
	
	top_level_combinational_decoder u1_combdec (
		.Op(Op),
		.Funct(Funct),
		.Rd(Rd),
		.FlagW(FlagW),
		.PCS(PCS),
		.RegW(RegW),
		.MemW(MemW),
		.MemtoReg(MemtoReg),
		.ALUSrc(ALUSrc),
		.ImmSrc(ImmSrc),
		.RegSrc(RegSrc),
		.ALUControl(ALUControl),
		.BL(BL),
		.BX(BX)
		);
		
	conditional_logic u2_condlogic (
		.clk(clk),
		.reset(reset),
		.PCS(PCS),
		.RegW(RegW),
		.MemW(MemW),
		.Cond(Cond),
		.Flags(Flags),
		.FlagW(FlagW),
		.PCSrc(PCSrc),
		.RegWrite(RegWrite),
		.MemWrite(MemWrite)
		);
		
endmodule
