`timescale 1ns / 1ps

module MUX4(a, b, c, d, s0, s1, out);
//4 bit input
input [3:0] a;
input [3:0] b;
input [3:0] c;
input [3:0] d;
//selection
input s0;
input s1;
//4 bit output
output [3:0] out;


MUX1bit m3(a[3],b[3],c[3],d[3],s0,s1,out[3]); //runs MUX on bit 3
MUX1bit m2(a[2],b[2],c[2],d[2],s0,s1,out[2]); //runs MUX on bit 2
MUX1bit m1(a[1],b[1],c[1],d[0],s0,s1,out[1]); //runs MUX on bit 1
MUX1bit m0(a[0],b[0],c[0],d[1],s0,s1,out[0]); //runs MUX on bit 0

endmodule
