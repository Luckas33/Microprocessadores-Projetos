`timescale 1ns / 1ps

module BitManipulation_tb;

    // Entradas
    reg [7:0] data_in;
    reg enable_shift;
    reg direction_shift;
    reg enable_rotate;
    reg direction_rotate;

    // Saídas
    wire [7:0] data_out;
    wire carry;

    // Instância do módulo a ser testado
    BitManipulation uut (
        .data_in(data_in),
        .enable_shift(enable_shift),
        .direction_shift(direction_shift),
        .enable_rotate(enable_rotate),
        .direction_rotate(direction_rotate),
        .data_out(data_out),
        .carry(carry)
    );

    // Teste de deslocamento e rotação
    initial begin
        $display("Início dos testes para BitManipulation");

        // Caso inicial
        data_in = 8'b00001100; 
        enable_shift = 0; 
        enable_rotate = 0; 
        direction_shift = 0; 
        direction_rotate = 0; 
        #10;
        $display("Inicial: Entrada=%b, Saída=%b, Carry=%b", data_in, data_out, carry);

        // Teste de shift para a esquerda
        enable_shift = 1; 
        direction_shift = 0; // Para a esquerda
        #10;
        $display("Shift Left: Entrada=%b, Saída=%b, Carry=%b", data_in, data_out, carry);

        // Teste de shift para a direita
        direction_shift = 1; // Para a direita
        #10;
        $display("Shift Right: Entrada=%b, Saída=%b, Carry=%b", data_in, data_out, carry);

        // Teste de rotação para a esquerda
        enable_shift = 0; 
        enable_rotate = 1; 
        direction_rotate = 0; // Para a esquerda
        #10;
        $display("Rotate Left: Entrada=%b, Saída=%b, Carry=%b", data_in, data_out, carry);

        // Teste de rotação para a direita
        direction_rotate = 1; // Para a direita
        #10;
        $display("Rotate Right: Entrada=%b, Saída=%b, Carry=%b", data_in, data_out, carry);

        $display("Fim dos testes para BitManipulation");
        $finish;
    end

endmodule
