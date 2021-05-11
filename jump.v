`timescale 100fs/100fs
module Jump
    (
        input jr,
        input [31:0] rs,
        input [25:0] target,
        output [31:0] jump_addr
    );
    assign jump_addr = (jr) ? rs: {{6{1'b0}}, target};
endmodule