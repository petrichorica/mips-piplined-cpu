`timescale 100fs/100fs
module PCSrc
    (
        input branchD,
        input branch_eqD,
        input [1:0] fw_branch1,  // The forwarding multiplexer for RD1 for branch instructions
        input [1:0] fw_branch2,  // The forwarding multiplexer for RD2 for branch instructions
        // Mux control: 
        // 00: no forwarding
        // 10: EX forwarding
        // 01: MEM forwarding
        input signed [31:0] rs,
        input signed [31:0] rt,
        input signed [31:0] alu_outM,
        input signed [31:0] write_resultW,
        output reg src  //src=1 means branch
    );

    wire signed [31:0] opr1;
    wire signed [31:0] opr2;
    assign opr1 = (fw_branch1 == 2'b10) ? alu_outM:
                (fw_branch1 == 2'b01) ? write_resultW:
                rs;
    assign opr2 = (fw_branch2 == 2'b10) ? alu_outM:
                (fw_branch2 == 2'b01) ? write_resultW:
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