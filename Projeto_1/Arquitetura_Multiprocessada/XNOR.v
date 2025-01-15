module XNOR (
    input [7:0] a,         // Primeiro operando
    input [7:0] b,         // Segundo operando
    output reg [7:0] result // Resultado da operação XNOR
);
    integer i;
    always @(*) begin
        for (i = 0; i < 8; i = i + 1) begin
            // Operação XNOR bit a bit
            if ((a[i] == 1'b1 && b[i] == 1'b1) || (a[i] == 1'b0 && b[i] == 1'b0))
                result[i] = 1'b1; // NOT XOR é 1 quando os bits são iguais
            else
                result[i] = 1'b0;
        end
    end
