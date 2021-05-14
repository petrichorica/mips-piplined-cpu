`timescale 100fs/100fs
module Write_back
    (
        input signed [31:0] alu_out,  // The result of ALU
        input signed [31:0] read_data,  // The data obtained from memory
        input mem_to_reg,
        output signed [31:0] write_result
    );
    assign write_result = (mem_to_reg==1'b1) ? read_data : alu_out;
endmodule