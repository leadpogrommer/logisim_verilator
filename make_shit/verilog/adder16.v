module adder16 (
    input wire [15:0] a,
    input wire [15:0] b,
    output wire [15:0] s
);
    assign s = a + b;
endmodule
