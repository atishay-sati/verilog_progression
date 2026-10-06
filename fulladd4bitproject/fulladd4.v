`timescale 1ns / 1ps

module fulladd4(sum, c_out, a, b, c_in); //takes in 3 inputs a, b, and c_in and calculates final sum and c_out
output[3:0] sum; //four bit sum
output c_out; //the carry out after the full adder
input[3:0] a, b; //a and b are 4 bit inputs where a[0] corresponds to the last bit
input c_in; //our input carry_in  (initial carry_in)

wire c1, c2, c3; //our carry signals after each adder

fulladd f0(sum[0], c1, a[0], b[0], c_in); //bit 0
fulladd f1(sum[1], c2, a[1], b[1], c1); //bit 1
fulladd f2(sum[2], c3, a[2], b[2], c2); //bit 2
fulladd f3(sum[3], c_out, a[3], b[3], c3); //bit 3

endmodule
