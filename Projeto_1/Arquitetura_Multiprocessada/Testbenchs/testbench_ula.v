`timescale 1ns/1ps

module ULA_tb;

    // Entradas
    reg [3:0] ula_operation;
    reg [7:0] operand1;
    reg [7:0] operand2;

    // Saídas
    wire [7:0] result;
    wire [7:0] flags;

    // Instância da ULA
    ULA uut (
        .ula_operation(ula_operation),
        .operand1(operand1),
        .operand2(operand2),
        .result(result),
        .flags(flags)
    );

    // Inicialização
    initial begin
        // Monitoramento dos sinais
        $monitor("Time=%0d ns | Op=%b | Operand1=%b | Operand2=%b | Result=%b | Flags=%b",
                 $time, ula_operation, operand1, operand2, result, flags);

        // Teste 1: ADD
        #10 ula_operation = 4'b0001; // ADD
        operand1 = 8'b00000101;     // 5 em binário
        operand2 = 8'b00000110;     // 6 em binário
        #10; // Aguarde o resultado

        // Teste 2: SUB
        #10 ula_operation = 4'b0010; // SUB
        operand1 = 8'b00001100;     // 12 em binário
        operand2 = 8'b00000101;     // 5 em binário
        #10;

        // Teste 3: MUL
        #10 ula_operation = 4'b0011; // MUL
        operand1 = 8'b00000011;     // 3 em binário
        operand2 = 8'b00000010;     // 2 em binário
        #10;

        // Teste 4: DIV
        #10 ula_operation = 4'b0100; // DIV
        operand1 = 8'b00001000;     // 8 em binário
        operand2 = 8'b00000010;     // 2 em binário
        #10;

        // Teste 5: MOD
        #10 ula_operation = 4'b0101; // MOD
        operand1 = 8'b00001001;     // 9 em binário
        operand2 = 8'b00000010;     // 2 em binário
        #10;

        // Teste 6: AND
        #10 ula_operation = 4'b0110; // AND
        operand1 = 8'b10101010;     // Exemplo binário
        operand2 = 8'b11001100;     // Exemplo binário
        #10;

        // Teste 7: OR
        #10 ula_operation = 4'b0111; // OR
        operand1 = 8'b10101010;
        operand2 = 8'b11001100;
        #10;

        // Teste 8: XOR
        #10 ula_operation = 4'b1000; // XOR
        operand1 = 8'b10101010;
        operand2 = 8'b11001100;
        #10;

        // Teste 9: NOT
        #10 ula_operation = 4'b1001; // NOT
        operand1 = 8'b10101010;     // Operando para NOT
        operand2 = 8'b00000000;     // Ignorado para NOT
        #10;

        // Teste 10: Operação inválida
        #10 ula_operation = 4'b1111; // Operação inválida
        operand1 = 8'b00000000;
        operand2 = 8'b00000000;
        #10;

        // Finaliza a simulação
        $finish;
    end

endmodule
