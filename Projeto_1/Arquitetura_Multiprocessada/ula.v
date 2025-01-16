module ULA (
    input [3:0] ula_operation,
    input [7:0] operand1,
    input [7:0] operand2,
    output reg [7:0] result,
    output reg [3:0] flags
);

    wire [7:0] add_result, sub_result, mul_result, div_result, mod_result;
    wire [7:0] and_result, or_result, xor_result, not_result, nor_result, nand_result, xnor_result;
    wire [3:0] add_flags, sub_flags, mul_flags, div_flags, mod_flags;

    // Instância dos módulos matemáticos
    ADD add(.a(operand1), .b(operand2), .result(add_result), .status_flags(add_flags));
    SUB sub(.a(operand1), .b(operand2), .result(sub_result), .status_flags(sub_flags));
    MUL mul(.a(operand1), .b(operand2), .result(mul_result), .status_flags(mul_flags));
    DIV div(.a(operand1), .b(operand2), .result(div_result), .status_flags(div_flags));
    MOD mod(.a(operand1), .b(operand2), .result(mod_result), .status_flags(mod_flags));
    
    // Instância dos módulos lógicos
    AND and_gate(.a(operand1), .b(operand2), .result(and_result));
    OR or_gate(.a(operand1), .b(operand2), .result(or_result));
    XOR xor_gate(.a(operand1), .b(operand2), .result(xor_result));
    NOT not_gate(.a(operand1), .result(not_result));
    NOR nor_gate(.a(operand1), .b(operand2), .result(nor_result));
    NAND nand_gate(.a(operand1), .b(operand2), .result(nand_result));
    XNOR xnor_gate(.a(operand1), .b(operand2), .result(xnor_result));

    always @(*) begin
    // Decodifica a operação
    case (ula_operation)
        4'b0001: begin
            result = add_result;    // ADD
            flags = add_flags;      // Atualiza as flags para ADD
        end
        4'b0010: begin
            result = sub_result;    // SUB
            flags = sub_flags;      // Atualiza as flags para SUB
        end
        4'b0011: begin
            result = mul_result;    // MUL
            flags = mul_flags;      // Atualiza as flags para MUL
        end
        4'b0100: begin
            result = div_result;    // DIV
            flags = div_flags;      // Atualiza as flags para DIV
        end
        4'b0101: begin
            result = mod_result;    // MOD
            flags = mod_flags;      // Atualiza as flags para MOD
        end
        4'b0110: begin 
            result = and_result;  // AND
            flags[0] = (and_result == 8'b00000000); // Zero flag (Z)
            flags[1] = and_result[7]; // Sign flag (S)
            flags[2] = 0; //carry(não se aplica)
            flags[3] = 0; //overflow (não se aplica)
        end
            4'b0111: begin 
            result = or_result;   // OR
            flags[0] = (or_result == 8'b00000000); // Zero flag (Z)
            flags[1] = or_result[7]; // Sign flag (S)
            flags[2] = 0; // carry (não se aplica)
            flags[3] = 0; // overflow (não se aplica)
        end

        4'b1000: begin 
            result = xor_result;  // XOR
            flags[0] = (xor_result == 8'b00000000); // Zero flag (Z)
            flags[1] = xor_result[7]; // Sign flag (S)
            flags[2] = 0; // carry (não se aplica)
            flags[3] = 0; // overflow (não se aplica)
        end

        4'b1001: begin 
            result = not_result;  // NOT
            flags[0] = (not_result == 8'b00000000); // Zero flag (Z)
            flags[1] = not_result[7]; // Sign flag (S)
            flags[2] = 0; // carry (não se aplica)
            flags[3] = 0; // overflow (não se aplica)
        end

        4'b1010: begin 
            result = nor_result;  // NOR
            flags[0] = (nor_result == 8'b00000000); // Zero flag (Z)
            flags[1] = nor_result[7]; // Sign flag (S)
            flags[2] = 0; // carry (não se aplica)
            flags[3] = 0; // overflow (não se aplica)
        end

        4'b1011: begin 
            result = nand_result; // NAND
            flags[0] = (nand_result == 8'b00000000); // Zero flag (Z)
            flags[1] = nand_result[7]; // Sign flag (S)
            flags[2] = 0; // carry (não se aplica)
            flags[3] = 0; // overflow (não se aplica)
        end

        4'b1100: begin 
            result = xnor_result; // XNOR
            flags[0] = (xnor_result == 8'b00000000); // Zero flag (Z)
            flags[1] = xnor_result[7]; // Sign flag (S)
            flags[2] = 0; // carry (não se aplica)
            flags[3] = 0; // overflow (não se aplica)
        end

        default: result = 8'b0;        // Operação inválida
        endcase
    end

endmodule
