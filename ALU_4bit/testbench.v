
`timescale 1ns / 1ps

module testbench;

reg [3:0] A;
reg [3:0] B;
reg [3:0] OPERATION;
wire [3:0] RESULT;
reg [3:0] EXPECTED;

integer i;
integer j;
integer pass_count;
integer fail_count;

alu_4bit uut (.a(A),.b(B),.operation(OPERATION),.result(RESULT));

initial begin
    pass_count = 0;
    fail_count = 0;

    // Test several combinations of A and B
    for (i = 0; i < 4; i = i + 1) begin

        // Change A and B for each group of tests
        case (i)
            0: begin A = 4'd5;  B = 4'd3;  end
            1: begin A = 4'd15; B = 4'd1;  end
            2: begin A = 4'd0;  B = 4'd0;  end
            3: begin A = 4'd10; B = 4'd0;  end
        endcase

        // Test every operation for this pair of inputs
        for (j = 0; j < 16; j = j + 1) begin
             OPERATION = j;

            #10;

            // Calculate the expected result
            case (OPERATION)
                4'b0000: EXPECTED = A + B;
                4'b0001: EXPECTED = A - B;
                4'b0010: EXPECTED = A * B;
                4'b0011: EXPECTED =
                    (B != 0) ? A / B : 4'b0000;
                4'b0100: EXPECTED =
                    (B != 0) ? A % B : 4'b0000;
                4'b0101: EXPECTED = A + 1'b1;
                4'b0110: EXPECTED = A - 1'b1;
                4'b0111: EXPECTED = A & B;
                4'b1000: EXPECTED = A | B;
                4'b1001: EXPECTED = A ^ B;
                4'b1010: EXPECTED = ~A;
                4'b1011: EXPECTED = A << 1;
                4'b1100: EXPECTED = A >> 1;
                4'b1101: EXPECTED = (A == B) ? 4'd1 : 4'd0;
                4'b1110: EXPECTED = (A < B) ? 4'd1 : 4'd0;
                4'b1111: EXPECTED = ~(A & B);
                default: EXPECTED = 4'b0000;
            endcase

            // Compare actual and expected results
            if (RESULT === EXPECTED) begin
                $display("PASS | OP=%b (%d), A=%b (%d), B=%b (%d), Expected=%b, Actual=%b",
                         OPERATION, OPERATION, A, A, B, B,
                         EXPECTED, RESULT);
                pass_count = pass_count + 1;
            end
            else begin
                $display("FAIL | OP=%b (%d), A=%b (%d), B=%b (%d), Expected=%b, Actual=%b",
                         OPERATION, OPERATION, A, A, B, B,
                         EXPECTED, RESULT);
                fail_count = fail_count + 1;
            end
        end
    end

    $display("------------------------------------------");
    $display("Verification complete");
    $display("Passed: %d", pass_count);
    $display("Failed: %d", fail_count);
    $display("Total:  %d", pass_count + fail_count);

    if (fail_count == 0)
        $display("ALL TESTS PASSED!");
    else
        $display("SOME TESTS FAILED!");

    $finish;
end

endmodule
