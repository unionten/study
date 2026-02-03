`timescale 1ns / 1ps
`define SINGLE_TO_BI_Nm1To0(a,b,in,out)       generate for(i=1;i<=b;i=i+1)begin assign out[b-i] = in[a*b-1-(a-1)*(i-1)-(i-1):a*b-1-(a-1)*(i)-(i-1)];end endgenerate
`define BI_TO_SINGLE_Nm1To0(a,b,in,out)       generate for(i=1;i<=b;i=i+1)begin assign out[a*b-1-(a-1)*(i-1)-(i-1):a*b-1-(a-1)*(i)-(i-1)] = in[b-i];end endgenerate
`define SINGLE_TO_TRI_Nm1To0(a,b,c,in,out)    generate for(i=1;i<=b;i=i+1)begin for(j=1;j<=c;j=j+1)begin assign out[b-i][c-j] = in[a*b*c-1-(a-1)* ((i-1)*c+(j-1)) - ((i-1)*c+(j-1)) :a*b*c-1-(a-1)* ((i-1)*c+(j-1)+1) - ((i-1)*c+(j-1)) ];end end endgenerate
`define TRI_TO_SINGLE_Nm1To0(a,b,c,in,out)    generate for(i=1;i<=b;i=i+1)begin for(j=1;j<=c;j=j+1)begin assign out[a*b*c-1-(a-1)* ((i-1)*c+(j-1)) - ((i-1)*c+(j-1)) :a*b*c-1-(a-1)* ((i-1)*c+(j-1)+1) - ((i-1)*c+(j-1)) ] = in[b-i][c-j];end end endgenerate
`define SINGLE_TO_FOUR_Nm1To0(a,b,c,d,in,out) generate for(i=1;i<=b;i=i+1)begin for(j=1;j<=c;j=j+1)begin for(k=1;k<=d;k=k+1)begin assign out[b-i][c-j][d-k] = in[(b-i)*(c*d*a)-1 +(c-j)*(d*a) +(d-k)*a +(a-1)+1:(b-i)*(c*d*a)-1 +(c-j)*(d*a) +(d-k)*a+1]; end end end endgenerate
`define FOUR_TO_SINGLE_Nm1To0(a,b,c,d,in,out) generate for(i=1;i<=b;i=i+1)begin for(j=1;j<=c;j=j+1)begin for(k=1;k<=d;k=k+1)begin assign out[(b-i)*(c*d*a)-1 +(c-j)*(d*a) +(d-k)*a +(a-1)+1:(b-i)*(c*d*a)-1 +(c-j)*(d*a) +(d-k)*a+1] = in[b-i][c-j][d-k]; end end end endgenerate

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: yzhu
// 
// Create Date: 2023/07/13 13:03:34
// Design Name: 
// Module Name: reconcat_2
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//////////////////////////////////////////////////////////////////////////////////


module reconcat_2(
input                                   PIXEL_VS_I,
input                                   PIXEL_HS_I,
input                                   PIXEL_DE_I,
output                                  PIXEL_VS_O,
output                                  PIXEL_HS_O,
output                                  PIXEL_DE_O,
input  [C_DDR_PIXEL_MAX_BYTE_NUM*8*C_MAX_PORT_NUM-1:0]  PIXEL_DATA_I,//最大        {R10  G10   B10  2'b0},{R10  G10   B10  2'b0},{R10  G10   B10  2'b0},{R10  G10   B10  2'b0}
output [C_MAX_BPC*3*C_MAX_PORT_NUM-1:0]                 PIXEL_DATA_O //native端    {R10  G10   B10},{R10  G10   B10},{R10  G10   B10},{R10  G10   B10}
                                                                     //          or{R10  G6},{R10  G6},{R10  G6},{R10  G6}

);                                                             

parameter  C_MAX_PORT_NUM =  4;
parameter  C_MAX_BPC      =  8;
parameter  C_DDR_PIXEL_MAX_BYTE_NUM = 4;

genvar i,j,k;

assign PIXEL_VS_O  = PIXEL_VS_I ;
assign PIXEL_HS_O  = PIXEL_HS_I ;
assign PIXEL_DE_O  = PIXEL_DE_I ;


wire [C_DDR_PIXEL_MAX_BYTE_NUM*8-1:0] pixel_data_i_m  [C_MAX_PORT_NUM-1:0]; 
`SINGLE_TO_BI_Nm1To0((C_DDR_PIXEL_MAX_BYTE_NUM*8),C_MAX_PORT_NUM,PIXEL_DATA_I,pixel_data_i_m)

wire [C_MAX_BPC*3-1:0]  pixel_data_o_m [C_MAX_PORT_NUM-1:0]; 

generate for(i=0;i<=C_MAX_PORT_NUM-1;i=i+1)begin
    assign pixel_data_o_m[i] = {pixel_data_i_m[i]};
    
end
endgenerate


`BI_TO_SINGLE_Nm1To0((C_MAX_BPC*3),C_MAX_PORT_NUM,pixel_data_o_m,PIXEL_DATA_O) 
 
    

    
    
endmodule
