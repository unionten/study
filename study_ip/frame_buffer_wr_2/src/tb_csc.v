`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/29 11:53:00
// Design Name: 
// Module Name: tb_csc
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


module tb_csc(

    );
reg clk;
always #10 clk = ~clk ;  
 
 reg rst ;
 reg hs ;
 reg de ;
 
 

 
csc  //operates as the max scale
    #(.C_PORT_NUM(2   ),
      .C_BPC     (8        ),
      .C_RGB2YUV_EN (1  ), //control if there is rgb2yuv Module for YUV series
      .C_FIFO_EN (1 ), //control if there is fifo Module for YUV420
      .C_DLY_SRL (3 ) )  // must >= 3
    csc_u  (
    .CLK_I        (clk           ),
    .RST_I        ( rst  ),
    .OSPACE_I     (2), //output color space :  0:RGB , 1:YUV444 , 2:YUV422 , 3:YUV420 
    .VS_I         (0          ), 
    .HS_I         (hs          ),
    .DE_I         (de        ),
    .R_I          (32'hFFFFFFF              ), //exp: RRRR
    .G_I          (32'hFFFFFFF               ), //exp: GGGG
    .B_I          (0              ), //exp: BBBB
    .PIXEL_VS_O   (          ), 
    .PIXEL_HS_O   (          ), 
    .PIXEL_DE_O   (          ), 
    .PIXEL_DATA_O (      ),  //exp: {BGR}{BGR}{BGR}{BGR} ; {VUY}{VUY}{VUY}{VUY} ; {0VY}{0UY}{0VY}{0UY} ; {VYY}{UYY}{VYY}{UYY}        
    .ACTUAL_PORT_NUM_I ( 1 )    
    );


    
initial begin
     de = 0;
     hs= 0 ;
    clk = 0;
    rst = 1;
    #2000;
    rst = 0;
    #2000;
    hs = 1;
    #20;
    hs = 0;
    #400;
    
    de = 1;
    #2000;
    de = 0;






end
    
    
    
endmodule
