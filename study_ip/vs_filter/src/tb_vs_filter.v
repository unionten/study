`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/21 15:43:50
// Design Name: 
// Module Name: tb_vs_filter
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


module tb_vs_filter(

    );

reg clk ;
reg rstn ;
reg vs ;

always #0.5 clk = ~clk ;

initial begin
    clk  = 0 ;
    rstn = 0 ;
    vs   = 0 ;
    
    
    #200.6;
    rstn =  1;
    
    #500 ;
    
    vs = 1 ;
    #20;
    vs = 0 ;
    #2000;
    
    vs = 1 ;
    #20;
    vs = 0 ;
    #2000;
    
    vs = 1 ;
    #20;
    vs = 0 ;
    #2000;
    
    
    vs = 1 ;
    #20;
    vs = 0 ;
    #2000;
    
    vs = 1 ;
    #20;
    vs = 0 ;
    #2050; 
    

    vs = 1 ;
    #20;
    vs = 0 ;
    #2000; 


    vs = 1 ;
    #20;
    vs = 0 ;
    #2051; 
    
    
    vs = 1 ;
    #20;
    vs = 0 ;
    #2000;   
    
    
    vs = 1 ;
    #20;
    vs = 0 ;
    #2000; 


    vs = 1 ;
    #20;
    vs = 0 ;
    #2000; 


    vs = 1 ;
    #20;
    vs = 0 ;
    #2000; 


    vs = 1 ;
    #20;
    vs = 0 ;
    #2000; 



    vs = 1 ;
    #20;
    vs = 0 ;
    #2000;     
  
    vs = 1 ;
    #20;
    vs = 0 ;
    #2000;  
    
        vs = 1 ;
    #20;
    vs = 0 ;
    #2000;  
    
    
    
    vs = 1 ;
    #20;
    vs = 0 ;
    #2000;  
    
    
    vs = 1 ;
    #20;
    vs = 0 ;
    #2000;  



    #10000;
    vs = 1 ;
    #20;
    vs = 0 ;
    #2000;  

    #10000;
    vs = 1 ;
    #20;
    vs = 0 ;
    #2000;  
    
    
    
        #10000;
    vs = 1 ;
    #20;
    vs = 0 ;
    #2000;  
    
    
    
        #10000;
    vs = 1 ;
    #20;
    vs = 0 ;
    #2000;  
    
    
    
        #10000;
    vs = 1 ;
    #20;
    vs = 0 ;
    #2000;  
    
    
    
        #10000;
    vs = 1 ;
    #20;
    vs = 0 ;
    #2000;  
    
    
        #10000;
    vs = 1 ;
    #20;
    vs = 0 ;
    #2000;  
end





vs_filter   vs_filter_u (
    .CLK_I         (clk  ),
    .RSTN_I        (rstn ),
    .VS_I          (vs   ),// __|————|_____ 
    .VS_O          (vs_o ),//  --- 检测下沿，生成使能信号，保证输出占空比和输入一致 -- 无延时
    .VS_STABLE_O   (vs_stable ),


.FILTER_EN_I                 (1)   ,
.FILTER_TIMES_I              (3)   ,
.FILTER_THRESHHOLD_CLKPRD_I  (55)    //差值





    // 


);

    
    
    
endmodule
