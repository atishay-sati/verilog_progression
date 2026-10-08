`timescale 1ns / 1ps

module decoder(in, i0, i1, i2, i3, i4, i5, i6, i7);
input [2:0] in;
output i0, i1, i2, i3, i4, i5, i6, i7;

assign i0 = ~in[2] & ~in[1] & ~in[0];
assign i1 = ~in[2] & ~in[1] & in[0];
assign i2 = ~in[2] & in[1] & ~in[0];
assign i3 = ~in[2] & in[1] & in[0];
assign i4 = in[2] & ~in[1] & ~in[0];
assign i5 = in[2] & ~in[1] & in[0];
assign i6 = in[2] & in[1] & ~in[0];
assign i7 = in[2] & in[1] & in[0];

//alternate method: assign out = 8'b00000001 << in; this just says shift the "1" to the left by whatever number in is


endmodule
