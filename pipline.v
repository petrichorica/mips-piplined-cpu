`timescale 100fs/100fs
module Pipline
    (
        input clk
    );
    reg [31:0] pcF = 32'b0;
    wire [31:0] pc_in_word;

    assign pc_in_word = pcF/32'd4;

    /* IF */
    wire [31:0] instruction;
    InstructionRAM i_mem(clk, 1'b0, 1'b1, pc_in_word, instruction);
    always @(negedge clk) begin
        pcF <= pcF + 32'd4;
    end

    /* ID */
    // Register file & imm extend
    reg [31:0] instrD;
    // reg [31:0] write_resultD;
    // reg [4:0] write_addrD;
    // reg_writeW is defined in WB block
    wire [31:0] rsD;
    wire [31:0] rtD;
    wire [4:0] rs_addrD;
    wire [4:0] rt_addrD;
    wire [4:0] rd_addrD;
    wire [31:0] extended_immD;
    wire [4:0] shamtD;

    Instruction_decode reg_d(instrD, clk, write_resultW, write_reg_addrW, reg_writeW, rsD, rtD, 
                            rs_addrD, rt_addrD, rd_addrD, extended_immD, shamtD);
    
    // Control unit
    wire reg_writeD;
    wire mem_to_reg_writeD;
    // wire mem_readD;
    wire mem_writeD;
    wire branchD;
    wire [3:0] alu_controlD;
    wire alu_sourceD;
    wire alu_source_shiftD;  // alu_source_shift = 1 if rs is replaced by shamt
    wire reg_dstD;

    Control control(instrD, reg_writeD, mem_to_reg_writeD, mem_writeD, branchD, 
                    alu_controlD, alu_sourceD, alu_source_shiftD, reg_dstD);

    reg [31:0] pcD;
    always @(negedge clk) begin
        pcD <= pcF;
        instrD <= instruction;
    end

    /* EX */
    // Control signal
    reg reg_writeE;
    reg mem_to_reg_writeE;
    // reg mem_readE;
    reg mem_writeE;
    reg branchE;
    reg [3:0] alu_controlE;
    reg alu_sourceE;
    reg alu_source_shiftE;  // alu_source_shift = 1 if rs is replaced by shamt
    reg reg_dstE;

    // Data
    reg [31:0] rsE;  // reg1
    reg [31:0] rtE;  // reg2
    reg [4:0] shamtE;  // shift amount
    reg [4:0] rs_addrE;
    reg [4:0] rt_addrE;
    reg [4:0] rd_addrE;
    reg [31:0] immE;
    reg [31:0] pcE;
    wire zeroE;
    wire [31:0] alu_outE;
    wire [31:0] write_dataE;  // The 32-bit data to be write into the memory
    wire [4:0] write_reg_addrE;
    wire [31:0] pc_branchE;

    // Forwarding multiplexer
    wire [1:0] fw_alu1;
    wire [1:0] fw_alu2;
    Hazard_unit hazard(reg_writeW, write_reg_addrW, reg_writeM, write_reg_addrM, 
                    rs_addrE, rt_addrE, fw_alu1, fw_alu2);

    Alu alu_ex(rsE, rtE, shamtE, alu_outM, write_resultW, rt_addrE, rd_addrE, immE, 
            pcE, alu_controlE, alu_sourceE, alu_source_shiftE, reg_dstE, 
            fw_alu1, fw_alu2, zeroE, alu_outE, write_dataE, write_reg_addrE, pc_branchE);
    
    always @(negedge clk) begin
        reg_writeE <= reg_writeD;
        mem_to_reg_writeE <= mem_to_reg_writeD;
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
    end

    /* MEM */
    // Control signal
    reg reg_writeM;
    reg mem_to_reg_writeM;
    reg mem_writeM;
    reg branchM;

    // Data
    reg zeroM;
    reg [31:0] alu_outM;
    reg [31:0] write_dataM;  // The 32-bit data to be write into the memory
    reg [4:0] write_reg_addrM;
    wire [31:0] read_dataM;

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
    end

    /* WB */
    // Control signal
    reg reg_writeW;
    reg mem_to_reg_writeW;

    // Data
    reg [31:0] alu_outW;
    reg [31:0] read_dataW;
    reg [4:0] write_reg_addrW;
    wire [31:0] write_resultW;

    Write_back wb(alu_outW, read_dataW, mem_to_reg_writeW, write_resultW);

    always @(negedge clk) begin
        reg_writeW <= reg_writeM;
        mem_to_reg_writeW <= mem_to_reg_writeM;
        alu_outW <= alu_outM;
        read_dataW <= read_dataM;
        write_reg_addrW <= write_reg_addrM;
    end
endmodule