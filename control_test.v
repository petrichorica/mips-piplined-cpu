`timescale 100fs/100fs
module control_test;
    reg [31:0] instruction;
    wire reg_write;
    wire mem_to_reg_write;
    // wire mem_read;
    wire mem_write;
    wire branch;
    wire [3:0] alu_control;
    wire alu_source;
    wire alu_source_shift;  // alu_source_shift = 1 if rs is replaced by shamt
    wire reg_dst;


    Control ct(instruction, reg_write, mem_to_reg_write, mem_write, branch, alu_control, alu_source, alu_source_shift, reg_dst);
    always
    begin
        $monitor("%t,  %b,  %b,  %b,  %b,  %b,  %b,  %b,  %b", 
                $realtime, reg_write, mem_to_reg_write, mem_write, branch, alu_control, alu_source, alu_source_shift, reg_dst);
        #8
            instruction <= 32'b000000_00001_01010_00110_00000_100000;  // add
        #10
            instruction <= 32'b001000_01111_01110_0000000000000010;  // addi
        #10
            instruction <= 32'b000101_00001_00010_0000000000010001;  // bne
        #10
            instruction <= 32'b100011_00010_00110_0000000100001000;  // lw
        #10
            instruction <= 32'b000000_00100_00011_00011_00001_000000;  // sll
        #10
            instruction <= 32'b000000_00010_00001_00101_00010_000111;  // srav
        #10
            instruction <= 32'b000000_00111_01100_00101_00000_100111;  // nor
        #10 $finish;
    end
endmodule