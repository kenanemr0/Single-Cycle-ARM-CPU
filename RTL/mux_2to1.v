module mux_2to1 #(parameter W = 32) (
	input [W-1:0] D0,
	input  [W-1:0] D1,
	input sel,
	output [W-1:0] Out
	);
	
	assign Out = sel ? D1 : D0;
	
endmodule
	