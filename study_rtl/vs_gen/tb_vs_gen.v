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


module tb_vs_gen(

    );
    
    
vs_gen   
#(.CLK_CYCLE_NUM_1(500),
.CLK_CYCLE_NUM_2  (10),
.CLK_CYCLE_NUM_3  (5000))

uuu
(
. PCLK_I  (clk ),
. RSTN_I (1),
. DE_I   (de),
.  VS_O  (vs)
);

reg clk ;
reg de ;


always #5 clk = ~clk ;

initial begin
clk = 0;
de = 0;
#5000;
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




end


    
    
endmodule
