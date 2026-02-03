`timescale 1ns / 1ps
`define SINGLE_TO_BI_Nm1To0(a,b,in,out)       generate for(i=1;i<=b;i=i+1)begin assign out[b-i] = in[a*b-1-(a-1)*(i-1)-(i-1):a*b-1-(a-1)*(i)-(i-1)];end endgenerate
`define BI_TO_SINGLE_Nm1To0(a,b,in,out)       generate for(i=1;i<=b;i=i+1)begin assign out[a*b-1-(a-1)*(i-1)-(i-1):a*b-1-(a-1)*(i)-(i-1)] = in[b-i];end endgenerate
`define SINGLE_TO_TRI_Nm1To0(a,b,c,in,out)    generate for(i=1;i<=b;i=i+1)begin for(j=1;j<=c;j=j+1)begin assign out[b-i][c-j] = in[a*b*c-1-(a-1)* ((i-1)*c+(j-1)) - ((i-1)*c+(j-1)) :a*b*c-1-(a-1)* ((i-1)*c+(j-1)+1) - ((i-1)*c+(j-1)) ];end end endgenerate
`define TRI_TO_SINGLE_Nm1To0(a,b,c,in,out)    generate for(i=1;i<=b;i=i+1)begin for(j=1;j<=c;j=j+1)begin assign out[a*b*c-1-(a-1)* ((i-1)*c+(j-1)) - ((i-1)*c+(j-1)) :a*b*c-1-(a-1)* ((i-1)*c+(j-1)+1) - ((i-1)*c+(j-1)) ] = in[b-i][c-j];end end endgenerate
`define SINGLE_TO_FOUR_Nm1To0(a,b,c,d,in,out) generate for(i=1;i<=b;i=i+1)begin for(j=1;j<=c;j=j+1)begin for(k=1;k<=d;k=k+1)begin assign out[b-i][c-j][d-k] = in[(b-i)*(c*d*a)-1 +(c-j)*(d*a) +(d-k)*a +(a-1)+1:(b-i)*(c*d*a)-1 +(c-j)*(d*a) +(d-k)*a+1]; end end end endgenerate
`define FOUR_TO_SINGLE_Nm1To0(a,b,c,d,in,out) generate for(i=1;i<=b;i=i+1)begin for(j=1;j<=c;j=j+1)begin for(k=1;k<=d;k=k+1)begin assign out[(b-i)*(c*d*a)-1 +(c-j)*(d*a) +(d-k)*a +(a-1)+1:(b-i)*(c*d*a)-1 +(c-j)*(d*a) +(d-k)*a+1] = in[b-i][c-j][d-k]; end end end endgenerate


//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:  yzhu
// 
// Create Date: 2023/06/22 20:23:15
// Design Name: 
// Module Name: reconcat2
// Project Name: 
// Target Devices: 
//////////////////////////////////////////////////////////////////////////////////
/*
reconcat2
    #(.C_MAX_PORT_NUM(),
      .C_MAX_BPC     (),
      .C_DDR_PIXEL_MAX_BYTE_NUM())
    reconcat2_u(
    .PIXEL_VS_I    () ,
    .PIXEL_HS_I    () ,
    .PIXEL_DE_I    () ,
    .PIXEL_VS_O    () ,
    .PIXEL_HS_O    () ,
    .PIXEL_DE_O    () ,
    .PIXEL_DATA_I  () ,  // [C_MAX_BPC*3*C_MAX_PORT_NUM-1:0]  {R10  G10   B10},{R10  G10   B10},{R10  G10   B10},{R10  G10   B10}
    .PIXEL_DATA_O  ()    // [C_DDR_PIXEL_MAX_BYTE_NUM*8*C_MAX_PORT_NUM-1:0]  {R10  G10   B10  2'b0},{R10  G10   B10  2'b0},{R10  G10   B10  2'b0},{R10  G10   B10  2'b0}
    );                                                              // or{R10  G6},{R10  G6},{R10  G6},{R10  G6}

*/


//对已经是 像素内紧凑 的输入，“对每个像素数据内”，进行机械的补0或者削减
module reconcat2(
input                                  PIXEL_VS_I,
input                                  PIXEL_HS_I,
input                                  PIXEL_DE_I,
output                                  PIXEL_VS_O,
output                                  PIXEL_HS_O,
output                                  PIXEL_DE_O,
input  [C_MAX_BPC*3*C_MAX_PORT_NUM-1:0]  PIXEL_DATA_I, //   {R10  G10   B10},{R10  G10   B10},{R10  G10   B10},{R10  G10   B10}
output [C_DDR_PIXEL_MAX_BYTE_NUM*8*C_MAX_PORT_NUM-1:0]  PIXEL_DATA_O//   {R10  G10   B10  2'b0},{R10  G10   B10  2'b0},{R10  G10   B10  2'b0},{R10  G10   B10  2'b0}
    );                                                              // or{R10  G6},{R10  G6},{R10  G6},{R10  G6}

parameter  C_MAX_PORT_NUM =  4;
parameter  C_MAX_BPC      =  8;
parameter  C_DDR_PIXEL_MAX_BYTE_NUM = 4;

localparam C_TEMP_BYTE_NUM = (C_MAX_BPC*3/8) < C_DDR_PIXEL_MAX_BYTE_NUM ? (C_MAX_BPC*3/8) : C_DDR_PIXEL_MAX_BYTE_NUM;


genvar i,j,k;

assign PIXEL_VS_O  = PIXEL_VS_I ;
assign PIXEL_HS_O  = PIXEL_HS_I ;
assign PIXEL_DE_O  = PIXEL_DE_I ;



wire [C_MAX_BPC*3-1:0] pixel_data_i_m  [C_MAX_PORT_NUM-1:0]; 
`SINGLE_TO_BI_Nm1To0((C_MAX_BPC*3),C_MAX_PORT_NUM,PIXEL_DATA_I,pixel_data_i_m)

wire [C_DDR_PIXEL_MAX_BYTE_NUM*8-1:0]  pixel_data_o_m [C_MAX_PORT_NUM-1:0]; 

generate for(i=0;i<=C_MAX_PORT_NUM-1;i=i+1)begin
    assign pixel_data_o_m[i] = {0,pixel_data_i_m[i][C_TEMP_BYTE_NUM*8-1:0]}; //好像这里不需要这么判断，直接赋值就好了
    
end
endgenerate


`BI_TO_SINGLE_Nm1To0((C_DDR_PIXEL_MAX_BYTE_NUM*8),C_MAX_PORT_NUM,pixel_data_o_m,PIXEL_DATA_O) 
 
    
endmodule
