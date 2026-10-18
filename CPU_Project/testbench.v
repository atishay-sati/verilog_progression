
`timescale 1ns / 1ps

module testbench;

reg CLK;
reg RESET;
reg ENABLE;
reg JUMP;
reg [3:0] JUMP_ADDR;

wire [3:0] RESULT;

cpu uut(
    .clk(CLK),
    .reset(RESET),
    .enable(ENABLE),
    .jump(JUMP),
    .jump_addr(JUMP_ADDR),
    .result(RESULT)
);

always #5 CLK = ~CLK;

initial begin
    CLK = 0;
    RESET = 1;
    ENABLE = 0;
    JUMP = 0;
    JUMP_ADDR = 4'b0000;
    
    $display("Initial PC=%d | R0=%d R1=%d R2=%d R3=%d",
             uut.pc,
             uut.readwrite.registers[0],
             uut.readwrite.registers[1],
             uut.readwrite.registers[2],
             uut.readwrite.registers[3]);
             
    // Test 1: Reset the CPU
    #10;
    RESET = 0;
    ENABLE = 1;

    $display("\nTEST 1: Normal execution");
    repeat (2) begin
        @(posedge CLK);
        #1;
        $display("PC=%d | R0=%d R1=%d R2=%d R3=%d",
                 uut.pc,
                 uut.readwrite.registers[0],
                 uut.readwrite.registers[1],
                 uut.readwrite.registers[2],
                 uut.readwrite.registers[3]);
    end

    // Test 2: Disable execution
    $display("\nTEST 2: Disable execution");
    ENABLE = 0;

    repeat (2) begin
        @(posedge CLK);
        #1;
        $display("PC=%d | R0=%d R1=%d R2=%d R3=%d",
                 uut.pc,
                 uut.readwrite.registers[0],
                 uut.readwrite.registers[1],
                 uut.readwrite.registers[2],
                 uut.readwrite.registers[3]);
    end

    // Test 3: Jump to address 2
    $display("\nTEST 3: Jump to address 2");
    JUMP_ADDR = 4'd2;
    JUMP = 1;

    @(posedge CLK);
    #1;
    $display("PC after jump = %d", uut.pc);

    JUMP = 0;

    // Test 4: Resume execution
    $display("\nTEST 4: Resume execution");
    ENABLE = 1;

    repeat (2) begin
        @(posedge CLK);
        #1;
        $display("PC=%d | R0=%d R1=%d R2=%d R3=%d",
                 uut.pc,
                 uut.readwrite.registers[0],
                 uut.readwrite.registers[1],
                 uut.readwrite.registers[2],
                 uut.readwrite.registers[3]);
    end

    // Test 5: Reset the PC
    $display("\nTEST 5: Reset the CPU");
    RESET = 1;
    ENABLE = 0;

    @(posedge CLK);
    #1;
    $display("PC after reset = %d", uut.pc);

    RESET = 0;

    #10;
    $finish;
end

endmodule
