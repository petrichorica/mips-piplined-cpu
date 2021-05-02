`timescale 100fs/100fs
module Alu
    (   
        input [31:0] rs,  // reg1
        input [31:0] rt,  // reg2
        input [4:0] shamt,  // shift amount
        input [4:0] rt_addr,
        input [4:0] rd_addr,
        input [31:0] imm,
        input [31:0] pc,
        input [3:0] alu_control,
        input alu_source,
        input alu_source_shift,
        input reg_dst,
        output reg zero,
        output reg [31:0] alu_out,
        output reg [31:0] write_data,  // The 32-bit data to be write into the memory
        output reg [4:0] write_reg_addr,
        output reg [31:0] pc_branch
    );

    reg [31:0] oprA;  // Operand A
    reg [31:0] oprB;  // Operand B
    always @(*) begin
        pc_branch <= pc + (imm << 2'd2);
        write_reg_addr <= (reg_dst==1'b1) ? rd_addr : rt_addr;
        write_data <= rt;
        begin
            oprA = (alu_source_shift==1'b1) ? {27'b0, shamt} : rs;
            oprB = (alu_source==1'b1) ? imm : rt;
            // ALU
            case(alu_control)
            4'b0001: alu_out = oprA + oprB;
            4'b0010: alu_out = oprA - oprB;
            4'b0011: alu_out = oprA & oprB;
            4'b0100: alu_out = oprA | oprB;
            4'b0101: alu_out = oprA ^ oprB;
            4'b0110: alu_out = ~(oprA | oprB);
            4'b0111: alu_out = (oprA < oprB) ? 1'b1 : 1'b0;
            4'b1000: alu_out = oprB << oprA;
            4'b1001: alu_out = oprB >> oprA;
            4'b1010: alu_out = oprB >>> oprA;
            endcase
            zero = (alu_out==1'b0) ? 1'b1 : 1'b0;
        end
    end
endmodule