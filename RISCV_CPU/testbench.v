`timescale 1ns / 1ps

module testbench;

// ============================================================
// TESTBENCH SIGNALS
// ============================================================

// The testbench generates the clock that drives the CPU.
// The clock changes every 5 ns, giving it a 10 ns period.
reg clk;

// reset places the CPU into its initial state.
// enable allows the CPU to execute instructions.
reg reset;
reg enable;

// These wires observe the CPU's current program counter and
// the instruction being fetched from instruction memory.
wire [31:0] pc_out;
wire [31:0] instruction_out;

// passed counts successful checks.
// failed counts checks where the actual value differs
// from the expected value.
integer passed;
integer failed;

// Loop counter used when initializing instruction memory.
integer i;


// ============================================================
// CPU INSTANTIATION
// ============================================================

// Instantiate the CPU being tested.
//
// The testbench supplies clk, reset, and enable.
// pc_out and instruction_out are connected so that we can
// observe the CPU while it executes the test program.
cpu dut (
    .clk(clk),
    .reset(reset),
    .enable(enable),
    .pc_out(pc_out),
    .instruction_out(instruction_out)
);


// ============================================================
// CLOCK GENERATION
// ============================================================

// Toggle the clock every 5 ns.
// One complete clock cycle therefore takes 10 ns.
//
// The CPU normally updates its sequential state on a rising
// edge of this clock.
always #5 clk = ~clk;


// ============================================================
// INSTRUCTION ENCODING FUNCTIONS
// ============================================================

// These functions assemble 32-bit RISC-V instructions from
// their individual fields.
//
// They are testbench helpers, not part of the CPU itself.
// Instead of manually writing every instruction as a long
// binary or hexadecimal number, we provide its fields.
//
// RISC-V instructions are 32 bits wide in this RV32I project.
// Different instruction formats place their fields in
// different bit positions.


// ------------------------------------------------------------
// R-TYPE ENCODER
// Used for register-to-register operations such as:
// ADD, SUB, AND, OR, XOR, SLL, SRL, SLT, and SLTU.
//
// Bit layout:
// [31:25] funct7
// [24:20] rs2
// [19:15] rs1
// [14:12] funct3
// [11:7]  rd
// [6:0]   opcode
// ------------------------------------------------------------
function [31:0] enc_r;
    input [6:0] funct7;
    input [4:0] rs2;
    input [4:0] rs1;
    input [2:0] funct3;
    input [4:0] rd;
    input [6:0] opcode;
    begin
        enc_r = {funct7, rs2, rs1, funct3, rd, opcode};
    end
endfunction


// ------------------------------------------------------------
// I-TYPE ENCODER
// Used for immediate arithmetic, loads, and JALR.
//
// The 12-bit immediate is stored in bits [31:20].
// The CPU must sign-extend this immediate for instructions
// such as ADDI, LW, and JALR.
//
// Shift-immediate instructions also use this format, but the
// shift amount is stored in bits [24:20].
// ------------------------------------------------------------
function [31:0] enc_i;
    input [11:0] imm;
    input [4:0] rs1;
    input [2:0] funct3;
    input [4:0] rd;
    input [6:0] opcode;
    begin
        enc_i = {imm, rs1, funct3, rd, opcode};
    end
endfunction


// ------------------------------------------------------------
// S-TYPE ENCODER
// Used for store instructions such as SW.
//
// The 12-bit immediate is split into two pieces:
// [11:5] goes into instruction bits [31:25].
// [4:0]  goes into instruction bits [11:7].
//
// This checks whether the CPU correctly reconstructs a
// store address from a split immediate.
// ------------------------------------------------------------
function [31:0] enc_s;
    input [11:0] imm;
    input [4:0] rs2;
    input [4:0] rs1;
    input [2:0] funct3;
    input [6:0] opcode;
    begin
        enc_s = {imm[11:5], rs2, rs1, funct3,
                 imm[4:0], opcode};
    end
endfunction


// ------------------------------------------------------------
// B-TYPE ENCODER
// Used for conditional branches.
//
// The branch immediate is split across several instruction
// fields. Its least significant bit is not stored because
// branch offsets are multiples of 2 bytes.
//
// The tests below use +8, which skips one 32-bit instruction
// and lands on the instruction two positions after the branch.
// ------------------------------------------------------------
function [31:0] enc_b;
    input [12:0] imm;
    input [4:0] rs2;
    input [4:0] rs1;
    input [2:0] funct3;
    input [6:0] opcode;
    begin
        enc_b = {imm[12], imm[10:5], rs2, rs1,
                 funct3, imm[4:1], imm[11], opcode};
    end
endfunction


// ------------------------------------------------------------
// U-TYPE ENCODER
// Used for LUI and AUIPC.
//
// The 20-bit immediate occupies instruction bits [31:12].
// The CPU appends 12 zero bits to form the 32-bit value.
// ------------------------------------------------------------
function [31:0] enc_u;
    input [19:0] imm;
    input [4:0] rd;
    input [6:0] opcode;
    begin
        enc_u = {imm, rd, opcode};
    end
endfunction


// ------------------------------------------------------------
// J-TYPE ENCODER
// Used for JAL.
//
// Like B-type instructions, the J-type immediate is split
// across multiple fields and includes an implicit zero bit.
// JAL jumps to PC + immediate and saves PC + 4 in rd.
// ------------------------------------------------------------
function [31:0] enc_j;
    input [20:0] imm;
    input [4:0] rd;
    input [6:0] opcode;
    begin
        enc_j = {imm[20], imm[10:1], imm[11],
                 imm[19:12], rd, opcode};
    end
endfunction


// ============================================================
// REGISTER CHECK TASK
// ============================================================

// Read one register directly from the CPU's register-file
// array and compare it against the expected result.
//
// The hierarchical path below assumes the register file
// instance is named register_file_inst and its array is
// named registers.
//
// The === operator checks exact 4-state equality. This means
// an X or Z value does not accidentally count as a pass.
//
// Every check increments either passed or failed.
task check_reg;
    input [4:0] reg_num;
    input [31:0] expected;
    reg [31:0] actual;
    begin
        actual = dut.register_file_inst.registers[reg_num];

        if (actual === expected) begin
            $display("PASS: x%0d = %08h", reg_num, actual);
            passed = passed + 1;
        end
        else begin
            $display("FAIL: x%0d expected %08h, got %08h",
                     reg_num, expected, actual);
            failed = failed + 1;
        end
    end
endtask


// ============================================================
// MAIN TEST PROGRAM
// ============================================================

initial begin

    // --------------------------------------------------------
    // TEST SETUP
    // --------------------------------------------------------

    // Start the clock low.
    clk = 0;

    // Hold reset active while setting up the program.
    reset = 1;

    // Keep the CPU disabled during program initialization.
    enable = 0;

    // Start both test counters at zero.
    passed = 0;
    failed = 0;


    // --------------------------------------------------------
    // INITIALIZE INSTRUCTION MEMORY
    // --------------------------------------------------------

    // Fill all 256 instruction-memory entries with NOP.
    //
    // 32'h00000013 encodes:
    //     addi x0, x0, 0
    //
    // A NOP is useful as a default because it performs no
    // architectural register update: writes to x0 are ignored.
    //
    // Initializing every entry also prevents unused addresses
    // from containing unknown X values during simulation.
    for (i = 0; i < 256; i = i + 1)
        dut.instruction_memory_inst.memory[i] = 32'h00000013;

    // Allow a little simulation time for initialization.
    #1;


    // ========================================================
    // TEST GROUP 1: BASIC ARITHMETIC AND LOGICAL INSTRUCTIONS
    // ========================================================

    // TEST 1: ADDI
    // x1 = x0 + 5 = 5.
    // Checks immediate decoding, ALU addition, and writeback.
    dut.instruction_memory_inst.memory[0] =
        enc_i(12'd5, 5'd0, 3'b000, 5'd1, 7'b0010011);


    // TEST 2: ADDI
    // x2 = x0 + 7 = 7.
    // Creates a second known value for later operations.
    dut.instruction_memory_inst.memory[1] =
        enc_i(12'd7, 5'd0, 3'b000, 5'd2, 7'b0010011);


    // TEST 3: ADD
    // x3 = x1 + x2 = 5 + 7 = 12.
    // Checks R-type instruction decoding and two-register reads.
    dut.instruction_memory_inst.memory[2] =
        enc_r(7'b0000000, 5'd2, 5'd1, 3'b000, 5'd3, 7'b0110011);


    // TEST 4: SUB
    // x4 = x3 - x1 = 12 - 5 = 7.
    // Checks that SUB is distinguished from ADD using funct7.
    dut.instruction_memory_inst.memory[3] =
        enc_r(7'b0100000, 5'd1, 5'd3, 3'b000, 5'd4, 7'b0110011);


    // TEST 5: AND
    // x5 = 5 AND 7 = 5.
    // Checks bitwise AND, which produces 1 only where both
    // input bits are 1.
    dut.instruction_memory_inst.memory[4] =
        enc_r(7'b0000000, 5'd2, 5'd1, 3'b111, 5'd5, 7'b0110011);


    // TEST 6: OR
    // x6 = 5 OR 7 = 7.
    // Checks bitwise OR, which produces 1 where either input
    // bit is 1.
    dut.instruction_memory_inst.memory[5] =
        enc_r(7'b0000000, 5'd2, 5'd1, 3'b110, 5'd6, 7'b0110011);


    // TEST 7: XOR
    // x7 = 5 XOR 7 = 2.
    // Checks bitwise XOR, which produces 1 where the input
    // bits differ.
    dut.instruction_memory_inst.memory[6] =
        enc_r(7'b0000000, 5'd2, 5'd1, 3'b100, 5'd7, 7'b0110011);


    // TEST 8: SLL
    // x8 = x1 shifted left by the low 5 bits of x2.
    // Here, 5 << 7 = 640.
    // Checks register-based shift amount handling.
    dut.instruction_memory_inst.memory[7] =
        enc_r(7'b0000000, 5'd2, 5'd1, 3'b001, 5'd8, 7'b0110011);


    // TEST 9: SRL
    // x9 = x8 logically shifted right by 7.
    // 640 >> 7 = 5.
    // Logical right shift inserts zeros from the left.
    dut.instruction_memory_inst.memory[8] =
        enc_r(7'b0000000, 5'd2, 5'd8, 3'b101, 5'd9, 7'b0110011);


    // TEST 10: ADDI WITH NEGATIVE IMMEDIATE
    // x13 = -1.
    // A 12-bit immediate of 0xFFF must be sign-extended to
    // 32'hFFFFFFFF, not zero-extended to 32'h00000FFF.
    dut.instruction_memory_inst.memory[9] =
        enc_i(12'hFFF, 5'd0, 3'b000, 5'd13, 7'b0010011);


    // TEST 11: SRAI
    // x14 = arithmetic-right-shift(-1, 1) = -1.
    // Arithmetic right shift preserves the sign bit.
    // This distinguishes SRAI from a logical right shift.
    dut.instruction_memory_inst.memory[10] =
        enc_i(12'h401, 5'd13, 3'b101, 5'd14, 7'b0010011);


    // TEST 12: SRLI
    // x15 = logical-right-shift(0xFFFFFFFF, 1)
    //     = 0x7FFFFFFF.
    // Logical right shift inserts a zero into bit 31.
    dut.instruction_memory_inst.memory[11] =
        enc_i(12'h001, 5'd13, 3'b101, 5'd15, 7'b0010011);


    // TEST 13: SLLI
    // x16 = 5 << 2 = 20.
    // Checks immediate-based shifting rather than using rs2.
    dut.instruction_memory_inst.memory[12] =
        enc_i(12'h002, 5'd1, 3'b001, 5'd16, 7'b0010011);


    // TEST 14: ANDI
    // x17 = -1 AND 15 = 15.
    // Checks immediate bitwise AND and immediate sign extension.
    dut.instruction_memory_inst.memory[13] =
        enc_i(12'h00F, 5'd13, 3'b111, 5'd17, 7'b0010011);


    // TEST 15: ORI
    // x18 = 0 OR 18 = 18.
    // Checks immediate bitwise OR.
    dut.instruction_memory_inst.memory[14] =
        enc_i(12'h012, 5'd0, 3'b110, 5'd18, 7'b0010011);


    // TEST 16: XORI
    // x19 = 18 XOR 31 = 13.
    // This value will later be overwritten by the JALR target
    // instruction, which writes 77 to x19.
    // The final register check therefore verifies the later
    // write, not this intermediate XORI result.
    dut.instruction_memory_inst.memory[15] =
        enc_i(12'h01F, 5'd18, 3'b100, 5'd19, 7'b0010011);


    // TEST 17: SLT
    // x20 = 1 because signed 5 < signed 7.
    // SLT writes 1 when its signed comparison is true.
    // This register will later be overwritten by a JAL test.
    dut.instruction_memory_inst.memory[16] =
        enc_r(7'b0000000, 5'd2, 5'd1, 3'b010, 5'd20, 7'b0110011);


    // TEST 18: SLTU
    // x21 = 0 because unsigned 7 < unsigned 5 is false.
    // Checks unsigned rather than signed comparison behavior.
    dut.instruction_memory_inst.memory[17] =
        enc_r(7'b0000000, 5'd1, 5'd2, 3'b011, 5'd21, 7'b0110011);


    // TEST 19: SLTI
    // x22 = 1 because signed 5 < signed 6.
    // This result is checked at the end. The JAL test below
    // uses x10 as its link destination so x22 is not overwritten.
    dut.instruction_memory_inst.memory[18] =
        enc_i(12'd6, 5'd1, 3'b010, 5'd22, 7'b0010011);


    // TEST 20: SLTIU
    // x23 = 1 because unsigned 5 < unsigned 0xFFFFFFFF.
    // The immediate -1 is sign-extended to 0xFFFFFFFF, which
    // is a large unsigned number when used by SLTIU.
    dut.instruction_memory_inst.memory[19] =
        enc_i(12'hFFF, 5'd1, 3'b011, 5'd23, 7'b0010011);


    // ========================================================
    // TEST GROUP 2: DATA MEMORY
    // ========================================================

    // TEST 21: SW
    // Store x3, which contains 12, into memory address 0.
    // This checks:
    //   1. Store instruction decoding.
    //   2. Address calculation: x0 + 0 = 0.
    //   3. Data-memory write enable.
    //   4. Correct store data selection from rs2.
    dut.instruction_memory_inst.memory[20] =
        enc_s(12'd0, 5'd3, 5'd0, 3'b010, 7'b0100011);


    // TEST 22: LW
    // Load the word from address 0 into x24.
    // Because SW stored 12 there, x24 should become 12.
    // This checks the data-memory read path and writeback mux.
    dut.instruction_memory_inst.memory[21] =
        enc_i(12'd0, 5'd0, 3'b010, 5'd24, 7'b0000011);


    // ========================================================
    // TEST GROUP 3: CONDITIONAL BRANCHES
    // ========================================================

    // A branch immediate of +8 means:
    // target PC = current PC + 8.
    //
    // Since each instruction occupies 4 bytes, this skips the
    // instruction immediately after the branch.
    //
    // Each branch test places a "wrong-path" instruction that
    // writes 99 immediately after the branch. If the branch is
    // taken correctly, that instruction is skipped. The target
    // instruction writes a small expected value instead.


    // TEST 23: BEQ TAKEN
    // x3 = 12 and x24 = 12, so the values are equal.
    // The CPU should jump from instruction 22 to instruction 24.
    dut.instruction_memory_inst.memory[22] =
        enc_b(13'd8, 5'd24, 5'd3, 3'b000, 7'b1100011);


    // If BEQ is taken, this instruction must be skipped.
    // If x25 becomes 99, the branch was not taken correctly.
    dut.instruction_memory_inst.memory[23] =
        enc_i(12'd99, 5'd0, 3'b000, 5'd25, 7'b0010011);


    // Branch target: x25 = 1.
    // Final expected value x25=1 confirms the skip occurred.
    dut.instruction_memory_inst.memory[24] =
        enc_i(12'd1, 5'd0, 3'b000, 5'd25, 7'b0010011);


    // TEST 24: BNE TAKEN
    // x1 = 5 and x2 = 7, so they are not equal.
    // The CPU should jump from instruction 25 to instruction 27.
    dut.instruction_memory_inst.memory[25] =
        enc_b(13'd8, 5'd2, 5'd1, 3'b001, 7'b1100011);


    // Wrong-path instruction: should not set x26 to 99.
    dut.instruction_memory_inst.memory[26] =
        enc_i(12'd99, 5'd0, 3'b000, 5'd26, 7'b0010011);


    // Branch target: x26 = 2.
    dut.instruction_memory_inst.memory[27] =
        enc_i(12'd2, 5'd0, 3'b000, 5'd26, 7'b0010011);


    // TEST 25: BLT TAKEN
    // Signed comparison: 5 < 7 is true.
    // The CPU should jump to instruction 30.
    dut.instruction_memory_inst.memory[28] =
        enc_b(13'd8, 5'd2, 5'd1, 3'b100, 7'b1100011);


    // Wrong-path instruction: should not set x27 to 99.
    dut.instruction_memory_inst.memory[29] =
        enc_i(12'd99, 5'd0, 3'b000, 5'd27, 7'b0010011);


    // Branch target: x27 = 3.
    dut.instruction_memory_inst.memory[30] =
        enc_i(12'd3, 5'd0, 3'b000, 5'd27, 7'b0010011);


    // TEST 26: BGE TAKEN
    // Signed comparison: 7 >= 5 is true.
    // The CPU should jump to instruction 33.
    dut.instruction_memory_inst.memory[31] =
        enc_b(13'd8, 5'd1, 5'd2, 3'b101, 7'b1100011);


    // Wrong-path instruction: should not set x28 to 99.
    dut.instruction_memory_inst.memory[32] =
        enc_i(12'd99, 5'd0, 3'b000, 5'd28, 7'b0010011);


    // Branch target: x28 = 4.
    dut.instruction_memory_inst.memory[33] =
        enc_i(12'd4, 5'd0, 3'b000, 5'd28, 7'b0010011);


    // TEST 27: BLTU TAKEN
    // Unsigned comparison: 5 < 7 is true.
    // The CPU should jump to instruction 36.
    dut.instruction_memory_inst.memory[34] =
        enc_b(13'd8, 5'd2, 5'd1, 3'b110, 7'b1100011);


    // Wrong-path instruction: should not set x29 to 99.
    dut.instruction_memory_inst.memory[35] =
        enc_i(12'd99, 5'd0, 3'b000, 5'd29, 7'b0010011);


    // Branch target: x29 = 5.
    dut.instruction_memory_inst.memory[36] =
        enc_i(12'd5, 5'd0, 3'b000, 5'd29, 7'b0010011);


    // TEST 28: BGEU TAKEN
    // Unsigned comparison: 7 >= 5 is true.
    // The CPU should jump to instruction 39.
    dut.instruction_memory_inst.memory[37] =
        enc_b(13'd8, 5'd1, 5'd2, 3'b111, 7'b1100011);


    // Wrong-path instruction: should not set x30 to 99.
    // This is safe because the later JALR will overwrite x30
    // with its return address.
    dut.instruction_memory_inst.memory[38] =
        enc_i(12'd99, 5'd0, 3'b000, 5'd30, 7'b0010011);


    // Branch target: x30 = 6.
    // This is also overwritten later by JALR.
    dut.instruction_memory_inst.memory[39] =
        enc_i(12'd6, 5'd0, 3'b000, 5'd30, 7'b0010011);


    // TEST 29: BEQ NOT TAKEN
    // x1=5 and x2=7, so equality is false.
    // The CPU must continue to the next instruction rather
    // than jumping over it.
    dut.instruction_memory_inst.memory[40] =
        enc_b(13'd8, 5'd2, 5'd1, 3'b000, 7'b1100011);


    // This instruction should execute because BEQ was false.
    // It sets x31 to 9 temporarily. A later ADDI replaces x31
    // with the JALR target address 208.
    dut.instruction_memory_inst.memory[41] =
        enc_i(12'd9, 5'd0, 3'b000, 5'd31, 7'b0010011);


    // ========================================================
    // TEST GROUP 4: JAL AND JALR
    // ========================================================

    // TEST 30: JAL
    // JAL jumps to PC+8 and writes PC+4 to its destination.
    //
    // At instruction index 42:
    //   PC = 42 * 4 = 168
    //   jump target = 168 + 8 = 176 (instruction index 44)
    //   link value = 168 + 4 = 172
    //
    // x10 is used as rd so the earlier SLTI result in x22
    // remains available for checking.
    dut.instruction_memory_inst.memory[42] =
        enc_j(21'd8, 5'd10, 7'b1101111);


    // Wrong-path instruction: this should be skipped by JAL.
    // If executed, it would set x20 to 99.
    dut.instruction_memory_inst.memory[43] =
        enc_i(12'd99, 5'd0, 3'b000, 5'd20, 7'b0010011);


    // JAL target: x20 = 8.
    // This proves that the jump landed at instruction 44.
    dut.instruction_memory_inst.memory[44] =
        enc_i(12'd8, 5'd0, 3'b000, 5'd20, 7'b0010011);


    // TEST 31: Prepare the JALR target address.
    // x31 = 208 decimal = 0xD0.
    // Instruction memory index 52 corresponds to byte address
    // 52 * 4 = 208.
    dut.instruction_memory_inst.memory[45] =
        enc_i(12'd208, 5'd0, 3'b000, 5'd31, 7'b0010011);


    // TEST 32: JALR
    // JALR jumps to (rs1 + immediate) with bit 0 cleared.
    //
    // Here:
    //   target = x31 + 0 = 208
    //   target instruction index = 208 / 4 = 52
    //   link value = current PC + 4
    //
    // This checks register-based jump addressing, the JALR
    // control path, and saving the return address in x30.
    dut.instruction_memory_inst.memory[46] =
        enc_i(12'd0, 5'd31, 3'b000, 5'd30, 7'b1100111);


    // Instructions 47 through 51 remain NOPs.
    // Correct JALR behavior jumps directly over them to 52.


    // JALR target instruction:
    // x19 = 77.
    // This also replaces the earlier XORI result in x19.
    // Checking x19=77 verifies that execution reached index 52.
    dut.instruction_memory_inst.memory[52] =
        enc_i(12'd77, 5'd0, 3'b000, 5'd19, 7'b0010011);


    // ========================================================
    // TEST GROUP 5: U-TYPE INSTRUCTIONS
    // ========================================================

    // TEST 33: LUI
    // LUI places the 20-bit immediate in bits [31:12]
    // and fills the lower 12 bits with zeros.
    //
    // x12 = 0x12345 << 12 = 0x12345000.
    dut.instruction_memory_inst.memory[53] =
        enc_u(20'h12345, 5'd12, 7'b0110111);


    // TEST 34: AUIPC
    // AUIPC adds the U-type immediate to the current PC.
    //
    // Instruction index 54 has PC = 54 * 4 = 216.
    // Immediate = 0x00001 << 12 = 4096.
    // Expected x11 = 4096 + 216 = 4312 = 0x10D8.
    //
    // This checks that AUIPC uses the PC as an ALU input
    // instead of using the value from a general-purpose register.
    dut.instruction_memory_inst.memory[54] =
        enc_u(20'h00001, 5'd11, 7'b0010111);


    // ========================================================
    // TEST GROUP 6: HALT LOOP
    // ========================================================

    // This is not a dedicated HALT instruction.
    // JAL x0,0 jumps back to its own address forever.
    //
    // Because rd=x0, the link address is discarded.
    // The CPU remains active, but it repeatedly executes this
    // self-jump instead of running beyond the test program.
    dut.instruction_memory_inst.memory[55] =
        enc_j(21'd0, 5'd0, 7'b1101111);


    // ========================================================
    // RESET AND EXECUTION
    // ========================================================

    // Hold reset through two rising clock edges so that the
    // CPU's sequential state has time to reset.
    repeat (2) @(posedge clk);

    // Move slightly past the clock edge before changing reset
    // and enable, avoiding a same-time-step race with the CPU.
    #1;
    reset = 0;
    enable = 1;


    // Let the CPU execute the program.
    // The program contains branches and jumps, so not every
    // instruction-memory entry is executed sequentially.
    // The final JAL x0,0 loops at instruction 55.
    repeat (65) @(posedge clk);

    // Wait until after the final rising edge before inspecting
    // the register file and data memory.
    #1;


    // ========================================================
    // CHECK RESULTS
    // ========================================================

    $display("");
    $display("========== RV32I CPU TEST RESULTS ==========");


    // --------------------------------------------------------
    // Arithmetic and logical operation results
    // --------------------------------------------------------

    // ADDI x1,x0,5
    check_reg(1,  32'd5);

    // ADDI x2,x0,7
    check_reg(2,  32'd7);

    // ADD x3,x1,x2: 5 + 7 = 12
    check_reg(3,  32'd12);

    // SUB x4,x3,x1: 12 - 5 = 7
    check_reg(4,  32'd7);

    // AND x5,x1,x2: 5 AND 7 = 5
    check_reg(5,  32'd5);

    // OR x6,x1,x2: 5 OR 7 = 7
    check_reg(6,  32'd7);

    // XOR x7,x1,x2: 5 XOR 7 = 2
    check_reg(7,  32'd2);

    // SLL x8,x1,x2: 5 << 7 = 640
    check_reg(8,  32'd640);

    // SRL x9,x8,x2: 640 >> 7 = 5
    check_reg(9,  32'd5);


    // --------------------------------------------------------
    // Negative values and immediate arithmetic
    // --------------------------------------------------------

    // ADDI with immediate -1 must sign-extend to all ones.
    check_reg(13, 32'hFFFFFFFF);

    // SRAI preserves the sign bit of -1.
    check_reg(14, 32'hFFFFFFFF);

    // SRLI inserts zero into the most significant bit.
    check_reg(15, 32'h7FFFFFFF);

    // SLLI: 5 << 2 = 20.
    check_reg(16, 32'd20);

    // ANDI: -1 AND 15 = 15.
    check_reg(17, 32'd15);

    // ORI: 0 OR 18 = 18.
    check_reg(18, 32'd18);


    // --------------------------------------------------------
    // Comparison instruction results
    // --------------------------------------------------------

    // SLT: signed 5 < 7 is true, so x20 initially becomes 1.
    // Later, the JAL target intentionally overwrites x20 with 8.
    // Therefore x20's final check below tests JAL target execution,
    // not the original SLT result.
    //
    // SLTU: unsigned 7 < 5 is false, so x21 should be 0.
    check_reg(21, 32'd0);

    // SLTI: signed 5 < 6 is true, so x22 should remain 1.
    // The JAL test uses x10, leaving x22 untouched.
    check_reg(22, 32'd1);

    // SLTIU: unsigned 5 < unsigned 0xFFFFFFFF is true.
    check_reg(23, 32'd1);


    // --------------------------------------------------------
    // Memory operation results
    // --------------------------------------------------------

    // LW must load the value 12 that SW stored at address 0.
    check_reg(24, 32'd12);


    // --------------------------------------------------------
    // Branch results
    // --------------------------------------------------------

    // BEQ taken: skipped the instruction that would write 99.
    // The branch target wrote 1.
    check_reg(25, 32'd1);

    // BNE taken: branch target wrote 2 instead of 99.
    check_reg(26, 32'd2);

    // BLT taken: branch target wrote 3 instead of 99.
    check_reg(27, 32'd3);

    // BGE taken: branch target wrote 4 instead of 99.
    check_reg(28, 32'd4);

    // BLTU taken: branch target wrote 5 instead of 99.
    check_reg(29, 32'd5);


    // --------------------------------------------------------
    // Jump results
    // --------------------------------------------------------

    // JALR link address:
    // index 46 has PC = 46*4 = 184.
    // PC + 4 = 188, which is written into x30.
    check_reg(30, 32'd188);

    // x31 is loaded with 208 to provide the JALR target address.
    check_reg(31, 32'd208);

    // LUI: 0x12345 placed in the upper 20 bits.
    check_reg(12, 32'h12345000);

    // AUIPC: PC 216 + immediate 4096 = 4312.
    check_reg(11, 32'd4312);

    // JAL at instruction 42 saves PC+4 = 172 into x10.
    check_reg(10, 32'd172);

    // The JAL target instruction writes 8 to x20.
    check_reg(20, 32'd8);

    // The JALR target instruction writes 77 to x19.
    check_reg(19, 32'd77);


    // --------------------------------------------------------
    // Special register test: x0 must always equal zero
    // --------------------------------------------------------

    // RISC-V register x0 is hardwired to zero.
    // Writes targeting x0 must not change its value.
    // The final halt instruction also targets x0.
    check_reg(0, 32'd0);


    // --------------------------------------------------------
    // Direct data-memory check
    // --------------------------------------------------------

    // Check the memory itself, not just the value loaded back
    // into x24. This independently verifies that SW changed
    // memory location zero to the expected value 12.
    if (dut.data_memory_inst.memory[0] === 32'd12) begin
        $display("PASS: memory[0] = 12");
        passed = passed + 1;
    end
    else begin
        $display("FAIL: memory[0] expected 12, got %h",
                 dut.data_memory_inst.memory[0]);
        failed = failed + 1;
    end


    // ========================================================
    // FINAL TEST SUMMARY
    // ========================================================

    $display("-------------------------------------------");
    $display("PASSED: %0d", passed);
    $display("FAILED: %0d", failed);
    $display("-------------------------------------------");

    // If no check failed, every assertion in this testbench
    // passed. This does not mean every RV32I instruction or
    // every possible input combination has been tested.
    if (failed == 0)
        $display("ALL TESTS PASSED");
    else
        $display("SOME TESTS FAILED");

    $finish;
end

endmodule
