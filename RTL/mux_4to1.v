module mux_4to1 #(parameter W = 32) (
	input [W-1:0] D0,
	input [W-1:0] D1,
	input [W-1:0] D2,
	input [W-1:0] D3,
	input [1:0] sel,
	output reg [W-1:0] Y
	);
	
	always @(*) begin
		case(sel)
		2'b00: Y = D0;
		2'b01: Y = D1;
		2'b10: Y = D2;
		2'b11: Y = D3;
		endcase
	end
	
endmodule
