`timescale 1ns / 1ps

module immediate_generator(instruction, immediate);

input [31:0] instruction;
output reg [31:0] immediate;

always @(*) begin
    case (instruction[6:0])

        // I-type: addi, loads, jalr
        //format:
        //31         20 19    15 14   12 11     7 6      0
        //+------------+--------+-------+--------+--------+
        //| imm[11:0]  |  rs1   | funct3|   rd   | opcode |
        //+------------+--------+-------+--------+--------+
        
        //last 7 bits of the instruction (opcode)
        7'b0010011,  // OP-IMM opcode: arithmetic/logical immediate instructions (e.g., addi, andi, ori, xori). Uses a register value and an immediate, then stores the result in a destination register.
        7'b0000011,  // LOAD opcode: loads data from memory (e.g., lw) using a register value + immediate as the memory address, then stores the loaded data in a destination register.
        7'b1100111:  begin /// JALR opcode: jumps to an address calculated from a register value + immediate, and saves PC + 4 in the destination register.
            immediate = {{20{instruction[31]}}, //copies the sign bit (bit 31) 20 times. Will result in 20 1s in the beginning if negative or 20 0s in the beginning if positive 
                         instruction[31:20]}; //the first 12 bits our instruction
        end
        
        // S-type: stores (sw)
        7'b0100011: begin //opp code for sw
            //ex: sw x3, 12(x1) stores 32 bit value in x3 to the address of x1 + 12 
            //we use immediate generator to get the value of 12
            //format of instruction: 
            //31       25 24    20 19    15 14   12 11     7 6      0
            //+----------+--------+--------+-------+---------+--------+
            //|imm[11:5] |  rs2   |  rs1   |funct3| imm[4:0]| opcode |
            //+----------+--------+--------+-------+---------+--------+
            immediate = {{20{instruction[31]}},  //copies the sign bit (bit 31) 20 times. Will result in 20 1s in the beginning if negative or 20 0s in the beginning if positive
                         instruction[31:25], //our immediate values are split so this is the upper half
                         instruction[11:7]}; //this is the lower half of the immediate values
        end

        // B-type: conditional branches
        //format 
        //31     30 29    25 24    20  19  15 14   12 11    8 7      7 6       0
        //+--------+--------+--------+-------+-------+-------+--------+---------+
        //|imm[12] |imm[10:5|  rs2   |  rs1  |funct3 |imm[4:1]|imm[11] | opcode |
        //+--------+--------+--------+-------+-------+-------+--------+---------+
        7'b1100011: begin //opp code for beq (equal), bne (not equal), blt (less than (signed  with twos complement), bge (greater than or equal (signed with twos complement)
            immediate = {{19{instruction[31]}},
                         instruction[31],
                         instruction[7],
                         instruction[30:25],
                         instruction[11:8],
                         1'b0};
        end

        // U-type: lui, auipc
        // Used to work with large 32-bit values.
        //
        // Instruction format:
        // [31:12] = 20-bit immediate
        // [11:7]  = rd       : destination register
        // [6:0]   = opcode   : identifies LUI or AUIPC
        //
        // Unlike B-type, we do NOT sign-extend the immediate here.
        // We put the 20-bit immediate in the upper 20 bits
        // and append 12 zeros at the end.
        //
        // LUI:   uses this value directly.
        // AUIPC: adds this value to the current PC.
        7'b0110111,
        7'b0010111: begin
            immediate = {instruction[31:12], 12'b0};
        end

        // J-type: jal
        // Used to jump to another instruction address and save the current address in a register
        // Essentially this immediate is how many bytes we are jumping
        // the return address (PC + 4) in rd.
        //
        // Instruction format:
        // [31]    = imm[20]     : sign bit of the jump offset
        // [30:21] = imm[10:1]   : part of the jump offset
        // [20]    = imm[11]     : part of the jump offset
        // [19:12] = imm[19:12]  : part of the jump offset
        // [11:7]  = rd          : destination register
        // [6:0]   = opcode      : 1101111 for JAL
        //
        // The immediate bits are scattered, so we rearrange them.
        // The final 0 is added because jump offsets are multiples of 2.
        // Copy the sign bit to the front to extend the offset to 32 bits.
        7'b1101111: begin 
            immediate = {{11{instruction[31]}},
                         instruction[31],
                         instruction[19:12],
                         instruction[20],
                         instruction[30:21],
                         1'b0};
        end
        
        //if the oppcode isn't found then we are generating an 32 bit immediate of just zeros
        default: begin
            immediate = 32'b0;
        end

    endcase
end

endmodule
