module mux_8to1 #(parameter W = 32) (
	input [W-1:0] D0,
	input [W-1:0] D1,
	input [W-1:0] D2,
	input [W-1:0] D3,
	input [W-1:0] D4,
	input [W-1:0] D5,
	input [W-1:0] D6,
	input [W-1:0] D7,
	input [2:0] sel,
	output reg [W-1:0] Y
	);
	
	always @(*) begin
		case(sel)
		3'b000: Y = D0;
		3'b001: Y = D1;
		3'b010: Y = D2;
		3'b011: Y = D3;
		3'b100: Y = D4;
		3'b101: Y = D5;
		3'b110: Y = D6;
		3'b111: Y = D7;
		endcase
	end
	
endmodule
	