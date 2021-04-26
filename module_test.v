`timescale 100fs/100fs
module processor;
    reg clk = 1'b0;
    wire[31:0] data;
    reg[31:0] read;
    reg[64:0] write;
    MainMemory memory(clk, 1'b0, 1'b1, read, write, data);
    always #10 clk <= ~clk;
    always
    begin
    $monitor("%t,      %h,      %h,      %h", $realtime, read, write, data);
    #8
        read <= 32'b00000000000000000000000000000001;
        write <= 65'b10000000000000000000000000000000100000000000000000000000000000010;
    #10 
    #10
        read <= 32'b00000000000000000000000000000001;
        write <= 65'b10000000000000000000000000000001000000000000000000000000000000011;
    #10
    #10
        read <= 32'b00000000000000000000000000000001;
        write <= 65'b0;
    #10
        $finish;
    end
endmodule