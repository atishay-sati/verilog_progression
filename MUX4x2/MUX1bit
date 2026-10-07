`timescale 1ns / 1ps

module MUX1bit(a, b, c, d, s0, s1, out);
input a;
input b;
input c;
input d;
input s0;
input s1;
output out;

wire wa, wb, wc, wd; //wires for each output from comparison

and(wa, a, ~s0, ~s1); //if s0 = 0 and s1 = 0, the wire will carry the value of a
and(wb, b, s0, ~s1); //if s0 = 1 and s1 = 0, the wire will carry the value of b
and(wc, c, ~s0, s1); //if s0 = 0 and s1 = 1, the wire will carry the value of c
and(wd, d, s0, s1); //if s0 = 1 and s1 = 1, the wire will carry the value of d
or(out, wa, wb, wc, wd); //if any of the values is 1, then the output will be 0
//essentially how this works is that it is impossible to get a wire output of 1 if
//we are on a selection that isn't supposed to happen. What this means is that if I wanted
//to choose b, s0 = 1, ~s1 = 1, which is makes it possible to get a return from b. If I was 
//to check with c, ~s0 = 0, s1 = 0, which makes it impossible to get a non-zero output from c

endmodule
