`timescale 1ns / 1ps


module gpu_to_bus #(parameter BASE_ADDR = 16'hff00)(
    input clk,

    output reg [15:0] vram_addr,
    output reg [15:0] vram_data,
    output wire vram_write,

    input wire [15:0] cpu_addr,
    input wire [15:0] cpu_data,
    input wire cpu_write 
);

reg [3:0] vram_write_cycles;

(* keep = "true", mark_debug = "true" *)reg prev_cpu_write;
initial begin
    vram_addr = 0;
    vram_write_cycles = 0;
    prev_cpu_write = 0;
end


assign vram_write = (vram_write_cycles != 0);

(* keep = "true", mark_debug = "true" *)wire wr = cpu_write & (~prev_cpu_write);

always @(posedge clk) begin
    if (wr && (cpu_addr == (BASE_ADDR + 16'h0))) begin
        // set current addr
        vram_addr <= cpu_data;
    end

    if (wr && (cpu_addr == (BASE_ADDR + 16'h2))) begin
        vram_write_cycles <= 2; // TOOD: wtf???
        vram_data <= cpu_data;
        vram_addr <= (vram_addr + 16'h1);
    end
    prev_cpu_write <= cpu_write;

    if (vram_write_cycles != 0) vram_write_cycles <= (vram_write_cycles - 1);
end



endmodule