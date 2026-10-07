`timescale 1ns / 1ps

module comparator4(a, b, greater, less, equal);
input [3:0] a;
input [3:0] b;
output greater;
output less;
output equal;

//wires for our outputs from 1 bit comparator
wire g3, g2, g1, g0; 
wire l3, l2, l1, l0;
wire e3, e2, e1, e0;

//runs the comparator for our 4 bits
comparator comp3(a[3], b[3], g3, l3, e3);
comparator comp2(a[2], b[2], g2, l2, e2);
comparator comp1(a[1], b[1], g1, l1, e1);
comparator comp0(a[0], b[0], g0, l0, e0);


// a is greater than b if the most significant unequal bit has a = 1 and b = 0
assign greater = g3 |
                 (e3 & g2) |
                 (e3 & e2 & g1) |
                 (e3 & e2 & e1 & g0);

// a is greater than b if the most significant unequal bit has a = 0 and b = 1
assign less = l3 |
              (e3 & l2) |
              (e3 & e2 & l1) |
              (e3 & e2 & e1 & l0);
              
//a is equal to b if all the bits are equal to each other              
assign equal = e3 & e2 & e1 & e0;  


endmodule
