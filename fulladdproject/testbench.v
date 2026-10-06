`timescale 1ns / 1ps        // Sets simulation time units to 1 ns and precision to 1 ps

module testbench;            // Starts the testbench module

reg [0:3] A;                 // Creates a 4-bit input signal A
reg [0:3] B;                 // Creates a 4-bit input signal B
reg C_IN;                    // Creates a 1-bit carry-in signal

wire [3:0] SUM;              // Creates a 4-bit output for the sum
wire C_OUT;                  // Creates a 1-bit output for the carry-out

fulladd4 FA_4(SUM, C_OUT, A, B, C_IN);  // Connects the full adder to the testbench signals

initial                         // Starts a block that runs once at the beginning
begin
$monitor($time,
         "A=%b (%d), B=%b (%d), C_IN=%b (%d), C_OUT=%b (%d), SUM=%b (%d)\n",
         A, A, B, B, C_IN, C_IN, C_OUT, C_OUT, SUM, SUM);  // Continuously prints the signals when they change
end


initial                         // Starts another block that runs once at the beginning
begin
A = 4'd0; B = 4'd0; C_IN = 1'b0;  // Sets the initial input values
//4'd3 means take the decimal 3 and convert into binary of 4 bits
#5 A = 4'd3; B = 4'd4;             
#5 A = 4'd2; B = 4'd5;             // Waits 5 ns, then sets A=2 and B=5
#5 A = 4'd9; B = 4'd9;             // Waits 5 ns, then sets A=9 and B=9
#5 A = 4'd10; B = 4'd15;            // Waits 5 ns, then sets A=10 and B=15
#5 A = 4'd10; B = 4'd5; C_IN = 1'b1; // Waits 5 ns, then sets A=10, B=5, Cin=1
end

endmodule                         // Ends the testbench module
