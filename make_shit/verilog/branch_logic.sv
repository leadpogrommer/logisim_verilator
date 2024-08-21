`timescale 1ns / 1ps

module branch_logic(
    input wire [3:0] cccc /*!p:l*/,
    input wire [3:0] CVZN,

    output wire go /*!p:r*/
);
    wire C, V, Z, N;
    reg dcsn;

    assign {C, V, Z, N} = CVZN;

    wire reverse = cccc[0];
    assign go = dcsn ^ reverse;

    always_comb begin
        case (cccc[3:1])
            0: dcsn = Z;
            1: dcsn = C;
            2: dcsn = N;
            3: dcsn = V;
            4: dcsn = C & (~Z) & 1;
            5: dcsn = ~(N ^ V) & 1;
            6: dcsn = (~Z) & ~(N ^ V) & 1;
            7: dcsn = 1;
        endcase
    end

endmodule