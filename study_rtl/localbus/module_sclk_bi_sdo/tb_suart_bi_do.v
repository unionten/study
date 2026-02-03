`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// Create Date: 2021/12/24 19:49:03
// Design Name: 
// Module Name: tb_suart_bi_do
//////////////////////////////////////////////////////////////////////////////////
module tb_suart_bi_do(
);

reg rst;
reg clk;
reg start;
reg [79:0] pdata;
reg [7:0] num;

suart_bi_do
    #(.MAX_BYTE_NUM(10))
    suart_bi_do_u(
    .RST_I          (rst),
    .SCLK_I         (clk),//pos caozuo
    .START_I        (start),
    .CMD_I          (1),//2'b00:单次写  2'b01:外部连续写  [1:0] 
    .PDATA_I        (pdata),//[8*MAX_BYTE_NUM-1:0]
    .DATA_BYTE_NUM_I(num),//[7:0]
    .ALMOST_PULSE_O (almost_pulse),//
    .SCLK_O         (sck),
    .D1_O           (d1),
    .D0_O           (d0)
    );

    always #10 clk = ~clk;
    initial begin
        rst = 1;
        start = 0;
        clk = 0;
        #100;
        rst = 0;
        #200;
        
        start = 1;
        pdata = 80'haabbccdd11223344;
        num = 1;
        #24;
        start = 0;
          
    end
    
    initial begin
        #386;
        num = 1;
        pdata = 80'haabbccdd1122aabb;
        start = 1;
        #21;
        start = 0;
        
    end
    
    
endmodule
