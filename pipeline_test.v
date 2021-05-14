`timescale 100fs/100fs
module Pipeline_test;
    reg clk = 1'b0;
    reg finish = 1'b0;
    integer fd;
    Pipeline pipeline(clk);

    initial begin
        fd = $fopen("out.txt", "w");
    end

    always #10 clk <= ~clk;

    always @(pipeline.instrM) begin
        if (pipeline.instrM == 32'hffffffff) begin
            finish <= 1'b1;
        end
    end

    // always begin
    // $display("The clock cycle is 20.");
    // $display("time:instruction:ALU out in EX: write result in WB");
    // $monitor("%t,  %h,  %3d,  %3d", 
    //         $realtime, pipeline.instruction, pipeline.alu_outE, pipeline.write_resultW);

    // #160 $finish;
    // end

    always @(finish) begin
        if (finish) begin : display
            integer i;
            // $display("Main Memory:");
            for (i=0; i<512; i=i+1) begin
                // $display("%b", pipeline.memory.DATA_RAM[i]);
                $fdisplay(fd, "%b", pipeline.memory.DATA_RAM[i]);
            end
            $fclose(fd);
            $finish;
        end
    end
endmodule