`timescale 1ns / 1ps

module instruction_decoder(instruction, operation, regout, regin1, regin2);
input [15:0] instruction; //takes in 16 bit instruction from instruction memory
output reg [3:0] operation;
output reg [1:0] regout;
output reg [1:0] regin1;
output reg [1:0] regin2;


always @(*) begin
    operation = instruction[15:12]; //first 4 bits are operation
    regout = instruction[11:10]; //bits 11 and 10 is our register being written
    regin1 = instruction[9:8]; //bits 9 and 8 is our first register being read
    regin2 = instruction[7:6]; //bits 7 and 6 is our second register being read
    //rest of the bits are unassigned
end
    
endmodule
