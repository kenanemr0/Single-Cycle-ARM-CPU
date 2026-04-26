module seven_seg_display (
    input [3:0] data_in,
    output [6:0] HEX
);
    
    assign HEX = seven_seg(data_in);
    
    function [6:0] seven_seg;
        input [3:0] digit;
        begin
            case(digit)
                4'h0: seven_seg = 7'b1000000; // 0
                4'h1: seven_seg = 7'b1111001; // 1
                4'h2: seven_seg = 7'b0100100; // 2
                4'h3: seven_seg = 7'b0110000; // 3
                4'h4: seven_seg = 7'b0011001; // 4
                4'h5: seven_seg = 7'b0010010; // 5
                4'h6: seven_seg = 7'b0000010; // 6
                4'h7: seven_seg = 7'b1111000; // 7
                4'h8: seven_seg = 7'b0000000; // 8
                4'h9: seven_seg = 7'b0010000; // 9
                4'hA: seven_seg = 7'b0001000; // A
                4'hB: seven_seg = 7'b0000011; // b
                4'hC: seven_seg = 7'b1000110; // C
                4'hD: seven_seg = 7'b0100001; // d
                4'hE: seven_seg = 7'b0000110; // E
                4'hF: seven_seg = 7'b0001110; // F
                default: seven_seg = 7'b1111111; // Blank if error
            endcase
        end
    endfunction

endmodule
