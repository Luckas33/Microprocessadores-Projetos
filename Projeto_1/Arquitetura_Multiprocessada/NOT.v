module NOT (
    input [7:0] a,         // Operando único
    output reg [7:0] result // Resultado da operação NOT
);
    integer i;
    always @(*) begin
        for (i = 0; i < 8; i = i + 1) begin
            // Operação NOT bit a bit
            if (a[i] == 1'b1)
                result[i] = 1'b0;
            else 
                result[i] = 1'b1;
        end
    end
endmodule
