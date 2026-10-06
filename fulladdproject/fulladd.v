`timescale 1ns / 1ps
    
module fulladd(sum, c_out, a, b, c_in);
input a;
input b;
input c_in;
output sum;
output c_out;

wire s1, c1, c2;

xor(s1, a, b); //takes sum s1 as input of a XOR b (0, 0 -> 0 | 1, 0 -> 1 | 0, 1 -> 1, 1, 1 -> 0)
and(c1, a, b); //takes carry c1 as the input of a AND b (0, 0 -> 0 | 1, 0 -> 0 | 0, 1 -> 0, 1, 1 -> 1)
xor(sum, s1, c_in); //takes the final sum by taking the s1 XOR c_in
and(c2, s1, c_in); //gets the carry c2
or(c_out, c2, c1); //gets the carry_out to the next adder

//essentially this is how it works
//We check the first bits a and b to see if they have the same bit, if they do not, we set s1 = 1
//Then we check s1 and the c_in to see if they are the same bit, if they do not, we set sum=1
//For the carry we are implementing 2 different kids of logic:
//If our initially carry from taking A AND B is 1, then our carry will be one no matter c_in
//If not, then we check if s1 = 1 AND c_in = 1, and if it is, then our c_out=1


endmodule
