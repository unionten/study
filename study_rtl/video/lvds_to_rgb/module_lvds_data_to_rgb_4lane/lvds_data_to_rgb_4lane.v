`timescale 1ns / 1ps
`define SINGLE_TO_BI_RE_0(a,b,in,out)    generate for(i=1;i<=b;i=i+1)begin assign out[b-i] = in[a*b-1-(a-1)*(i-1)-(i-1):a*b-1-(a-1)*(i)-(i-1)];end endgenerate
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 2021/06/18 13:13:21
// Module Name: lvds_data_to_rgb_4lane
//////////////////////////////////////////////////////////////////////////////////
module lvds_data_to_rgb_4lane(//4*7=28,即每个像素28bit
LVDFS_DATA_I//uut_name.hs_m[i]
);                                                                                                
parameter PIXEL_NUM = 4;
localparam MODE = "VESA_RF";//"VESA_RF" or "JEIDA_RF"
//////////////////////////////////////////////////////////////////////////////////
genvar i,j,k;   
input [28*PIXEL_NUM-1:0] LVDFS_DATA_I;
//////////////////////////////////////////////////////////////////////////////////
(*keep="true"*)wire [27:0] pixel_m [0:PIXEL_NUM-1];
(*keep="true"*)wire [0:0]  hs_m    [0:PIXEL_NUM-1];
(*keep="true"*)wire [0:0]  vs_m    [0:PIXEL_NUM-1];
(*keep="true"*)wire [0:0]  de_m    [0:PIXEL_NUM-1];
(*keep="true"*)wire [7:0]  r_m     [0:PIXEL_NUM-1];
(*keep="true"*)wire [7:0]  g_m     [0:PIXEL_NUM-1];
(*keep="true"*)wire [7:0]  b_m     [0:PIXEL_NUM-1];
//////////////////////////////////////////////////////////////////////////////////
`SINGLE_TO_BI_RE_0(28,PIXEL_NUM,LVDFS_DATA_I,pixel_m)
//////////////////////////////////////////////////////////////////////////////////
//https://blog.csdn.net/zhuyong006/article/details/80833108
generate 
    if(MODE == "VESA_RF")begin
        for(i=0;i<PIXEL_NUM;i=i+1)begin
            //VESA//(#)即解析出的lvds数据的高低顺序
            //     ————————————————|______________________|——————————————   左为时间起始
            //0+/-：R0(24), R1(20), R2(16), R3(12), R4(8) , R5(4), G0(0)
            //1+/-：G1(25), G2(21), G3(17), G4(13), G5(9) , B0(5), B1(1)
            //2+/-：B2(26), B3(22), B4(18), B5(14), HS(10), VS(6), DE(2)
            //3+/-：R6(27), R7(23), G6(19), G7(15), B6(11), B7(7), 0 (3)
            assign hs_m[i] =  pixel_m[i][10];
            assign vs_m[i] =  pixel_m[i][6];
            assign de_m[i] =  pixel_m[i][2];
            assign r_m[i]  = {pixel_m[i][23],pixel_m[i][27],pixel_m[i][4] ,pixel_m[i][8] ,pixel_m[i][12],pixel_m[i][16],pixel_m[i][20],pixel_m[i][24]};
            assign g_m[i]  = {pixel_m[i][15],pixel_m[i][19],pixel_m[i][9] ,pixel_m[i][13],pixel_m[i][17],pixel_m[i][21],pixel_m[i][25],pixel_m[i][0] };
            assign b_m[i]  = {pixel_m[i][7] ,pixel_m[i][11],pixel_m[i][14],pixel_m[i][18],pixel_m[i][22],pixel_m[i][26],pixel_m[i][1] ,pixel_m[i][5] };
        end
    end  
    else if(MODE == "JEIDA_RF")begin
        for(i=0;i<PIXEL_NUM;i=i+1)begin
            //0+/-：R2(24), R3(20), R4(16), R5(12), R6(8) , R7(4), G2(0)
            //1+/-：G3(25), G4(21), G5(17), G6(13), G7(9) , B2(5), B3(1)
            //2+/-：B4(26), B5(22), B6(18), B7(14), HS(10), VS(6), DE(2)
            //3+/-：R0(27), R1(23), G0(19), G1(15), B0(11), B1(7), 0 (3)
            assign hs_m[i] =  pixel_m[i][10];
            assign vs_m[i] =  pixel_m[i][6];
            assign de_m[i] =  pixel_m[i][2];
            assign r_m[i]  = {pixel_m[i][4] ,pixel_m[i][8] ,pixel_m[i][12],pixel_m[i][16],pixel_m[i][20],pixel_m[i][24],pixel_m[i][23],pixel_m[i][27]};
            assign g_m[i]  = {pixel_m[i][9] ,pixel_m[i][13],pixel_m[i][17],pixel_m[i][21],pixel_m[i][25],pixel_m[i][0] ,pixel_m[i][15],pixel_m[i][19]};
            assign b_m[i]  = {pixel_m[i][14],pixel_m[i][18],pixel_m[i][22],pixel_m[i][26],pixel_m[i][1] ,pixel_m[i][5] ,pixel_m[i][7] ,pixel_m[i][11]};
        end
    end
    else begin
        for(i=0;i<PIXEL_NUM;i=i+1)begin
            //VESA
            //0+/-：R0(24), R1(20), R2(16), R3(12), R4(8) , R5(4), G0(0)
            //1+/-：G1(25), G2(21), G3(17), G4(13), G5(9) , B0(5), B1(1)
            //2+/-：B2(26), B3(22), B4(18), B5(14), HS(10), VS(6), DE(2)
            //3+/-：R6(27), R7(23), G6(19), G7(15), B6(11), B7(7), 0 (3)
            assign hs_m[i] =  pixel_m[i][10];
            assign vs_m[i] =  pixel_m[i][6];
            assign de_m[i] =  pixel_m[i][2];
            assign r_m[i]  = {pixel_m[i][23],pixel_m[i][27],pixel_m[i][4] ,pixel_m[i][8] ,pixel_m[i][12],pixel_m[i][16],pixel_m[i][20],pixel_m[i][24]};
            assign g_m[i]  = {pixel_m[i][15],pixel_m[i][19],pixel_m[i][9] ,pixel_m[i][13],pixel_m[i][17],pixel_m[i][21],pixel_m[i][25],pixel_m[i][0] };
            assign b_m[i]  = {pixel_m[i][7] ,pixel_m[i][11],pixel_m[i][14],pixel_m[i][18],pixel_m[i][22],pixel_m[i][26],pixel_m[i][1] ,pixel_m[i][5] };
        end
    end
endgenerate


endmodule