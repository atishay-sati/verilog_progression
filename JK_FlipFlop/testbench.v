`timescale 1ns / 1ps


module testbench;
reg J, K, CLK = 0;
wire Q;

always #5 CLK = ~CLK;

jk_flipflop memory1bit(J,K,CLK,Q);



initial
begin
$monitor($time, "J = %b K = %b CLK = %b Q = %b", 
                 J, K, CLK, Q);
end

initial
begin
#2 J = 1'b0; K = 1'b0;
#10 J = 1'b0; K = 1'b1;
#10 J = 1'b1; K = 1'b0;
#10 J = 1'b1; K = 1'b1;
#10 J = 1'b1; K = 1'b1;
#10 $finish;

end
endmodule
