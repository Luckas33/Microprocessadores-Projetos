module MUL (
    input [7:0] a,       // Primeiro operando
    input [7:0] b,       // Segundo operando
    output [7:0] result  // Resultado (produto)
);

    assign result = a * b; // Multiplicação direta

endmodule