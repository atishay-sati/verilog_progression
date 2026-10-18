`timescale 1ns / 1ps

module instruction_memory(address, instruction);
input [3:0] address;
output reg [15:0] instruction;

reg [15:0] memory [0:15];

initial begin
    // Format: {operation, destination, source1, source2, unused}
    
    //R0 = R1 + R2
    memory[0] = {4'b0000, 2'b00, 2'b01, 2'b10, 6'b000000}; //these values concatenate into ONE 16 bit value. The instruction decoder will later decode this bit 
    // R3 = R0 - R1
    memory[1] = {4'b0001, 2'b11, 2'b00, 2'b01, 6'b000000};
    // R2 = R1 * R3
    memory[2] = {4'b0010, 2'b10, 2'b01, 2'b11, 6'b000000};
    
    //R1 = R2 / R3
    memory[3] = {4'b0011, 2'b01, 2'b10, 2'b11, 6'b000000};

    // Fill remaining slots with zero
    memory[4]  = 16'b0;
    memory[5]  = 16'b0;
    memory[6]  = 16'b0;
    memory[7]  = 16'b0;
    memory[8]  = 16'b0;
    memory[9]  = 16'b0;
    memory[10] = 16'b0;
    memory[11] = 16'b0;
    memory[12] = 16'b0;
    memory[13] = 16'b0;
    memory[14] = 16'b0;
    memory[15] = 16'b0;
    
    
end
always @(*) begin
    instruction = memory[address];
end
endmodule
