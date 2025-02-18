module BitManipulation ( //Realiza as operações de deslocamento de bit a direita e à esquerda
    input [7:0] data_in, 
    input enable_shift,
    input direction_shift, 
    input enable_rotate,
    input direction_rotate,
    output reg [7:0] data_out,
    output reg carry
);
    always @(*) begin
        data_out = data_in;
        carry = 0;

        if (enable_shift) begin
            if (direction_shift == 0) begin // Shift para a esquerda
                data_out = data_in << 1;
                carry = data_in[7];
            end else begin // Shift para a direita
                data_out = data_in >> 1;
                carry = data_in[0];
            end
        end else if (enable_rotate) begin
            if (direction_rotate == 0) begin // Rotate para a esquerda
                data_out = {data_in[6:0], data_in[7]};
                carry = data_in[7];
            end else begin // Rotate para a direita
                data_out = {data_in[0], data_in[7:1]};
                carry = data_in[0];
            end
        end
    end
endmodule