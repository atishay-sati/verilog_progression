`timescale 1ns / 1ps

//pc
module program_counter(clk, reset, enable, jump, jump_addr, pc);
input clk;
input reset;
input enable;
input jump;
input [3:0] jump_addr;

output reg [3:0] pc;

initial begin
    pc = 4'b0000; //initial value
end

always @(posedge clk) begin
    if (reset)
        pc <= 4'b0000;
    else if (jump) //jumps to desired address (instruction for later use)
        pc <= jump_addr;
    else if (enable) //increments by 1 bit if no jump
        pc <= pc + 1'b1;
end

endmodule
