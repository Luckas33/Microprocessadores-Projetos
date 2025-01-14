module DIV (
    input [7:0] a,  // Dividendo
    input [7:0] b,  // Divisor
    output reg [7:0] quotient,  // Quociente
    output reg [7:0] remainder  // Resto
);
    integer i;

    always @(*) begin
        quotient = 0;  // Inicializa o quociente como 0
        remainder = a;  // Inicializa o resto como o dividendo

        // Loop de subtração sucessiva
        for (i = 0; i < 8; i = i + 1) begin  // gambiarra que funciona é mudar para 100 o 8
            if (remainder >= b) begin
                remainder = remainder - b;  // Subtrai o divisor do resto
                quotient = quotient + 1;  // Incrementa o quociente
            end
        end
    end

endmodule