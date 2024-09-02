`timescale 1ns / 1ps

module cdm16_wrapper_wrapper(
    input wire clock,

    input wire [31:0] gpio_control,
    output wire [31:0] gpio_data,

    output wire [14:0] mem_addr,
    output wire [15:0] mem_out,
    input wire [15:0] mem_in,
    output wire mem_en,
    output wire [1:0] mem_write,
    output wire [2:0] leds_out
);
cdm16_wrapper cdm16_wrapper_inst(
    clock,
    gpio_control,
    gpio_data,
    mem_addr,
    mem_out,
    mem_in,
    mem_en,
    mem_write,
    leds_out
);


endmodule // rev 8