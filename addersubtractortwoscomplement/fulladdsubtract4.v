`timescale 1ns / 1ps


module fulladdsubtract4(operation, sum, c_out, a, b, c_in);
input operation; //inputs our operation where 0 is addition and 1 is subtraction
input [3:0] a; //inputs our 4 bit a value
input [3:0] b; //inputs our 4 bit b value
input c_in; //inputs our carry in
output [3:0] sum; //outputs our sum
output c_out; //outputs our carry out

wire c1, c2, c3; //our carries between operations

wire [3:0] b_twos_complement; //our two's complement for b

//THIS LINE IS IMPORTANT!
assign b_twos_complement = (b ^ {4{operation}}) + operation;
//If our operation is 0 (addition), then b = b, but if operation is 1, we perform 
//twos complement by flipping each bit of b and adding one bit




fulladd f0(sum[0], c1, a[0], b_twos_complement[0], c_in); //0 bit
fulladd f1(sum[1], c2, a[1], b_twos_complement[1], c1); //1 bit
fulladd f2(sum[2], c3, a[2], b_twos_complement[2], c2); //2 bit
fulladd f3(sum[3], c_out, a[3], b_twos_complement[3], c3); //3 bit
    



endmodule
