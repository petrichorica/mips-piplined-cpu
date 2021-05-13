`timescale 100fs/100fs
module Pipeline_test;
    reg clk = 1'b1;
    reg finish = 1'b0;
    Pipeline pipeline(clk);

    always #10 clk <= ~clk;

    always @(pipline.instrM) begin
        if (pipeline.instrM == 32'hffffffff) begin
            finish <= 1'b1;
        end
    end

    // always begin
    // $monitor("%t,  %h,  %3d,  %h,  %3d,  %3d,  %3d,  %3d,  %3d,  %3d,   %h,  %h", 
    //         $realtime, pipline.instrE, pipline.alu_outE, pipline.instrD,
    //         pipline.jumpD, pipline.fw_rd1, pipline.instr_enable,
    //         pipline.mem_readM, pipline.write_reg_addrM, pipline.rs_addrD, 
    //         pipline.jump_addrD, pipline.pcD);

    // #700 $finish;
    // end

    always @(finish) begin
        if (finish) begin : display
            integer i;
            $display("Main Memory:");
            for (i=0; i<512; i=i+1) begin
                $display("%b", pipeline.memory.DATA_RAM[i]);
            end
            $finish;
        end
    end
endmodule