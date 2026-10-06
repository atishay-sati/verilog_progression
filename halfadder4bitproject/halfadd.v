`timescale 1ns / 1ps

module halfadd(sum, carry, a, b); 
input a, b; //takes 1 bit inputs a and b
output sum, carry; //outputs 1 bit sum and carry

xor(sum, a, b); //sum is calculated using xor gate of a and b
and(carry, a, b); //carry is calculated using and gate of a and b

endmodule
