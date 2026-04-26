module mux_16to1 #(parameter W = 32) (
	input [W-1:0] D0,
	input [W-1:0] D1,
	input [W-1:0] D2,
	input [W-1:0] D3,
	input [W-1:0] D4,
	input [W-1:0] D5,
	input [W-1:0] D6,
	input [W-1:0] D7,
	input [W-1:0] D8,
	input [W-1:0] D9,
	input [W-1:0] D10,
	input [W-1:0] D11,
	input [W-1:0] D12,
	input [W-1:0] D13,
	input [W-1:0] D14,
	input [W-1:0] D15,
	input [3:0] sel,
	output reg [W-1:0] Y
	);
	
	always @(*) begin
		case(sel)
		4'b0000: Y = D0;
		4'b0001: Y = D1;
		4'b0010: Y = D2;
		4'b0011: Y = D3;
		4'b0100: Y = D4;
		4'b0101: Y = D5;
		4'b0110: Y = D6;
		4'b0111: Y = D7;
		4'b1000: Y = D8;
		4'b1001: Y = D9;
		4'b1010: Y = D10;
		4'b1011: Y = D11;
		4'b1100: Y = D12;
		4'b1101: Y = D13;
		4'b1110: Y = D14;
		4'b1111: Y = D15;
		endcase
	end
	
endmodule
	