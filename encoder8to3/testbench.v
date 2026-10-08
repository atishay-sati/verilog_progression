`timescale 1ns / 1ps

module testbench;
reg I0, I1, I2, I3, I4, I5, I6, I7;
wire [2:0] OUT;

encoder EightThree(I0, I1, I2, I3, I4, I5, I6, I7, OUT);

initial
begin
$monitor($time, "I0 = %b I1 = %b I2 = %b I3 = %b I4 = %b I5 = %b I6 = %b I7 = %b OUT = %b (%d)",
                 I0, I1, I2, I3, I4, I5, I6, I7, OUT, OUT);
end
initial
begin
I0 = 1; I1 = 0; I2 = 0; I3 = 0; I4 = 0; I5 = 0; I6 = 0; I7 = 0;
#5 I0 = 0; I1 = 1; I2 = 0; I3 = 0; I4 = 0; I5 = 0; I6 = 0; I7 = 0;
#5 I0 = 0; I1 = 0; I2 = 1; I3 = 0; I4 = 0; I5 = 0; I6 = 0; I7 = 0;
#5 I0 = 0; I1 = 0; I2 = 0; I3 = 1; I4 = 0; I5 = 0; I6 = 0; I7 = 0;
#5 I0 = 0; I1 = 0; I2 = 0; I3 = 0; I4 = 1; I5 = 0; I6 = 0; I7 = 0;
#5 I0 = 0; I1 = 0; I2 = 0; I3 = 0; I4 = 0; I5 = 1; I6 = 0; I7 = 0;
#5 I0 = 0; I1 = 0; I2 = 0; I3 = 0; I4 = 0; I5 = 0; I6 = 1; I7 = 0;
#5 I0 = 0; I1 = 0; I2 = 0; I3 = 0; I4 = 0; I5 = 0; I6 = 0; I7 = 1;
end

endmodule
