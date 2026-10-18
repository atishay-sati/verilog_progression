`timescale 1ns / 1ps

module testbench;
reg E, R, CLK = 0;
wire [3:0] Q;

always #5 CLK = ~CLK;

counter_conditional counter(E,R,CLK,Q);

initial begin
    $monitor($time, "E = %b R = %b CLK = %b Q = %b (%d)",
                     E, R, CLK, Q, Q);
end

initial begin
    #2 E = 1'b0; R = 1'b1;
    #10 E = 1'b1; R = 1'b0;
    #10 E = 1'b1; R = 1'b0;
    #10 E = 1'b1; R = 1'b0;
    #10 E = 1'b1; R = 1'b1;
    #10 E = 1'b1; R = 1'b0;
end
endmodule
