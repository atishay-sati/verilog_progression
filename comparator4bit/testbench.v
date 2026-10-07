`timescale 1ns / 1ps

module testbench;
reg [0:3] A;
reg [0:3] B;
wire GREATER;
wire LESS;
wire EQUAL;

comparator4 COMP(A, B, GREATER, LESS, EQUAL); //runs a 4 bit comparison between A and B

initial
begin
$monitor($time, "A = %b (%d), B = %b (%d), GREATER = %b, LESS = %b, EQUAL = %b",
                A, A, B, B, GREATER, LESS, EQUAL);
end

initial
begin
A = 4'd0; B = 4'd0; //equal
#5 A = 4'd5; B = 4'd1; //greater
#5 A = 4'd3; B = 4'd4; //less
#5 A = 4'd5; B = 4'd2; //greater
#5 A = 4'd14; B = 4'd15; //less
#5 A = 4'd2; B = 4'd2; //equal
end


endmodule
