`timescale 1ns / 1ps

module testbench;
reg CLK = 0;
wire [3:0] Q;

always #5 CLK = ~CLK;

counter_4bit counter(CLK, Q);

initial begin
$monitor($time, "CLK = %b Q = %b (%d)",
                 CLK, Q, Q);
end

endmodule
