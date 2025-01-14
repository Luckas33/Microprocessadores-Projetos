`timescale 1ns/1ps

module testbench_multiplicacao;

    reg [7:0] a, b;       // Entradas
    wire [7:0] result;    // Saída

    // Instanciar o módulo de multiplicação
    MUL uut (
        .a(a),
        .b(b),
        .result(result)
    );

    initial begin
        // Testar alguns casos
        a = 8'd3; b = 8'd4; #10; // 3 * 4 = 12
        $display("a=%d, b=%d, result=%d", a, b, result);

        a = 8'd15; b = 8'd2; #10; // 15 * 2 = 30
        $display("a=%d, b=%d, result=%d", a, b, result);

        a = 8'd10; b = 8'd10; #10; // 10 * 10 = 100
        $display("a=%d, b=%d, result=%d", a, b, result);

        $stop;
    end

endmodule
