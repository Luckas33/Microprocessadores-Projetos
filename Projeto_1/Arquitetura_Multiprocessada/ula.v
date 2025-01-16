module ULA (
    input [7:0] opcode,
    input [7:0] operand1,
    input [7:0] operand2,
    output reg [7:0] result,
    output reg [7:0] flags
);

    wire [7:0] add_result, sub_result, mul_result, div_result, mod_result;
    wire [7:0] and_result, or_result, xor_result, not_result, nor_result, nand_result, xnor_result;

    // Instância dos módulos matemáticos
    ADD add(.a(operand1), .b(operand2), .result(add_result));
    SUB sub(.a(operand1), .b(operand2), .result(sub_result));
    MUL mul(.a(operand1), .b(operand2), .result(mul_result));
    DIV div(.a(operand1), .b(operand2), .result(div_result));
    MOD mod(.a(operand1), .b(operand2), .result(mod_result));

    // Instância dos módulos lógicos
    AND and_gate(.a(operand1), .b(operand2), .result(and_result));
    OR or_gate(.a(operand1), .b(operand2), .result(or_result));
    XOR xor_gate(.a(operand1), .b(operand2), .result(xor_result));
    NOT not_gate(.a(operand1), .result(not_result));
    NOR nor_gate(.a(operand1), .b(operand2), .result(nor_result));
    NAND nand_gate(.a(operand1), .b(operand2), .result(nand_result));
    XNOR xnor_gate(.a(operand1), .b(operand2), .result(xnor_result));

    always @(*) begin
        case (opcode)
            8'b00000001: result = add_result;  // ADD
            8'b00000010: result = sub_result;  // SUB
            8'b00000011: result = mul_result;  // MUL
            8'b00000100: result = div_result;  // DIV
            8'b00000101: result = mod_result;  // MOD
            8'b00000110: result = and_result;  // AND
            8'b00000111: result = or_result;   // OR
            8'b00001000: result = xor_result;  // XOR
            8'b00001001: result = not_result;  // NOT
            8'b00001010: result = nor_result;  // NOR
            8'b00001011: result = nand_result; // NAND
            8'b00001100: result = xnor_result; // XNOR
            default: result = 8'b0;            // Operação inválida
        endcase
    end

    always @(*) begin
    flags[0] = (result == 0); // Zero Flag
    flags[1] = carry_flag;    // Carry Flag
    flags[2] = result[15];    // Sinal (bit mais significativo)
    flags[3] = ~^result;      // Paridade (XOR de todos os bits)
    flags[4] = 0;             // Interrupção (não usado no momento)
    flags[5] = 0;             // Direção (não usado no momento)
    flags[6] = overflow_flag; // Overflow (calculado separadamente)
    end

endmodule
