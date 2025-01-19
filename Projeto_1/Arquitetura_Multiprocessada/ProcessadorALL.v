`timescale 1ns / 1ps

module ADD (
    input [7:0] a,
    input [7:0] b,
    output [7:0] result,
    output [3:0] status_flags
);
    wire [7:0] carry;

    // Primeiro bit (somador de meio-bit)
    half_adder HA0(.a(a[0]), .b(b[0]), .sum(result[0]), .carry(carry[0]));

    // Demais bits (somadores completos)
    full_adder FA1(.a(a[1]), .b(b[1]), .cin(carry[0]), .sum(result[1]), .cout(carry[1]));
    full_adder FA2(.a(a[2]), .b(b[2]), .cin(carry[1]), .sum(result[2]), .cout(carry[2]));
    full_adder FA3(.a(a[3]), .b(b[3]), .cin(carry[2]), .sum(result[3]), .cout(carry[3]));
    full_adder FA4(.a(a[4]), .b(b[4]), .cin(carry[3]), .sum(result[4]), .cout(carry[4]));
    full_adder FA5(.a(a[5]), .b(b[5]), .cin(carry[4]), .sum(result[5]), .cout(carry[5]));
    full_adder FA6(.a(a[6]), .b(b[6]), .cin(carry[5]), .sum(result[6]), .cout(carry[6]));
    full_adder FA7(.a(a[7]), .b(b[7]), .cin(carry[6]), .sum(result[7]), .cout(carry[7]));

    assign status_flags[0] = (result == 8'b00000000);        // Zero flag (Z)
    assign status_flags[1] = result[7];                        // Sign flag (S)
    assign status_flags[2] = carry[7];                         // Carry flag (C)
    assign status_flags[3] = (a[7] == b[7] && result[7] != a[7]); // Overflow flag (V)

endmodule

// Somador de meio-bit
module half_adder (
    input a,
    input b,
    output sum,
    output carry
);
    assign sum = a ^ b;
    assign carry = a & b;
endmodule

// Somador completo
module full_adder (
    input a,
    input b,
    input cin,
    output sum,
    output cout
);
    wire s1, c1, c2;
    half_adder HA1(.a(a), .b(b), .sum(s1), .carry(c1));
    half_adder HA2(.a(s1), .b(cin), .sum(sum), .carry(c2));
    assign cout = c1 | c2;
endmodule


module SUB (
    input [7:0] a,
    input [7:0] b,
    output [7:0] result,
    output [3:0] status_flags
);
    wire [7:0] b_complement;
    
    // Calcular complemento de dois do operando B
    assign b_complement = ~b + 1;

    // Somar A + (~B + 1) (usando o módulo ADD já implementado)
    ADD adder(
        .a(a),
        .b(b_complement),
        .result(result),
        .status_flags({status_flags[3], status_flags[2], status_flags[1], status_flags[0]})
    );

    // Flags de status para subtração:
    // Zero flag (Z) -> se o resultado for 0
    assign status_flags[0] = (result == 8'b00000000); 

    // Sign flag (S) -> se o bit mais significativo do resultado for 1
    assign status_flags[1] = result[7]; 

    // Carry flag (C) -> flag de carry é 1 quando não há borrow, então usa a Carry Flag do módulo ADD
   // A Carry Flag já vem do módulo ADD

    // Overflow flag (V) -> ocorre quando os sinais dos operandos são diferentes e o sinal do resultado é incorreto
    assign status_flags[3] = (a[7] != b[7]) && (result[7] == b_complement[7]);

endmodule



module MUL (
    input [7:0] a,          // Primeiro operando
    input [7:0] b,          // Segundo operando
    output reg [7:0] result, // Resultado da multiplicação
    output reg [3:0] status_flags // Flags de status
);
    reg [15:0] product;     // Produto parcial (16 bits para evitar perda de dados)
    integer i;

    always @(*) begin
        product = 0; // Inicializa o produto
        for (i = 0; i < 8; i = i + 1) begin
            if (b[i]) begin
                product = product + (a << i); // Soma parcial com deslocamento
            end
        end
        result = product[7:0]; // Apenas os 8 bits menos significativos
        // Configurar flags
        status_flags[0] = (result == 8'b0); // Zero flag
        status_flags[1] = result[7];        // Sign flag
        status_flags[2] = (product[15:8] != 0); // Carry flag
        status_flags[3] = 0;                // Overflow flag (não aplicável aqui)
    end
endmodule




module DIV(
    input [7:0] a,         // Dividendo
    input [7:0] b,         // Divisor
    output reg [7:0] result // Quociente
);

    integer count; // Variável para contar o número de subtrações
    reg [7:0] temp_a; // Usado para manipular o dividendo sem alterá-lo

    always @(*) begin
        // Inicializando o quociente
        result = 8'b0;
        count = 0; // Contador de subtrações

        // Verificando divisão por zero
        if (b == 8'b0) begin
            result = 8'b0; // Retorna 0 se divisor for zero
        end else begin
            temp_a = a; // Copia o dividendo para manipulação

            // Realiza a subtração sucessiva enquanto o dividendo for maior ou igual ao divisor
            while (temp_a >= b) begin
                temp_a = temp_a - b; // Subtrai o divisor do dividendo
                count = count + 1;    // Incrementa o contador de subtrações
            end

            // O resultado é o número de subtrações
            result = count;
        end
    end

endmodule

module MOD (
    input [7:0] a,
    input [7:0] b,
    output [7:0] result
);
    reg [7:0] r;
    integer i;

    always @(*) begin
        r = a;
        for (i = 7; i >= 0; i = i - 1) begin
            if (r >= (b << i)) begin
                r = r - (b << i);
            end
        end
    end

    assign result = r;
endmodule

module AND (
    input [7:0] a,         // Primeiro operando
    input [7:0] b,         // Segundo operando
    output reg [7:0] result // Resultado da operação AND
);
    always @(*) begin
        result = a & b; // Operação AND bit a bit
    end
endmodule


module OR (
    input [7:0] a,         // Primeiro operando
    input [7:0] b,         // Segundo operando
    output reg [7:0] result // Resultado da operação OR
);
    integer i;
    always @(*) begin
        for (i = 0; i < 8; i = i + 1) begin
            // Operação OR bit a bit
            if (a[i] == 1'b1 || b[i] == 1'b1) 
                result[i] = 1'b1;
            else 
                result[i] = 1'b0;
        end
    end
endmodule

module XOR (
    input [7:0] a,         // Primeiro operando
    input [7:0] b,         // Segundo operando
    output reg [7:0] result // Resultado da operação XOR
);
    integer i;
    always @(*) begin
        for (i = 0; i < 8; i = i + 1) begin
            // Operação XOR bit a bit
            if ((a[i] == 1'b1 && b[i] == 1'b0) || (a[i] == 1'b0 && b[i] == 1'b1))
                result[i] = 1'b1;
            else 
                result[i] = 1'b0;
        end
    end
endmodule

module NOT (
    input [7:0] a,         // Operando único
    output reg [7:0] result // Resultado da operação NOT
);
    integer i;
    always @(*) begin
        for (i = 0; i < 8; i = i + 1) begin
            // Operação NOT bit a bit
            if (a[i] == 1'b1)
                result[i] = 1'b0;
            else 
                result[i] = 1'b1;
        end
    end
endmodule

module NAND (
    input [7:0] a,         // Primeiro operando
    input [7:0] b,         // Segundo operando
    output reg [7:0] result // Resultado da operação NAND
);
    integer i;
    always @(*) begin
        for (i = 0; i < 8; i = i + 1) begin
            // Operação NAND bit a bit
            if (a[i] == 1'b1 && b[i] == 1'b1)
                result[i] = 1'b0; // NOT AND é 0 quando ambos os bits são 1
            else
                result[i] = 1'b1;
        end
    end
endmodule

module NOR (
    input [7:0] a,         // Primeiro operando
    input [7:0] b,         // Segundo operando
    output reg [7:0] result // Resultado da operação NOR
);
    integer i;
    always @(*) begin
        for (i = 0; i < 8; i = i + 1) begin
            // Operação NOR bit a bit
            if (a[i] == 1'b0 && b[i] == 1'b0)
                result[i] = 1'b1; // NOT OR é 1 quando ambos os bits são 0
            else
                result[i] = 1'b0;
        end
    end
endmodule

module XNOR (
    input [7:0] a,         // Primeiro operando
    input [7:0] b,         // Segundo operando
    output reg [7:0] result // Resultado da operação XNOR
);
    integer i;
    always @(*) begin
        for (i = 0; i < 8; i = i + 1) begin
            // Operação XNOR bit a bit
            if ((a[i] == 1'b1 && b[i] == 1'b1) || (a[i] == 1'b0 && b[i] == 1'b0))
                result[i] = 1'b1; // NOT XOR é 1 quando os bits são iguais
            else
                result[i] = 1'b0;
        end
    end
endmodule

module BitManipulation ( //Realiza as operações de deslocamento de bit a direita e à esquerda
    input [7:0] data_in, 
    input enable_shift,
    input direction_shift, 
    input enable_rotate,
    input direction_rotate,
    output reg [7:0] data_out,
    output reg carry
);
    always @(*) begin
        data_out = data_in;
        carry = 0;

        if (enable_shift) begin
            if (direction_shift == 0) begin // Shift para a esquerda
                data_out = data_in << 1;
                carry = data_in[7];
            end else begin // Shift para a direita
                data_out = data_in >> 1;
                carry = data_in[0];
            end
        end else if (enable_rotate) begin
            if (direction_rotate == 0) begin // Rotate para a esquerda
                data_out = {data_in[6:0], data_in[7]};
                carry = data_in[7];
            end else begin // Rotate para a direita
                data_out = {data_in[0], data_in[7:1]};
                carry = data_in[0];
            end
        end
    end
endmodule

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


module Register (
    input clk,
    input reset,
    input [7:0] data_in,
    output reg [7:0] data_out
);

    always @(posedge clk or posedge reset) begin
        if (reset)
            data_out <= 8'b0;
        else
            data_out <= data_in;
    end

endmodule

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
          	8'b00001110: ula_operation = 4'b1110; // SLL
            8'b00001111: ula_operation = 4'b1111; // SRL
            default: ula_operation = 4'b0000; // Operação inválida
        endcase
    end
endmodule

module Processor (
    input clk,                   // Clock
    input reset,                 // Reset global
    input [7:0] opcode,          // Opcode
    input [7:0] operand1,        // Primeiro operando
    input [7:0] operand2,        // Segundo operando
    output reg [7:0] result,     // Resultado
    output reg [3:0] flags,      // Flags de status
    output reg ula_ready         // Sinal de "pronto" do processador
);

    wire [3:0] ula_operation;    // Operação decodificada pela ULA
    wire [7:0] ula_result;       // Resultado da ULA
    wire [3:0] ula_flags;        // Flags gerados pela ULA
    wire ula_ready_internal;     // Sinal de "pronto" da ULA

    // Registradores internos para armazenar operandos
    reg [7:0] reg_operand1;
    reg [7:0] reg_operand2;

    // Registradores para sincronizar o tempo de exibição
    reg [2:0] cycle_counter;      // Contador de ciclos de clock
    reg operation_started;        // Flag para verificar se a primeira operação foi concluída
    reg mov_active;               // Flag para controlar a operação de MOV
    reg mov_display_ready;        // Flag para indicar quando o display pode ser acionado
    reg [7:0] mov_result_buffer;  // Buffer temporário para o valor do resultado de MOV

    // Instância do controlador
    Controller controller (
        .opcode(opcode),
        .ula_operation(ula_operation)
    );

    // Instância da ULA
    ULA ula (
        .clk(clk),
        .reset(reset),
        .ula_operation(ula_operation),
        .operand1(reg_operand1),
        .operand2(reg_operand2),
        .result(ula_result),
        .flags(ula_flags),
        .ula_ready(ula_ready_internal) // Sinal pronto da ULA
    );

    // Processamento síncrono
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Resetar sinais e registradores
            result <= 8'b0;
            flags <= 4'b0;
            ula_ready <= 1'b0;
            reg_operand1 <= 8'b0;
            reg_operand2 <= 8'b0;
            cycle_counter <= 3'b0; // Reseta o contador de ciclos
            operation_started <= 1'b0; // Reseta a flag de início de operação
            mov_active <= 1'b0;    // Reseta a flag de MOV
            mov_display_ready <= 1'b0; // Reseta a flag de exibição do MOV
            mov_result_buffer <= 8'b0; // Reseta o buffer de resultado do MOV
        end else begin
            if (opcode == 8'b00001101) begin // Operação MOV
                if (!mov_active) begin
                    // Primeiro ciclo: copia o valor do operand1 para o buffer de resultado
                    mov_result_buffer <= operand1;
                    flags <= 4'b0000; // Flags podem ser ajustadas conforme necessário
                    ula_ready <= 1'b1;
                    mov_active <= 1'b1; // Ativa a operação de MOV
                    mov_display_ready <= 1'b0; // Prepara para exibir no próximo ciclo
                  	
                end else if (!mov_display_ready) begin
                    // Segundo ciclo: prepara para exibir o valor
                    result <= mov_result_buffer; // Atualiza o resultado
                    mov_display_ready <= 1'b1;
                  	$display(
                        "Time=%0dns | Opcode=MOV | Source=operand1 | Destination=result | Flags=%b",
                        $time, flags
                    );
                end else if (mov_display_ready) begin
                    // Exibe o resultado no segundo ciclo apenas
                    $display(
                        "Time=%0dns | Opcode=MOV | Source=%b | Destination=%b | Flags=%b",
                        $time, mov_result_buffer, result, flags
                    );
                    mov_active <= 1'b0; // Finaliza a operação de MOV
                    mov_display_ready <= 1'b0;
                end
            end else if (ula_ready_internal) begin
                if (!operation_started) begin
                    // Primeira operação concluída
                    operation_started <= 1'b1;
                    result <= ula_result;
                    flags <= ula_flags;
                    ula_ready <= 1'b1;

                    // Exibição imediata da primeira operação
                    $display(
                        "Time=%0dns | Opcode=%b | Operand1=%b | Operand2=%b | ULA Operation=%b | Result=%b | Flags=%b",
                        $time, opcode, reg_operand1, reg_operand2, ula_operation, ula_result, ula_flags
                    );
                end else if (cycle_counter < 3) begin
                    // Incrementa o contador de ciclos após a primeira operação
                    cycle_counter <= cycle_counter + 1;
                    ula_ready <= 1'b0;
                end else begin
                    // Atualiza os resultados após 4 ciclos de clock
                    result <= ula_result;
                    flags <= ula_flags;
                    ula_ready <= 1'b1;

                    // Exibição após 4 ciclos
                    $display(
                        "Time=%0dns | Opcode=%b | Operand1=%b | Operand2=%b | ULA Operation=%b | Result=%b | Flags=%b",
                        $time, opcode, reg_operand1, reg_operand2, ula_operation, ula_result, ula_flags
                    );

                    // Reseta o contador para a próxima operação
                    cycle_counter <= 3'b0;
                end
            end else begin
                ula_ready <= 1'b0; // Enquanto a ULA não estiver pronta
                cycle_counter <= 3'b0; // Reseta o contador caso a ULA reinicie
            end

            // Armazena os operandos para manter consistência com a operação em andamento
            reg_operand1 <= operand1;
            reg_operand2 <= operand2;
        end
    end

endmodule



module InstructionMemory (
    input clk,                  // Clock
    input [7:0] address,        // Endereço da instrução
    input write_enable,         // Habilita escrita
    input [23:0] data_in,       // Dados de entrada (instrução completa)
    output reg [23:0] data_out  // Dados de saída (instrução completa)
);

    reg [23:0] memory [0:255];  // Memória de 256 instruções de 24 bits

    always @(posedge clk) begin
        if (write_enable) begin
            memory[address] <= data_in; // Escreve na memória
        end
        data_out <= memory[address];   // Lê da memória
    end
endmodule

module InstructionLoader (
    input clk,                     // Clock
    input reset,                   // Reset
    output reg [7:0] opcode,       // Opcode da instrução
    output reg [7:0] operand1,     // Primeiro operando
    output reg [7:0] operand2,     // Segundo operando
    output reg done,               // Indica que todas as instruções foram processadas
    output reg write_enable,       // Habilita escrita na memória
    output reg [7:0] address,      // Endereço para a memória
    output reg [23:0] data_out     // Dados para a memória
);

    reg [7:0] memory [0:255];      // Memória interna para carregar o arquivo
    reg [7:0] pc;                  // Contador de programa (PC)
    reg [2:0] state;               // Máquina de estados

    localparam LOAD_OPCODE   = 3'b000;
    localparam LOAD_OPERAND1 = 3'b001;
    localparam LOAD_OPERAND2 = 3'b010;
    localparam STORE         = 3'b011;
    localparam DONE          = 3'b100;

    initial begin
        $readmemb("instructions.bin", memory); // Carrega instruções de arquivo
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc <= 0;
            opcode <= 0;
            operand1 <= 0;
            operand2 <= 0;
            write_enable <= 0;
            address <= 0;
            data_out <= 0;
            state <= LOAD_OPCODE;
            done <= 0;
        end else begin
            case (state)
                LOAD_OPCODE: begin
                    if (pc < 256) begin
                        opcode <= memory[pc];
                        pc <= pc + 1;
                        state <= LOAD_OPERAND1;
                    end else begin
                        state <= DONE;
                    end
                end
                LOAD_OPERAND1: begin
                    operand1 <= memory[pc];
                    pc <= pc + 1;
                    state <= LOAD_OPERAND2;
                end
                LOAD_OPERAND2: begin
                    operand2 <= memory[pc];
                    pc <= pc + 1;
                    state <= STORE;
                end
                STORE: begin
                    write_enable <= 1;
                    address <= pc / 3;
                    data_out <= {opcode, operand1, operand2};
                    state <= LOAD_OPCODE;
                end
                DONE: begin
                    done <= 1;
                end
            endcase
        end
    end
endmodule

module TopLevel (
    input clk,
    input reset,
    output [7:0] result,
    output [3:0] flags,
    output reg done // Sinal indicando que a execução foi encerrada
);

    wire [7:0] opcode, operand1, operand2;
    wire [23:0] instruction;
    wire write_enable;
    wire [7:0] address;
    wire [23:0] data_out;

    reg stop_execution; // Controle interno para interromper o processamento

    // Memória de instruções
    InstructionMemory instr_mem (
        .clk(clk),
        .address(address),
        .write_enable(write_enable),
        .data_in(data_out),
        .data_out(instruction)
    );

    // Carregador de instruções
    InstructionLoader instr_loader (
        .clk(clk),
        .reset(reset),
        .opcode(opcode),
        .operand1(operand1),
        .operand2(operand2),
        .done(),
        .write_enable(write_enable),
        .address(address),
        .data_out(data_out)
    );

    // Processador
    Processor processor (
        .clk(clk),
        .reset(reset),
        .opcode(opcode),
        .operand1(operand1),
        .operand2(operand2),
        .result(result),
        .flags(flags)
    );

    // Controle de término
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            done <= 1'b0;
            stop_execution <= 1'b0;
        end else begin
         
            if (opcode === 8'bxxxxxxxx) begin
                stop_execution <= 1'b1;
                done <= 1'b1; 
              	$finish;
            end
        end
    end

    // Controla o sinal de write_enable para evitar operações após o término
    assign write_enable = ~stop_execution;

endmodule
