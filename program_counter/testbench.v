`timescale 1ns / 1ps

module testbench;

reg CLK = 0;
reg RESET;
reg ENABLE;
reg JUMP;
reg [3:0] JUMP_ADDR;

wire [3:0] PC;

// Instantiate program counter
program_counter uut (
    .clk(CLK),
    .reset(RESET),
    .enable(ENABLE),
    .jump(JUMP),
    .jump_addr(JUMP_ADDR),
    .pc(PC)
);

// Clock period = 10 ns
always #5 CLK = ~CLK;

initial begin
    RESET = 0;
    ENABLE = 0;
    JUMP = 0;
    JUMP_ADDR = 0;

    $display("Time | RESET | ENABLE | JUMP | JUMP_ADDR | PC");
    $monitor("%4t |   %b   |   %b    |  %b   |    %d      | %d",
             $time, RESET, ENABLE, JUMP, JUMP_ADDR, PC);

    // TEST 1: Reset PC to 0
    RESET = 1;
    @(posedge CLK);
    #1;
    if (PC !== 4'd0)
        $display("FAIL: Reset test");
    else
        $display("PASS: Reset test");

    // TEST 2: Increment PC from 0 to 1
    RESET = 0;
    ENABLE = 1;
    @(posedge CLK);
    #1;
    if (PC !== 4'd1)
        $display("FAIL: Increment test 1");
    else
        $display("PASS: Increment test 1");

    // TEST 3: Increment PC from 1 to 2
    @(posedge CLK);
    #1;
    if (PC !== 4'd2)
        $display("FAIL: Increment test 2");
    else
        $display("PASS: Increment test 2");

    // TEST 4: Hold PC at 2 when ENABLE = 0
    ENABLE = 0;
    @(posedge CLK);
    #1;
    if (PC !== 4'd2)
        $display("FAIL: Hold test");
    else
        $display("PASS: Hold test");

    // TEST 5: Jump to address 10
    JUMP = 1;
    JUMP_ADDR = 4'd10;
    @(posedge CLK);
    #1;
    if (PC !== 4'd10)
        $display("FAIL: Jump test");
    else
        $display("PASS: Jump test");

    // TEST 6: Reset takes priority over jump
    RESET = 1;
    @(posedge CLK);
    #1;
    if (PC !== 4'd0)
        $display("FAIL: Reset priority test");
    else
        $display("PASS: Reset priority test");

    $display("\nFinal PC = %d (%b)", PC, PC);

    $finish;
end

endmodule
