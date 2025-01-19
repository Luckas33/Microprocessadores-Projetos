`timescale 1ns / 1ps

module TopLevel_tb;

    reg clk;
    reg reset;
    wire [7:0] result;
    wire [3:0] flags;

    // Instância do TopLevel
    TopLevel dut (
        .clk(clk),
        .reset(reset),
        .result(result),
        .flags(flags)
    );

    // Clock de 10ns
    always #5 clk = ~clk;

    initial begin
        // Inicializa os sinais
        clk = 0;
        reset = 1;

        // Desasserta reset após alguns ciclos
        #20 reset = 0;
    end


endmodule
