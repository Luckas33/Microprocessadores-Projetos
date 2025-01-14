module MUL (
    input [7:0] a,          // Primeiro operando
    input [7:0] b,          // Segundo operando
    output reg [7:0] result // Resultado da multiplicação
);
    reg [7:0] temp_a;       // Valor deslocado de 'a'
    reg [7:0] temp_b;       // Valor deslocado de 'b'
    reg [7:0] sum;          // Resultado parcial da soma
    reg [15:0] product;     // Produto parcial
    integer i;

    // Instância do módulo de soma
    wire [7:0] add_result;
    ADD adder(.a(product[7:0]), .b(temp_a), .result(add_result));

    always @(*) begin
        // Inicialização
        temp_a = a;
        temp_b = b;
        product = 0;

        // Algoritmo de multiplicação (baseado em deslocamentos e somas)
        for (i = 0; i < 8; i = i + 1) begin
            if (temp_b[0] == 1) begin
                sum = add_result;   // Soma parcial usando o módulo ADD
                product[7:0] = sum; // Atualiza os 8 bits menos significativos do produto
            end
            temp_a = temp_a << 1; // Desloca 'temp_a' para a esquerda (multiplica por 2)
            temp_b = temp_b >> 1; // Desloca 'temp_b' para a direita (divide por 2)
        end

        // Retorna apenas os 8 bits menos significativos
        result = product[7:0];
    end
endmodule