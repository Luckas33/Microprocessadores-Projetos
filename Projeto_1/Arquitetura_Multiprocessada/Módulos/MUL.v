module MUL (
    input [7:0] a,          // Primeiro operando
    input [7:0] b,          // Segundo operando
    output reg [7:0] result, // Resultado da multiplicação
    output reg [3:0] status_flags // Flags de status
);
    reg [15:0] product;     // Produto parcial (16 bits para evitar perda de dados)
    integer i;

    always @(*) begin
        product = 0; // Inicializa o produto
        for (i = 0; i < 8; i = i + 1) begin
            if (b[i]) begin
                product = product + (a << i); // Soma parcial com deslocamento
            end
        end
        result = product[7:0]; // Apenas os 8 bits menos significativos
        // Configurar flags
        status_flags[0] = (result == 8'b0); // Zero flag
        status_flags[1] = result[7];        // Sign flag
        status_flags[2] = (product[15:8] != 0); // Carry flag
        status_flags[3] = 0;                // Overflow flag (não aplicável aqui)
    end
endmodule
