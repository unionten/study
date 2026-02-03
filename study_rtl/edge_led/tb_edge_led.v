`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/01/15 17:01:06
// Design Name: 
// Module Name: tb_edge_led
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


module tb_edge_led(

    );
    
    

reg clk ;
reg pos;

  
edge_led
#( .C_CLK_PRD_NS(200),
   .C_FLICKER_PRD_MS (1))
edge_led_u
(
.CLK_I      (clk),
.RSTN_I     (1),
.POS_I      (pos),//___|——|_____
.FLICKER_O  (FLICKER_O)// 检测到一个上沿时，灯闪烁一下
);

always #2 clk = ~clk ;

initial begin
clk = 0;
pos = 0;
#200;
pos = 1 ;
#200;
pos = 0;

#30000;
pos = 1 ;
#200;
pos = 0;



end


endmodule




