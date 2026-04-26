module shifter #(parameter W = 32) (
	input [1:0] shifter_control,
	input [4:0] shamt,
	input [W-1:0] data_in,
	output reg [W-1:0] data_out
	);
	
	always @(*) begin
		case(shifter_control)
		2'b00: data_out = data_in << shamt;
		2'b01: data_out = data_in >> shamt;
		2'b10: data_out = $signed(data_in) >>> shamt;
		2'b11: begin
			if (shamt == 0)
				data_out = data_in;
			else
				data_out = (data_in >> shamt) | (data_in << (W - shamt));
			end
		default: data_out = {W{1'b0}};
		endcase
	end

endmodule
	