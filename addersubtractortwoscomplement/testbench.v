`timescale 1ns / 1ps

module testbench;
reg OPERATION;
reg [3:0] A;
reg [3:0] B;
reg C_IN;
wire C_OUT;
wire [3:0] SUM;
integer NEGATIVE;

fulladdsubtract4 FS_4(OPERATION, SUM, C_OUT, A, B, C_IN);

always @(*) //whenever values change
begin
    if (OPERATION == 1 && C_OUT == 0) //This just says if we're doing subtraction, and the addition used to perform that subtraction didn't produce a carry-out, then A < B, so the result is negative.
    begin
        NEGATIVE = $signed(SUM); //convert the sum to a negative number
    end
    else
    begin
        NEGATIVE = SUM; //negative is just the decimal version of sum
    end
end

initial
begin
$monitor($time,
         "A=%b (%d), B=%b (%d), C_IN=%b (%d), C_OUT=%b (%d), SUM=%b (%2d)\n",
         A, A, B, B, C_IN, C_IN, C_OUT, C_OUT, SUM, NEGATIVE);  // Continuously prints the signals when they change
end

initial
begin

//ADDITION TEST CASES (OPERATION = 0)
#5 OPERATION = 0; A = 4'd0;  B = 4'd0;  C_IN = 1'b0; // Basic zero addition
#5 OPERATION = 0; A = 4'd3;  B = 4'd4;  C_IN = 1'b0; 
#5 OPERATION = 0; A = 4'd5;  B = 4'd5;  C_IN = 1'b1; 
#5 OPERATION = 0; A = 4'd10; B = 4'd5;  C_IN = 1'b0; // Addition (10 + 5 = 15, max 4-bit value)
#5 OPERATION = 0; A = 4'd15; B = 4'd1;  C_IN = 1'b0; 
#5 OPERATION = 0; A = 4'd15; B = 4'd15; C_IN = 1'b1; 
//SUBTRACTION TEST CASES (OPERATION = 1)
#5 OPERATION = 1; A = 4'd0;  B = 4'd0;  C_IN = 1'b0; // Basic zero subtraction
#5 OPERATION = 1; A = 4'd10; B = 4'd5;  C_IN = 1'b0; 
#5 OPERATION = 1; A = 4'd9;  B = 4'd9;  C_IN = 1'b0; 
#5 OPERATION = 1; A = 4'd10; B = 4'd5;  C_IN = 1'b1; 
#5 OPERATION = 1; A = 4'd3;  B = 4'd4;  C_IN = 1'b0; // Negative result / Borrow needed (3 - 4)
#5 OPERATION = 1; A = 4'd0;  B = 4'd1;  C_IN = 1'b0; 

end 


endmodule
