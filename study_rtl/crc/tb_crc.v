`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/11/26 17:12:46
// Design Name: 
// Module Name: tb_crc
//////////////////////////////////////////////////////////////////////////////////
module tb_crc(

);

reg rst;
reg clk;
reg data_valid;
reg [31:0] data;
wire [31:0] checksum;


crc32  crc32_u(
    .rst         (rst),
    .clk         (clk),
    .crc_en      (data_valid),
    .data_in     (data),
    .crc_out     (checksum));

always #10 clk = ~clk;

initial begin
    clk = 0;
    data_valid = 0;
    rst = 1;
    #205;
    rst = 0;
    #200;
    data_valid = 1;
    data = 1;
    #20;
    data = 2;
    #20;
    data = 3;
    #20;
    data = 4;
    #20;
    data = 5;
    #20;
    data = 6;
    #20;
    data_valid = 0;
    
    #2000;
    $stop;

    
end 
    
endmodule
