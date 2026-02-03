`timescale 1ns / 1ps
`define DELAY_OUTGEN(clk,rst,data_in,data_out,DATA_WIDTH,DLY)                                           generate if(DLY==0)begin  assign data_out = data_in; end  else if(DLY==1)begin  reg [DATA_WIDTH-1:0] a_temp = 0; always@(posedge clk) a_temp <= data_in; assign data_out = a_temp ; end  else begin  reg [DATA_WIDTH-1:0] a_temp [DLY-1:0] ;always@(posedge clk) begin  if(rst)a_temp[DLY-1] <= 0; else   a_temp[DLY-1] <= data_in; end  for(i=0;i<=DLY-2;i=i+1)begin  always@(posedge clk)begin  if(rst)begin  a_temp[i] <= 0; end  else begin  a_temp[i] <= a_temp[i+1]; end  end  end  assign data_out = a_temp[0]; end  endgenerate



//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/10 17:15:24
// Design Name: 
// Module Name: rgb_to_yuv
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


module rgb_to_yuv(
input                         RST_I ,
input                         CLK_I ,
input                         HS_I  ,
input                         VS_I  ,
input                         DE_I  ,
input  [C_BPC*C_PORT_NUM-1:0] R_I   ,
input  [C_BPC*C_PORT_NUM-1:0] G_I   ,
input  [C_BPC*C_PORT_NUM-1:0] B_I   ,
output [C_BPC*C_PORT_NUM-1:0] Y_O   ,
output [C_BPC*C_PORT_NUM-1:0] U_O   ,
output [C_BPC*C_PORT_NUM-1:0] V_O   ,
output                        HS_O  ,
output                        VS_O  ,
output                        DE_O  


    );
   
parameter C_BPC      = 8;
parameter C_PORT_NUM = 4;
parameter C_DLY      = 2;//must >=2

genvar i;  

generate for(i=0;i<=(C_PORT_NUM-1);i=i+1)begin
rgb2yuv 
    #(.C_BPC(C_BPC),
      .C_DLY(C_DLY))
    rgb2yuv_u(
    .RST_I (RST_I ),
    .CLK_I (CLK_I ),       
    .R_I   (R_I[i*C_BPC+:C_BPC]),
    .G_I   (G_I[i*C_BPC+:C_BPC]),
    .B_I   (B_I[i*C_BPC+:C_BPC]),
    .Y_O   (Y_O[i*C_BPC+:C_BPC]),
    .U_O   (U_O[i*C_BPC+:C_BPC]),
    .V_O   (V_O[i*C_BPC+:C_BPC])
    );
end
endgenerate


`DELAY_OUTGEN(CLK_I,RST_I,HS_I,HS_O,1,C_DLY)
`DELAY_OUTGEN(CLK_I,RST_I,VS_I,VS_O,1,C_DLY)
`DELAY_OUTGEN(CLK_I,RST_I,DE_I,DE_O,1,C_DLY)   



   
endmodule
