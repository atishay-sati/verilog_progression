`timescale 1ns / 1ps

module cpu(clk, reset, enable, pc_out, instruction_out);

input clk;
input reset;
input enable;

output wire [31:0] pc_out;
output wire [31:0] instruction_out;

// ==========================================
// 1. Program Counter and Instruction Memory
// ==========================================

wire [31:0] pc;
wire [31:0] pc_plus4;
wire [31:0] instruction;

assign pc_plus4 = pc + 32'd4;
assign pc_out = pc;
assign instruction_out = instruction;

// Instruction memory supplies the instruction at the current PC address
instruction_memory instruction_memory_inst (
    .address(pc),
    .instruction(instruction)
);

// ==========================================
// 2. Control Unit
// ==========================================

wire [3:0] alu_operation;
wire [1:0] alu_a_src;
wire alu_src;
wire reg_write_control;
wire mem_read;
wire mem_write_control;
wire [1:0] result_src;
wire branch;
wire jump;
wire [1:0] pc_src;

control_unit control_unit_inst (
    .instruction(instruction),
    .alu_operation(alu_operation),
    .alu_a_src(alu_a_src),
    .alu_src(alu_src),
    .reg_write(reg_write_control),
    .mem_read(mem_read),
    .mem_write(mem_write_control),
    .result_src(result_src),
    .branch(branch),
    .jump(jump),
    .pc_src(pc_src)
);

// ==========================================
// 3. Immediate Generator
// ==========================================

wire [31:0] immediate;

immediate_generator immediate_generator_inst (
    .instruction(instruction),
    .immediate(immediate)
);

// ==========================================
// 4. Register File
// ==========================================

wire [31:0] reg1;
wire [31:0] reg2;
reg [31:0] writeback_data;

wire [4:0] read_reg1;
wire [4:0] read_reg2;
wire [4:0] write_reg;

assign read_reg1 = instruction[19:15];
assign read_reg2 = instruction[24:20];
assign write_reg = instruction[11:7];

register_file register_file_inst (
    .clk(clk),
    .read_reg1(read_reg1),
    .read_reg2(read_reg2),
    .write_reg(write_reg),
    .write_data(writeback_data),
    .enable(enable && reg_write_control),
    .reg1(reg1),
    .reg2(reg2)
);

// ==========================================
// 5. ALU Input Selection
// ==========================================

reg [31:0] alu_a;
reg [31:0] alu_b;

always @(*) begin

    // Select ALU input A
    case (alu_a_src)
        2'b00: alu_a = reg1;
        2'b01: alu_a = 32'd0;
        2'b10: alu_a = pc;
        default: alu_a = reg1;
    endcase

    // Select ALU input B
    if (alu_src == 1'b0) begin
        alu_b = reg2;
    end
    else begin
        alu_b = immediate;
    end

    // Shift-immediate instructions use instruction[24:20]
    if (instruction[6:0] == 7'b0010011 &&
        (instruction[14:12] == 3'b001 ||
         instruction[14:12] == 3'b101)) begin
        alu_b = {27'd0, instruction[24:20]};
    end
end

// ==========================================
// 6. ALU
// ==========================================

wire [31:0] alu_result;

ALU alu_inst (
    .a(alu_a),
    .b(alu_b),
    .operation(alu_operation),
    .result(alu_result)
);

// ==========================================
// 7. Data Memory
// ==========================================

wire [31:0] memory_read_data;

data_memory data_memory_inst (
    .clk(clk),
    .address(alu_result),
    .write_data(reg2),
    .mem_read(mem_read),
    .mem_write(enable && mem_write_control),
    .read_data(memory_read_data)
);

// ==========================================
// 8. Writeback Selection
// ==========================================

always @(*) begin
    case (result_src)
        2'b00: writeback_data = alu_result;
        2'b01: writeback_data = memory_read_data;
        2'b10: writeback_data = pc_plus4;
        default: writeback_data = alu_result;
    endcase
end

// ==========================================
// 9. Branch and Jump Logic
// ==========================================

wire branch_taken;
wire pc_redirect;
reg [31:0] pc_target;

assign branch_taken = branch && (alu_result != 32'd0);
assign pc_redirect = branch_taken || jump;

always @(*) begin

    // Normally execute the next sequential instruction
    pc_target = pc_plus4;

    // Conditional branch taken
    if (branch_taken) begin
        pc_target = pc + immediate;
    end

    // Unconditional jump
    else if (jump) begin
        case (pc_src)

            // JAL: PC + immediate
            2'b01:
                pc_target = pc + immediate;

            // JALR: register + immediate, with bit 0 cleared
            2'b10:
                pc_target = {alu_result[31:1], 1'b0};

            default:
                pc_target = pc_plus4;

        endcase
    end
end

program_counter program_counter_inst (
    .clk(clk),
    .reset(reset),
    .enable(enable),
    .jump(pc_redirect),
    .jump_addr(pc_target),
    .pc(pc)
);

// ==========================================
// End of CPU
// ==========================================

endmodule
