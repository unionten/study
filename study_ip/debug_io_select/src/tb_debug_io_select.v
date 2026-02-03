`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/25 16:14:28
// Design Name: 
// Module Name: tb_debug_io_select
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_debug_io_select(

    );

reg  [7:0]a=0 ;
reg  [7:0]b=0 ;
reg  [7:0]c =0;
 reg  [7:0]d =0;
 wire [3:0] debug_io;
 
 
 reg clk=0;
 reg resetn ;
 
 always #5 clk = ~clk ;
 
 initial begin
    clk = 0;
    resetn = 0 ;
    #500;
    resetn = 1 ;
    
    #400;
    
    a = 8'b00000001 ;
    b = 8'b00000001 ;
    c = 8'b00000001 ;
    d = 8'b00000001 ;
    
    
 #2000;
 
    a = 8'b00000000 ;
    b = 8'b00000001 ;
    c = 8'b00000001;
    d = 8'b00000001 ;
    
 #2000;
    a = 8'b00000001 ;
    b = 8'b00000000 ;
    c = 8'b00000001;
    d = 8'b00000001 ;
    
 #2000;
    a = 8'b00000000 ;
    b = 8'b00000000 ;
    c = 8'b00000000;
    d = 8'b00000001 ;
 #2000;
 
     a = 8'b00000001 ;
    b = 8'b00000001 ;
    c = 8'b00000000;
    d = 8'b00000000 ;
 #2000;
 
     a = 8'b00000000 ;
    b = 8'b00000001 ;
    c = 8'b00000000;
    d = 8'b00000000 ;
 #2000;
 
     a = 8'b00000001 ;
    b = 8'b00000000 ;
    c = 8'b00000001;
    d = 8'b00000000 ;
 #2000;
 
     a = 8'b00000000 ;
    b = 8'b00000000 ;
    c = 8'b00000001;
    d = 8'b00000000 ;
 #2000;
 
     a = 8'b00000001 ;
    b = 8'b00000001 ;
    c = 8'b00000001;
    d = 8'b00000001 ;
 #2000;
 
     a = 8'b00000000 ;
    b = 8'b00000001 ;
    c = 8'b00000000;
    d = 8'b00000001 ;
 #2000;
 
     a = 8'b00000001 ;
    b = 8'b00000000 ;
    c = 8'b00000000;
    d = 8'b00000001 ;
 #2000;
 
     a = 8'b00000000 ;
    b = 8'b00000000 ;
    c = 8'b00000000;
    d = 8'b00000001 ;
 #2000;
 
 
 
 
 
 end
 
 
debug_io_select  debug_io_selectu
 (
 
.S_AXI_ACLK     (clk) ,//总线时钟
.S_AXI_ARESETN  (resetn) ,



.FSYNC_I        (a)     ,
.FSYNC_FILTER_I (b)     ,
.VS_I           (c)     ,
.AUX_I          (d)    ,
 
.DEBUG_O (debug_io)
 
 
 );  
    
    
    
    
endmodule
