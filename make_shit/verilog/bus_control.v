`timescale 1ns / 1ps

module bus_control(
    input wire[15:0] from_bus /*!w:150,p:l*/,
    output reg[15:0] to_bus,

    output reg[15:0] data_out /*!p:r*/,
    input wire[15:0] data_in,

    input wire sign_extend /*!p:t*/,
    input wire odd_address,
    input wire word,
    input wire clk_no_inhibit,



    output wire inc_address /*!p:b*/,
    output reg phase,
    output wire clk_inhibit,

    input wire reset
);

    assign clk_inhibit = odd_address & word;
    assign inc_address = phase;

    reg[7:0] dataTempRegister;

    always @(negedge clk_no_inhibit) begin
        if (reset) begin
            phase = 0;
            dataTempRegister = 8'd0;
        end else begin 
            phase = clk_inhibit;
            if (clk_inhibit) dataTempRegister = data_in[7:0];
        end
    end


    // bus -> out
    always begin
        if (word & phase) data_out = {from_bus[7:0], from_bus[15:8]};
        else data_out = from_bus;
    end

    // in -> bus
    always begin
        if (word)
            if (phase) to_bus = {data_in[7:0], dataTempRegister};
            else to_bus = data_in;
        else
            if (sign_extend) to_bus = {{8{data_in[7]}}, data_in[7:0]};
            else to_bus = {8'd0, data_in[7:0]};
    end


endmodule