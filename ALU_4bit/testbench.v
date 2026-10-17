`timescale 1ns / 1ps

module testbench;
reg [3:0] A;
reg [3:0] B;
reg [3:0] OPERATION;
wire [3:0] RESULT;

integer i;

alu_4bit uut (.a(A),.b(B),.operation(OPERATION),.result(RESULT));

initial begin
    A = 4'd5;
    B = 4'd3;

    for (i = 0; i < 16; i = i + 1) begin
        OPERATION = i;
        #10;

        $display("operation=%b (%d), a=%b (%d), b=%b (%d), result=%b (%d)",
                 OPERATION, OPERATION, A, A, B, B, RESULT, RESULT);
    end

    $finish;
end

endmodule
