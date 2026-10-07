`timescale 1ns / 1ps

module testbench;
reg [3:0] A;
reg [3:0] B;
reg [3:0] C;
reg [3:0] D;
reg S0;
reg S1;
wire [3:0] OUT;

MUX4 M(A, B, C, D, S0, S1, OUT);

initial
begin
$monitor($time, "A = %b (%d) B = %b (%d) C = %b (%d) D = %b (%d) S0 = %b S1 = %b OUT = %b (%d)", 
                A, A, B, B, C, C, D, D, S0, S1, OUT, OUT);
end
initial
begin
A = 4'b0000; B = 4'b1010; C = 4'b0101; D = 4'b1111; S0 = 0; S1 = 0; //A
#5 A = 4'b0000; B = 4'b1010; C = 4'b0101; D = 4'b1111; S0 = 1; S1 = 0; //B
#5 A = 4'b0000; B = 4'b1010; C = 4'b0101; D = 4'b1111; S0 = 0; S1 = 1; //C
#5 A = 4'b0000; B = 4'b1010; C = 4'b0101; D = 4'b1111; S0 = 1; S1 = 1; //D
end
endmodule
