`timescale 100fs/100fs
module Pipline_test;
    reg clk = 1'b1;
    Pipline pipline(clk);

    always #10 clk <= ~clk;

    always begin
    $monitor("%t,  %h,  %h,  %h,  %h,  %h,  %h,  %h,  %h,  %h", $realtime, pipline.instruction, 
            pipline.alu_outE, pipline.fw_alu1, pipline.fw_alu2, 
            pipline.alu_ex.oprA, pipline.alu_ex.oprB, 
            pipline.alu_ex.rd_addr, pipline.write_reg_addrM, pipline.rs_addrE);

    #200 $finish;
    end
endmodule