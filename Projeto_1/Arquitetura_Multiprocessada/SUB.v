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

