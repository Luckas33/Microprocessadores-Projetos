module MUL (
    input [7:0] a,          // Primeiro operando
    input [7:0] b,          // Segundo operando
    output reg [7:0] result, // Resultado da multiplicação
    output reg [3:0] status_flags
);
    reg [15:0] product;     // Produto parcial (16 bits para evitar perda de dados)
    reg [7:0] temp_a;       // Valor deslocado de 'a'
    reg [7:0] temp_b;       // Valor deslocado de 'b'
    integer i;

    always @(*) begin
        // Inicialização
        product = 0;        // Produto parcial
        temp_a = a;         // Operando a
        temp_b = b;         // Operando b

        // Algoritmo de multiplicação (multiplicação em série)
        for (i = 0; i < 8; i = i + 1) begin
            if (temp_b[0] == 1) begin
                product = product + temp_a; // Soma 'temp_a' ao produto parcial
            end
            temp_a = temp_a << 1; // Multiplica 'temp_a' por 2
            temp_b = temp_b >> 1; // Divide 'temp_b' por 2
        end

        // Resultado: 8 bits menos significativos do produto
        result = product[7:0];

        // Flags
        // Zero flag (Z): se o resultado for zero
        status_flags[0] = (result == 8'b00000000);

        // Sign flag (S): se o bit mais significativo do resultado for 1
        status_flags[1] = result[7];

        // Carry flag (C): se houve overflow para os bits superiores
        status_flags[2] = (product[15:8] != 8'b00000000);

        // Overflow flag (V): se dois números de sinais iguais produzem um sinal oposto
        status_flags[3] = (a[7] == b[7]) && (result[7] != a[7]);
    end
endmodule
