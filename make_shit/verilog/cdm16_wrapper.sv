`timescale 1ns / 1ps


module cdm16_wrapper(
    input wire clock,

    input wire [31:0] gpio_control,
    output wire [31:0] gpio_data,

    output wire [14:0] mem_addr,
    output reg [15:0] mem_out,
    input wire [15:0] mem_in,
    output wire mem_en,
    output wire [1:0] mem_write,
    output wire [2:0] leds_out
);

wire cdm_dbg_fetch;
wire cdm_input_clock;
wire cdm_in_hold;
wire cdm_in_irq;
(* keep = "true", mark_debug = "true" *) wire [15:0] cdm_SP;
(* keep = "true", mark_debug = "true" *)wire [15:0] cdm_PC;
(* keep = "true", mark_debug = "true" *)wire [15:0] cdm_PS;
(* keep = "true", mark_debug = "true" *)wire [15:0] cdm_address;
(* keep = "true", mark_debug = "true" *)wire cdm_mem;
(* keep = "true", mark_debug = "true" *)wire cdm_data;
(* keep = "true", mark_debug = "true" *)wire cdm_read;
(* keep = "true", mark_debug = "true" *)wire cdm_word;
(* keep = "true", mark_debug = "true" *)wire [15:0] cdm_data_out;
(* keep = "true", mark_debug = "true" *)reg [15:0] cdm_data_in;
wire cdm_int_en;
wire cdm_clk;
wire cdm_clk_no_inhibit;
(* keep = "true", mark_debug = "true" *)wire [1:0] cdm_status;
wire [5:0] cdm_direct_exc_vec;
wire cdm_exc_trig_ext;
wire cdm_IAck;
wire [5:0] cdm_int_vec;
(* keep = "true", mark_debug = "true" *) wire cdm_reset;
wire [15:0] cdm_regs [7:0];

cdm16 cdm_inst(
cdm_dbg_fetch,
cdm_input_clock,
cdm_in_hold,
cdm_in_irq,
cdm_SP,
cdm_PC,
cdm_PS,
cdm_address,
cdm_mem,
cdm_data,
cdm_read,
cdm_word,
cdm_data_out,
cdm_data_in,
cdm_int_en,
cdm_clk,
cdm_clk_no_inhibit,
cdm_status,
cdm_direct_exc_vec,
cdm_exc_trig_ext,
cdm_IAck,
cdm_int_vec,
cdm_reset,
cdm_regs
);


// reg [3:0] clk_div_counter;
reg [15:0] selected_reg_data;

wire [3:0] selected_reg_num = gpio_control[3:0];
assign cdm_reset = gpio_control[4];
// wire clock_enable = gpio_control[5];
assign leds_out = gpio_control[6:4];

assign gpio_data = {14'd0, cdm_status, selected_reg_data};

// assign cdm_input_clock = (clk_div_counter < 8);
assign cdm_input_clock = clock;

// always @(posedge clock) clk_div_counter <= clk_div_counter + 1;

assign mem_addr = cdm_address[15:1];
assign mem_en = cdm_mem;
assign mem_write = {!cdm_read && cdm_mem && (cdm_word || cdm_address[0]), !cdm_read && cdm_mem && (cdm_word || !cdm_address[0])};

// initial begin
//     clk_div_counter = 0;
// end

always_comb begin
    if (selected_reg_num < 8) selected_reg_data = cdm_regs[selected_reg_num[2:0]];
    else begin
        case(selected_reg_num)
            default: selected_reg_data = 0;
            8: selected_reg_data = cdm_SP;
            9: selected_reg_data = cdm_PC;
            10: selected_reg_data = cdm_PS;
        endcase
    end

    if(cdm_word) begin
        cdm_data_in = mem_in;
        mem_out = cdm_data_out;
    end else begin
        if(cdm_address[0]) begin
            cdm_data_in = {8'd0, mem_in[15:8]};
            mem_out = {cdm_data_out[7:0], 8'd0};
        end else begin
            cdm_data_in = {8'd0, mem_in[7:0]};
            mem_out = {8'd0, cdm_data_out[7:0]};
        end
    end
end


endmodule
