module XOR (
    input [7:0] a,         // Primeiro operando
    input [7:0] b,         // Segundo operando
    output reg [7:0] result // Resultado da operação XOR
);
    integer i;
    always @(*) begin
        for (i = 0; i < 8; i = i + 1) begin
            // Operação XOR bit a bit
            if ((a[i] == 1'b1 && b[i] == 1'b0) || (a[i] == 1'b0 && b[i] == 1'b1))
                result[i] = 1'b1;
            else 
                result[i] = 1'b0;
        end
    end
endmodule
