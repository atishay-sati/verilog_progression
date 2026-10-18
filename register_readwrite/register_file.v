`timescale 1ns / 1ps

module register_file(clk, opp, read_reg1, read_reg2, write_reg, enable);
input clk;
input [3:0] opp;  //set operation value (16 bits for 16 operations)
input [1:0] read_reg1; //set registers that want to be read. 00 corresponds to r0, 01 corresponds to r1, etc.
input [1:0] read_reg2;
input [1:0] write_reg; //set register that should be written in
input enable; //enables us to write on clk posedge

reg [3:0] reg1; //declares a 4 bit value that will store the first register we choose
reg [3:0] reg2; //declares a 4 bit value that will store the first register we choose

reg [3:0] registers [0:3]; //declares a four register 4 bit array of our 4 registers in it

wire [3:0] result; //our resulting value from whatever we do with the 2 registers we read

//stores our initial values into our 4 registers
initial begin
    registers[0] = 4'b0000; //0
    registers[1] = 4'b0001; //1
    registers[2] = 4'b0010; //2
    registers[3] = 4'b0100; //4
end

//reads reg1 and reg2
always @(*) begin
    reg1 = registers[read_reg1];
    reg2 = registers[read_reg2];
end

//evaluates reg1 and reg2 with our operation to produce the result
alu process(.a(reg1), .b(reg2), .operation(opp), .result(result));

//stores result in desired register if enable is 1
always @(posedge clk) begin
    if (enable)
        registers[write_reg] = result;
end

endmodule
