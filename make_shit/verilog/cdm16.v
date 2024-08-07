`timescale 1ns / 1ps

`include "common.vh"

// TODO: fix unaligned PC&SP exceptions

module cdm16(
    input wire [15:0] dummy_instruction /*!w:200*/,
    output wire dbg_CUT,
    output wire [2:0] dbg_phase,
    input wire dummy_exc_triggered,
    input wire dummy_virt_instr,
    output wire dbg_fetch,
    input wire input_clock,
    input wire in_hold,
    input wire in_irq,
    input wire dummy_critical_fault,

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


    output wire dbg_startup,

    input wire [27:0] uc_in_normal,
    input wire [27:0] uc_in_exception,
    input wire [5:0] direct_exc_vec,
    input wire exc_trig_ext,

    output wire IAck,
    input wire [5:0] int_vec,


    output reg [15:0] regs /*!p:t,t:registers,s:20*/ [7:0]  // TODO: fix array in the middle of port list

);

wire [3:0] ps_flags = PS[3:0];
reg [15:0] bus0; // TODO
reg [15:0] bus1; // TODO
// wire [15:0] busD; // TODO
// reg [15:0] busD_noregs; // busD without PC or SP. hack to avoid circular combinational logic


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


wire pc_inc_inhibit = exc_triggered ? virtual_instruction : br_rel_nop;

wire pc_asrt_inc = jsr & ucommand[UC_PC_ASRTD];
wire [15:0] pc_incremented = exc_triggered ? (PC - 2) : (PC + 2);
wire [15:0] pc_value = pc_asrt_inc ? pc_incremented : PC;

reg [15:0] realSP;
assign SP = ucommand[UC_SP_DEC] ? realSP - 2 : realSP;

/* verilator lint_off MULTIDRIVEN */
always @(posedge fetch) begin
    instruction <= 0;
end

always @(negedge input_clock) begin
    clk_hold <= in_hold;

    if(_wait) clk_wait <= 1;
    if(in_irq) clk_wait <= 0;

    if(halt) clk_halt <= 1;

    if(critical_fault) clk_critical_fault <= 1;

    // clk_no_inhibit
    if (clk_no_inhibit_active) begin
        // exceptions
        exc_trig_sp <= busD[0] && ucommand[UC_SP_LATCH]; // TODO: this is probably wrong
        exc_trig_pc <= busD[0] && ucommand[UC_PC_LATCH]; // TODO: this is probably wrong


        if (exc_trig_ext) exc_vec <= direct_exc_vec;
        if (has_any_reason_to_fault) begin
            if (latch_double_fault) exc_intenral_vec <= 4;
            else if (exc_trig_ext) exc_intenral_vec <= 7;
            else if (exc_trig_invalid_inst) exc_intenral_vec <= 3;
            else if (exc_trig_pc) exc_intenral_vec <= 2;
            else if (exc_trig_sp) exc_intenral_vec <= 1;
        end

        if (fetch) virtual_instruction <= latch_int || startup;
        if (fetch) instruction <= fetched_instruction;

        if (has_any_reason_to_fault) exc_latch <= 1;
        if (reset_exc) exc_latch <= 0;

        // bus control
        io_phase <= clk_inhibit;
        if (clk_inhibit) bus_control_tmp <= data_in[7:0];
    end



    if (clk_no_inhibit_active & (!clk_inhibit)) begin
        // fething and exceptions

        if (CUT) phase <= 0;
        else phase <= phase + 1;

        if (CUT) cut_something <= !cut_something;

        // regs
        if (ucommand[UC_PC_LATCH]) PC <= busD;

        if (ucommand[UC_SP_LATCH]) realSP <= busD;

        if (ucommand[UC_PS_LATCH_WORD]) PS <= busD;
        else if (ei) PS[15] <= 1;
        else if(di) PS[15] <= 0;
        else if(ucommand[UC_PS_LATCH_FLAGS]) PS[3:0] <= alu_out_CVZN;

        if (ucommand[UC_RLATCH]) regs[rd] <= busD;

        if (ucommand[UC_PC_INC] & !pc_inc_inhibit) PC <= pc_incremented;

        if (ucommand[UC_SP_INC]) realSP <= realSP + 2;
        if (ucommand[UC_SP_DEC]) realSP <= realSP - 2;

        if (startup && CUT) not_startup <= 1;
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


// exceptions & instruction fetching
wire CUT = ucommand[UC_CUT];
reg [2:0] phase;
reg cut_something;
reg not_startup;
wire startup = !not_startup;
wire fetch = (!cut_something) && (phase == 0);
wire latch_int = exc_triggered || (in_irq && int_en);
assign IAck = fetch && (in_irq && int_en);
wire reset_exc = exc_triggered && fetch;
wire double_fault = instruction == 16'h8004;
wire exc_triggered = has_any_reason_to_fault || exc_latch;
wire critical_fault = double_fault && has_any_reason_to_fault;
wire [27:0] ucommand /*verilator split_var*/ = status[1] || startup || (latch_int && fetch) ? 28'h8000000 : (exc_triggered ? uc_in_exception : uc_in_normal);

reg [5:0] exc_vec;
reg [2:0] exc_intenral_vec;
reg exc_latch;
reg virtual_instruction;
reg [15:0] instruction;


wire exc_trig_invalid_inst = !exc_latch && (uc_in_normal == 0);

reg exc_trig_sp;// = busD[0] && ucommand[UC_SP_LATCH]; 
reg exc_trig_pc; // = busD[0] && ucommand[UC_PC_LATCH];

wire has_any_reason_to_fault = exc_trig_sp || exc_trig_pc || exc_trig_invalid_inst || exc_trig_ext;
wire latch_double_fault = (rti || _int) || (exc_trig_ext && (exc_trig_sp || exc_trig_pc || exc_trig_invalid_inst)) || (exc_latch && has_any_reason_to_fault);
wire [15:0] exc_instruction = 16'h8000 | (!exc_triggered ? {10'd0, int_vec}: (
    exc_trig_ext ? (
        latch_double_fault ? 16'h4 : {10'd0, direct_exc_vec}
    ) : (
        exc_intenral_vec == 7 ? {10'd0, exc_vec} : {13'd0, exc_intenral_vec}
    )
));
wire [15:0] fetched_instruction = startup ? 16'h8200 : (latch_int ? exc_instruction: busD);


assign dbg_phase = phase;
assign dbg_startup = startup;
assign dbg_fetch = fetch;

endmodule