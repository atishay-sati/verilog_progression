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

// ALTERNATIVE SOLUTION: behavioral D flip-flop using always @(posedge clk)

//always @(posedge clk)   // runs only at the instant clk rises from 0 to 1
//    q <= d;             // sample d at that instant and store it in q (nonblocking, as is standard for flip-flops)
                        // between rising edges nothing triggers this block, so q holds its value
 
//assign qbar = ~q;       // qbar is always the inverse of q


endmodule
