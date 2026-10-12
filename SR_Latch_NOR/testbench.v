`timescale 1ns / 1ps

module testbench;
reg S, R;
wire Q, QBAR;

SR_Latch memory1bit(S, R, Q, QBAR);

initial
begin
$monitor($time, "S = %b, R = %b, Q = %b, QBAR = %b", S, R, Q, QBAR);
end

initial
begin
 // Initialize to Q=0 / QBAR=1 with a short reset pulse
S = 0; R = 1;
#5 R = 0;          // release: latch holds Q=0, QBAR=1
#5 S = 1; R = 0;   // set
#5 S = 0; R = 0;   // hold (Q stays 1)
#5 S = 0; R = 1;   // reset
#5 S = 0; R = 0;   // hold (Q stays 0)
#5 $finish;
end
endmodule
