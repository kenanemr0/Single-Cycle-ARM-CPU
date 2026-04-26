module reg_sync_res #(parameter W = 32) (
	input wire clk,
	input wire reset,
	input wire [W-1:0] write_data,
	output reg [W-1:0] read_data
	);
	
	always @(posedge clk) begin
		if (reset)
			read_data <= {W{1'b0}};
		else
			read_data <= write_data;
		end
		
endmodule
