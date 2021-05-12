`timescale 100fs/100fs
module Jump
    (
        input jr,
        input [31:0] rs,
        input [25:0] target,
        input [1:0] fw_rd1,  // The forwarding multiplexer for RD1 for branch and jr instructions
        // Mux control: 
        // 00: no forwarding
        // 10: EX forwarding
        // 01: MEM forwarding
        input signed [31:0] alu_outE,
        input signed [31:0] alu_outM,
        output [31:0] jump_addr
    );
    // assign jump_addr = (jr) ? rs: {{4'b0000}, target, {2'b00}};
    assign jump_addr = (jr) ? ((fw_rd1 == 2'b10) ? alu_outE:
                            (fw_rd1 == 2'b01) ? alu_outM:
                            rs):
                        {{4'b0000}, target, {2'b00}};
endmodule