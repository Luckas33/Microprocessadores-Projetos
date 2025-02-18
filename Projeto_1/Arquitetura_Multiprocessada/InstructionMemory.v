module InstructionMemory ( // memória externa
    input clk,                  // Clock
    input [7:0] address,        // Endereço da instrução
    input write_enable,         // Habilita escrita
    input [23:0] data_in,       // Dados de entrada (instrução completa)
    output reg [23:0] data_out  // Dados de saída (instrução completa)
);

    reg [23:0] memory [0:255];  // Memória de 256 instruções de 24 bits

    always @(posedge clk) begin
        if (write_enable) begin
            memory[address] <= data_in; // Escreve na memória
        end
        data_out <= memory[address];   // Lê da memória
    end
endmodule
