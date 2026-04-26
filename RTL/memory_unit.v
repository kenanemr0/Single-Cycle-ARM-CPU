module memory_unit #(
    parameter W             = 4,
    parameter address_width = 32
)(
    input                   clk,
    input                   write_en,
    input  [8*W-1:0]        write_data,
    input  [address_width-1:0] address,
    output [8*W-1:0]        read_data
);
    // Byte-addressed input → word-addressed M9K (divide by 4)
    wire [5:0] word_addr = address[7:2];

    altsyncram #(
        .operation_mode         ("SINGLE_PORT"),
        .width_a                (32),
        .widthad_a              (6),        // 2^6 = 64 words = 256 bytes
        .numwords_a             (64),
        .outdata_reg_a          ("UNREGISTERED"), // combinational read
        .init_file              ("UNUSED"),
        .intended_device_family ("Cyclone III"),
        .lpm_hint               ("ENABLE_RUNTIME_MOD=NO"),
        .lpm_type               ("altsyncram"),
        .wrcontrol_aclr_a       ("NONE")
    ) ram_inst (
        .address_a  (word_addr),
        .clock0     (clk),
        .data_a     (write_data),
        .wren_a     (write_en),
        .q_a        (read_data)
    );

endmodule