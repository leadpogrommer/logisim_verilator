`timescale 1ns / 1ps

`include "common.vh"

module cdm16(
    input wire [15:0] instruction /*!w:200*/,
    input wire [27:0] ucommand,
    input wire [2:0] phase,
    input wire exc_triggered,
    input wire virtual_instruction,
    input wire fetch,
    input wire input_clock,
    input wire in_hold,
    input wire in_irq,
    input wire critical_fault,

    output wire rti,
    output wire _int,
    output wire halt,
    output wire _wait,
    output wire [9:0] ucode_addr,

    // real outputs
    output wire [15:0] SP,
    output reg [15:0] PC,
    output reg [15:0] PS,
    output wire [15:0] address,
    output wire mem,
    output wire data,
    output wire read,
    output wire word,
    output wire [15:0] data_out,
    input wire [15:0] data_in,

    output reg [15:0] busD,

    output wire int_en,

    output wire clk,
    output wire clk_no_inhibit,
    output reg [1:0] status,
    output reg [15:0] regs /*!p:t,t:registers,s:20*/ [7:0]  // TODO: fix array in the middle of port list

);

wire [3:0] ps_flags = PS[3:0];
reg [15:0] bus0; // TODO
reg [15:0] bus1; // TODO
// wire [15:0] busD; // TODO


// decoder outputs
wire jsr;
wire br_rel_nop;
wire [2:0] shift_count_d;
wire arith_carry;
wire [2:0] alu_func;
wire [2:0] alu_op_type;
wire [2:0] rs0;
wire [2:0] rs1;
wire [2:0] rd;
wire [15:0] imm;
wire ei;
wire di;
decoder decoder_inst (
    .instruction,
    .CVZN(ps_flags),
    .ucommand,
    .phase,
    .exc_triggered,
    .fetch,

    .jsr,
    .rti,
    ._int,
    .halt,
    ._wait,
    .br_rel_nop,

    .shift_count_d,
    .arith_carry,
    .alu_func,
    .alu_op_type,
    .rs0,
    .rs1,
    .rd,
    .imm,
    .ucode_addr,
    .ei,
    .di
    );


// wire [15:0] regs_bus0_out;
// wire [15:0] regs_bus1_out;
// wire [15:0] regs_busD_out;
// registers registers_inst(
//     .rs0,
//     .rs1,
//     .rd,
//     .r_latch(ucommand[UC_RLATCH]),
//     .clk,
//     .busD_in(busD),

//     .bus0(regs_bus0_out),
//     .bus1(regs_bus1_out),
//     .busD_out(regs_busD_out),
//     .regs
// );


wire inc_address;
wire [15:0] alu_out;
wire [3:0] alu_out_CVZN;
ALU ALU_inst(
    .A(bus0),
    .B(bus1),
    .Cin(arith_carry ? ps_flags[3] : (ucommand[UC_MEM] & inc_address)),
    .op_type(alu_op_type),
    .func(alu_func),
    .shif_count_ni(shift_count_d),

    .S(alu_out),
    .CVZN(alu_out_CVZN)
);


reg io_phase;
assign inc_address = io_phase;
assign mem = ucommand[UC_MEM];
assign data = ucommand[UC_DATA];
assign read = ucommand[UC_READ];
assign word = ucommand[UC_WORD] & !(io_phase | clk_inhibit);
assign address = alu_out;


// clock control
reg clk_hold;
reg clk_wait;
reg clk_halt;
reg clk_critical_fault;
wire clk_inhibit = address[0] & ucommand[UC_WORD];

wire clk_no_inhibit_active = !(clk_hold | clk_wait | clk_halt | clk_critical_fault);
assign clk_no_inhibit = clk_no_inhibit_active & input_clock;
assign clk = clk_no_inhibit && (!clk_inhibit);

// reg bus_control_phase;
reg [7:0] bus_control_tmp;
reg [15:0] bus_control_out_to_bus;




// bus_control bus_control_inst(
//     .from_bus(busD),
//     .to_bus(bus_control_out_to_bus),
//     .data_out,
//     .data_in,
//     .sign_extend(ucommand[UC_SIGN_EXTEND]),
//     .odd_address(address[0]),
//     .word(ucommand[UC_WORD]),
//     .clk_no_inhibit,

