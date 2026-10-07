`timescale 1ns / 1ps

module comparator(a, b, greater, less, equal);
input a; //1 bit input
input b; //1 bit input
output greater; 
output less;
output equal;

and(greater, a, ~b); //sets greater to 1 if a AND not b. basically only if a = 1 and b = 0 will it return 1 
and(less, ~a, b); //sets less to 1 if NOT a AND b. basically only if a = 0 and b = 1 will it return 1 
xnor(equal, a, b); //sets equal to 1 if NOT XOR A and B. basically return 1 if a = 0 and b = 0 or a = 1 and b = 1

endmodule
