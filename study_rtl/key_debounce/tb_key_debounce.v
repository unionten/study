`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/13 14:09:26
// Design Name: 
// Module Name: tb_key_debounce
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


module tb_key_debounce(

    );
    
reg clk;
reg rstn;
reg key_in;
wire key_out ;
    
key_debounce  
    #(.C_CLK_PRD_NS              (10) ,
      .C_LOW_LEVEL_THRESHOLD_US  (0) ,
      .C_HIGH_LEVEL_THRESHOLD_US (0)  )
    key_debounce_u (
    .CLK_I    (clk ),  
    .RSTN_I   (rstn),      
    .KEY_I    (key_in  ),     // 原始按键输入
    .KEY_O    (key_out)      // 消抖后
    );


always #5 clk = ~clk ; 



initial begin
clk = 0;
key_in = 0;
rstn = 0;
#200;
rstn = 1;
#6000;
key_in = 1;
#40000;
key_in = 0;
#90000;

key_in = 1;
#60000;
key_in = 0;
#110000;







end









    
    
    
endmodule
