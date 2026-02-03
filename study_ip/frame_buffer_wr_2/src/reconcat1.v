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
// Create Date: 2023/06/22 18:35:27
// Design Name: 
// Module Name: reconcat
// Project Name: 
// Target Devices: 
//////////////////////////////////////////////////////////////////////////////////
/*
reconcat1
    #(.C_MAX_PORT_NUM(),  //valid: 1 2 4 8
      .C_MAX_BPC     ())  //valid : 6 8 10 12 16
    reconcat1_u  (
    .RST_I         () ,
    .CLK_I         () ,
    .TARGET_BPC_I  () , //[3:0]
    .PIXEL_VS_I    () ,
    .PIXEL_HS_I    () ,
    .PIXEL_DE_I    () ,
    .PIXEL_DATA_I  () ,//[C_MAX_BPC*3*C_MAX_PORT_NUM-1:0]  {R10  G10   B10},{R10  G10   B10},{R10  G10   B10},{R10  G10   B10}
    .PIXEL_VS_O    () ,
    .PIXEL_HS_O    () ,
    .PIXEL_DE_O    () ,
    .PIXEL_DATA_O  () //[C_MAX_BPC*3*C_MAX_PORT_NUM-1:0]   {R10  G10   B10},{R10  G10   B10},{R10  G10   B10},{R10  G10   B10}
                                                     //   {R8 G8 B8  6'b0},{R8 G8 B8  6'b0},{R8 G8 B8  6'b0},{R8 G8 B8  6'b0}  
                                                     //or {R6 G6 B6 12'b0},{R6 G6 B6 12'b0},{R6 G6 B6 12'b0},{R6 G6 B6 12'b0} 
    );
*/
//模块功能：输出宽度相对于输入宽度不变，但是按照实际色深，实现像素内紧凑排布
module reconcat1(
input                                  RST_I,
input                                  CLK_I,
input   [3:0]                          TARGET_BPC_I,
input                                  PIXEL_VS_I,
input                                  PIXEL_HS_I,
input                                  PIXEL_DE_I,
input   [C_MAX_BPC*3*C_MAX_PORT_NUM-1:0] PIXEL_DATA_I,//{R10  G10   B10},{R10  G10   B10},{R10  G10   B10},{R10  G10   B10}
output   reg                            PIXEL_VS_O=0,
output   reg                            PIXEL_HS_O=0,
output   reg                            PIXEL_DE_O=0,
output  [C_MAX_BPC*3*C_MAX_PORT_NUM-1:0] PIXEL_DATA_O//   {R10  G10   B10},{R10  G10   B10},{R10  G10   B10},{R10  G10   B10}
                                                     //   {R8 G8 B8  6'b0},{R8 G8 B8  6'b0},{R8 G8 B8  6'b0},{R8 G8 B8  6'b0}  
                                                     //or {R6 G6 B6 12'b0},{R6 G6 B6 12'b0},{R6 G6 B6 12'b0},{R6 G6 B6 12'b0} 
);

parameter C_MAX_PORT_NUM        = 1;//valid: 1 2 4 8
parameter C_MAX_BPC             = 6;//valid : 6 8 10 12 16

genvar i,j,k;

always@(posedge CLK_I)PIXEL_VS_O <= PIXEL_VS_I;
always@(posedge CLK_I)PIXEL_HS_O <= PIXEL_HS_I;
always@(posedge CLK_I)PIXEL_DE_O <= PIXEL_DE_I;


wire [C_MAX_BPC-1:0] pixel_data_i_m [C_MAX_PORT_NUM-1:0][2:0];
`SINGLE_TO_TRI_Nm1To0((C_MAX_BPC),C_MAX_PORT_NUM,3,PIXEL_DATA_I,pixel_data_i_m)

reg [C_MAX_BPC*3-1:0] pixel_data_o_m [C_MAX_PORT_NUM-1:0];



generate for(i=0;i<=C_MAX_PORT_NUM-1;i=i+1)begin
    always@(posedge CLK_I)begin
        if(RST_I)begin
            pixel_data_o_m[i] <= 0;
        end
        else begin
            case(TARGET_BPC_I)
                //if you want to reduse resource, you can deleate some entrys
                6 :pixel_data_o_m[i] <= C_MAX_BPC>=6 ? {0,pixel_data_i_m[i][2][5:0],pixel_data_i_m[i][1][5:0],pixel_data_i_m[i][0][5:0]}:   pixel_data_o_m[i]; 
                8 :pixel_data_o_m[i] <= C_MAX_BPC>=8 ? {0,pixel_data_i_m[i][2][7:0],pixel_data_i_m[i][1][7:0],pixel_data_i_m[i][0][7:0]}:    pixel_data_o_m[i];    
                10:pixel_data_o_m[i] <= C_MAX_BPC>=10 ?  {0,pixel_data_i_m[i][2][9:0],pixel_data_i_m[i][1][9:0],pixel_data_i_m[i][0][9:0]}:   pixel_data_o_m[i]; 
                12:pixel_data_o_m[i] <= C_MAX_BPC>=12 ?  {0,pixel_data_i_m[i][2][11:0],pixel_data_i_m[i][1][11:0],pixel_data_i_m[i][0][11:0]}:pixel_data_o_m[i];
                16:pixel_data_o_m[i] <= C_MAX_BPC>=16 ?  {0,pixel_data_i_m[i][2][15:0],pixel_data_i_m[i][1][15:0],pixel_data_i_m[i][0][15:0]}:pixel_data_o_m[i];  
                default:; // doing nothing will consume the least resource
            endcase
        end
    end
end
endgenerate


`BI_TO_SINGLE_Nm1To0((C_MAX_BPC*3),C_MAX_PORT_NUM,pixel_data_o_m,PIXEL_DATA_O)


    
endmodule
