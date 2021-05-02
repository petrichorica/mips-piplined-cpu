`timescale 100fs/100fs
module Pipline_test;
    reg clk = 1'b1;
    Pipline pipline(clk);

    always #10 clk <= ~clk;

    always begin
    $monitor("%t,  %h,  %h,  %h,  %h,  %h", $realtime, pipline.instruction, 
            pipline.instrD, pipline.alu_outE, pipline.rsE, pipline.rtE);
    #200 $finish;
    end
endmodule