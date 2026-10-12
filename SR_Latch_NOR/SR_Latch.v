`timescale 1ns / 1ps


module SR_Latch(s, r, q, qbar);
input s,r;  
output q, qbar;

nor #1(q, r, qbar);
nor #1(qbar, s, q);
//When the pulse changes, Q and Qbar are fed back into the NOR gate so that they hold their respective value
//They hold values (at R = 0, S = 0) by feeding each NOR gate with their value
//For example, if Q = 1 and QBAR = 0, then NOR(S,QBAR) is 1 = Q and vice versa

endmodule
