`timescale 100fs/100fs
module Hazard_unit
    (
        input reg_writeW,
        input [4:0] write_reg_addrW,
        input reg_writeM,
        input [4:0] write_reg_addrM,
        input [4:0] rs_addrE,
        input [4:0] rt_addrE,
        output reg [1:0] fw_alu1,  // The forwarding multiplexer for the first ALU operand
        output reg [1:0] fw_alu2  // The forwarding multiplexer for the second ALU operand
        // Mux control: 
        // 00: no forwarding
        // 10: EX forwarding
        // 01: MEM forwarding
    );
    always @(*) begin
        if (reg_writeM == 1'b1 && write_reg_addrM != 5'b0 
            && write_reg_addrM == rs_addrE)
            begin
                fw_alu1 <= 2'b10; 
            end
        else if (reg_writeW == 1'b1 && write_reg_addrW != 5'b0
            && write_reg_addrW == rs_addrE)
            begin
                fw_alu1 <= 2'b01;
            end
        else begin
            fw_alu1 <= 2'b00;
        end
        
        if (reg_writeM == 1'b1 && write_reg_addrM != 5'b0 
            && write_reg_addrM == rt_addrE)
            begin
                fw_alu2 <= 2'b10;
            end
        else if (reg_writeW == 1'b1 && write_reg_addrW != 5'b0
            && write_reg_addrW == rt_addrE)
            begin
                fw_alu2 <= 2'b01;
            end
        else begin
            fw_alu2 <= 2'b00;
        end
    end
endmodule