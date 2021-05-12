`timescale 100fs/100fs
module ForwardingD
    (
        input reg_writeE,
        input [4:0] write_reg_addrE,
        input reg_writeM,
        input [4:0] write_reg_addrM,
        input [4:0] rs_addrD,
        input [4:0] rt_addrD,
        output reg [1:0] fw_rd1,  // The forwarding multiplexer for RD1 for branch and jr instructions
        output reg [1:0] fw_rd2  // The forwarding multiplexer for RD2 for branch and jr instructions
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
                fw_rd1 <= 2'b01; 
            end
        else if (reg_writeE == 1'b1 && write_reg_addrE != 5'b0
            && write_reg_addrE == rs_addrD)
            begin
                fw_rd1 <= 2'b10;
            end
        else begin
            fw_rd1 <= 2'b00;
        end
        
        if (reg_writeM == 1'b1 && write_reg_addrM != 5'b0 
            && write_reg_addrM == rt_addrD)
            begin
                fw_rd2 <= 2'b01;
            end
        else if (reg_writeE == 1'b1 && write_reg_addrE != 5'b0
            && write_reg_addrE == rt_addrD)
            begin
                fw_rd2 <= 2'b10;
            end
        else begin
            fw_rd2 <= 2'b00;
        end
    end
endmodule