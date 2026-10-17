`timescale 1ns / 1ps


module jk_flipflop(j,k,clk,q);
input j,k,clk;
output reg q;

always @(posedge clk) //checks at positive edge of clk when changing from 0 to 1 to avoid race-around condition
begin
q <= (j & ~q) | (~k & q);   //logic for setting q
end

//CLK, J, K, Qn+1, Q'n+1 
//------------------------
//  0  x  x  Qn  Q'n
//  1  0  0  Qn  Q'n      hold
//  1  0  1  0   1        reset
//  1  1  0  1   0        set
//  1  1  1  Q'n Qn       toggle (flip)

//basically this is an SR flip flop except we are making use of the J = 1 and K = 1 condition

endmodule
