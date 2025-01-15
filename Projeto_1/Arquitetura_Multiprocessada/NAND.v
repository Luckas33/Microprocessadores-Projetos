module NAND (
    input [7:0] a,         // Primeiro operando
    input [7:0] b,         // Segundo operando
    output reg [7:0] result // Resultado da operação NAND
);
    integer i;
    always @(*) begin
        for (i = 0; i < 8; i = i + 1) begin
            // Operação NAND bit a bit
            if (a[i] == 1'b1 && b[i] == 1'b1)
                result[i] = 1'b0; // NOT AND é 0 quando ambos os bits são 1
            else
                result[i] = 1'b1;
        end
    end
endmodule
