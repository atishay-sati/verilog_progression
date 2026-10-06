`timescale 1ns / 1ps

module testbench;
reg A, B; //basically says we are setting this value
wire SUM; //what our output will be
wire C_OUT; //what our output will be

halfadd HA(SUM, C_OUT, A, B); //computes sum and c_out with given inputs
initial
begin
$monitor ($time, "A = %b (%d), B = %b (%d), SUM = %b (%d), C_OUT = %b (%d)", 
                    A, A, B, B, SUM, SUM, C_OUT, C_OUT);
end
initial
begin
A = 1'd0; B = 1'd0; //1'd0 means we are giving one bit for the number 0 (any integer can go in here but will be truncated) by bit size
#5 A = 1'd1; B = 1'd0; //5 nano second increment change A to 1 and B to 0
#5 A = 1'd0; B = 1'd1;
#5 A = 1'd1; B = 1'd1;

end


endmodule
