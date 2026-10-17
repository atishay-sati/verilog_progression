`timescale 1ns / 1ps

module testbench;
reg [3:0] D; 
reg CLK = 0;
wire [3:0] Q;

always #5 CLK = ~CLK;

register_4bit memory4bit(D, CLK, Q);

initial begin
    $monitor($time, "D = %b (%d) CLK = %b Q = %b (%d)", 
                    D, D, CLK, Q, Q);
end

integer i;
initial begin
    D = 0;
    #2
    for (i = 0; i < 16; i = i+1) begin
        D = i;
        #10;
    end
    $finish;
end

endmodule
