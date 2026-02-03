`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/02/29 10:14:05
// Design Name: 
// Module Name: tb_drp_cconverter
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


module tb_drp_cconverter(

    );
    
    reg en;
    reg rdy;
    reg we ;
    reg clk1 ;
    reg clk2 , rst1 ,rst2 ;
drp_cconverter uut(
.S_DRPCLK_I  (clk1),
.S_DRPRST_I  (rst1),
.S_DRPADDR_I (231),
.S_DRPDI_I   (1231),
.S_DRPDO_O   (),
.S_DRPEN_I   (en),
.S_DRPWE_I   (we),
.S_DRPRDY_O  (),
.M_DRPCLK_I  (clk2),
.M_DRPRST_I  (rst2),
.M_DRPADDR_O (),
.M_DRPDI_O   (),
.M_DRPDO_I   (4356345),
.M_DRPEN_O   (),
.M_DRPWE_O   (),
.M_DRPRDY_I  (rdy)

);


always #5 clk1 = ~clk1;
always #2 clk2 = ~clk2;

initial begin
    en = 0;
    we = 0;
    rdy = 0;
    clk1 = 0;
    clk2 = 0;
    rst1 = 1;
    rst2 = 1;
    #200;
    rst1 = 0;
    rst2 = 0;
    #201;
    
    en = 1;
    we = 1;
    #10;
    en = 0;
    #200;
    
    rdy = 1;
    #6;
    rdy = 0;




end

    
    
    
endmodule
