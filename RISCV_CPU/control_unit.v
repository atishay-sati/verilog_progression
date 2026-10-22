
`timescale 1ns / 1ps

module control_unit(instruction, alu_operation, alu_a_src, alu_src, reg_write, mem_read, mem_write, result_src, branch, jump, pc_src);

input [31:0] instruction;

output reg [3:0] alu_operation;
output reg [1:0] alu_a_src; //Selects ALU input A: 00 = register, 01 = zero, 10 = PC
output reg alu_src; //Selects register data or immediate for ALU input B (0 for register, 1 for immediate)
output reg reg_write; //0 or 1 based on whether or not we want to write into a register
output reg mem_read; //Enables a data-memory read (0 or 1)
output reg mem_write; //Enables a data-memory write (0 or 1). Example: sw x3, 12(x1) stores the value of x3 at the memory address x1 + 12
output reg [1:0] result_src; //Selects what gets written back to the register file: 00 = ALU result, 01 = data read from memory, 10 = PC + 4 for jal and jalr
output reg branch; //Indicates a conditional branch (B-type)
output reg jump; //Indicates jal or jalr (jumping to another address)
output reg [1:0] pc_src; //Selects next PC: 00 = PC + 4, 01 = PC + immediate, 10 = JALR target

wire [2:0] funct3;
wire [6:0] funct7;

assign funct3 = instruction[14:12];
assign funct7 = instruction[31:25];

always @(*) begin

    //Default control signals
    alu_operation = 4'b0000; //ADD
    alu_a_src     = 2'b00; //Register for ALU input A
    alu_src       = 1'b0; //Register for input B
    reg_write     = 1'b0; //Write disabled
    mem_read      = 1'b0; //Read disabled
    mem_write     = 1'b0; //Write disabled
    result_src    = 2'b00; //ALU result
    branch        = 1'b0; //Branch disabled
    jump          = 1'b0; //Jump disabled
    pc_src        = 2'b00; //Continue to PC + 4

    case (instruction[6:0])

        //R-Type: add, sub, and, or, xor, shifts, comparisons
        //Format:
        //31      25 24    20 19   15 14        12 11    7 6      0
        //+---------+--------+-------+------------+------+--------+
        //| funct7  |  rs2   |  rs1  |   funct3   |  rd  | opcode |
        //+---------+--------+-------+------------+------+--------+
        7'b0110011: begin
            alu_src = 1'b0; //Use the second register value as ALU input B
            reg_write = 1'b1; //Write the ALU result into rd

            case (funct3)

                3'b000: begin
                    if (funct7 == 7'b0100000)
                        alu_operation = 4'b0001; //SUB
                    else if (funct7 == 7'b0000000)
                        alu_operation = 4'b0000; //ADD
                    else
                        reg_write = 1'b0; //Invalid encoding, do not write
                end

                3'b111: begin
                    alu_operation = 4'b0010; //AND
                    if (funct7 != 7'b0000000)
                        reg_write = 1'b0;
                end

                3'b110: begin
                    alu_operation = 4'b0011; //OR
                    if (funct7 != 7'b0000000)
                        reg_write = 1'b0;
                end

                3'b100: begin
                    alu_operation = 4'b0100; //XOR
                    if (funct7 != 7'b0000000)
                        reg_write = 1'b0;
                end

                3'b001: begin
                    alu_operation = 4'b0101; //SLL
                    if (funct7 != 7'b0000000)
                        reg_write = 1'b0;
                end

                3'b101: begin
                    if (funct7 == 7'b0100000)
                        alu_operation = 4'b0111; //SRA
                    else if (funct7 == 7'b0000000)
                        alu_operation = 4'b0110; //SRL
                    else
                        reg_write = 1'b0;
                end

                3'b010: begin
                    alu_operation = 4'b1000; //SLT
                    if (funct7 != 7'b0000000)
                        reg_write = 1'b0;
                end

                3'b011: begin
                    alu_operation = 4'b1001; //SLTU
                    if (funct7 != 7'b0000000)
                        reg_write = 1'b0;
                end

                default: begin
                    reg_write = 1'b0; //Unsupported operation
                end

            endcase
        end

        //I-Type arithmetic: addi, andi, ori, xori, shifts, comparisons
        //Uses one register value and an immediate value
        7'b0010011: begin
            alu_src = 1'b1; //Use immediate for ALU input B
            reg_write = 1'b1; //Write the ALU result into rd

            case (funct3)

                3'b000: alu_operation = 4'b0000; //ADDI
                3'b111: alu_operation = 4'b0010; //ANDI
                3'b110: alu_operation = 4'b0011; //ORI
                3'b100: alu_operation = 4'b0100; //XORI
                3'b010: alu_operation = 4'b1000; //SLTI
                3'b011: alu_operation = 4'b1001; //SLTIU

                3'b001: begin
                    alu_operation = 4'b0101; //SLLI
                    if (funct7 != 7'b0000000)
                        reg_write = 1'b0;
                end

                3'b101: begin
                    if (funct7 == 7'b0100000)
                        alu_operation = 4'b0111; //SRAI
                    else if (funct7 == 7'b0000000)
                        alu_operation = 4'b0110; //SRLI
                    else
                        reg_write = 1'b0;
                end

                default: begin
                    reg_write = 1'b0;
                end

            endcase
        end

        //LOAD: lw
        //Example: lw x3, 12(x1) reads memory at address x1 + 12 and stores the loaded value in x3
        7'b0000011: begin
            if (funct3 == 3'b010) begin //LW: load a 32-bit word
                alu_operation = 4'b0000; //ADD base register value and immediate to calculate memory address
                alu_src = 1'b1; //Use immediate for ALU input B
                mem_read = 1'b1; //Enable data-memory read
                reg_write = 1'b1; //Write loaded data into rd
                result_src = 2'b01; //Select data read from memory
            end
        end

        //S-TYPE: sw
        //Example: sw x3, 12(x1) stores the value of x3 at memory address x1 + 12
        //format of instruction:
        //31       25 24    20 19    15 14   12 11     7 6      0
        //+----------+--------+--------+-------+---------+--------+
        //|imm[11:5] |  rs2   |  rs1   | funct3| imm[4:0]| opcode |
        //+----------+--------+--------+-------+---------+--------+
        7'b0100011: begin
            if (funct3 == 3'b010) begin //SW: store a 32-bit word
                alu_operation = 4'b0000; //ADD base register value and immediate to calculate memory address
                alu_src = 1'b1; //Use immediate for ALU input B
                mem_write = 1'b1; //Enable data-memory write
            end
        end

        //B-Type: beq, bne, blt, bge, bltu, bgeu
        //Compares two register values and branches if the condition is true
        //format:
        //31     30:25    24:20  19:15 14:12 11:8 7 6:0
        //+------+--------+------+------+-----+----+-------+
        //|imm12 | imm10:5| rs2  | rs1  |funct3|imm11:8|imm11|opcode|
        //+------+--------+------+------+-----+----+-------+
        7'b1100011: begin
            alu_src = 1'b0; //Use both register values
            branch = 1'b1; //Tell the CPU this is a conditional branch

            case (funct3)
                3'b000: alu_operation = 4'b1010; //BEQ: branch if equal
                3'b001: alu_operation = 4'b1011; //BNE: branch if not equal
                3'b100: alu_operation = 4'b1000; //BLT: branch if less than, signed
                3'b101: alu_operation = 4'b1100; //BGE: branch if greater than or equal, signed
                3'b110: alu_operation = 4'b1001; //BLTU: branch if less than, unsigned
                3'b111: alu_operation = 4'b1101; //BGEU: branch if greater than or equal, unsigned

                default: begin
                    branch = 1'b0;
                end
            endcase

            pc_src = 2'b00; //Default to PC + 4; the datapath selects the branch target if the branch is taken
        end

        //J-Type: jal
        //Jumps to PC + immediate and saves PC + 4 in rd
        //Instruction format:
        // [31]    = imm[20]     : sign bit of the jump offset
        // [30:21] = imm[10:1]   : part of the jump offset
        // [20]    = imm[11]     : part of the jump offset
        // [19:12] = imm[19:12]  : part of the jump offset
        // [11:7]  = rd          : destination register
        // [6:0]   = opcode      : 1101111 for JAL
        7'b1101111: begin
            jump = 1'b1; //Enable jump
            pc_src = 2'b01; //Select PC + immediate as the jump target
            reg_write = 1'b1; //Write return address into rd
            result_src = 2'b10; //Select PC + 4
        end

        //I-Type: jalr
        //Jumps to (register value + immediate) with bit 0 cleared, and saves PC + 4 in rd
        //format:
        //31         20 19    15 14   12 11     7 6      0
        //+------------+--------+-------+--------+--------+
        //| imm[11:0]  |  rs1   | funct3|   rd   | opcode |
        //+------------+--------+-------+--------+--------+
        7'b1100111: begin
            if (funct3 == 3'b000) begin
                alu_operation = 4'b0000; //ADD register value and immediate
                alu_src = 1'b1; //Use immediate for ALU input B
                jump = 1'b1; //Enable jump
                pc_src = 2'b10; //Select (register + immediate) with bit 0 cleared
                reg_write = 1'b1; //Write return address into rd
                result_src = 2'b10; //Select PC + 4
            end
        end

        //U-Type: LUI, AUIPC
        //Instruction format:
        // [31:12] = 20-bit immediate
        // [11:7]  = rd
        // [6:0]   = opcode

        //LUI: Loads the upper immediate into the destination register
        //Example: lui x5, 0x12345 gives x5 = 0x12345000
        7'b0110111: begin
            alu_a_src = 2'b01; //Use zero for ALU input A
            alu_src = 1'b1; //Use the U-type immediate for ALU input B
            alu_operation = 4'b0000; //ADD zero + immediate
            reg_write = 1'b1; //Write enabled
        end

        //AUIPC: Adds the upper immediate to the current PC
        //Example: auipc x5, 0x12345 gives x5 = PC + 0x12345000
        7'b0010111: begin
            alu_a_src = 2'b10; //Use PC for ALU input A
            alu_src = 1'b1; //Use the U-type immediate for ALU input B
            alu_operation = 4'b0000; //ADD PC + immediate
            reg_write = 1'b1; //Write enabled
        end

        //Unsupported instruction
        default: begin
            //Default control signals remain unchanged
        end

    endcase
end

endmodule
