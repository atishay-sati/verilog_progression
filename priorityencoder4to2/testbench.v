`timescale 1ns / 1ps

module testbench;
reg I3, I2, I1, I0;
wire Y1, Y2;

priorityencoder FourtoTwo(I3, I2, I1, I0, Y1, Y2);
initial
begin
$monitor($time, " I3 = %b I2 = %b I1 = %b I0 = %b Y1 = %b Y2 = %b",
                 I3, I2, I1, I0, Y1, Y2);
end


initial
begin
I3 = 1'b1; I2 = 1'b1; I1 = 1'b1; I0 = 1'b1;
#5 I3 = 1'b1; I2 = 1'b1; I1 = 1'b1; I0 = 1'b0;
#5 I3 = 1'b1; I2 = 1'b1; I1 = 1'b0; I0 = 1'b0;
#5 I3 = 1'b1; I2 = 1'b0; I1 = 1'b0; I0 = 1'b0;
#5 I3 = 1'b0; I2 = 1'b1; I1 = 1'b1; I0 = 1'b1;
#5 I3 = 1'b0; I2 = 1'b1; I1 = 1'b0; I0 = 1'b1;
#5 I3 = 1'b0; I2 = 1'b0; I1 = 1'b1; I0 = 1'b1;
#5 I3 = 1'b0; I2 = 1'b0; I1 = 1'b1; I0 = 1'b0;
#5 I3 = 1'b0; I2 = 1'b0; I1 = 1'b0; I0 = 1'b1;
#5 I3 = 1'b0; I2 = 1'b0; I1 = 1'b0; I0 = 1'b0;
end

endmodule
