`timescale 1ns / 1ps

module testbench;
reg [3:0] A;
reg [3:0] B;
reg B_IN;

wire [3:0] DIFFERENCE;
wire B_OUT;

fullsubtractor4 FS4( A, B, B_IN, DIFFERENCE, B_OUT);

integer result;

always @(*) begin
    if (B_OUT == 1'b1)
        result = -((~DIFFERENCE + 1'b1) & 4'b1111);
    else
        result = DIFFERENCE;
end

initial
begin
$monitor($time, "A = %b (%d), B = %b (%d), B_IN=%b (%d), B_OUT=%b (%d), DIFFERENCE=%b (%2d)\n",
                 A, A, B, B, B_IN, B_IN, B_OUT, B_OUT, DIFFERENCE, result);
                 
end

initial
begin
A = 4'd0; B = 4'd0; B_IN = 1'b0;
#5 A = 4'd3; B = 4'd4;             
#5 A = 4'd2; B = 4'd5;             // Waits 5 ns, then sets A=5 and B=2
#5 A = 4'd9; B = 4'd9;  B_IN = 1'b1;             // Waits 5 ns, then sets A=9 and B=9
#5 A = 4'd10; B = 4'd15;            // Waits 5 ns, then sets A=10 and B=15
#5 A = 4'd10; B = 4'd5; // Waits 5 ns, then sets A=5, B=10
end
endmodule
