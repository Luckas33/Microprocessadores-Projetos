module SUB (
    input [7:0] a,
    input [7:0] b,
    output [7:0] result
);
    wire [7:0] b_complement;

    // Calcular complemento de dois do operando B
    assign b_complement = ~b + 1;

    // Somar A + (~B + 1) (usando o módulo ADD já implementado)
    ADD adder(.a(a), .b(b_complement), .result(result));

endmodule