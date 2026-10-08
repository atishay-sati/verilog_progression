`timescale 1ns / 1ps

module encoder(i0, i1, i2, i3, i4, i5, i6, i7, out);
input i0, i1, i2, i3, i4, i5, i6, i7; //8 inputs, each corresponding to a different output
output [2:0] out;

assign out[2] = i4 | i5 | i6 | i7; //inputs with 1 at bit 2
assign out[1] = i2 | i3 | i6 | i7; //inputs with 1 at bit 1
assign out[0] = i1 | i3 | i5 | i7; //inputs with 1 at bit 0

//i0 = 000
//i1 = 001
//i2 = 010
//i3 = 011
//i4 = 100
//i5 = 101
//i6 = 110
//i7 = 111

endmodule
