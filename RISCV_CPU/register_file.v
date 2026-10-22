`timescale 1ns / 1ps

module register_file(clk, read_reg1, read_reg2, write_reg, write_data, enable, reg1, reg2);
input clk;
input [4:0] read_reg1; //get address of registers that want to be read. 00000 corresponds to r0, 00001 corresponds to r1, etc.
input [4:0] read_reg2;
input [4:0] write_reg; //set register that should be written in
input [31:0] write_data; //data sent from ALU to write in register
input enable; //enables us to write on clk posedge
output reg [31:0] reg1; //declares a 32 bit value that will store the first register we choose
output reg [31:0] reg2; //declares a 32 bit value that will store the first register we choose

reg [31:0] registers [0:31]; //declares a 32 register 32 bit array of our 32 registers in it

integer i;
//sets all 32 registers equal to 0
initial begin
    for (i = 0; i < 32; i = i + 1)
        registers[i] = 32'd0;
end

// Read two registers
always @(*) begin
    if (read_reg1 == 5'd0)
        reg1 = 32'd0; //register x0 is hardwired to 0
    else
        reg1 = registers[read_reg1];

    if (read_reg2 == 5'd0)
        reg2 = 32'd0; //register x0 is hardwired to 0
    else
        reg2 = registers[read_reg2];
end

// Write on the rising clock edge
always @(posedge clk) begin
    if (enable && write_reg != 5'd0)
        registers[write_reg] <= write_data;
end

endmodule
