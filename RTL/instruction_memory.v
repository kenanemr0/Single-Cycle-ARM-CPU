module instruction_memory #(
    parameter address_width = 32
)(
    input clk,
	 input  [address_width-1:0] PC_in,
    output [31:0]              PC_out
);
    // PC is byte-addressed; M9K is word-addressed --> divide by 4
    wire [5:0] word_addr = PC_in[7:2];

    altsyncram #(
        .operation_mode         ("ROM"),
        .width_a                (32),
        .widthad_a              (6),
        .numwords_a             (64),
        .outdata_reg_a          ("UNREGISTERED"),
        .init_file              ("instructions.mif"),
        .intended_device_family ("Cyclone III"),
        .lpm_hint               ("ENABLE_RUNTIME_MOD=NO"),
        .lpm_type               ("altsyncram")
    ) rom_inst (
        .address_a (word_addr),
        .clock0    (clk),
        .q_a       (PC_out)
    );

endmodule