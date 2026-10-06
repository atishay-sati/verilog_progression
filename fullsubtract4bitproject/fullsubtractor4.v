`timescale 1ns / 1ps


module fullsubtractor4(a, b, borrow_in, difference, borrow_out);
input [3:0] a; //creates 4 bit number
input [3:0] b; //creates 4 bit number
input borrow_in; //sets the initial borrow_in
output [3:0] difference; //sets the 4 bit difference
output borrow_out; //The subtraction required a borrow beyond the most significant bit

wire b1, b2, b3; //borrow wires

fullsubtractor fs0(a[0], b[0], borrow_in, difference[0], b1); //calculates difference in least significant bit 
fullsubtractor fs1(a[1], b[1], b1, difference[1], b2);
fullsubtractor fs2(a[2], b[2], b2, difference[2], b3);
fullsubtractor fs3(a[3], b[3], b3, difference[3], borrow_out); //calculates difference in most significant bit

endmodule
