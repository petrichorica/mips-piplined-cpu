`timescale 100fs/100fs
module Pipline_test;
    reg clk = 1'b1;
    reg finish = 1'b0;
    Pipline pipline(clk);

    always #10 clk <= ~clk;

    always @(pipline.instrM) begin
        if (pipline.instrM == 32'hffffffff) begin
            finish <= 1'b1;
        end
    end

    // always begin
    // $monitor("%t,  %h,  %d", $realtime, pipline.instrE, pipline.alu_outE);

    // #400 $finish;
    // end

    always @(finish) begin
        if (finish) begin : display
            integer i;
            $display("The top 30 rows of the Main Memory:");
            for (i=0; i<30; i=i+1) begin
                $display("%b", pipline.memory.DATA_RAM[i]);
            end
            $finish;
        end
    end
endmodule