`timescale 1ns / 1ps

module ALU(
    input wire [15:0] A /*!p:l*/,
    input wire [15:0] B,
    input wire Cin /*!p:t,t:Cin*/,

    output wire [15:0] S /*!p:r*/,
    output wire [3:0] CVZN,

    input wire [2:0] op_type /*!p:b,t:op,s:30*/,
    input wire [2:0] func /*!t:f*/,
    input wire [2:0] shif_count_ni /*!t:shift*/
);
function automatic checkC(input [16:0] i);
    checkC = i[16];
endfunction

function automatic checkV(input [15:0] rd, rs0, rs1); // TODO: check this
    checkV = ((rd[15] != 0) && (rs0[15] == 0) && (rs1[15] == 0)) ||
             ((rd[15] == 0) && (rs0[15] != 0) && (rs1[15] != 0)) ;
endfunction


    reg C;
    reg V;
    wire Z;
    wire N;
    assign CVZN[3:0] = {C, V, Z, N};

    assign Z = S == 16'd0;
    assign N = S[15];
    assign S = wS[15:0];

    wire [16:0] wA = {1'd0, A};
    wire [16:0] wB = {1'd0, B};
    reg  [16:0] wS;

    wire [4:0] wShiftCount = 5'd1 + {2'b0, shif_count_ni};


    always  begin
        case (op_type)
            default: begin
                wS = 0;
                C = 0;
                V = 0;
            end
            3'b001: begin // ALU_3
                case(func)
                    0: begin // AND
                        C = 0;
                        V = 0;
                        wS = wA & wB;
                    end
                    1: begin // OR
                        C = 0;
                        V = 0;
                        wS = wA | wB;
                    end
                    2: begin // XOR
                        C = 0;
                        V = 0;
                        wS = wA ^ wB;
                    end
                    3: begin // BIC
                        C = 0;
                        V = 0;
                        wS = wA & (wB ^ 17'hffff);
                    end
                    4: begin // ADD
                        wS = A + B;
                        C = checkC(wS);
                        V = checkV(S, A, B);
                    end
                    5: begin // ADC
                        wS = wA + wB + {16'd0, Cin};
                        C = checkC(wS);
                        V = checkV(S, A, B +{15'd0, Cin}); // TODO: maybe there's overflow in second arg
                    end
                    6: begin // SUB
                        wS = wA + (wB ^ 17'hffff) + 1;
                        C = checkC(wS);
                        V = checkV(S, A, (~B) + 1); // TODO: maybe there's overflow in second arg
                    end
                    7: begin // SBC
                        wS = wA + (wB ^ 17'hffff) + {16'd0, Cin};
                        C = checkC(wS);
                        V = checkV(S, A, (~B) + {15'd0, Cin}); // TODO: maybe there's overflow in second arg
                    end
                endcase
            end
            3'b010: begin // ALU_2
                case(func)
                    default: begin
                        wS = 0;
                        C = 0;
                        V = 0;
                    end
                    0: begin // NEG
                        wS = (wA ^ 17'hffff) + 1;
                        C = checkC(wS);
                        V = A == 16'h8000;
                    end
                    1: begin // NOT
                        wS = wA ^ 17'hffff;
                        C = 0;
                        V = 0;
                    end
                    2: begin // SXT
                        wS = {1'd0, {8{wA[7]}}, wA[7:0]};
                        C = 0;
                        V = 0;
                    end
                    3: begin // SCL
                        wS = wA & 17'h00FF;
                        C = 0;
                        V = 0;
                    end
                endcase
            end
            3'b100: begin
                V = 0;
                case(func)
                    default: begin
                        wS = 0;
                        C = 0;
                    end
                    0: begin // SHL
                        wS = wA << wShiftCount;
                        C = wA[16 - wShiftCount];
                    end
                    1: begin // SHR
                        wS = wA >> wShiftCount;
                        C = wA[wShiftCount - 1];
                    end
                    2: begin // SHRA
                        wS = {1'b0, (A >>> wShiftCount) | ({16{A[15]}} << (16 - wShiftCount))};
                        C = wA[wShiftCount - 1];
                    end
                    3: begin // ROL
                        wS = {1'b0, (A << wShiftCount) | {A >> (16 - wShiftCount)}};
                        C = wA[16 - wShiftCount];
                    end
                    4: begin // ROR
                        wS = {1'b0, (A >> wShiftCount) | {A << (16 - wShiftCount)}};
                        C = wA[wShiftCount - 1];
                    end
                    5: begin // RCL
                        wS = {1'b0, (A << wShiftCount) | {{15'd0, Cin} << (wShiftCount - 1)} |  {A >> (16 - wShiftCount + 1)}};
                        C = wA[16 - wShiftCount];
                    end
                    6: begin // RCR
                        wS = {1'b0, (A >> wShiftCount) | {{15'd0, Cin} << (16 - wShiftCount)} | {A << (16 - wShiftCount + 1)}};
                        C = wA[wShiftCount - 1];
                    end
                endcase
            end
        endcase
    end
    

endmodule