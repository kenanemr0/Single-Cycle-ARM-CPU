module conditional_logic (
	input clk,
	input reset,
	input [1:0] PCS,
	input RegW,
	input MemW,
	
	input [3:0] Cond,
	input [3:0] Flags,
	input [1:0] FlagW,
	
	output [1:0] PCSrc,
	output RegWrite,
	output MemWrite
	);
	
	reg [3:0] Flags_reg;
	wire [1:0] FlagWrite;
	wire CondEx;
	
	assign FlagWrite[0] = FlagW[0] & CondEx;
	assign FlagWrite[1] = FlagW[1] & CondEx; 
	
	always @(posedge clk or posedge reset) begin
		if (reset)
			Flags_reg <= 4'b0000;
		else begin
			if (FlagWrite[1])
				Flags_reg[3:2] <= Flags[3:2];
			
			if (FlagWrite[0])
				Flags_reg[1:0] <= Flags[1:0];
		end
	end
		
	condition_check_unit u1_condunit (
		.Cond(Cond),
		.Flags(Flags_reg),
		.CondEx(CondEx)
		);
		
		assign PCSrc = CondEx ? PCS : 2'b00;
		assign RegWrite = RegW & CondEx;
		assign MemWrite = MemW & CondEx;
		
endmodule
