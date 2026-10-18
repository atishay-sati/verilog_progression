`timescale 1ns / 1ps

//this module is just for connecting our pc, instructions, decoder, registers, and ALU
module cpu(clk, reset, enable, jump, jump_addr, result);
input clk;
input reset;
input enable;
input jump;
input [3:0] jump_addr;
output [3:0] result;

wire [3:0] pc;
wire [15:0] instruction;
wire [3:0] operation;
wire [1:0] regout;
wire [1:0] regin1;
wire [1:0] regin2;

program_counter counter(.clk(clk),.reset(reset),
                     .enable(enable),
                     .jump(jump),
                     .jump_addr(jump_addr), .pc(pc));

instruction_memory memorypull(.address(pc), 
                        .instruction(instruction));

instruction_decoder decode(.instruction(instruction),
                         .operation(operation),
                         .regout(regout),
                         .regin1(regin1),
                         .regin2(regin2));

register_file readwrite(.clk(clk),
                        .opp(operation),
                        .read_reg1(regin1),
                        .read_reg2(regin2),
                        .write_reg(regout),
                        .enable(enable),
                        .result(result));
                      
endmodule
