`timescale 100fs/100fs
module Pipline
    (
        input clk
    );
    reg [31:0] pcF = 32'b0;
    reg [31:0] pc_tmp = 32'b0;
    wire [31:0] pc_in_word;

    assign pc_in_word = pcF/32'd4;

    /* IF */
    wire [31:0] instruction;
    reg pc_enable = 1'b1;
    reg instr_enable = 1'b1;
    reg pc_src = 1'b0;

    always @(negedge clk) begin
        pcF <= pc_tmp;
    end

    always @(pcF, pc_branchD) begin
        if (pc_enable) begin
            if (pc_src) begin
                pc_tmp <= pc_branchD;
            end
            else if (jumpD) begin
                pc_tmp <= jump_addrD;
            end
            else begin
                pc_tmp <= pcF + 32'd4;
            end
        end
    end
    
    // always @(negedge clk) begin
    //     if (pc_enable) begin
    //         if (pc_src) begin
    //             pcF <= pc_branchD;
    //         end
    //         else begin
    //             pcF <= pcF + 32'd4;
    //         end
    //     end
    // end
    InstructionRAM i_mem(clk, 1'b0, 1'b1, pc_in_word, instruction);

    /* ID */
    // Register file & imm extend
    reg [31:0] instrD;
    reg [31:0] pcD;
    wire signed [31:0] rsD;
    wire signed [31:0] rtD;
    wire [4:0] rs_addrD;
    wire [4:0] rt_addrD;
    wire [4:0] rd_addrD;
    wire signed [31:0] extended_immD;
    wire [4:0] shamtD;
    wire [31:0] pc_branchD;

    Instruction_decode reg_d(instrD, pcD, clk, write_resultW, write_reg_addrW, 
                            reg_writeW, jumpD, linkD, rsD, rtD, rs_addrD, rt_addrD, 
                            rd_addrD, extended_immD, shamtD, pc_branchD);

    always @(negedge clk) begin
        if (instr_enable) begin
            if (branchD || jumpD) begin
                // Flush
                instrD <= 32'b0;
            end
            else begin
                pcD <= pcF + 32'd4;
                instrD <= instruction;
            end
        end
    end

    // Control unit
    wire reg_writeD;
    wire mem_to_reg_writeD;
    wire mem_readD;
    wire mem_writeD;
    wire branchD;
    wire branch_eqD;
    wire jumpD;
    wire linkD;  // For jal instruction
    wire jrD; // For jr instruction
    wire [25:0] target;
    wire [3:0] alu_controlD;
    wire alu_sourceD;
    wire alu_source_shiftD;  // alu_source_shift = 1 if rs is replaced by shamt
    wire reg_dstD;

    reg control_mux = 1'b1;  // used for stalling

    Control control(instrD, control_mux, reg_writeD, mem_to_reg_writeD, mem_readD, 
                    mem_writeD, branchD, branch_eqD, jumpD, linkD, jrD, target, 
                    alu_controlD, alu_sourceD, alu_source_shiftD, reg_dstD);

    wire [31:0] jump_addrD;
    Jump jump_mux(jrD, rsD, target, jump_addrD);

    /* EX */
    // Control signal
    reg reg_writeE;
    reg mem_to_reg_writeE;
    reg mem_readE;
    reg mem_writeE;
    reg branchE;
    reg [3:0] alu_controlE;
    reg alu_sourceE;
    reg alu_source_shiftE;  // alu_source_shift = 1 if rs is replaced by shamt
    reg reg_dstE;

    // Instruction
    reg [31:0] instrE;

    // Data
    reg signed [31:0] rsE;  // reg1
    reg signed [31:0] rtE;  // reg2
    reg [4:0] shamtE;  // shift amount
    reg [4:0] rs_addrE;
    reg [4:0] rt_addrE;
    reg [4:0] rd_addrE;
    reg signed [31:0] immE;
    reg [31:0] pcE;
    wire zeroE;
    wire signed [31:0] alu_outE;
    wire signed [31:0] write_dataE;  // The 32-bit data to be write into the memory
    wire [4:0] write_reg_addrE;
    wire [31:0] pc_branchE;

    // Forwarding multiplexer
    wire [1:0] fw_alu1;
    wire [1:0] fw_alu2;
    Forwarding forwarding(reg_writeW, write_reg_addrW, reg_writeM, write_reg_addrM, 
                    rs_addrE, rt_addrE, fw_alu1, fw_alu2);

    Alu alu_ex(rsE, rtE, shamtE, alu_outM, write_resultW, rt_addrE, rd_addrE, immE, 
            pcE, alu_controlE, alu_sourceE, alu_source_shiftE, reg_dstE, 
            fw_alu1, fw_alu2, zeroE, alu_outE, write_dataE, write_reg_addrE, pc_branchE);
    
    always @(negedge clk) begin
        reg_writeE <= reg_writeD;
        mem_to_reg_writeE <= mem_to_reg_writeD;
        mem_readE <= mem_readD;
        mem_writeE <= mem_writeD;
        branchE <= branchD;
        alu_controlE <= alu_controlD;
        alu_sourceE <= alu_sourceD;
        alu_source_shiftE <= alu_source_shiftD;
        reg_dstE <= reg_dstD;

        rsE <= rsD;
        rtE <= rtD;

        shamtE <= shamtD;
        rs_addrE <= rs_addrD;
        rt_addrE <= rt_addrD;
        rd_addrE <= rd_addrD;
        immE <= extended_immD;
        pcE <= pcD;

        instrE <= instrD;
    end

    /* MEM */
    // Control signal
    reg reg_writeM;
    reg mem_to_reg_writeM;
    reg mem_writeM;
    reg branchM;

    // Instruction
    reg [31:0] instrM;

    // Data
    reg zeroM;
    reg signed [31:0] alu_outM;
    reg signed [31:0] write_dataM;  // The 32-bit data to be write into the memory
    reg [4:0] write_reg_addrM;
    wire signed [31:0] read_dataM;

    wire [31:0] r_addr_in_word;
    assign r_addr_in_word = alu_outM / 32'd4;

    MainMemory memory(clk, 1'b0, 1'b1, r_addr_in_word, {mem_writeM, r_addr_in_word, write_dataM}, read_dataM);

    always @(negedge clk) begin
        reg_writeM <= reg_writeE;
        mem_to_reg_writeM <= mem_to_reg_writeE;
        mem_writeM <= mem_writeE;
        branchM <= branchE;
        zeroM <= zeroE;
        alu_outM <= alu_outE;
        write_dataM <= write_dataE;
        write_reg_addrM <= write_reg_addrE;

        instrM <= instrE;
    end

    /* WB */
    // Control signal
    reg reg_writeW;
    reg mem_to_reg_writeW;

    // Data
    reg signed [31:0] alu_outW;
    reg signed [31:0] read_dataW;
    reg [4:0] write_reg_addrW;
    wire signed [31:0] write_resultW;

    Write_back wb(alu_outW, read_dataW, mem_to_reg_writeW, write_resultW);

    always @(negedge clk) begin
        reg_writeW <= reg_writeM;
        mem_to_reg_writeW <= mem_to_reg_writeM;
        alu_outW <= alu_outM;
        read_dataW <= read_dataM;
        write_reg_addrW <= write_reg_addrM;

        if (instrM == 32'hffffffff) begin
            $finish;
        end
    end

    /* hazard detection */
    wire pc_enable_w;
    wire instr_enable_w;
    wire control_mux_w;

    Hazard hazard(mem_readE, rt_addrE, rs_addrD, rt_addrD, pc_src, jumpD,
                pc_enable_w, instr_enable_w, control_mux_w);
    always @(pc_enable_w, instr_enable_w, control_mux_w) begin
        pc_enable <= pc_enable_w;
        instr_enable <= instr_enable_w;
        control_mux <= control_mux_w;
    end

    /* Forwarding in ID for branch instructions*/
    wire [1:0] fw_branch1;
    wire [1:0] fw_branch2;
    ForwardingD fwD(reg_writeW, write_reg_addrW, reg_writeM, write_reg_addrM, 
                rs_addrD, rt_addrD, fw_branch1, fw_branch2);

    /* PC source for branch instructions */
    wire pc_src_w;
    PCSrc pc_src_mux(branchD, branch_eqD, fw_branch1, fw_branch2, rsD, rtD, 
                alu_outM, write_resultW, pc_src_w);
    always @(pc_src_w) begin
        pc_src <= pc_src_w;
    end
endmodule