module NOR (
    input [7:0] a,         // Primeiro operando
    input [7:0] b,         // Segundo operando
    output reg [7:0] result // Resultado da operação NOR
);
    integer i;
    always @(*) begin
        for (i = 0; i < 8; i = i + 1) begin
            // Operação NOR bit a bit
            if (a[i] == 1'b0 && b[i] == 1'b0)
                result[i] = 1'b1; // NOT OR é 1 quando ambos os bits são 0
            else
                result[i] = 1'b0;
        end
    end
endmodule
