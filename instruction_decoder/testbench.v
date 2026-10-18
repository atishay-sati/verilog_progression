`timescale 1ns / 1ps

module testbench;

reg [15:0] INSTRUCTION;
wire [3:0] OPERATION;
wire [1:0] REGOUT;
wire [1:0] REGIN1;
wire [1:0] REGIN2;

instruction_decoder uut (
    .instruction(INSTRUCTION),
    .operation(OPERATION),
    .regout(REGOUT),
    .regin1(REGIN1),
    .regin2(REGIN2)
);

initial begin
    $display("Instruction      | Operation | Dest | Src1 | Src2");

    $monitor("%b |    %b    |  %b  |  %b  |  %b",
             INSTRUCTION, OPERATION, REGOUT, REGIN1, REGIN2);

    // ADD R0, R1, R2
    INSTRUCTION = {4'b0000, 2'b00, 2'b01, 2'b10, 6'b000000};
    #10;

    // SUB R3, R0, R1
    INSTRUCTION = {4'b0001, 2'b11, 2'b00, 2'b01, 6'b000000};
    #10;

    // MUL R2, R1, R3
    INSTRUCTION = {4'b0010, 2'b10, 2'b01, 2'b11, 6'b000000};
    #10;

    $finish;
end

endmodule
