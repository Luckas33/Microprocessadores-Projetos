module Controller (
    input [7:0] opcode,
    output reg [3:0] ula_operation
);
    // Decodificador de instruções
    always @(*) begin
        case (opcode)
            8'b00000001: ula_operation = 4'b0001; // ADD
            8'b00000010: ula_operation = 4'b0010; // SUB
            8'b00000011: ula_operation = 4'b0011; // MUL
            8'b00000100: ula_operation = 4'b0100; // DIV
            8'b00000101: ula_operation = 4'b0101; // MOD
            8'b00000110: ula_operation = 4'b0110; // AND
            8'b00000111: ula_operation = 4'b0111; // OR
            8'b00001000: ula_operation = 4'b1000; // XOR
            8'b00001001: ula_operation = 4'b1001; // NOT
            8'b00001010: ula_operation = 4'b1010; // NOR
            8'b00001011: ula_operation = 4'b1011; // NAND
            8'b00001100: ula_operation = 4'b1100; // XNOR
            default: ula_operation = 4'b0000; // Operação inválida
        endcase
    end
endmodule