`timescale 1ns / 1ps

module testbench;

reg CLK = 0;
reg [3:0] OPP;
reg [1:0] READ_REG1;
reg [1:0] READ_REG2;
reg [1:0] WRITE_REG;
reg ENABLE;

register_file uut (
    .clk(CLK),
    .opp(OPP),
    .read_reg1(READ_REG1),
    .read_reg2(READ_REG2),
    .write_reg(WRITE_REG),
    .enable(ENABLE)
);

always #5 CLK = ~CLK;

// Display all register values
task display_registers;
begin
    $display("R0=%d (%b) | R1=%d (%b) | R2=%d (%b) | R3=%d (%b)",
        uut.registers[0], uut.registers[0],
        uut.registers[1], uut.registers[1],
        uut.registers[2], uut.registers[2],
        uut.registers[3], uut.registers[3]);
end
endtask

initial begin
    OPP = 0;
    READ_REG1 = 1;
    READ_REG2 = 2;
    WRITE_REG = 0;
    ENABLE = 0;

    #2;
    $display("\nInitial register values:");
    display_registers();

    // TEST 1: Addition: R1 + R2 -> R0
    $display("\nTEST 1: ADD R1 + R2 -> R0");
    OPP = 4'b0000;
    READ_REG1 = 1;
    READ_REG2 = 2;
    WRITE_REG = 0;
    ENABLE = 1;

    #1;
    $display("Before write:");
    display_registers();

    @(posedge CLK);
    #1;
    $display("After write:");
    display_registers();

    if (uut.registers[0] !== 4'd3)
        $display("FAIL: Addition/write test");
    else
        $display("PASS: Addition/write test");

    // TEST 2: Writing disabled
    $display("\nTEST 2: ENABLE = 0");
    ENABLE = 0;

    #1;
    $display("Before clock edge:");
    display_registers();

    @(posedge CLK);
    #1;
    $display("After clock edge:");
    display_registers();

    if (uut.registers[0] !== 4'd3)
        $display("FAIL: Register changed while disabled");
    else
        $display("PASS: Write enable test");

    // TEST 3: Subtraction: R2 - R1 -> R3
    $display("\nTEST 3: SUB R2 - R1 -> R3");
    OPP = 4'b0001;
    READ_REG1 = 2;
    READ_REG2 = 1;
    WRITE_REG = 3;
    ENABLE = 1;

    #1;
    $display("Before write:");
    display_registers();

    @(posedge CLK);
    #1;
    $display("After write:");
    display_registers();

    if (uut.registers[3] !== 4'd1)
        $display("FAIL: Subtraction/write test");
    else
        $display("PASS: Subtraction/write test");

    // TEST 4: Multiplication: R1 * R3 -> R2
    $display("\nTEST 4: MUL R1 * R3 -> R2");
    OPP = 4'b0010;
    READ_REG1 = 1;
    READ_REG2 = 3;
    WRITE_REG = 2;

    #1;
    $display("Before write:");
    display_registers();

    @(posedge CLK);
    #1;
    $display("After write:");
    display_registers();

    if (uut.registers[2] !== 4'd1)
        $display("FAIL: Multiplication/write test");
    else
        $display("PASS: Multiplication/write test");

    $display("\nFinal register values:");
    display_registers();

    $finish;
end

endmodule
