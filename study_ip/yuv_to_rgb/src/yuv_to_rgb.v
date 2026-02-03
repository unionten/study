`timescale 1ns / 1ps
`define DELAY_OUTGEN(clk,rst,data_in,data_out,DATA_WIDTH,DLY)                                           generate if(DLY==0)begin  assign data_out = data_in; end  else if(DLY==1)begin  reg [DATA_WIDTH-1:0] a_temp = 0; always@(posedge clk) a_temp <= data_in; assign data_out = a_temp ; end  else begin  reg [DATA_WIDTH-1:0] a_temp [DLY-1:0] ;always@(posedge clk) begin  if(rst)a_temp[DLY-1] <= 0; else   a_temp[DLY-1] <= data_in; end  for(i=0;i<=DLY-2;i=i+1)begin  always@(posedge clk)begin  if(rst)begin  a_temp[i] <= 0; end  else begin  a_temp[i] <= a_temp[i+1]; end  end  end  assign data_out = a_temp[0]; end  endgenerate


//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/10 09:40:35
// Design Name: 
// Module Name: yuv_to_rgb 
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


module yuv_to_rgb(
input                          CLK_I ,
input                          RST_I ,
input                          HS_I  ,
input                          VS_I  ,
input                          DE_I  ,
input  [C_BPC*C_PORT_NUM-1:0]  Y_I   ,
input  [C_BPC*C_PORT_NUM-1:0]  U_I   ,
input  [C_BPC*C_PORT_NUM-1:0]  V_I   ,
output                         HE_O  ,
output                         VS_O  ,
output                         DE_O  ,
output [C_BPC*C_PORT_NUM-1:0]  R_O   ,
output [C_BPC*C_PORT_NUM-1:0]  G_O   ,
output [C_BPC*C_PORT_NUM-1:0]  B_O   


 );
   
parameter C_BPC      = 8;
parameter C_PORT_NUM = 4;
parameter C_DLY      = 3;//must >=3



yuv_rgb  yuv_rgb_u( //stage 2
	.vid_clk  (CLK_I  ),
	.vid_rst  (RST_I  ),
	.RGB_Y    (Y_I ), //[31:0]
	.RGB_U    (U_I ), 
	.RGB_V    (V_I ),
	.TPG_HS   (HS_I),
	.TPG_VS   (VS_I),
	.TPG_DE   (DE_I),
    
	.HS       (HE_O ),
	.VS       (VS_O ),
	.DE       (DE_O ),
	.R        (R_O), //[31:0]
	.G        (G_O),
	.B        (B_O),         
	.data_rgb () //[95:0]
);

/*

genvar i;  


wire  [C_BPC*C_PORT_NUM-1:0]  R_O_s3   ;
wire  [C_BPC*C_PORT_NUM-1:0]  G_O_s3   ;
wire  [C_BPC*C_PORT_NUM-1:0]  B_O_s3   ;



generate for(i=0;i<=(C_PORT_NUM-1);i=i+1)begin
yuv2rgb  //delay = 3
    #(.C_BPC ( C_BPC ) )// for timing closure
    yuv2rgb_core(
    .CLK_I  (CLK_I ),  
    .RST_I  (RST_I ),
    .Y_I    (Y_I[i*C_BPC+:C_BPC] ),  //[C_BPC-1:0]  
    .U_I    (U_I[i*C_BPC+:C_BPC]   ),  //[C_BPC-1:0]  
    .V_I    (V_I[i*C_BPC+:C_BPC]   ),  //[C_BPC-1:0]  
    .R_O    (R_O_s3[i*C_BPC+:C_BPC]   ),  //[C_BPC-1:0]  
    .G_O    (G_O_s3[i*C_BPC+:C_BPC]   ),  //[C_BPC-1:0]  
    .B_O    (B_O_s3[i*C_BPC+:C_BPC]  )   //[C_BPC-1:0]  
    );
end
endgenerate


`DELAY_OUTGEN(CLK_I,RST_I,HS_I,HE_O,1,C_DLY)
`DELAY_OUTGEN(CLK_I,RST_I,VS_I,VS_O,1,C_DLY)
`DELAY_OUTGEN(CLK_I,RST_I,DE_I,DE_O,1,C_DLY)

`DELAY_OUTGEN(CLK_I,RST_I,R_O_s3,R_O,(C_BPC*C_PORT_NUM),C_DLY-3)
`DELAY_OUTGEN(CLK_I,RST_I,G_O_s3,G_O,(C_BPC*C_PORT_NUM),C_DLY-3)
`DELAY_OUTGEN(CLK_I,RST_I,B_O_s3,B_O,(C_BPC*C_PORT_NUM),C_DLY-3)
*/

    
    
    
endmodule
