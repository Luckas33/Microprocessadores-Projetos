module DIV(
    input [7:0] a,         // Dividendo
    input [7:0] b,         // Divisor
    output reg [7:0] result // Quociente
);

    integer count; // Variável para contar o número de subtrações
    reg [7:0] temp_a; // Usado para manipular o dividendo sem alterá-lo

    always @(*) begin
        // Inicializando o quociente
        result = 8'b0;
        count = 0; // Contador de subtrações

        // Verificando divisão por zero
        if (b == 8'b0) begin
            result = 8'b0; // Retorna 0 se divisor for zero
        end else begin
            temp_a = a; // Copia o dividendo para manipulação

            // Realiza a subtração sucessiva enquanto o dividendo for maior ou igual ao divisor
            while (temp_a >= b) begin
                temp_a = temp_a - b; // Subtrai o divisor do dividendo
                count = count + 1;    // Incrementa o contador de subtrações
            end

            // O resultado é o número de subtrações
            result = count;
        end
    end

endmodule