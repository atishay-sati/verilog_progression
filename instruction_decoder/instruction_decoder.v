`timescale 1ns / 1ps

module instruction_decoder(instruction, operation, regout, regin1, regin2);
input [15:0] instruction;
output reg [3:0] operation;
output reg [1:0] regout;
output reg [1:0] regin1;
output reg [1:0] regin2;


always @(*) begin
    operation = instruction[15:12];
    regout = instruction[11:10];
    regin1 = instruction[9:8];
    regin2 = instruction[7:6];
end
    
endmodule
