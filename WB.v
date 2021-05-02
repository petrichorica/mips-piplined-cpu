`timescale 100fs/100fs
module write_back
    (
        input [31:0] alu_out,
        input [31:0] read_data,
        input mem_to_reg,
        output [31:0] write_result
    );
    assign write_result = (mem_to_reg==1) ? read_data : alu_out;
endmodule