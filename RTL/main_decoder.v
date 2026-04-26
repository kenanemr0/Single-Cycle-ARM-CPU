module main_decoder (
	input [1:0] Op, // Instr [27:26]
	input [5:0] Funct, // Instr[25:20]
	
	output reg Branch,
	output reg BX,
	output reg BL,
	
	output reg RegW,
	output reg MemtoReg,
	output reg ALUSrc,
	output reg ALUOp,
	output reg MemW,
	
	output reg [1:0] ImmSrc,
	output reg [1:0] RegSrc
	);
	
	wire I_bit = Funct[5];
	wire L_bit = Funct[0];
	wire [3:0] CMD = Funct[4:1];
		
	// If I_bit is 1, it is Immediate Field Instruction
	// If it is 0, it is Register Field Instruction
	
	// If L_bit is 1, It is Load, if 0, it is Store
	
	// CMD decides what operation ALU should execute.
	
	always @(*) begin
	
	// Enter Default Values as zeros
		Branch = 1'b0;
		BX = 1'b0;
		BL = 1'b0;
		RegW = 1'b0;
		MemtoReg = 1'b0;
		ALUSrc = 1'b0;
		ALUOp = 1'b0;
		MemW = 1'b0;
		ImmSrc = 2'b00;
		RegSrc = 2'b00;
		
		case (Op)
		
	// First, Data-Processing Instructions, Op code is 2-bit 00
		
		2'b00: begin
			if (!I_bit && (CMD == 4'b1001)) begin
				BX = 1'b1;
				ALUSrc = 1'b0;
				ALUOp = 1'b1;
			end
			
		else begin
			ALUSrc = I_bit;
			ALUOp = 1'b1;
			
			ImmSrc = 2'b00;
			
			RegSrc = 2'b00;
			
			RegW = (CMD != 4'b1010) ? 1'b1 : 1'b0; // CMP does not write to any Register
			end
		end

		2'b01: begin
			ALUSrc = 1'b1;
			ImmSrc = 2'b01;
			RegSrc = 2'b10;
			MemtoReg = L_bit;
			RegW = L_bit;
			MemW = ~L_bit;
		end
		
		2'b10: begin
			ImmSrc = 2'b10;
			
			RegSrc = 2'b01;
			
			Branch = 1'b1;
			
			BL = Funct[4];
			RegW = Funct[4];
		end
		
		default: begin
			Branch = 1'b0;
			BX = 1'b0;
			BL = 1'b0;
			RegW = 1'b0;
			MemtoReg = 1'b0;
			ALUSrc = 1'b0;
			ALUOp = 1'b0;
			MemW = 1'b0;
			ImmSrc = 2'b00;
			RegSrc = 2'b00;
		end
		endcase
	end	
	
endmodule
			
			
			
			
			
			
			
			
			
			
			