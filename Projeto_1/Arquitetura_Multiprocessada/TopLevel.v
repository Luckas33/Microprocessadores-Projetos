module TopLevel ( // faz a integração do instruction loader, memória externa e processador
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
