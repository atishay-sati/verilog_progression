`timescale 1ns / 1ps

module testbench;

reg [3:0] ADDRESS;
wire [15:0] INSTRUCTION;

instruction_memory uut (
    .address(ADDRESS),
    .instruction(INSTRUCTION)
);

initial begin
    $display("Addr | Instruction      | Operation | Dest | Src1 | Src2 | Unused");
    $monitor("%4d | %b |   %b    |  %b  |  %b  |  %b  | %b",
             ADDRESS, INSTRUCTION, INSTRUCTION[15:12],INSTRUCTION[11:10],INSTRUCTION[9:8], INSTRUCTION[7:6], INSTRUCTION[5:0]);

    ADDRESS = 4'd0;
    #10;
    ADDRESS = 4'd1;
    #10;
    ADDRESS = 4'd2;
    #10;
    ADDRESS = 4'd3;
    #10;
    ADDRESS = 4'd4;
    #10;
    $finish;
end

endmodule
