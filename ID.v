`timescale 100fs/100fs
module Instruction_decode
    (
        input [31:0] instruction,
        // input [31:0] pc_in,
        input clk,
        input [31:0] write_result,
        input [4:0] write_addr,
        input register_write,
        output reg [31:0] rs,
        output reg [31:0] rt,
        output wire [4:0] rt_addr,
        output wire [4:0] rd_addr,
        output reg [31:0] extended_imm,
        output wire [4:0] shamt
        // output [31:0] pc_out
    );

    // assign pc_out = pc_in;

    reg [31:0] reg_init [31:0];
    reg flag = 1'b1;
    initial
    begin:block1
    integer i;
    for (i=0; i<32; i = i+1) begin
        reg_init[i] = 32'b0000000000000000000000000000000;
    end
    end
    
    wire [4:0] rs_addr;
    wire [15:0] imm;
    wire [5:0] op;

    assign op = instruction[31:26];
    assign rs_addr = instruction[25:21];
    assign rt_addr = instruction[20:16];
    assign rd_addr = instruction[15:11];
    assign imm = instruction[15:0];
    assign shamt = instruction[10:6];

    always @(posedge clk)
    begin
        begin
            if (register_write == 1'b1 && write_addr != 1'b0) begin
            reg_init[write_addr] <= write_result;
            end
        end

        begin
            rs <= reg_init[rs_addr];
            rt <= reg_init[rt_addr];

            if (op == 6'hc || op == 6'hd || op == 6'he) begin
                extended_imm <= {{16{1'b0}}, imm};
            end
            else begin
                extended_imm <= {{16{imm[15]}}, imm};
            end
        end
    end

endmodule