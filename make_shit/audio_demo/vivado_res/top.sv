`timescale 1ns / 1ps


interface SPI;
    logic CLK;
    logic MISO;
    logic MOSI;
    logic CS;

modport SLAVE (input CLK, input CS, input MOSI, output MISO);
modport MASTER (output CLK, output CS, output MOSI, input MISO);
    
endinterface

// SPI: J3 [ Vcc, CLK, ..., CS, MISO, MOSI, GND ]
module top(
    SPI.SLAVE debug_spi,
    output reg [7:0] leds [3:0],
    input system_clock,
    output wire [7:0] led_stripe,
    input wire [7:0] buttons,
    SPI.MASTER dac,
    SPI.MASTER adc
    );


// CDM
// cdm wires
(* keep = "true", mark_debug = "true" *)reg cdm_reset;
(* keep = "true", mark_debug = "true" *)wire cdm_hold;
reg [15:0] cdm_data_in;
(* keep = "true", mark_debug = "true" *)wire [15:0] cdm_data_out;
(* keep = "true", mark_debug = "true" *)wire [15:0] cdm_address;
(* keep = "true", mark_debug = "true" *)wire cdm_mem;
(* keep = "true", mark_debug = "true" *)wire cdm_read;
(* keep = "true", mark_debug = "true" *)wire cdm_word;
(* keep = "true", mark_debug = "true" *)wire [15:0] cdm_regs [7:0];
(* keep = "true", mark_debug = "true" *)wire [15:0] cdm_SP;
(* keep = "true", mark_debug = "true" *)wire [15:0] cdm_PC;
(* keep = "true", mark_debug = "true" *)wire [15:0] cdm_PS;
(* keep = "true", mark_debug = "true" *)wire [1:0] cdm_status;
(* keep = "true", mark_debug = "true" *)reg cdm_irq;
(* keep = "true", mark_debug = "true" *)reg [5:0] cdm_int_vec;
(* keep = "true", mark_debug = "true" *)wire cdm_iack;

// ram wires
(* keep = "true", mark_debug = "true" *)wire [14:0] mem_addr;
(* keep = "true", mark_debug = "true" *)wire mem_en;
(* keep = "true", mark_debug = "true" *)wire [1:0] mem_write;
(* keep = "true", mark_debug = "true" *)wire [15:0] mem_in;
(* keep = "true", mark_debug = "true" *)reg [15:0] mem_out;

// audio ram wires
(* keep = "true", mark_debug = "true" *)reg [14:0] audio_mem_addr;
(* keep = "true", mark_debug = "true" *)reg audio_mem_en = 0;
(* keep = "true", mark_debug = "true" *)reg [1:0] audio_mem_write = 0;
(* keep = "true", mark_debug = "true" *)wire [15:0] audio_mem_in;
(* keep = "true", mark_debug = "true" *)reg [15:0] audio_mem_out;

// spi mem control
reg mem_controlled_by_spi = 0;
assign cdm_hold = mem_controlled_by_spi;

(* keep = "true", mark_debug = "true" *)reg [7:0] bits_read;    
(* keep = "true", mark_debug = "true" *)reg [15:0] spi_data;
(* keep = "true", mark_debug = "true" *)reg [7:0] spi_current_command;
(* keep = "true", mark_debug = "true" *)reg [15:0] spi_current_addr;
(* keep = "true", mark_debug = "true" *)reg [15:0] spi_current_data;
(* keep = "true", mark_debug = "true" *)wire dbg_cw = debug_spi.CS;
(* keep = "true", mark_debug = "true" *)wire dbg_clk = debug_spi.CLK;
(* keep = "true", mark_debug = "true" *)wire dbg_mosi = debug_spi.MOSI;
(* keep = "true", mark_debug = "true" *)wire dbg_miso = debug_spi.MISO;

localparam CMD_REG_READ = 8'd1;
localparam CMD_RESET_SET = 8'd2;
localparam CMD_MEM_WRITE = 8'd3;
localparam CMD_MEM_READ = 8'd4;

localparam REG_SP = 16'd8;
localparam REG_PC = 16'd9;
localparam REG_PS = 16'd10;
localparam REG_STA = 16'd11;

localparam GOT_CMD = 8;
localparam GOT_ADDR = GOT_CMD + 16;
localparam GOT_DATA = GOT_ADDR + 16;

// memory map
// set stack top to 0xB000
localparam MEM_DSP_RUNNING =    16'hBFF2;
localparam MEM_FREE_HALF =      16'hBFF4;
localparam MEM_BUTTONS =        16'hBFF6;
localparam MEM_LEDS =           16'hBFF8;
localparam MEM_AUDIO_FIRST =    16'hC000;
localparam MEM_AUDIO_SECOND =   16'hE000;

//reg have_command;
//reg have_addr;
//reg have_data;
assign led_stripe[1:0] = cdm_status;
assign led_stripe[2] = cdm_hold;
assign led_stripe[3] = cdm_reset;


cdm16 cdm16(
    .input_clock(system_clock),
    .reset(cdm_reset),
    .in_hold(cdm_hold),
    .data_out(cdm_data_out),
    .data_in(cdm_data_in),
    .direct_exc_vec(0),
    .exc_trig_ext(0),
    
    .address(cdm_address),
    .mem(cdm_mem),
    .read(cdm_read),
    .word(cdm_word),
    
    .regs(cdm_regs),
    .SP(cdm_SP),
    .PS(cdm_PS),
    .PC(cdm_PC),
    .status(cdm_status),
    .in_irq(cdm_irq),
    .int_vec(cdm_int_vec),
    .IAck(cdm_iack)
);

bd_top_wrapper bdt(
    .cdm_ram_addr(mem_addr),
    .cdm_ram_clock(system_clock),
    .cdm_ram_din(mem_out),
    .cdm_ram_dout(mem_in),
    .cdm_ram_en(mem_en),
    .cdm_ram_wr(mem_write),
    
    .audio_ram_addr(audio_mem_addr),
    .audio_ram_clock(system_clock),
    .audio_ram_din(audio_mem_out),
    .audio_ram_dout(audio_mem_in),
    .audio_ram_en(audio_mem_en),
    .audio_ram_wr(audio_mem_write)
);

assign mem_addr = mem_controlled_by_spi ? spi_current_addr[15:1] : cdm_address[15:1];
assign mem_en = cdm_mem || mem_controlled_by_spi;
assign mem_write = mem_controlled_by_spi ? {spi_current_command == CMD_MEM_WRITE, spi_current_command == CMD_MEM_WRITE} : {!cdm_read && cdm_mem && (cdm_word || cdm_address[0]), !cdm_read && cdm_mem && (cdm_word || !cdm_address[0])};

wire free_audio_half;

always_comb begin
    if (mem_controlled_by_spi) begin
        mem_out = spi_current_data;
    end else if(cdm_word) begin
        // CDM MMIO
        case(cdm_address)
            default: cdm_data_in = mem_in;
            MEM_BUTTONS: cdm_data_in = {8'b0, ~buttons};
            MEM_FREE_HALF: cdm_data_in = {15'b0, free_audio_half}; 
        endcase
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

// END CDM

//wire [7:0] command = spi_data[7:0];
//wire [15:0] addr = spi_data;
//wire [15:0] data = spi_data;

reg [15:0] spi_reply_data;
assign debug_spi.MISO = spi_reply_data[15];
reg [1:0] prev_spi_clock = 2'b0;

wire spi_pos = prev_spi_clock == 2'b01;
wire spi_neg = prev_spi_clock == 2'b10;
wire [15:0] csd /*current_spi_data*/ = {spi_data[14:0], debug_spi.MOSI}; 

reg audio_debug;
assign led_stripe[7] = audio_debug;

reg [32:0] tick_counter = 0;

localparam clocks_per_sample = 600;
(* keep = "true", mark_debug = "true" *)reg [10:0] audio_ctr = 0;
(* keep = "true", mark_debug = "true" *)reg [15:0] audio_ptr = MEM_AUDIO_FIRST;
(* keep = "true", mark_debug = "true" *)reg [15:0] dac_out;

assign dac.CLK = system_clock;
assign dac.MOSI = dac_out[15];
(* keep = "true", mark_debug = "true" *)wire debug_dac_mosi = dac.MOSI;
(* keep = "true", mark_debug = "true" *)wire debug_dac_cs = dac.CS;

assign adc.CLK = system_clock;
reg [14:0] adc_in;
assign free_audio_half = audio_ptr >= MEM_AUDIO_SECOND;
reg cdm_dsp_running = 0;

assign led_stripe[6] = cdm_dsp_running;


always @(posedge system_clock) begin
    // audio output
    if(audio_ctr == clocks_per_sample - 1) audio_ctr <= 0;
    else audio_ctr <= audio_ctr + 1;
    
    // This could be paralellized more, but IDC
    case(audio_ctr)
        0: audio_ptr <= audio_ptr == 16'hfffe ? MEM_AUDIO_FIRST : audio_ptr + 2; 
        1: begin
            audio_mem_en <= 1;
            audio_mem_addr <= audio_ptr[15:1];
        end
        3: begin
            audio_mem_en <= 0;
            dac.CS <= 0;
            dac_out <= {4'd0, audio_mem_in[15:6], 2'd0};
        end
        19: begin
            dac.CS <= 1;
        end
        20: begin
            adc.CS <= 0;
        end
        36: begin
            adc.CS <= 1;
            audio_mem_out <= {adc_in[11:4], 8'd0};
            audio_mem_write <= 2'b11;
            audio_mem_en <= 1;
        end
        37: begin
           audio_mem_write <= 2'b00;
           audio_mem_en <= 0;
        end
        
        299: audio_debug <= 1;
        599: audio_debug <= 0;
    endcase
    if(audio_ctr != 3) dac_out <= dac_out << 1;
    adc_in <= {adc_in[14:0], adc.MISO};
    


    // CDM MMIO
    if (!mem_controlled_by_spi && mem_en && !cdm_read && cdm_word) begin // CDM is writing word
        case(cdm_address)
            MEM_LEDS: leds[0] <= cdm_data_out[7:0];
            MEM_LEDS+2: leds[1] <= cdm_data_out[7:0];
            MEM_LEDS+4: leds[2] <= cdm_data_out[7:0];
            MEM_LEDS+6: leds[3] <= cdm_data_out[7:0];
            MEM_DSP_RUNNING: cdm_dsp_running <= cdm_data_out[0];
        endcase
    end
    // interrupts
    if (tick_counter == 12000000) tick_counter <= 0;
    else tick_counter <= tick_counter + 1;
    
    // interrupts are broken
    // oh no
//    if(tick_counter == 0) begin
//        cdm_int_vec <= 5;
//        cdm_irq <= 1;
//    end
    
//    if(cdm_iack) cdm_irq <= 0;
end


// debug spi
always @(posedge system_clock) begin
   prev_spi_clock <= {prev_spi_clock[0], debug_spi.CLK};
    if(debug_spi.CS == 1 ) begin
        bits_read <= 1;
        mem_controlled_by_spi <= 0;
        spi_data <= 0;
//        have_command <= 0;
//        have_addr <= 0;
//        have_data <= 0;
    end else if(spi_pos) begin
        // transaction ongoing
        spi_data <= csd;
        
        
        if (bits_read == GOT_CMD) begin 
            spi_current_command <= csd[7:0];
//            have_command <= 1;
        end        
        if(bits_read == GOT_ADDR) begin
            spi_current_addr <= csd;
            if ( spi_current_command == CMD_MEM_READ) begin
                mem_controlled_by_spi <= 1;
            end
//            have_addr <= 1;
        end
        if (bits_read == GOT_DATA) begin
            spi_current_data <= csd;
            
//            have_data <= 1;
        end   
    end
    
    if (debug_spi.CS == 0 && spi_neg) begin
        bits_read <= bits_read  + 1;
        if (bits_read == GOT_ADDR) begin
            // set spi_reply_data
            if( spi_current_command == CMD_REG_READ ) begin
                case(spi_current_addr)
                    default: spi_reply_data <= cdm_regs[spi_current_addr];
                    REG_SP: spi_reply_data <= cdm_SP;
                    REG_PC: spi_reply_data <= cdm_PC;
                    REG_PS: spi_reply_data <= cdm_PS;
                    REG_STA: spi_reply_data <= {14'd0, cdm_status};
                endcase
            end else if( spi_current_command == CMD_MEM_READ ) begin
                spi_reply_data <= mem_in;
            end
        end else begin
            spi_reply_data <= spi_reply_data << 1;
        end
        
        if ( bits_read == GOT_DATA ) begin
            if( spi_current_command == CMD_RESET_SET ) cdm_reset <= spi_current_data[0];
            if(spi_current_command == CMD_MEM_WRITE) mem_controlled_by_spi <= 1;
            
        end
    end 
end
    
    
endmodule
