`timescale 100fs/100fs
module id_test;
    reg clk = 1'b0;
    reg [31:0] instruction;
    reg [31:0] pc;
    reg register_write = 1;
    reg [31:0] write_result = 32'd1;
    reg [4:0] write_addr = 5'd10;
    wire [31:0] rs;
    wire [31:0] rt;
    wire [4:0] rt_addr;
    wire [4:0] rd_addr;
    wire [31:0] extended_imm;
    wire [31:0] pc_out;

    Instruction_decode id_block(instruction, pc, clk, write_result, write_addr, register_write, rs, rt, rt_addr, rd_addr, extended_imm, pc_out);
    always #10 clk = ~clk;
    always
    begin
        $monitor("%t,   %h,   %h", $realtime, rs, rt);
        #8
            instruction <= 32'b00000000001010100000000000001010;
            pc <= 32'd20;
        #10 $finish;
    end
endmodule