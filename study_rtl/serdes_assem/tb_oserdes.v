`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/01/18 17:54:57
// Design Name: 
// Module Name: tb_oserdes
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


module tb_oserdes(

    );
localparam FAST_PRD   = 10.0;
reg [7:0] D;
wire OQ;
wire TQ;
reg CLK;
reg CLK_DIV;
reg RST;


parameter DEVICE     = "A7";
parameter DATA_WIDTH = 8;
parameter DATA_RATE  = "DDR" ;


localparam DIV        = DATA_WIDTH / (DATA_RATE=="DDR" ? 2 : 1) ;


oserdes  
#(.C_DEVICE     ( DEVICE ) ,//"KU" "KUP" "A7" "K7"
  .C_DATA_RATE  ( DATA_RATE) ,
  .C_DATA_WIDTH (DATA_WIDTH      ) )
   oserdes_u(
   .D_I       (D),
   .T_I       (0),
   .OQ_O      (OQ),
   .TQ_O      (TQ),
   .CLK_I     (CLK),
   .CLKDIV_I  (CLK_DIV),
   .RST_I     (RST)

    );

wire [7:0] Q_O;
iserdes  
#(.C_DEVICE     ( DEVICE ),//"KU" "KUP" "A7" "K7"
  .C_DATA_RATE  ( DATA_RATE ),
  .C_DATA_WIDTH ( DATA_WIDTH     ))
iserdes_u(
.CLK_I     (CLK),
.CLKDIV_I  (CLK_DIV),
.BITSLIP_I (0),
.RST_I     (RST),  
.D_I       (OQ),
.Q_O       (Q_O)

 );




always #(FAST_PRD/2.0) CLK = ~CLK;
always #(FAST_PRD/2.0*DIV) CLK_DIV = ~CLK_DIV;


initial begin
    RST =1;
    CLK = 1;
    CLK_DIV = 1;
D = 8'b00110010;

#2000;
RST = 0;


end

 
    
    
    
    
endmodule
