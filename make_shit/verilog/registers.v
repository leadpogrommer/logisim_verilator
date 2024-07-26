`timescale 1ns / 1ps

module registers(
    input wire [2:0] rs0 /*!w:200,p:l*/,
    input wire [2:0] rs1,
    input wire [2:0] rd,

    input wire r_latch /*!p:b,t:l*/,
    input wire clk /*!t:clk*/,

    output wire [15:0] bus0 /*!p:r,s:40*/,
    output wire [15:0] bus1,
    output wire [15:0] busD_out,
    input wire [15:0] busD_in /*!s:10*/,

    output reg [15:0] regs /*!p:t,t:registers,s:20*/ [7:0]
);

    assign busD_out = regs[rd];
    assign bus0 = regs[rs0];
    assign bus1 = regs[rs1];

    always @(negedge clk) begin
        if (r_latch) regs[rd] = busD_in;
    end

endmodule