`timescale 1ns / 1ps


module SR_FlipFlop(s, r,  clk, q, qbar);
input s,r,clk;
output q, qbar;

wire sPrime, rPrime;
nand(rPrime, r, clk);
nand(sPrime, s, clk);
nand #1(qbar, rPrime, q); //pulse
nand #1(q, sPrime, qbar); //pulse


//alternative method: 
//and(sPrime, s, cldk);
//and(rPrime, r, clk);
//nor #1(q, rPrime, qbar);
//nor #1(qbar, sPrime, q);
endmodule
