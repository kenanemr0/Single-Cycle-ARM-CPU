module datapath (
    input clk,
    input reset,

    // Signals from the Control Unit
    input [1:0] PCSrc,
    input RegWrite,
    input MemWrite,
    input MemtoReg,
    input ALUSrc,
    input [1:0] ImmSrc,
    input [1:0] RegSrc,
    input [1:0] ALUControl,
    input BL,
    input BX,

    // Signals to the Control Unit
    output [31:0] Instr,
    output [3:0] Flags,
    
    // Debugging out to top level (for your 7-segment displays)
    input [3:0] debug_addr,
	 input ALU_view_switch,
    output [31:0] debug_out
);

    // ---------------- Internal Wires ----------------
	wire [31:0] PC, PCNext, PCPlus4, PCPlus8, PCBranch;
	wire [31:0] ExtImm;
	wire [31:0] RD1, RD2, ShiftedRD2;
	wire [31:0] SrcA, SrcB, ALUResult, ReadData, Result;
	wire [3:0]  RA1, RA2, A3;
	wire [31:0] WD3;
	wire pc_write_en;
	wire [31:0] pc_mux_out;
	wire [31:0] RF_debug_out;
	wire [31:0] bx_target;   
	wire [31:0] pc_src_0;    
	wire is_MOV;      

    // ---------------- PC & Adders -----------------
    reg_sync_res #(32) PC_Reg (
        .clk(clk),
        .reset(reset),
        .write_data(PCNext),
        .read_data(PC)
    );

   // PC Adders, PC + 4, PC + 8, [PC + 8 + (ExtImm << 2)]

	adder a1_PCPlus4 (
		.data_in_1(PC),
		.data_in_2(32'd4),
		.data_out(PCPlus4)
		);
		
	adder a2_PCPlus8 (
		.data_in_1(PCPlus4),
		.data_in_2(32'd4),
		.data_out(PCPlus8)
		);
		
	adder a3_PCbranch (
		.data_in_1(PCPlus8),
		.data_in_2(ExtImm),
		.data_out(PCBranch)
		);

	// ----------------- PC & Register Muxes -----------------
	
	mux_2to1 #(32) m1_BXMux (
		.D0(Result),
		.D1(RD2),
		.sel(BX),
		.Out(bx_target)
		);
		
	mux_2to1 #(32) m2_PCMux0 (
		.D0(PCPlus4),
		.D1(PCBranch),
		.sel(PCSrc[0]),
		.Out(pc_src_0)
		);
		
	mux_2to1 #(32) m3_PCMux1 (
		.D0(pc_src_0),
		.D1(bx_target),
		.sel(PCSrc[1]),
		.Out(pc_mux_out)
		);
		
	mux_2to1 #(32) m4_PCENMux (
		.D0(pc_mux_out),
		.D1(Result),
		.sel(pc_write_en),
		.Out(PCNext)
		);
		
	// ----------------- Instruction Memory -----------------

	instruction_memory #(32) u1_imem (
		.clk(clk),
		.PC_in(PC),
		.PC_out(Instr)
		);
		
	// ----------------- Register File -----------------
	
	// Address Muxes
	
	mux_2to1 #(4) m5_RA1Mux (
		.D0(Instr[19:16]),
		.D1(4'd15),
		.sel(RegSrc[0]),
		.Out(RA1)
		);
		
	mux_2to1 #(4) m6_PCENMux (
		.D0(Instr[3:0]),
		.D1(Instr[15:12]),
		.sel(RegSrc[1]),
		.Out(RA2)
		);
		
	mux_2to1 #(4) m7_A3Mux (
		.D0(Instr[15:12]),
		.D1(4'd14),
		.sel(BL),
		.Out(A3)
		);
	
	// Write Data Mux for BL Instruction
	
	mux_2to1 #(32) m8_WD3Mux (
		.D0(Result),
		.D1(PCPlus4),
		.sel(BL),
		.Out(WD3)
		);
		
	register_file #(32) u2_RF (
		.clk(clk),
		.reset(reset),
		.write_en(RegWrite),
		.dest_addr(A3),
		.source_addr_1(RA1),
		.source_addr_2(RA2),
		.debug_addr(debug_addr),
		.write_data(WD3),
		.reg_15(PCPlus8),
		.read_data_1(RD1),
		.read_data_2(RD2),
		.debug_out(RF_debug_out),
		.pc_write_en(pc_write_en)
		);
		
	// ----------------- Extender & Shifter -----------------
	
	bit_extender u3_ExtUnit (
		.Instr(Instr[23:0]),
		.ImmSrc(ImmSrc),
		.Extended_Imm(ExtImm)
		);
		
	shifter #(32) u4_ShftUnit (
		.shifter_control(Instr[6:5]),
		.shamt(Instr[11:7]),
		.data_in(RD2),
		.data_out(ShiftedRD2)
		);
		
	// ----------------- ALU & Operands -----------------
	
	// Wire flag to detect MOV

	assign is_MOV = (Instr[27:26] == 2'b00) && (Instr[24:21] == 4'b1101);
	
	// Operand Muxes
	
	mux_2to1 #(32) m9_SrcAMux (
		.D0(RD1),
		.D1(32'b0),
		.sel(is_MOV),
		.Out(SrcA)
		);
		
	mux_2to1 #(32) m10_SrcBMux (
		.D0(ShiftedRD2),
		.D1(ExtImm),
		.sel(ALUSrc),
		.Out(SrcB)
		);
		
	ALU u5_ALUunit (
		.SrcA(SrcA),
		.SrcB(SrcB),
		.ALUControl({2'b00, ALUControl}),
		.ALUFlags(Flags),
		.ALU_Out(ALUResult)
		);
		
	// ----------------- Memory & Result -----------------
	
	memory_unit #(4, 32) u6_mem (
		.clk(clk),
		.write_en(MemWrite),
		.write_data(RD2),
		.address(ALUResult),
		.read_data(ReadData)
		);
		
	// Result Muxes
	
	wire [31:0] pre_mov_res;
	
	mux_2to1 #(32) m11_ResMux (
		.D0(ALUResult),
		.D1(ReadData),
		.sel(MemtoReg),
		.Out(pre_mov_res)
		);
		
	mux_2to1 #(32) m12_movfix (
		.D0(pre_mov_res),
		.D1(SrcB),
		.sel(is_MOV),
		.Out(Result)
		);
		
		assign debug_out = ALU_view_switch ? ALUResult : RF_debug_out;
		
endmodule
