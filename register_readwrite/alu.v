`timescale 1ns / 1ps

module alu(a, b, operation, result);
input [3:0] a;
input [3:0] b;
input [3:0] operation;
output reg [3:0] result;

always @(*) begin
    case (operation)
        4'b0000: result = a + b;                        // Addition: A + B
        4'b0001: result = a - b;                        // Subtraction: A - B
        4'b0010: result = a * b;                        // Multiplication: A * B
        4'b0011: result = (b != 0) ? a / b : 4'b0000;   // Division: A / B (0 if B = 0)
        4'b0100: result = (b != 0) ? a % b : 4'b0000;   // Modulo: A % B (0 if B = 0)
        4'b0101: result = a + 1'b1;                     // Increment A: A + 1
        4'b0110: result = a - 1'b1;                     // Decrement A: A - 1
        4'b0111: result = a & b;                        // Bitwise AND: A & B
        4'b1000: result = a | b;                        // Bitwise OR: A | B
        4'b1001: result = a ^ b;                        // Bitwise XOR: A ^ B
        4'b1010: result = ~a;                           // Bitwise NOT: ~A
        4'b1011: result = a << 1;                       // Shift left: A << 1
        4'b1100: result = a >> 1;                       // Shift right: A >> 1
        4'b1101: result = (a == b) ? 4'b0001 : 4'b0000; // Equal: A == B
        4'b1110: result = (a < b) ? 4'b0001 : 4'b0000;  // Unsigned less than: A < B
        4'b1111: result = ~(a & b);                     // Bitwise NAND: ~(A & B)
        default: result = 4'b0000;                      // Default: output 0
    endcase
        
end
endmodule
