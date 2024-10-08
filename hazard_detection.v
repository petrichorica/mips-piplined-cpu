`timescale 100fs/100fs
module Hazard
    (
        input mem_readE,
        input [4:0] rt_addrE,
        input [4:0] rs_addrD,
        input [4:0] rt_addrD,
        input mem_readM,
        input [4:0] write_reg_addrM,
        input pc_src,  // pc_src = 1 if branch occurs
        input jumpD,
        output reg pc_enable,
        output reg instr_enable,
        output reg control_mux
    );

    // If the instruction is a lw, branch, or jump instruction, insert stall
    always @(*) begin
        // lw
        if (mem_readE == 1'b1 && (rt_addrE == rs_addrD || rt_addrE == rt_addrD)) begin
            pc_enable <= 0;
            instr_enable <= 0;
            control_mux <= 0;
        end
        // lw and branch/jump hazards occur at the same time
        else if ((pc_src || jumpD) && 
            (mem_readM == 1'b1 && (write_reg_addrM == rs_addrD || write_reg_addrM == rt_addrD))) begin
            pc_enable <= 0;
            instr_enable <= 0;
            control_mux <= 0;
        end
        // branch or jump
        else if (pc_src || jumpD) begin
            pc_enable <= 1;
            instr_enable <= 1;
            control_mux <= 0;
        end
        else begin
            pc_enable <= 1;
            instr_enable <= 1;
            control_mux <= 1;
        end
    end
endmodule