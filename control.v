`timescale 100fs/100fs
module Control
    (
        input [31:0] instruction,
        input control_mux,
        output reg reg_write,
        output reg mem_to_reg_write,
        output reg mem_read,
        output reg mem_write,
        output reg branch,
        output reg branch_eq,  // branch_eq = 1 if beq; branch_eq = 0 if bne.
        output reg jump,
        output reg link,  // For jal instruction
        output reg jr,  // For jr instruction
        output [25:0] target,
        output reg [3:0] alu_control,
        output reg alu_source,
        output reg alu_source_shift,  // alu_source_shift = 1 if rs is replaced by shamt.
        output reg reg_dst
    );

    wire [5:0] opcode;
    wire [5:0] funct;
    assign opcode = instruction[31:26];
    assign funct = instruction[5:0];
    assign target = instruction[25:0];

    always @(instruction) begin
        if (~control_mux) begin
            reg_write <= 1'b0;
            mem_to_reg_write <= 1'b0;
            mem_read <= 1'b0;
            mem_write <= 1'b0;
            branch <= 1'b0;
            branch_eq <= 1'b0;
            jump <= 1'b0;
            link <= 1'b0;
            jr <= 1'b0;
            alu_control <= 4'b0;
            alu_source <= 1'b0;
            alu_source_shift <= 1'b0;
            reg_dst <= 1'b0;
        end

        else
        if (opcode == 6'h0) begin
            reg_write <= 1'b1;
            mem_to_reg_write <= 1'b0;
            mem_read <= 1'b0;
            mem_write <= 1'b0;
            branch <= 1'b0;
            branch_eq <= 1'b0;

            if (funct == 6'h8) begin  // jr
                jump <= 1'b1;
                link <= 1'b0;
                jr <= 1'b1;
            end
            else begin
                jump <= 1'b0;
            end

            link <= 1'b0;
            alu_source <= 1'b0;
            reg_dst <= 1'b1;
            case(funct)
                // add
                6'h20: alu_control <= 4'b0001;
                // addu
                6'h21: alu_control <= 4'b0001;
                // sub
                6'h22: alu_control <= 4'b0010;
                // subu
                6'h23: alu_control <= 4'b0010;
                // and
                6'h24: alu_control <= 4'b0011;
                // or
                6'h25: alu_control <= 4'b0100;
                // xor 
                6'h26: alu_control <= 4'b0101;
                // nor
                6'h27: alu_control <= 4'b0110;
                // slt
                6'h2a: alu_control <= 4'b0111;
                // sll
                6'h0: alu_control <= 4'b1000;
                // sllv
                6'h4: alu_control <= 4'b1000;
                // srl
                6'h2: alu_control <= 4'b1001;
                // srlv
                6'h6: alu_control <= 4'b1001;
                // sra
                6'h3: alu_control <= 4'b1010;
                // srav
                6'h7: alu_control <= 4'b1010;
            endcase

            if (funct == 6'h0 || funct == 6'h2 || funct == 6'h3) begin
                alu_source_shift <= 1'b1;
            end
            else begin
                alu_source_shift <= 1'b0;
            end
        end

        else begin
            alu_source_shift <= 1'b0;
            case(opcode)
                // addi
                6'h8: begin 
                    reg_write <= 1'b1;
                    mem_to_reg_write <= 1'b0;
                    mem_read <= 1'b0;
                    mem_write <= 1'b0;
                    branch <= 1'b0;
                    jump <= 1'b0;
                    alu_control <= 4'b0001;
                    alu_source <= 1'b1;
                    reg_dst <= 1'b0;
                end
                // addiu
                6'h9: begin
                    reg_write <= 1'b1;
                    mem_to_reg_write <= 1'b0;
                    mem_read <= 1'b0;
                    mem_write <= 1'b0;
                    branch <= 1'b0;
                    jump <= 1'b0;
                    alu_control <= 4'b0001;
                    alu_source <= 1'b1;
                    reg_dst <= 1'b0;
                end
                // andi
                6'hc: begin
                    reg_write <= 1'b1;
                    mem_to_reg_write <= 1'b0;
                    mem_read <= 1'b0;
                    mem_write <= 1'b0;
                    branch <= 1'b0;
                    jump <= 1'b0;
                    alu_control <= 4'b0011;
                    alu_source <= 1'b1;
                    reg_dst <= 1'b0;
                end
                // ori
                6'hd: begin
                    reg_write <= 1'b1;
                    mem_to_reg_write <= 1'b0;
                    mem_read <= 1'b0;
                    mem_write <= 1'b0;
                    branch <= 1'b0;
                    jump <= 1'b0;
                    alu_control <= 4'b0100;
                    alu_source <= 1'b1;
                    reg_dst <= 1'b0;
                end
                // xori
                6'he: begin
                    reg_write <= 1'b1;
                    mem_to_reg_write <= 1'b0;
                    mem_read <= 1'b0;
                    mem_write <= 1'b0;
                    branch <= 1'b0;
                    jump <= 1'b0;
                    alu_control <= 4'b0101;
                    alu_source <= 1'b1;
                    reg_dst <= 1'b0;
                end
                // beq
                6'h4: begin
                    reg_write <= 1'b0;
                    mem_read <= 1'b0;
                    mem_write <= 1'b0;
                    branch <= 1'b1;
                    jump <= 1'b0;
                    alu_control <= 4'b0010;
                    alu_source <= 1'b0;
                end
                // bne
                6'h5: begin
                    reg_write <= 1'b0;
                    mem_read <= 1'b0;
                    mem_write <= 1'b0;
                    branch <= 1'b1;
                    jump <= 1'b0;
                    alu_control <= 4'b0010;
                    alu_source <= 1'b0;
                end
                // lw
                6'h23: begin
                    reg_write <= 1'b1;
                    mem_to_reg_write <= 1'b1;
                    mem_read <= 1'b1;
                    mem_write <= 1'b0;
                    branch <= 1'b0;
                    jump <= 1'b0;
                    alu_control <= 4'b0001;
                    alu_source <= 1'b1;
                    reg_dst <= 1'b0;
                end
                // sw
                6'h2b: begin
                    reg_write <= 1'b0;
                    mem_read <= 1'b0;
                    mem_write <= 1'b1;
                    branch <= 1'b0;
                    jump <= 1'b0;
                    alu_control <= 4'b0001;
                    alu_source <= 1'b1;
                end
                // j
                6'h2: begin
                    reg_write <= 1'b0;
                    mem_read <= 1'b0;
                    mem_write <= 1'b0;
                    branch <= 1'b0;
                    jump <= 1'b1;
                    link <= 1'b0;
                    jr <= 1'b0;
                end
                // jal
                6'h3: begin
                    reg_write <= 1'b0;
                    mem_read <= 1'b0;
                    mem_write <= 1'b0;
                    branch <= 1'b0;
                    jump <= 1'b1;
                    link <= 1'b1;
                    jr <= 1'b0;
                end
            endcase
            if (opcode == 6'h4) begin  // beq
                branch_eq <= 1'b1;
            end
            else begin
                branch_eq <= 1'b0;
            end
        end
    end
endmodule