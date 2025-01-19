`timescale 1ns / 1ps

module Processor_tb;

    reg clk;
    reg reset;

    wire [7:0] opcode;
    wire [7:0] operand1;
    wire [7:0] operand2;
    wire done;

    // Instância do InstructionLoader
    InstructionLoader loader (
        .clk(clk),
        .reset(reset),
        .opcode(opcode),
        .operand1(operand1),
        .operand2(operand2),
        .done(done)
    );

    // Instância do Processador
    Processor uut (
        .clk(clk),
        .reset(reset),
        .opcode(opcode),
        .operand1(operand1),
        .operand2(operand2),
        .done(done),
        .result(),
        .flags()
    );

    // Geração do clock
    always #5 clk = ~clk;

    initial begin
        // Inicialização
        clk = 0;
        reset = 1;

        // Liberar reset após 10ns
        #10 reset = 0;

        // A simulação será encerrada automaticamente pelo $finish no módulo Processor
    end

endmodule
