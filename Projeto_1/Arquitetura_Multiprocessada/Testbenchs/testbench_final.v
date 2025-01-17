module Testbench;
    reg clk;
    reg reset;
    wire [7:0] opcode, operand1, operand2; // Sinais das instruções
    wire [7:0] result;                     // Resultado da operação
    wire [7:0] flags;                      // Flags da ULA

    // Instância do carregador de instruções
    InstructionLoader loader(
        .opcode(opcode),
        .operand1(operand1),
        .operand2(operand2),
        .clk(clk),
        .reset(reset)
    );

    // Instância do processador
    Processador cpu(
        .clk(clk),
        .reset(reset),
        .opcode(opcode),
        .operand1(operand1),
        .operand2(operand2),
        .result(result),
        .flags(flags)
    );

    // Geração de clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Clock com período de 10 unidades de tempo
    end

    // Simulação
    initial begin
        reset = 1;
        #10 reset = 0; // Desativa o reset após 10 unidades de tempo

        // Exibindo os resultados no log
        #20; // Atraso inicial para estabilização
        $display("Iniciando simulação...");
        
        // Simula o processamento das instruções
        #50; // Aguarda 50 unidades de tempo para observar os primeiros resultados
        $display("Resultado: %b, Flags: %b", result, flags);

        // Adicione mais observações de resultados conforme necessário
        #200 $finish;  // Finaliza a simulação após 200 unidades de tempo
    end
endmodule