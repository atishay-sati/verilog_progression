`timescale 1ns / 1ps

module testbench;
reg S = 0, R = 0, CLK = 0;
wire Q, QBAR;

SR_FlipFlop memory1bit(S, R, CLK, Q, QBAR);

always #5 CLK = ~CLK;   // alternates between 1 and 0 every 5 seconds; period = 10 ns, rising edges at 5, 15, 25, ...

initial
begin
$monitor($time, "CLK = %b, S = %b, R = %b,  Q = %b, QBAR = %b", CLK, S, R, Q, QBAR);
end

initial
begin
// Reset first to get out of X (clk is 0 until t=5)
S = 0; R = 1;
#10;                // clk is high from 5 to 10 -> latch resets, q=0
S = 1; R = 0;       // clk is low from 10 to 15 -> nothing happens
#10;                // clk high from 15 to 20 -> set, q=1
S = 0; R = 0;       // hold
#10;
S = 0; R = 1;       // reset
#10;
$finish;
end

endmodule
