`timescale 1ns / 1ps

module ALU(a, b, operation, result);

input [31:0] a;
input [31:0] b;
input [3:0] operation;

output reg [31:0] result;


// Internal operation codes (these will ALWAYS stay the same)
localparam ADD  = 4'b0000;
localparam SUB  = 4'b0001;
localparam AND  = 4'b0010;
localparam OR   = 4'b0011;
localparam XOR  = 4'b0100;
localparam SLL  = 4'b0101;
localparam SRL  = 4'b0110;
localparam SRA  = 4'b0111;
localparam SLT  = 4'b1000;
localparam SLTU = 4'b1001;
localparam EQ   = 4'b1010;
localparam NE   = 4'b1011;
localparam GE   = 4'b1100;
localparam GEU  = 4'b1101;

always @(*) begin
    case (operation)
        ADD:  result = a + b;                                      // Add a and b
        SUB:  result = a - b;                                      // Subtract b from a

        AND:  result = a & b;                                      // Bitwise AND
        OR:   result = a | b;                                      // Bitwise OR
        XOR:  result = a ^ b;                                      // Bitwise XOR

        SLL:  result = a << b[4:0];                                // Shift left by b's lower 5 bits
        SRL:  result = a >> b[4:0];                                // Logical shift right
        SRA:  result = $signed(a) >>> b[4:0];                      // Arithmetic shift right

        SLT:  result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0; // 1 if a < b (signed)
        SLTU: result = (a < b) ? 32'd1 : 32'd0;                   // 1 if a < b (unsigned)

        EQ:   result = (a == b) ? 32'd1 : 32'd0;                  // 1 if a equals b
        NE:   result = (a != b) ? 32'd1 : 32'd0;                  // 1 if a does not equal b
        GE:   result = ($signed(a) >= $signed(b)) ? 32'd1 : 32'd0; // 1 if a >= b (signed)
        GEU:  result = (a >= b) ? 32'd1 : 32'd0;                  // 1 if a >= b (unsigned)

        default: result = 32'd0;
    endcase
end

endmodule
