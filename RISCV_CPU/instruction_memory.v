`timescale 1ns / 1ps

module instruction_memory(address, instruction);

input [31:0] address;
output wire [31:0] instruction;

reg [31:0] memory [0:255];

initial begin
    // addi x1, x0, 5      the bits passed correspond to storing 5 in x1 using x0 + 5
    memory[0] = 32'h00500093; //00000000 01010000 00000000 10010011

    // addi x2, x0, 7
    memory[1] = 32'h00700113;

    // add x3, x1, x2      the bits passed correspond to storing x1 + x2 --> x3 in RISC V
    memory[2] = 32'h002081B3;

    // sub x4, x3, x1
    memory[3] = 32'h40118233;

    // add x5, x3, x4
    memory[4] = 32'h004182B3;

    // Remaining entries: NOP instructions
    memory[5]  = 32'h00000013;
    memory[6]  = 32'h00000013;
    memory[7]  = 32'h00000013;
    memory[8]  = 32'h00000013;
    memory[9]  = 32'h00000013;
    memory[10] = 32'h00000013;
    memory[11] = 32'h00000013;
    memory[12] = 32'h00000013;
    memory[13] = 32'h00000013;
    memory[14] = 32'h00000013;
    memory[15] = 32'h00000013;
end

assign instruction = memory[address[9:2]];

endmodule

