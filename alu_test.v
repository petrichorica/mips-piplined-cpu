`timescale 100fs/100fs
module alu_test;
    reg [31:0] rs;  // reg1
    reg [31:0] rt;  // reg2
    reg [4:0] shamt;  // shift amount
    reg [4:0] rt_addr;
    reg [4:0] rd_addr;
    reg [31:0] imm;
    reg [31:0] pc;
    reg [3:0] alu_control;
    reg alu_source;
    reg alu_source_shift;
    reg reg_dst;
    wire zero;
    wire [31:0] alu_out;
    wire [31:0] write_data;  // The 32-bit data to be write into the memory
    wire [4:0] write_reg_addr;
    wire [31:0] pc_branch;

    Alu at(rs, rt, shamt, rt_addr, rd_addr, imm, pc, alu_control, alu_source, 
        alu_source_shift, reg_dst, zero, alu_out, write_data, write_reg_addr, pc_branch);

    always
    begin
        $monitor("%t,  %h,  %h,  %h,  %h", 
                $realtime, zero, alu_out, write_data, write_reg_addr, pc_branch);
        #8
            rs <= 32'd10;  // addi
            rt <= 32'd20;
            shamt <= 5'b0;
            rt_addr <= 5'b01100;
            rd_addr <= 5'b01001;
            imm <= 32'd20;
            pc <= 32'd100;
            alu_control <= 4'b0001;
            alu_source <= 1;
            alu_source_shift <= 0;
            reg_dst <= 0;
        #10
            alu_control <= 4'b0010;  // sub
            alu_source <= 0;
            reg_dst <= 1;
        #10
            alu_control <= 4'b0010;  // bne
        #10
            shamt <= 5'b00010;
            alu_control <= 4'b1000;  // sll
            alu_source_shift <= 1;
        #10
            shamt <= 5'b0;
            rs <= 32'd1;
            alu_control <= 4'b1010;  // srav
            alu_source_shift <= 0;
        #10
            alu_control <= 4'b0111;  // slt
            alu_source <= 0;
        #10 $finish;
    end
endmodule