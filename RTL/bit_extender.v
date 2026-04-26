module bit_extender (
    input [23:0] Instr,
    input [1:0] ImmSrc,
    
    output reg [31:0] Extended_Imm
    );
    
    // Rotation amount for Data-Processing: rot * 2 
    wire [4:0] rotate_amt = {Instr[11:8], 1'b0}; 
    
    always @(*) begin
        case (ImmSrc)
        
        // Data-Processing: 8-bit immediate rotated right
        2'b00: begin
            if (rotate_amt == 5'b0)
                Extended_Imm = {24'b0, Instr[7:0]};
            else
                // Perform the Right Rotation (ROR) 
                Extended_Imm = ({24'b0, Instr[7:0]} >> rotate_amt) | ({24'b0, Instr[7:0]} << (32 - rotate_amt));
        end
        
        // Memory (LDR/STR): 12-bit Zero Extension
        2'b01: Extended_Imm = {20'b0, Instr[11:0]};
        
        // Branch: 24-bit Sign Extension and Shift Left 2
        2'b10: Extended_Imm = {{6{Instr[23]}}, Instr[23:0], 2'b00};
        
        // Default Case
        default: Extended_Imm = 32'b0;
      endcase
     end
     
endmodule