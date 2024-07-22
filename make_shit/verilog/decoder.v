localparam UC_IMM_EXTEND_NEGATIVE = 5;
localparam UC_IMM_SHIFT = 6;

`define IT(NAME, T, COND=(1)) wire NAME = (inst_type == T) && COND

module decoder(
    // inputs
    input wire [15:0] instruction /*!p:l*/,
    input wire [3:0] CVZN,
    input wire [27:0] ucommand,
    input wire [2:0] phase,
    input wire exc_triggered,


    // outputs
    output wire jsr /*!p:r*/,
    output wire rti,
    output wire _int, // ok
    output wire halt,
    output wire _wait,

    output wire  br_rel_nop,

    output wire [2:0] shift_count_d,
    output wire arith_carry,
    output wire [2:0] alu_func,
    output wire [2:0] alu_op_type,

    output wire [2:0] rs0,
    output wire [2:0] rs1,
    output wire [2:0] rd,

    output wire [15:0] imm, // ok

    output wire [9:0] ucode_addr,

    output wire ei,
    output wire di
);

// primary decoder
wire [8:0] imm9_d = instruction[8:0];
wire [5:0] imm6_d = instruction[8:3];
wire [1:0] XY = instruction[12:11];
wire X = XY[1];
wire Y = XY[0];

wire [3:0] op_type_d0 = instruction[3:0];
wire [3:0] op_type_d1 = instruction[6:3];
wire [3:0] op_type_d2 = instruction[9:6];
wire [3:0] op_type_d3 = instruction[12:9];

wire [3:0] br_rel_flags_d = op_type_d3;
wire [3:0] br_abs_flags_D = op_type_d0;

wire [2:0] inst_type = instruction[15:13];

wire [2:0] alu_op_d0 = instruction[8:6];
wire [2:0] alu_op_d1 = instruction[11:9];

wire [2:0] rs0_d = instruction[5:3];
wire [2:0] rs1_d = instruction[8:6];
wire [2:0] rd_d = instruction[2:0];

assign shift_count_d = rs1_d;


// here goes big decoder tree
`IT(_0op, 0, (!X && !Y));
`IT(br_abs_d, 0, (!X && Y));
`IT(shifts, 0, (X));
`IT(_1op, 1);
`IT(_2op, 2, (XY == 0));
`IT(alu3_ind, 2, (XY == 1));
`IT(mem2, 2, (XY == 2));
`IT(alu2, 2, (XY == 3));
`IT(is_imm6, 3);
`IT(is_imm9, 4);
`IT(mem3, 5, (X));
`IT(alu3, 5, (X));
`IT(br_rel_n_d, 6);
`IT(br_rel_p_d, 7);


assign _int = is_imm9 && !(op_type_d3[1] || op_type_d3[2] || op_type_d3[3]);

// registers
assign rs0 = is_imm6 ? rd_d : rs0_d;
assign rs1 = (_1op || alu3_ind) ? rd_d : rs1_d;
assign rd = rd_d;

// alu
assign arith_carry = shifts || alu3;
assign alu_func = (arith_carry || alu2 || alu3_ind) ?  ((alu2 || alu3_ind) ? alu_op_d0 : alu_op_d1) : ((is_imm6 && (op_type_d3[3:1] == 3'b111)) ? 6 : 5);
wire [2:0] alu_op_type_nondefault = {shifts, alu2, alu3 | alu3_ind};
assign alu_op_type = alu_op_type_nondefault == 0 ? 1 : alu_op_type_nondefault;

// misc instrs
// wire jsr_or_rti = _0op && op_type_d0[3] && !(op_type_d0[1] || op_type_d0[2]);
// assign jsr = jsr_or_rti && op_type_d0[0]
assign jsr = (op_type_d0 == 4'b1000) && _0op;
assign rti = (op_type_d0 == 4'b1001) && _0op;
assign halt = (op_type_d0 == 4'b0100) && _0op && !exc_triggered;
assign _wait = (op_type_d0 == 4'b0101) && _0op && !exc_triggered;
assign ei = (op_type_d0 == 4'b0110) && _0op && !exc_triggered;
assign di = (op_type_d0 == 4'b0111) && _0op && !exc_triggered;

// branches
wire br_go;
branch_logic branches(.cccc(br_abs_d ? br_abs_flags_D : br_rel_flags_d), .CVZN(CVZN), .go(br_go));
wire br_abs = br_abs_d && br_go;
wire br_abs_nop = br_abs_d && !br_abs;
wire br_rel_n = br_rel_n_d && br_go;
wire br_rel_p = br_rel_p_d && br_go;
assign br_rel_nop = (br_rel_n_d && !br_rel_n) || (br_rel_p_d && ! br_rel_p);


// imm calculation
wire [15:0] imm_temp = is_imm6 ? {{10{ucommand[UC_IMM_EXTEND_NEGATIVE]}}, imm6_d} : {{7{ucommand[UC_IMM_EXTEND_NEGATIVE]}}, imm9_d};
assign imm = _int ? (imm_temp << 2) | (phase[0] ? 16'd2 : 16'd0) : (imm_temp << ucommand[UC_IMM_SHIFT]);

endmodule