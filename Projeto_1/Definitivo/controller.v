module Controller (
    input [7:0] opcode,
    output reg [2:0] ula_operation
);

    // Decodificador de instruções
    always @(*) begin
        case (opcode)
            8'b00000001: ula_operation = 3'b000; // ADD
            8'b00000010: ula_operation = 3'b001; // SUB
            8'b00000011: ula_operation = 3'b010; // MUL
            8'b00000100: ula_operation = 3'b011; // DIV
            8'b00000101: ula_operation = 3'b100; // MOD
            default: ula_operation = 3'b111;    // Operação inválida
        endcase
    end

endmodule