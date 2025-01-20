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
