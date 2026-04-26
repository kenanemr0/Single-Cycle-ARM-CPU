module ALU_decoder (
	input ALUOp,
	input BX,
	
	input [3:0] CMD,
	input S_bit,
	
	output reg [1:0] ALUControl,
	output reg [1:0] FlagW
	);
	
	always @(*) begin
	
		ALUControl = 2'b00;
		FlagW = 2'b00;
		
		if (!ALUOp) begin // Check if ALUOp is 0, Memory
			ALUControl = 2'b00; // Always Addition for ALUOp = 0
		end
		
		else if (BX) begin
			ALUControl = 2'b11; // BX Passes R14 trough ALU
		end
		
		else begin
			
			case(CMD)
			
			4'b0000: ALUControl = 2'b10; // AND
			4'b0010: ALUControl = 2'b01; // SUB
			4'b0100: ALUControl = 2'b00; // ADD
			4'b1010: ALUControl = 2'b01; // CMP, (SUB Result is only for Flags)
			4'b1100: ALUControl = 2'b11; // ORR
			4'b1101: ALUControl = 2'b11; // MOV Uses ORR Logic to Pass trough ALU
			default: ALUControl = 2'b00; // Safety for Addition
 
			endcase
 		
		if (S_bit || CMD == 4'b1010) begin
			FlagW[1] = 1'b1; // N, Z
		
		if (CMD == 4'b1010 || CMD == 4'b0100 || CMD == 4'b0010)
			FlagW[0] = 1'b1; // C, V
		end
	end
end
		
endmodule
