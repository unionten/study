`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/16 19:08:39
// Design Name: 
// Module Name: tb_vs_gen
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


module tb_hs_gen(

    );
    
    
hs_gen   
#(.PCLK_CYCLE_NUM_1(10),
.PCLK_CYCLE_NUM_2  (2),
.PCLK_CYCLE_NUM_3  (5))

uuu
(
. PCLK_I  (clk ),
. RSTN_I (1),
.VS_I   (vs),
. DE_I   (de),
.  HS_O  (hs)
);

reg clk ;
reg de ;
reg vs ;

always #5 clk = ~clk ;

initial begin
vs = 0 ;
clk = 0;
de = 0;
#5000;
vs =1;
#200;
vs = 0;

de = 1 ;
#400;
de = 0 ;
#400;
de =1 ;
#300;
de = 0;
#600;
de = 1 ;
#400;
de= 0;

#2000;

vs = 1;
#200;
vs= 0;
#2000;

de = 1;
#200;
de = 0;




end


    
    
endmodule
