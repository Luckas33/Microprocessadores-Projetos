`timescale 1ns/1ps

module Controller_tb;

    // Entradas
    reg [7:0] opcode;

    // Saídas
    wire [3:0] ula_operation;

    // Instância do Controller
    Controller uut (
        .opcode(opcode),
        .ula_operation(ula_operation)
    );

    // Inicialização
    initial begin
        // Monitoramento dos sinais
        $monitor("Time=%0dns | Opcode=%b | ULA Operation=%b", $time, opcode, ula_operation);

        // Teste 1: ADD
        #10 opcode = 8'b00000001; // ADD
        #10;

        // Teste 2: SUB
        #10 opcode = 8'b00000010; // SUB
        #10;

        // Teste 3: MUL
        #10 opcode = 8'b00000011; // MUL
        #10;

        // Teste 4: DIV
        #10 opcode = 8'b00000100; // DIV
        #10;

        // Teste 5: MOD
        #10 opcode = 8'b00000101; // MOD
        #10;

        // Teste 6: AND
        #10 opcode = 8'b00000110; // AND
        #10;

        // Teste 7: OR
        #10 opcode = 8'b00000111; // OR
        #10;

        // Teste 8: XOR
        #10 opcode = 8'b00001000; // XOR
        #10;

        // Teste 9: NOT
        #10 opcode = 8'b00001001; // NOT
        #10;

        // Teste 10: NOR
        #10 opcode = 8'b00001010; // NOR
        #10;

        // Teste 11: NAND
        #10 opcode = 8'b00001011; // NAND
        #10;

        // Teste 12: XNOR
        #10 opcode = 8'b00001100; // XNOR
        #10;

        // Teste 13: Operação inválida
        #10 opcode = 8'b11111111; // Operação inválida
        #10;

        // Finaliza a simulação
        $finish;
    end

endmodule
