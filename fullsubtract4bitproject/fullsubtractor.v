`timescale 1ns / 1ps

module fullsubtractor(a, b, borrow_in, difference, borrow_out);
input a, b, borrow_in;
output difference, borrow_out;

wire d1, borrow_1, borrow_2; 

xor(d1, a, b); //sets the difference of x and y as d1
xor(difference, d1, borrow_in); //sets the difference of d1 and borrow_in as difference
//essentially this block is doing x - y - borrow_in

and(borrow_1, ~a, b); //checks to see if A - B is negative, and if it is, sets b1 to 1
and(borrow_2, ~d1, borrow_in); //checks to see if d1 - borrow_in is negative, and if it is, sets b2 to 1
//essentially this block is checking to see if any of the subtractions are causing a negative

or(borrow_out, borrow_2, borrow_1); //if either is negative, it sets a borrow_out to 1 to the previous bit 

endmodule
