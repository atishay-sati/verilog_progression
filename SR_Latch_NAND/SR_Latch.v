`timescale 1ns / 1ps


module SR_Latch(s, r, q, qbar);
input s,r;  
output q, qbar;

nand #1(q, s, qbar);
nand #1(qbar, r, q);
//When the pulse changes, Q and Qbar are fed back into the NAND gate so that they hold their respective value
//They hold values (at R = 1, S = 1) by feeding each NAND gate with their value
//For example, at stable state, if Q = 1 and QBAR = 0, then NAND(S,Q) is 0 = QBAR and vice versa

//This is different to the XOR gate because the stable state (not changing) is high for both R and S

endmodule
