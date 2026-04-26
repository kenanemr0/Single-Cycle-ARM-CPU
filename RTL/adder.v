module adder (
	input [31:0] data_in_1,
	input [31:0] data_in_2,
	
	output [31:0] data_out
	);
	
	assign data_out = data_in_1 + data_in_2;
	
endmodule

	