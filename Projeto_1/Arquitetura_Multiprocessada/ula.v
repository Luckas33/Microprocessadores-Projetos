module ULA (
    input clk,
    input reset,
    input [3:0] ula_operation,
    input [7:0] operand1,
    input [7:0] operand2,
    output reg [7:0] result,
    output reg [3:0] flags,
    output reg ula_ready // Sinal indicando que a operação foi concluída
);

    // Resultados intermediários
    wire [7:0] add_result, sub_result, mul_result, div_result, mod_result;
    wire [7:0] and_result, or_result, xor_result, not_result, nor_result, nand_result, xnor_result;
    wire [3:0] add_flags, sub_flags, mul_flags;
  	wire [7:0] shift_result;
	wire carry;

    // Instância dos módulos matemáticos
    ADD add(.a(operand1), .b(operand2), .result(add_result), .status_flags(add_flags));
    SUB sub(.a(operand1), .b(operand2), .result(sub_result), .status_flags(sub_flags));
    MUL mul(.a(operand1), .b(operand2), .result(mul_result), .status_flags(mul_flags));
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
  
  	BitManipulation u_bit_manipulation (
    .data_in(operand1),                             // Entrada de dados (operand1)
    .enable_shift((ula_operation == 4'b1111 || ula_operation == 4'b1110)), // Habilita o deslocamento
    .direction_shift(ula_operation[0]),             // Direção do deslocamento: 0 para esquerda, 1 para direita
    .enable_rotate(1'b0),                           // Rotação desativada
    .direction_rotate(1'b0),                        // Não se aplica
    .data_out(shift_result),                        // Saída após deslocamento ou rotação
    .carry(carry)                                   // Sinal de carry (indicando o bit deslocado)
    );

    reg [2:0] cycle_counter; // Contador de ciclos

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            cycle_counter <= 3'b0;
            ula_ready <= 1'b0;
        end else begin
            if (cycle_counter < 3) begin
                cycle_counter <= cycle_counter + 1;
                ula_ready <= 1'b0;
            end else begin
                ula_ready <= 1'b1;
            end
        end
    end

    always @(*) begin
        case (ula_operation)
            4'b0001: begin // ADD
                result = add_result;
                flags = add_flags;
            end
            4'b0010: begin // SUB
                result = sub_result;
                flags = sub_flags;
            end
            4'b0011: begin // MUL
                result = mul_result;
                flags = mul_flags;
            end
            4'b0100: begin // DIV
                result = div_result;
                if (operand2 == 8'b0) begin
                    flags = 4'b1001; // Divisão por zero: Zero flag (Z) e Overflow flag (V)
                end else begin
                    flags[0] = (result == 8'b00000000); // Zero flag (Z)
                    flags[1] = result[7];              // Sign flag (S)
                    flags[2] = 0;                      // Carry flag (não se aplica)
                    flags[3] = 0;                      // Overflow flag (não se aplica)
                end
            end
            4'b0101: begin // MOD
                result = mod_result;
                flags[0] = (mod_result == 8'b00000000); // Zero flag (Z)
                flags[1] = mod_result[7];              // Sign flag (S)
                flags[2] = 0;                          // Carry flag (não se aplica)
                flags[3] = 0;                          // Overflow flag (não se aplica)
            end
            4'b0110: begin // AND
                result = and_result;
                flags[0] = (and_result == 8'b00000000); // Zero flag (Z)
                flags[1] = and_result[7];              // Sign flag (S)
                flags[2] = 0;                          // Carry flag (não se aplica)
                flags[3] = 0;                          // Overflow flag (não se aplica)
            end
            4'b0111: begin // OR
                result = or_result;
                flags[0] = (or_result == 8'b00000000); // Zero flag (Z)
                flags[1] = or_result[7];              // Sign flag (S)
                flags[2] = 0;                          // Carry flag (não se aplica)
                flags[3] = 0;                          // Overflow flag (não se aplica)
            end
            4'b1000: begin // XOR
                result = xor_result;
                flags[0] = (xor_result == 8'b00000000); // Zero flag (Z)
                flags[1] = xor_result[7];              // Sign flag (S)
                flags[2] = 0;                          // Carry flag (não se aplica)
                flags[3] = 0;                          // Overflow flag (não se aplica)
            end
            4'b1001: begin // NOT
                result = not_result;
                flags[0] = (not_result == 8'b00000000); // Zero flag (Z)
                flags[1] = not_result[7];              // Sign flag (S)
                flags[2] = 0;                          // Carry flag (não se aplica)
                flags[3] = 0;                          // Overflow flag (não se aplica)
            end
            4'b1010: begin // NOR
                result = nor_result;
                flags[0] = (nor_result == 8'b00000000); // Zero flag (Z)
                flags[1] = nor_result[7];              // Sign flag (S)
                flags[2] = 0;                          // Carry flag (não se aplica)
                flags[3] = 0;                          // Overflow flag (não se aplica)
            end
            4'b1011: begin // NAND
                result = nand_result;
                flags[0] = (nand_result == 8'b00000000); // Zero flag (Z)
                flags[1] = nand_result[7];              // Sign flag (S)
                flags[2] = 0;                           // Carry flag (não se aplica)
                flags[3] = 0;                           // Overflow flag (não se aplica)
            end
            4'b1100: begin // XNOR
                result = xnor_result;
                flags[0] = (xnor_result == 8'b00000000); // Zero flag (Z)
                flags[1] = xnor_result[7];              // Sign flag (S)
                flags[2] = 0;                           // Carry flag (não se aplica)
                flags[3] = 0;                           // Overflow flag (não se aplica)
            end
          	4'b1110: begin // DESLOCAMENTO PRA ESQUERDA
                flags[0] = (result == 8'b00000000); // Zero flag (Z)
                flags[1] = result[7];              // Sign flag (S)
                flags[2] = carry;                  // Carry flag
                flags[3] = 0;                      // Overflow flag (não se aplica)
                result = shift_result;
            end
            4'b1111: begin // DESLOCAMENTO PRA DIREITA
                flags[0] = (result == 8'b00000000); // Zero flag (Z)
                flags[1] = result[7];              // Sign flag (S)
                flags[2] = carry;                  // Carry flag
                flags[3] = 0;                      // Overflow flag (não se aplica)
            	result = shift_result;
            end
            default: begin // Operação inválida
                result = 8'b0;
                flags = 4'b0000;
            end
        endcase
    end

endmodule
