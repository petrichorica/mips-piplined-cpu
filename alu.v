`timescale 100fs/100fs
module ALU
    (   
        input signed [31:0] rs,  // reg1
        input signed [31:0] rt,  // reg2
        input [4:0] shamt,  // shift amount
        input signed [31:0] alu_outM,
        input signed [31:0] write_resultW,
        input [4:0] rt_addr,
        input [4:0] rd_addr,
        input signed [31:0] imm,
        input [3:0] alu_control,
        input alu_source,
        input alu_source_shift,
        input reg_dst,  // register to write back, rd or rt
        input [1:0] fw_alu1,  // Forwarding multiplexer 1
        input [1:0] fw_alu2,  // Forwarding multiplexer 2
        // Mux control: 
        // 00: no forwarding
        // 10: EX forwarding
        // 01: MEM forwarding
        output reg signed [31:0] alu_out,
        output reg signed [31:0] write_data,  // The 32-bit data to be write into the memory
        output reg [4:0] write_reg_addr
    );

    reg signed [31:0] oprA;  // Operand A
    reg signed [31:0] oprB;  // Operand B
    always @(rs, rt, shamt, alu_outM, write_resultW, rt_addr, rd_addr, imm, 
            alu_source, alu_source_shift, reg_dst, fw_alu1, fw_alu2)
    begin
        write_reg_addr <= (reg_dst == 1'b1) ? rd_addr : rt_addr;
        write_data <= (fw_alu2 == 2'b10) ? alu_outM :
                    (fw_alu2 == 2'b01) ? write_resultW :
                    rt;
        oprA <= (alu_source_shift == 1'b1) ? {27'b0, shamt} :
                (fw_alu1 == 2'b10) ? alu_outM :
                (fw_alu1 == 2'b01) ? write_resultW : 
                rs;
        oprB <= (alu_source == 1'b1) ? imm :
                (fw_alu2 == 2'b10) ? alu_outM : 
                (fw_alu2 == 2'b01) ? write_resultW :
                rt;
    end

    always @(oprA, oprB, alu_control) begin
        case(alu_control)
            4'b0001: alu_out <= oprA + oprB;
            4'b0010: alu_out <= oprA - oprB;
            4'b0011: alu_out <= oprA & oprB;
            4'b0100: alu_out <= oprA | oprB;
            4'b0101: alu_out <= oprA ^ oprB;
            4'b0110: alu_out <= ~(oprA | oprB);
            4'b0111: alu_out <= (oprA < oprB) ? 1'b1 : 1'b0;
            4'b1000: alu_out <= oprB << oprA;
            4'b1001: alu_out <= oprB >> oprA;
            4'b1010: alu_out <= oprB >>> oprA;
            endcase
    end
endmodule