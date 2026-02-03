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
// Create Date: 2023/07/13 13:03:12
// Design Name: 
// Module Name: reconcat_1
// Project Name: 
// Target Devices: 
// Tool Versions: 
//////////////////////////////////////////////////////////////////////////////////

//rd  reconcat 
module reconcat_1(
input CLK_I ,
input RST_I ,
input [7:0]                                   ACTUAL_DDR_BYTE_NUM_I, //该参数用于指示，如何理解ddr收到的数据
input                                                 PIXEL_DE_I   ,  
input                                                 PIXEL_HS_I   ,  
input                                                 PIXEL_VS_I   ,  
input [C_DDR_PIXEL_MAX_BYTE_NUM*8*C_MAX_PORT_NUM-1:0] PIXEL_DATA_I ,//紧凑
output reg                                            PIXEL_DE_O =0  ,
output reg                                            PIXEL_HS_O =0  ,
output reg                                            PIXEL_VS_O =0  ,
output reg [C_DDR_PIXEL_MAX_BYTE_NUM*8*C_MAX_PORT_NUM-1:0] PIXEL_DATA_O = 0  //展开
    );
parameter  C_MAX_PORT_NUM           = 4;
parameter  C_DDR_PIXEL_MAX_BYTE_NUM = 4;

genvar i,j,k;

// {xxxxxxxxxxxxxxxxxxaabbccdd} -> {xxxxaaxxxxxbbxxxxxxccxxxxxxdd} //xxxx 为无效值
// 思路：将左侧右移后即可填入 pixel_data_m_o 中
wire [C_DDR_PIXEL_MAX_BYTE_NUM*8-1:0] pixel_data_m_o [C_MAX_PORT_NUM-1:0];

generate for(i=0;i<=C_MAX_PORT_NUM-1;i=i+1)begin
    assign pixel_data_m_o[i] =  PIXEL_DATA_I>>ACTUAL_DDR_BYTE_NUM_I*8*i;
end
endgenerate

wire  [C_DDR_PIXEL_MAX_BYTE_NUM*8*C_MAX_PORT_NUM-1:0]  pixel_data_o_reg;

`BI_TO_SINGLE_Nm1To0((C_DDR_PIXEL_MAX_BYTE_NUM*8),C_MAX_PORT_NUM,pixel_data_m_o,pixel_data_o_reg)

always@(posedge CLK_I)begin
    if(RST_I)begin
        PIXEL_DATA_O <= 0;
    end
    else begin
        PIXEL_DATA_O <= pixel_data_o_reg;   
    end
end


always@(posedge CLK_I)begin
    if(RST_I)begin
        PIXEL_DE_O <= 0;
        PIXEL_HS_O <= 0;
        PIXEL_VS_O <= 0;
    end
    else begin
        PIXEL_DE_O <= PIXEL_DE_I;
        PIXEL_HS_O <= PIXEL_HS_I;
        PIXEL_VS_O <= PIXEL_VS_I;
    end
    
end

    
endmodule



