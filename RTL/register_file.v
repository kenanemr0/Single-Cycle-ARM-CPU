module register_file #(parameter W = 32) (
    input clk,
    input reset,
    input write_en,

    input [3:0] dest_addr,
    input [3:0] source_addr_1,
    input [3:0] source_addr_2,
    input [3:0] debug_addr,

    input [W-1:0] write_data,
    input [W-1:0] reg_15,   // external PC input

    output [W-1:0] read_data_1,
    output [W-1:0] read_data_2,
    output [W-1:0] debug_out,

    output pc_write_en       // explicit PC write signal
);

    // R0–R14 only (R15 handled externally)
    (* preserve *) reg [W-1:0] regs [0:14];
    integer i;

    // Write Logic
    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < 15; i = i + 1)
                regs[i] <= {W{1'b0}};
        end else begin
            if (write_en && dest_addr != 4'd15)
                regs[dest_addr] <= write_data;
        end
    end

    // Detect write to PC (R15)
    assign pc_write_en = write_en && (dest_addr == 4'd15);

    // Read Logic, Combinational

    // ARM behavior: R15 reads as PC+8
    assign read_data_1 = (source_addr_1 == 4'd15) ? reg_15 : regs[source_addr_1];
    assign read_data_2 = (source_addr_2 == 4'd15) ? reg_15 : regs[source_addr_2];
    assign debug_out   = (debug_addr   == 4'd15) ? reg_15 : regs[debug_addr];

endmodule
