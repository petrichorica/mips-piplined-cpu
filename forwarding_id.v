`timescale 100fs/100fs
module ForwardingD
    (
        input reg_writeW,
        input [4:0] write_reg_addrW,
        input reg_writeM,
        input [4:0] write_reg_addrM,
        input [4:0] rs_addrD,
        input [4:0] rt_addrD,
        output reg [1:0] fw_branch1,  // The forwarding multiplexer for RD1 for branch instructions
        output reg [1:0] fw_branch2  // The forwarding multiplexer for RD2 for branch instructions
        // Mux control: 
        // 00: no forwarding
        // 10: EX forwarding
        // 01: MEM forwarding
    );

    // Generate forwarding signal
    always @(*) begin
        if (reg_writeM == 1'b1 && write_reg_addrM != 5'b0 
            && write_reg_addrM == rs_addrD)
            begin
                fw_branch1 <= 2'b10; 
            end
        else if (reg_writeW == 1'b1 && write_reg_addrW != 5'b0
            && write_reg_addrW == rs_addrD)
            begin
                fw_branch1 <= 2'b01;
            end
        else begin
            fw_branch1 <= 2'b00;
        end
        
        if (reg_writeM == 1'b1 && write_reg_addrM != 5'b0 
            && write_reg_addrM == rt_addrD)
            begin
                fw_branch2 <= 2'b10;
            end
        else if (reg_writeW == 1'b1 && write_reg_addrW != 5'b0
            && write_reg_addrW == rt_addrD)
            begin
                fw_branch2 <= 2'b01;
            end
        else begin
            fw_branch2 <= 2'b00;
        end
    end
endmodule