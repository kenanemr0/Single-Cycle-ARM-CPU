module top_level_combinational_decoder (
	input [1:0] Op, // Instr [27:26]
	input [5:0] Funct, // Instr [25:20]
	input [3:0] Rd, // Instr [15:12]
	
	//-------To the Conditional Logic-------
	
	output [1:0] FlagW,
	output [1:0] PCS, 
	output RegW, 
	output MemW,
	
	//-------Directly to the Datapath-------
	
	output MemtoReg,
	output ALUSrc,
	output [1:0] ImmSrc,
	output [1:0] RegSrc,
	output [1:0] ALUControl,
	
	//-------Branch-type Signals-------
	
	output BL,
	output BX
	);
	
	// Internal Wires
	
	wire ALUOp;
	wire Branch;
	wire BX_W, BL_W;
	wire RegW_W, MemW_W;
	wire [3:0] CMD = Funct[4:1];
	wire S_bit = Funct[0];
	
	main_decoder u1_maindec (
		.Op(Op),
		.Funct(Funct),
		.Branch(Branch),
		.BX(BX_W),
		.BL(BL_W),
		.RegW(RegW_W),
		.MemtoReg(MemtoReg),
		.ALUSrc(ALUSrc),
		.ALUOp(ALUOp),
		.MemW(MemW_W),
		.ImmSrc(ImmSrc),
		.RegSrc(RegSrc)
		);
		
	ALU_decoder u2_ALUdec (
		.ALUOp(ALUOp),
		.BX(BX_W),
		.CMD(CMD),
		.S_bit(S_bit),
		.ALUControl(ALUControl),
		.FlagW(FlagW)
		);
		
	PC_Logic u3_PCLogic(
		.Rd(Rd),
		.Branch(Branch),
		.BX(BX_W),
		.RegW(RegW_W),
		.PCS(PCS)
		);
		
	assign BX = BX_W;
	assign BL = BL_W;
	assign RegW = RegW_W;
	assign MemW = MemW_W;
		
endmodule
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		