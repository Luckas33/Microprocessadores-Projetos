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