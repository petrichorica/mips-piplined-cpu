`timescale 100fs/100fs
module PCSrc
    (
        input branchD,
        input branch_eqD,
        input [1:0] fw_rd1,  // The forwarding multiplexer for RD1 for branch and jr instructions
        input [1:0] fw_rd2,  // The forwarding multiplexer for RD2 for branch and jr instructions
        // Mux control: 
        // 00: no forwarding
        // 10: EX forwarding
        // 01: MEM forwarding
        input signed [31:0] rs,
        input signed [31:0] rt,
        input signed [31:0] alu_outE,
        input signed [31:0] alu_outM,
        output reg src  //src=1 means branch
    );

    wire signed [31:0] opr1;
    wire signed [31:0] opr2;
    assign opr1 = (fw_rd1 == 2'b10) ? alu_outE:
                (fw_rd1 == 2'b01) ? alu_outM:
                rs;
    assign opr2 = (fw_rd2 == 2'b10) ? alu_outE:
                (fw_rd2 == 2'b01) ? alu_outM:
                rt;

    always @(*) begin
        if (branchD && branch_eqD && (opr1 == opr2)) begin
            src <= 1'b1;
        end
        else if (branchD && (~branch_eqD) && (opr1 != opr2)) begin
            src <= 1'b1;
        end
        else begin
            src <= 1'b0;
        end
    end
endmodule