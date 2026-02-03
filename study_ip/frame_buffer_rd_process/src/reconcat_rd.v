`define DELAY_OUTGEN(clk,rst,data_in,data_out,DATA_WIDTH,DLY)                                           generate if(DLY==0)begin  assign data_out = data_in; end  else if(DLY==1)begin  reg [DATA_WIDTH-1:0] a_temp = 0; always@(posedge clk) a_temp <= data_in; assign data_out = a_temp ; end  else begin  reg [DATA_WIDTH-1:0] a_temp [DLY-1:0] ;always@(posedge clk) begin  if(rst)a_temp[DLY-1] <= 0; else   a_temp[DLY-1] <= data_in; end  for(i=0;i<=DLY-2;i=i+1)begin  always@(posedge clk)begin  if(rst)begin  a_temp[i] <= 0; end  else begin  a_temp[i] <= a_temp[i+1]; end  end  end  assign data_out = a_temp[0]; end  endgenerate

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/14 08:16:05
// Design Name: 
// Module Name: reconcat_rd
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


module reconcat_rd(
input  CLK_I      ,
input  RST_I      ,
input  PIXEL_VS_I ,
input  PIXEL_HS_I ,
input  PIXEL_DE_I ,
input  PIXEL_DE_I_TOTAL ,
input  [C_DDR_PIXEL_MAX_BYTE_NUM*8*C_MAX_PORT_NUM-1:0] PIXEL_DATA_I ,//像素紧凑   [XXX8b8b8b,XXX8b8b8b,XXX8b8b8b,XXX8b8b8b]
input [7:0] ACTUAL_DDR_BYTE_NUM_I,// control stage 1 ; mean how to analyze PIXEL_DATA_I
input [3:0] TARGET_BPC_I,//control stage 3 ; mean how to analyze PIXEL_DATA_I
output PIXEL_VS_O,
output PIXEL_HS_O,
output PIXEL_DE_O,
output PIXEL_DE_O_TOTAL,
output [C_MAX_BPC*3*C_MAX_PORT_NUM-1:0] PIXEL_DATA_O // {R G B } or  {0 U Y } or {U Y Y}/{V Y Y} 读出时不关心RGB还是YUV, 如果内存格式为YUYV，此处也一样满足{0UY}
//注意这里借鉴frame_wr的完全对称的做法
 //note : how to analyze C_MAX_BPC*3
);

parameter  C_MAX_PORT_NUM           = 4;
parameter  C_DDR_PIXEL_MAX_BYTE_NUM = 4;
parameter  C_MAX_BPC                = 8 ;


genvar i,j,k;



wire vs1;
wire hs1;
wire de1;
wire vs2;
wire hs2;
wire de2;

wire [C_DDR_PIXEL_MAX_BYTE_NUM*8*C_MAX_PORT_NUM-1:0] pixel_temp1;
wire [C_MAX_BPC*3*C_MAX_PORT_NUM-1:0] pixel_temp2;

`DELAY_OUTGEN(CLK_I,0,PIXEL_DE_I_TOTAL,PIXEL_DE_O_TOTAL,1,2)

reconcat_1
    #(.C_MAX_PORT_NUM           (C_MAX_PORT_NUM),
      .C_DDR_PIXEL_MAX_BYTE_NUM (C_DDR_PIXEL_MAX_BYTE_NUM)) 
    reconcat_1_u(
.CLK_I      (CLK_I ),
.RST_I      (RST_I ),
.ACTUAL_DDR_BYTE_NUM_I(ACTUAL_DDR_BYTE_NUM_I), //[7:0] 
.PIXEL_VS_I (PIXEL_VS_I),
.PIXEL_HS_I (PIXEL_HS_I),  
.PIXEL_DE_I (PIXEL_DE_I),  
.PIXEL_DATA_I(PIXEL_DATA_I),// [C_DDR_PIXEL_MAX_BYTE_NUM*8*C_MAX_PORT_NUM-1:0] 像素紧凑
.PIXEL_VS_O (vs1),
.PIXEL_HS_O (hs1),
.PIXEL_DE_O (de1),
.PIXEL_DATA_O(pixel_temp1)  // [C_DDR_PIXEL_MAX_BYTE_NUM*8*C_MAX_PORT_NUM-1:0] 最大（DDR内实际存的最大像素宽度）
    );

    
//【切成接口】
reconcat_2 //每个像素 切分 C_MAX_BPC*3*C_MAX_PORT_NUM (像素内紧凑)
    #(.C_MAX_PORT_NUM (C_MAX_PORT_NUM),
      .C_MAX_BPC      (C_MAX_BPC),
      .C_DDR_PIXEL_MAX_BYTE_NUM (C_DDR_PIXEL_MAX_BYTE_NUM)) 
    reconcat_2_u
(
.PIXEL_VS_I(vs1),
.PIXEL_HS_I(hs1),
.PIXEL_DE_I(de1),
.PIXEL_DATA_I(pixel_temp1),//  [C_DDR_PIXEL_MAX_BYTE_NUM*8*C_MAX_PORT_NUM-1:0] 最大        {R10  G10   B10  2'b0},{R10  G10   B10  2'b0},{R10  G10   B10  2'b0},{R10  G10   B10  2'b0}
.PIXEL_VS_O(vs2),
.PIXEL_HS_O(hs2),
.PIXEL_DE_O(de2),
.PIXEL_DATA_O(pixel_temp2) // [C_MAX_BPC*3*C_MAX_PORT_NUM-1:0] native端    {R10  G10   B10},{R10  G10   B10},{R10  G10   B10},{R10  G10   B10}
                                                                     //          or{R10  G6},{R10  G6},{R10  G6},{R10  G6}

);                                                             



//【像素分量展开】
reconcat_3 //像素内紧凑 拓展为 每个像素展开
#( .C_MAX_PORT_NUM (C_MAX_PORT_NUM),       //valid: 1 2 4 8
   .C_MAX_BPC      (C_MAX_BPC))       //valid : 6 8 10 12 16
reconcat_3_u
(
.RST_I(RST_I),
.CLK_I(CLK_I),
.TARGET_BPC_I(TARGET_BPC_I),//[3:0]
.PIXEL_VS_I(vs2),
.PIXEL_HS_I(hs2),
.PIXEL_DE_I(de2), 
.PIXEL_DATA_O(PIXEL_DATA_O),  // [C_MAX_BPC*3*C_MAX_PORT_NUM-1:0]  例如，将6位色深填充为10位，适配native接口 //{R10  G10   B10},{R10  G10   B10},{R10  G10   B10},{R10  G10   B10
.PIXEL_VS_O(PIXEL_VS_O),
.PIXEL_HS_O(PIXEL_HS_O),
.PIXEL_DE_O(PIXEL_DE_O),
.PIXEL_DATA_I (pixel_temp2)//  [C_MAX_BPC*3*C_MAX_PORT_NUM-1:0]  输入为像素内紧凑数据
                                                      //   {R10  G10   B10},{R10  G10   B10},{R10  G10   B10},{R10  G10   B10}
                                                      //   {R8 G8 B8  6'b0},{R8 G8 B8  6'b0},{R8 G8 B8  6'b0},{R8 G8 B8  6'b0}  
                                                      //or {R6 G6 B6 12'b0},{R6 G6 B6 12'b0},{R6 G6 B6 12'b0},{R6 G6 B6 12'b0} 
);



endmodule



