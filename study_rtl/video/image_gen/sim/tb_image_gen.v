`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/05/09 16:55:19
// Design Name: 
// Module Name: tb_image_gen
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


module tb_image_gen(

    );

reg clk_50;
reg clk_200;
reg rst;

wire [3:0] lvds_clk_p ;
wire [3:0] lvds_clk_n ;
wire [15:0] lvds_data_p;
wire [15:0] lvds_data_n;


 
image_gen_top uut(
.CLK_50M_I(clk_50),
.RESET_I(rst),
.lvds_clk_p (lvds_clk_p) ,//[PORT_NUM-1:0]
.lvds_clk_n (lvds_clk_n) ,//[PORT_NUM-1:0] 
.lvds_data_p(lvds_data_p),//[LANE_NUM*PORT_NUM-1:0]
.lvds_data_n(lvds_data_n)//[LANE_NUM*PORT_NUM-1:0]

);  


image_parse_top
#( .PIXELS_PER_CLOCK ( 4 ))
uut2
(
.ref_clk(clk_200),//200M
.rst(rst),
.lvds_clk_p(lvds_clk_p),
.lvds_clk_n(lvds_clk_n),
.lvds_data_p(lvds_data_p),
.lvds_data_n(lvds_data_n),
.pixel_clk_o(pixel_clk),
.pixel_clk_locked_o(pixel_clk_locked),
.de_o(),
.vs_o(),
.hs_o(),
.r_o(),
.g_o(),
.b_o()

);


  
always #2.5 clk_200 = ~clk_200;
always #20 clk_50 = ~clk_50;
  
initial begin
rst=1;
clk_50=0;
clk_200 = 0;
#500;
rst =0;


   
    
end   
    
    
endmodule
