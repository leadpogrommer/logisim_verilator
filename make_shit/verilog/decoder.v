localparam UC_IMM_EXTEND_NEGATIVE = 5;
localparam UC_IMM_SHIFT = 6;

module decoder(
    // inputs
    input wire [15:0] instruction /*!p:l*/,
    input wire [3:0] CVZN,
    input wire [27:0] ucommand,
    input wire [2:0] phase,


    // outputs
    output wire jsr /*!p:r*/,
    output wire rti,
    output wire _int, // ok
    output wire halt,
    output wire _wait,

    output wire  br_rel_nop,

    output wire shift_count_d,
    output wire arith_carry,
    output wire alu_func,
    output wire alu_op_type,

    output wire rs1,
    output wire rs2,
    output wire rd,

    output wire [15:0] imm, // ok

    output wire [9:0] ucode_addr
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
wire [2:0] inst_type = instruction[15:13];

// here goes big decoder tree
wire is_imm6 = inst_type == 3'd3;
wire is_imm9 = inst_type == 3'd4;

assign _int = is_imm9 && !(op_type_d3[1] || op_type_d3[2] || op_type_d3[3]);


// imm calculation
wire [15:0] imm_temp = is_imm6 ? {{10{ucommand[UC_IMM_EXTEND_NEGATIVE]}}, imm6_d} : {{7{ucommand[UC_IMM_EXTEND_NEGATIVE]}}, imm9_d};
assign imm = _int ? (imm_temp << 2) | (phase[0] ? 16'd2 : 16'd0) : (imm_temp << ucommand[UC_IMM_SHIFT]);


endmodule