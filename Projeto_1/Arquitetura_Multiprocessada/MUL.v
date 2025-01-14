module MUL (
    input [7:0] a,
    input [7:0] b,
    output [7:0] result
);
    reg [15:0] product;
    integer i;

    always @(*) begin
        product = 0;
        for (i = 0; i < 8; i = i + 1) begin
            if (b[i] == 1)
                product = product + (a << i);
        end
    end

    assign result = product[7:0]; // Parte baixa do produto
endmodule