`timescale 1ns / 1ps

//memory addresses for lw and sw
module data_memory(clk, address, write_data, mem_read, mem_write, read_data);
input clk;
input [31:0] address;
input [31:0] write_data;
input mem_read;
input mem_write;

output reg [31:0] read_data;

// Stores 256 words, with each word containing 32 bits
reg [31:0] memory [0:255];

// Initialize memory to zero for simulation
integer i;
initial begin
    for (i = 0; i < 256; i = i + 1)
        memory[i] = 32'd0;
end

// Read data from memory
always @(*) begin
    if (mem_read)
        read_data = memory[address[9:2]];
    else
        read_data = 32'd0;
end

// Write data into memory on the rising clock edge
always @(posedge clk) begin
    if (mem_write)
        memory[address[9:2]] <= write_data;
end

endmodule
