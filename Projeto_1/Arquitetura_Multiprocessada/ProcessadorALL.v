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
    assign status_flags[3] = (a[7] == b[7]) && (result[7] != a[7]);

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
    output reg [3:0] status_flags
);
    reg [7:0] temp_a;       // Valor deslocado de 'a'
    reg [7:0] temp_b;       // Valor deslocado de 'b'
    reg [7:0] sum;          // Resultado parcial da soma
    reg [15:0] product;     // Produto parcial
    integer i;

    // Instância do módulo de soma
    wire [7:0] add_result;
    ADD adder(.a(product[7:0]), .b(temp_a), .result(add_result));

    always @(*) begin
        // Inicialização
        temp_a = a;
        temp_b = b;
        product = 0;

        // Algoritmo de multiplicação (baseado em deslocamentos e somas)
        for (i = 0; i < 8; i = i + 1) begin
            if (temp_b[0] == 1) begin
                sum = add_result;   // Soma parcial usando o módulo ADD
                product[7:0] = sum; // Atualiza os 8 bits menos significativos do produto
            end
            temp_a = temp_a << 1; // Desloca 'temp_a' para a esquerda (multiplica por 2)
            temp_b = temp_b >> 1; // Desloca 'temp_b' para a direita (divide por 2)
        end

        // Retorna apenas os 8 bits menos significativos
        result = product[7:0];

        // Cálculo das flags:
        // Zero flag (Z) -> se o resultado for 0
        status_flags[0] = (result == 8'b00000000);

        // Sign flag (S) -> se o bit mais significativo do resultado for 1
        status_flags[1] = result[7];

        // Carry flag (C) -> se houver overflow do produto para além de 8 bits
        status_flags[2] = (product[15:8] != 8'b00000000); // Se os 8 bits mais significativos do produto não são zero, houve carry

        // Overflow flag (V) -> ocorre quando dois números de sinais iguais produzem um resultado de sinal oposto
        status_flags[3] = (a[7] == b[7]) && (result[7] != a[7]);
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
    integer i;
    always @(*) begin
        for (i = 0; i < 8; i = i + 1) begin
            // Operação AND bit a bit
            if (a[i] == 1'b1 && b[i] == 1'b1) 
                result[i] = 1'b1;
            else 
                result[i] = 1'b0;
        end
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

module ULA (
    input [3:0] ula_operation,
    input [7:0] operand1,
    input [7:0] operand2,
    output reg [7:0] result,
    output reg [7:0] flags
);

    wire [7:0] add_result, sub_result, mul_result, div_result, mod_result;
    wire [7:0] and_result, or_result, xor_result, not_result, nor_result, nand_result, xnor_result;
    wire [3:0] add_flags, sub_flags, mul_flags;
    
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
            result = div_result;
            if (operand2 == 8'b0) begin  // Corrigir de 'b' para 'operand2'
                result = 8'b0;  // Resultado 0 por erro de divisão (divisão por zero)
                flags[0] = 1;   // Zero flag (Z) - resultado é zero
                flags[1] = 0;   // Sign flag (S) - divisão por zero, não faz sentido aplicar
                flags[2] = 1;   // Carry flag (C) - erro de divisão por zero
                flags[3] = 0;   // Overflow flag (V) - não se aplica para divisão
            end else begin 
                flags[0] = (result == 8'b00000000);  // Zero flag (Z) - se o resultado é zero
                flags[1] = result[7];                // Sign flag (S) - se o bit mais significativo é 1
                flags[2] = 0;                        // Carry flag (C) - não se aplica diretamente
                flags[3] = 0;                        // Overflow flag (V) - não se aplica diretamente
            end
        end

        4'b0101: begin 
           result = mod_result; // MOD
          flags[0] = (mod_result == 8'b00000000); // Zero flag (Z)
          flags[1] = mod_result[7]; // Sign flag (S)
          flags[2] = 0; // Carry flag (não se aplica para MOD)
          flags[3] = 0; // Overflow flag (não se aplica para MOD)
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
            default: ula_operation = 4'b0000; // Operação inválida
        endcase
    end
endmodule

module Processador (
    input clk,
    input reset,
    input [7:0] opcode,         // Código da operação
    input [7:0] operand1,       // Operando 1
    input [7:0] operand2,       // Operando 2
    output [7:0] result,        // Resultado da operação
    output [7:0] flags          // Flags (Zero, Carry, etc.)
);

    // Conexões internas
    wire [7:0] ula_result;
    wire [7:0] regA_out, regB_out, regC_out;
    wire [7:0] ula_flags;
    wire [3:0] ula_operation;
    // Instância dos registradores
    Register regA(.clk(clk), .reset(reset), .data_in(operand1), .data_out(regA_out));
    Register regB(.clk(clk), .reset(reset), .data_in(operand2), .data_out(regB_out));
    Register regC(.clk(clk), .reset(reset), .data_in(ula_result), .data_out(regC_out));

    // Instância do Controller
    Controller controller(
        .opcode(opcode),
        .ula_operation(ula_operation)
    );

    // Instância da ULA
    ULA ula(
        .ula_operation(ula_operation),
        .operand1(regA_out),
        .operand2(regB_out),
        .result(ula_result),
        .flags(ula_flags)
    );

    // Flags e resultados saem da ULA
    assign result = regC_out;
    assign flags = ula_flags;

endmodule

module InstructionLoader (
    output reg [7:0] opcode,       // Opcode da instrução
    output reg [7:0] operand1,     // Primeiro operando
    output reg [7:0] operand2,     // Segundo operando
    input clk,                     // Clock para controle de execução
    input reset                    // Reset do contador
);
  reg [7:0] memory [0:2];      // Memória para carregar as instruções
    reg [7:0] pc;                  // Contador de programa (PC)

    initial begin
        // Carrega o arquivo binário na memória
        $readmemb("instructions.bin", memory);
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc <= 0;               // Reinicia o contador de programa
        end else begin
            // Decodifica a instrução atual
            opcode <= memory[pc];
            operand1 <= memory[pc + 1];
            operand2 <= memory[pc + 2];
            pc <= pc + 3;          // Avança para a próxima instrução
        end
    end
endmodule
