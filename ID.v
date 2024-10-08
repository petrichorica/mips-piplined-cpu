`timescale 100fs/100fs
module Instruction_decode
    (
        input [31:0] instruction,
        input [31:0] pc,
        input clk,
        input signed [31:0] write_result,
        input [4:0] write_addr,
        input register_write,

        // For jal instruction
        input jumpD,
        input linkD,

        output reg signed [31:0] rs,
        output reg signed [31:0] rt,
        output wire [4:0] rs_addr,
        output wire [4:0] rt_addr,
        output wire [4:0] rd_addr,
        output reg signed [31:0] extended_imm,
        output wire [4:0] shamt,
        output reg [31:0] pc_branch
    );

    reg [31:0] reg_value [31:0];
    reg flag = 1'b1;
    initial
    begin:block1
    integer i;
    for (i=0; i<32; i = i+1) begin
        reg_value[i] = 32'b0000000000000000000000000000000;
    end
    end
    
    wire [15:0] imm;
    wire [5:0] op;

    assign op = instruction[31:26];
    assign rs_addr = instruction[25:21];
    assign rt_addr = instruction[20:16];
    assign rd_addr = instruction[15:11];
    assign imm = instruction[15:0];
    assign shamt = instruction[10:6];

    // Write back
    always @(register_write, write_addr, write_result) begin
        if (register_write == 1'b1 && write_addr != 5'b0) begin
            reg_value[write_addr] <= write_result;
        end
    end

    // jal: Save the address of the next instruction in register $ra 
    always @(jumpD, linkD) begin
        if (jumpD && linkD) begin
            reg_value[31] <= pc;
        end
    end

    // Read
    always @(posedge clk)
    begin
        rs <= reg_value[rs_addr];
        rt <= reg_value[rt_addr];

        if (op == 6'hc || op == 6'hd || op == 6'he) begin
            extended_imm <= {{16{1'b0}}, imm};
        end
        else begin
            extended_imm <= {{16{imm[15]}}, imm};
        end
    end

    always @(extended_imm) begin
        pc_branch <= (extended_imm << 2) + pc;
    end

endmodule