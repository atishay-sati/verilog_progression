`timescale 1ns / 1ps

module priorityencoder(i3, i2, i1, i0, y1, y2);
input i3, i2, i1, i0;
output y1, y2;

//i3 = 1, i2 = x, i1 = x, i0 = x, y1 = 1, y2 = 1
//i3 = 0, i2 = 1, i1 = x, i0 = x, y1 = 1, y2 = 0
//i3 = 0, i2 = 0, i1 = 1, i0 = x, y1 = 0, y2 = 1
//i3 = 0, i2 = 0, i1 = 0, i0 = 1, y1 = 0, y2 = 0

//this block checks if any of them are equal to 1, and if not, return x
//if they are, return the corresponding value
assign y1 = (i3 | i2 | i1 | i0) ? (i3 | i2) : 1'bx;
assign y2 = (i3 | i2 | i1 | i0) ? (i3 | i1) : 1'bx;

endmodule
