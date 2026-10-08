`timescale 1ns / 1ps

module testbench;
reg [2:0] IN;
wire I0, I1, I2, I3, I4, I5, I6, I7;

decoder ThreetoEight(IN, I0, I1, I2, I3, I4, I5, I6, I7);

initial
begin
$monitor($time, "INPUT = %b (%d) I0 = %b I1 = %b I2 = %b I3 = %b I4 = %b I5 = %b I6 = %b I7 = %b",
                IN, IN, I0, I1, I2, I3, I4, I5, I6, I7);
end

initial
begin
IN = 3'b000;
#5 IN = 3'b001;
#5 IN = 3'b010;
#5 IN = 3'b011;
#5 IN = 3'b100;
#5 IN = 3'b101;
#5 IN = 3'b110;
#5 IN = 3'b111;
end

endmodule
