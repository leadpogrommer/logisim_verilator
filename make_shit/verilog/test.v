module test(
    input wire clk,
    output wire[15:0] out
);
    reg [15:0] r;
    always @(posedge clk)
    begin
        r <= r + 16'b1;
    end;

    assign out = r;

endmodule