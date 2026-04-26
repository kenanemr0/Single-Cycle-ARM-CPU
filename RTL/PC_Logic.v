module PC_Logic (
	input [3:0] Rd,
	input Branch,
	input BX,
	input RegW,
	
	output reg [1:0] PCS
	);
		
	// If R15 is being written, Branch to that address
	
	wire write_pc = RegW & (Rd == 4'b1111);
	
	always @(*) begin
		if (BX) begin
			PCS = 2'b10;
		end
		else if (write_pc) begin
			PCS = 2'b10;
		end
		else if (Branch) begin
			PCS = 2'b01;
		end
		else begin
			PCS = 2'b00; // PC + 4
		end
	end
	
endmodule
