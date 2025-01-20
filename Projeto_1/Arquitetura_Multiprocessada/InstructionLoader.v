module InstructionLoader ( // lê arquivo binário
    input clk,                     // Clock
    input reset,                   // Reset
    output reg [7:0] opcode,       // Opcode da instrução
    output reg [7:0] operand1,     // Primeiro operando
    output reg [7:0] operand2,     // Segundo operando
    output reg done,               // Indica que todas as instruções foram processadas
    output reg write_enable,       // Habilita escrita na memória
    output reg [7:0] address,      // Endereço para a memória
    output reg [23:0] data_out     // Dados para a memória
);

    reg [7:0] memory [0:255];      // Memória interna para carregar o arquivo
    reg [7:0] pc;                  // Contador de programa (PC)
    reg [2:0] state;               // Máquina de estados

    localparam LOAD_OPCODE   = 3'b000;
    localparam LOAD_OPERAND1 = 3'b001;
    localparam LOAD_OPERAND2 = 3'b010;
    localparam STORE         = 3'b011;
    localparam DONE          = 3'b100;

    initial begin
        $readmemb("instructions.bin", memory); // Carrega instruções de arquivo
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc <= 0;
            opcode <= 0;
            operand1 <= 0;
            operand2 <= 0;
            write_enable <= 0;
            address <= 0;
            data_out <= 0;
            state <= LOAD_OPCODE;
            done <= 0;
        end else begin
            case (state)
                LOAD_OPCODE: begin
                    if (pc < 256) begin
                        opcode <= memory[pc];
                        pc <= pc + 1;
                        state <= LOAD_OPERAND1;
                    end else begin
                        state <= DONE;
                    end
                end
                LOAD_OPERAND1: begin
                    operand1 <= memory[pc];
                    pc <= pc + 1;
                    state <= LOAD_OPERAND2;
                end
                LOAD_OPERAND2: begin
                    operand2 <= memory[pc];
                    pc <= pc + 1;
                    state <= STORE;
                end
                STORE: begin
                    write_enable <= 1;
                    address <= pc / 3;
                    data_out <= {opcode, operand1, operand2};
                    state <= LOAD_OPCODE;
                end
                DONE: begin
                    done <= 1;
                end
            endcase
        end
    end
endmodule
