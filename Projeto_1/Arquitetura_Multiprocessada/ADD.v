module ADD (
    input [7:0] a,
    input [7:0] b,
    output [7:0] result
);
    wire [7:0] carry;

    // Primeiro bit (somador de meio-bit)
    half_adder HA0(.a(a[0]), .b(b[0]), .sum(result[0]), .carry(carry[0]));

    // Demais bits (somadores completos)
    full_adder FA1(.a(a[1]), .b(b[1]), .cin(carry[0]), .sum(result[1]), .cout(carry[1]));
    full_adder FA2(.a(a[2]), .b(b[2]), .cin(carry[1]), .sum(result[2]), .cout(carry[2]));
    full_adder FA3(.a(a[3]), .b(b[3]), .cin(carry[2]), .sum(result[3]), .cout(carry[3]));
    full_adder FA4(.a(a[4]), .b(b[4]), .cin(carry[3]), .sum(result[4]), .cout(carry[4]));
    full_adder FA5(.a(a[5]), .b(b[5]), .cin(carry[4]), .sum(result[5]), .cout(carry[5]));
    full_adder FA6(.a(a[6]), .b(b[6]), .cin(carry[5]), .sum(result[6]), .cout(carry[6]));
    full_adder FA7(.a(a[7]), .b(b[7]), .cin(carry[6]), .sum(result[7]), .cout(carry[7]));

endmodule

// Somador de meio-bit
module half_adder (
    input a,
    input b,
    output sum,
    output carry
);
    assign sum = a ^ b;
    assign carry = a & b;
endmodule

// Somador completo
module full_adder (
    input a,
    input b,
    input cin,
    output sum,
    output cout
);
    wire s1, c1, c2;
    half_adder HA1(.a(a), .b(b), .sum(s1), .carry(c1));
    half_adder HA2(.a(s1), .b(cin), .sum(sum), .carry(c2));
    assign cout = c1 | c2;
endmodule