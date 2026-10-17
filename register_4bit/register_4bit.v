`timescale 1ns / 1ps

module register_4bit(d, clk, q);
input [3:0] d;
input clk;
output [3:0] q;

d_flipflop bit3(d[3],clk,q[3]);
d_flipflop bit2(d[2],clk,q[2]);
d_flipflop bit1(d[1],clk,q[1]);
d_flipflop bit0(d[0],clk,q[0]);

endmodule