//     .inc_address,
//     .phase(io_phase),
//     .clk_inhibit,
//     .reset(0) // TODO: reset
// );

wire pc_inc_inhibit = exc_triggered ? virtual_instruction : br_rel_nop;

wire pc_asrt_inc = jsr & ucommand[UC_PC_ASRTD];
wire [15:0] pc_incremented = exc_triggered ? (PC - 2) : (PC + 2);
wire [15:0] pc_value = pc_asrt_inc ? pc_incremented : PC;

reg [15:0] realSP;
assign SP = ucommand[UC_SP_DEC] ? realSP - 2 : realSP;
always @(negedge input_clock) begin
    clk_hold = in_hold;

    if(_wait) clk_wait = 1;
    if(in_irq) clk_wait = 0;

    if(halt) clk_halt = 1;

    if(critical_fault) clk_critical_fault = 1;

    // bus_logic here
    if (clk_no_inhibit_active) begin
        io_phase = clk_inhibit;
        if (io_phase) bus_control_tmp = data_in[7:0];
    end



    if (clk_no_inhibit_active & (!clk_inhibit)) begin
        if (ucommand[UC_PC_LATCH]) PC = busD;

        if (ucommand[UC_SP_LATCH]) realSP = busD;

        // SP
        // if (ucommand[UC_SP_INC]) realSP += 2;
        // else if (ucommand[UC_SP_DEC]) realSP -= 2;
        // else if (ucommand[UC_SP_LATCH]) realSP = busD;

        // // PC
        // if (ucommand[UC_PC_INC] & !pc_inc_inhibit) PC = pc_incremented;
        // else if (ucommand[UC_PC_LATCH]) PC = busD;

        // PS
        if (ucommand[UC_PS_LATCH_WORD]) PS = busD;
        else if (ei) PS[15] = 1;
        else if(di) PS[15] = 0;
        else if(ucommand[UC_PS_LATCH_FLAGS]) PS[3:0] = alu_out_CVZN;

        // regs
        if (ucommand[UC_RLATCH]) regs[rd] = busD;

        if (ucommand[UC_PC_INC] & !pc_inc_inhibit) PC = pc_incremented;

        if (ucommand[UC_SP_INC]) realSP += 2;
        if (ucommand[UC_SP_DEC]) realSP -= 2;

    end
end

// buses
always begin
    // bus control
    if (ucommand[UC_WORD]) 
        if (io_phase) bus_control_out_to_bus = {data_in[7:0], bus_control_tmp};
        else bus_control_out_to_bus = data_in;
    else
        if (ucommand[UC_SIGN_EXTEND]) bus_control_out_to_bus = {{8{data_in[7]}}, data_in[7:0]};
        else bus_control_out_to_bus = {8'd0, data_in[7:0]};


    // bus0
    if (ucommand[UC_R_ASRT0]) bus0 = regs[rs0];
    else if (ucommand[UC_FP_ASRT0]) bus0 = regs[7];
    else if (ucommand[UC_SP_ASRT0]) bus0 = SP;
    else if (ucommand[UC_PC_ASRT0]) bus0 = pc_value;
    else bus0 = 0;

    // bus1
    if (ucommand[UC_R_ASRT1]) bus1 = regs[rs1];
    else if (ucommand[UC_IMM_ASRT1]) bus1 = imm;
    else bus1 = 0;

    // busD
    if (ucommand[UC_R_ASRTD]) busD = regs[rd];
    else if (ucommand[UC_IMM_ASRTD]) busD = imm;
    else if (ucommand[UC_READ]) busD = bus_control_out_to_bus;
    else if (ucommand[UC_SP_ASRTD]) busD = SP;
    else if (ucommand[UC_PC_ASRTD]) busD = pc_value;
    else if (ucommand[UC_ALU_ASRTD]) busD = alu_out;
    else if (ucommand[UC_PS_ASRTD]) busD = PS;
    else busD = 0;

    // status
    if (clk_critical_fault) status = 3;
    else if (clk_halt) status = 2;
    else if (clk_wait) status = 1;
    else status = 0;

    // bus control
    if (ucommand[UC_WORD] & io_phase) data_out = {busD[7:0], busD[15:8]};
    else data_out = busD;
    
end

assign int_en = PS[15];

endmodule