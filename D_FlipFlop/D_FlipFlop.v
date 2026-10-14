`timescale 1ns / 1ps

module D_FlipFlop(d, clk, q, qbar);
input d, clk; //input d will correspond to q and will change only when clk is 1
output q, qbar;

wire dprime, dbarprime, qprime, qbarprime, q2prime, q2barprime;

nand #1(dprime, d, ~clk); //master
nand #1(dbarprime, ~d, ~clk); 

nand #1(qprime, dprime, qbarprime);    
nand #1(qbarprime, dbarprime, qprime);

nand #1(q2prime, qprime, clk); //slave
nand #1(q2barprime, qbarprime, clk);

nand #1(q, q2prime, qbar);
nand #1(qbar, q2barprime, q);


endmodule
