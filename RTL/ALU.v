module ALU (
    input [31:0] SrcA,
    input [31:0] SrcB,
    input [3:0] ALUControl, // Controller gives 2 bits, paddded in the Datapath
    
    output reg [3:0] ALUFlags, // [3]=N, [2]=Z, [1]=C, [0]=V
    output reg [31:0] ALU_Out
);

    wire [32:0] sum;
    // 2's complement for Subtraction
    assign sum = SrcA + (ALUControl[0] ? ~SrcB : SrcB) + ALUControl[0];

    always @(*) begin
        case(ALUControl[1:0])
            2'b00: ALU_Out = sum[31:0];       // ADD
            2'b01: ALU_Out = sum[31:0];       // SUB
            2'b10: ALU_Out = SrcA & SrcB;     // AND
            2'b11: ALU_Out = SrcA | SrcB;     // ORR
            default: ALU_Out = 32'b0;
        endcase

        // Flag Generation
        ALUFlags[3] = ALU_Out[31]; // N: Negative (MSB)
        ALUFlags[2] = (ALU_Out == 0); // Z: Zero
        ALUFlags[1] = (~ALUControl[1]) & sum[32]; // C: Carry out (Only for ADD/SUB)
        
        // V: Overflow (Only for ADD/SUB) 
        // Occurs if sign of inputs are same but sign of result is different
        ALUFlags[0] = (~ALUControl[1]) & (~(SrcA[31] ^ SrcB[31] ^ ALUControl[0])) & (SrcA[31] ^ sum[31]);
    end

endmodule
