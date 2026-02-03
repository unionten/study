`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/25 17:48:41
// Design Name: 
// Module Name: tb_pattern
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


module tb_pattern(

    );

parameter C_PORT_NUM = 4;

reg rst;
reg clk;
reg vs;
reg hs;
reg de;


wire [C_PORT_NUM-1:0] VS_O ;
wire [C_PORT_NUM-1:0] HS_O ;
wire [C_PORT_NUM-1:0] DE_O ;
wire [C_PORT_NUM*8-1:0] R_O  ;
wire [C_PORT_NUM*8-1:0] G_O  ;
wire [C_PORT_NUM*8-1:0] B_O  ;


always #5 clk = ~clk;


initial begin
rst = 1;
clk = 0;
vs  = 0;
hs  = 0;
de  = 0;
#200;
rst = 0;
#2000;
vs = 1;
#200;
vs= 0;
#1000;
de = 1;
#1000;
de = 0;
#200;
hs = 1;
#100;
hs = 0;
#400;
de = 1;
#1000;
de = 0;


end


  
pattern  
    #(.C_PORT_NUM(C_PORT_NUM))
    pattern_u(
    .CLK_I(clk),
    .RST_I(rst),
    .VS_I (vs),
    .HS_I (hs),
    .DE_I (de),
    .VS_O (VS_O ),
    .HS_O (HS_O ),
    .DE_O (DE_O ),
    .R_O  (R_O  ),
    .G_O  (G_O  ),
    .B_O  (B_O  )

);

    
    
endmodule
