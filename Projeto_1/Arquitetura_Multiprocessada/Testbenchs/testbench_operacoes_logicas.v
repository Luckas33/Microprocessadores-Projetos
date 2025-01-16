`timescale 1ns / 1ps

module testbench_logicas;

    // Entradas
    reg [7:0] operand1; // Primeiro operando
    reg [7:0] operand2; // Segundo operando

    // Saídas
    wire [7:0] and_result, or_result, xor_result, not_result, nor_result, nand_result, xnor_result;

    // Instanciação dos módulos
    AND and_gate (.a(operand1), .b(operand2), .result(and_result));
    OR or_gate (.a(operand1), .b(operand2), .result(or_result));
    XOR xor_gate (.a(operand1), .b(operand2), .result(xor_result));
    NOT not_gate (.a(operand1), .result(not_result));
    NOR nor_gate (.a(operand1), .b(operand2), .result(nor_result));
    NAND nand_gate (.a(operand1), .b(operand2), .result(nand_result));
    XNOR xnor_gate (.a(operand1), .b(operand2), .result(xnor_result));

    // Procedimento inicial para aplicar os testes
    initial begin
        $display("Tempo\tOperand1\tOperand2\tAND\t\tOR\t\tXOR\t\tNOT\t\tNOR\t\tNAND\t\tXNOR");

        // Teste 1
        operand1 = 8'b00001111; // Operando 1
        operand2 = 8'b10101010; // Operando 2
        #10; // Aguarda 10 unidades de tempo
        $display("%0t\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b", 
                 $time, operand1, operand2, and_result, or_result, xor_result, 
                 not_result, nor_result, nand_result, xnor_result);

        // Teste 2
        operand1 = 8'b11110000; // Operando 1
        operand2 = 8'b10101010; // Operando 2
        #10; // Aguarda 10 unidades de tempo
        $display("%0t\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b", 
                 $time, operand1, operand2, and_result, or_result, xor_result, 
                 not_result, nor_result, nand_result, xnor_result);

        // Teste 3
        operand1 = 8'b00000000; // Operando 1
        operand2 = 8'b11111111; // Operando 2
        #10; // Aguarda 10 unidades de tempo
        $display("%0t\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b", 
                 $time, operand1, operand2, and_result, or_result, xor_result, 
                 not_result, nor_result, nand_result, xnor_result);

        // Teste 4
        operand1 = 8'b11111111; // Operando 1
        operand2 = 8'b00000000; // Operando 2
        #10; // Aguarda 10 unidades de tempo
        $display("%0t\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b", 
                 $time, operand1, operand2, and_result, or_result, xor_result, 
                 not_result, nor_result, nand_result, xnor_result);

        // Teste 5
        operand1 = 8'b10101010; // Operando 1
        operand2 = 8'b01010101; // Operando 2
        #10; // Aguarda 10 unidades de tempo
        $display("%0t\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b", 
                 $time, operand1, operand2, and_result, or_result, xor_result, 
                 not_result, nor_result, nand_result, xnor_result);

        // Finaliza a simulação
        $finish;
    end

endmodule
