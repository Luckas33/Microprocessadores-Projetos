module MOD (
    input [7:0] a,
    input [7:0] b,
    output [7:0] remainder
);
    reg [7:0] r;
    integer i;

    always @(*) begin
        r = a;
        for (i = 7; i >= 0; i = i - 1) begin
            if (r >= (b << i)) begin
                r = r - (b << i);
            end
        end
    end

    assign remainder = r;
endmodule