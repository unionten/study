`timescale 1ns / 1ps
`define BI_TO_SINGLE_RE_0(a,b,in,out)    generate for(i=1;i<=b;i=i+1)begin assign out[a*b-1-(a-1)*(i-1)-(i-1):a*b-1-(a-1)*(i)-(i-1)] = in[b-i];end endgenerate
`define SINGLE_TO_BI_RE_0(a,b,in,out)    generate for(i=1;i<=b;i=i+1)begin assign out[b-i] = in[a*b-1-(a-1)*(i-1)-(i-1):a*b-1-(a-1)*(i)-(i-1)];end endgenerate
`define TRI_TO_SINGLE_RE_0(a,b,c,in,out) generate for(i=1;i<=b;i=i+1)begin for(j=1;j<=c;j=j+1)begin assign out[a*b*c-1-(a-1)* ((i-1)*c+(j-1)) - ((i-1)*c+(j-1)) :a*b*c-1-(a-1)* ((i-1)*c+(j-1)+1) - ((i-1)*c+(j-1)) ] = in[b-i][c-j];end end endgenerate
`define SINGLE_TO_TRI_RE_0(a,b,c,in,out) generate for(i=1;i<=b;i=i+1)begin for(j=1;j<=c;j=j+1)begin assign out[b-i][c-j] = in[a*b*c-1-(a-1)* ((i-1)*c+(j-1)) - ((i-1)*c+(j-1)) :a*b*c-1-(a-1)* ((i-1)*c+(j-1)+1) - ((i-1)*c+(j-1)) ];end end endgenerate
`define FOUR_TO_SINGLE_0(a,b,c,d,in,out) generate for(i=1;i<=b;i=i+1)begin for(j=1;j<=c;j=j+1)begin for(k=1;k<=d;k=k+1)begin assign out[(b-i)*(c*d*a)-1 +(c-j)*(d*a) +(d-k)*a +(a-1)+1:(b-i)*(c*d*a)-1 +(c-j)*(d*a) +(d-k)*a+1] = in[b-i][c-j][d-k]; end end end endgenerate
`define SINGLE_TO_FOUR_0(a,b,c,d,in,out) generate for(i=1;i<=b;i=i+1)begin for(j=1;j<=c;j=j+1)begin for(k=1;k<=d;k=k+1)begin assign out[b-i][c-j][d-k] = in[(b-i)*(c*d*a)-1 +(c-j)*(d*a) +(d-k)*a +(a-1)+1:(b-i)*(c*d*a)-1 +(c-j)*(d*a) +(d-k)*a+1]; end end end endgenerate
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 2021/08/03 13:13:21
// Design Name: 
// Module Name: lvds_to_rgb_lane4_5
//////////////////////////////////////////////////////////////////////////////////
module lvds_to_rgb_4_5lane(
LVDS_DATA_I,//uut_name.hs_m[i]
DEEP10_I,
DE_O,
HS_O,
VS_O,
R_O,
G_O,
B_O
);  
//////////////////////////////////////////////////////////////////////////////////                                                                                              
parameter PORT_NUM = 4;//>=1 像素数
parameter LANE_NUM = 5;//5 or 4,default:4
//////////////////////////////////////////////////////////////////////////////////
localparam MODE = "VESA_RF";//"VESA_RF" "JEIDA_RF"(目前注释了)  ；  default:"VESA_RF"
genvar i,j,k;   
input  [LANE_NUM*7*PORT_NUM-1:0] LVDS_DATA_I;//LANE_NUM不同意味着LVDS排序不同
input  DEEP10_I;
output [1*PORT_NUM-1:0]  DE_O;
output [1*PORT_NUM-1:0]  HS_O;
output [1*PORT_NUM-1:0]  VS_O;
output [LANE_NUM*2*PORT_NUM-1:0]  R_O;
output [LANE_NUM*2*PORT_NUM-1:0]  G_O;
output [LANE_NUM*2*PORT_NUM-1:0]  B_O;
//////////////////////////////////////////////////////////////////////////////////
//为了重新组合，所建立的中间变量
(*keep="true"*)wire [LANE_NUM*7-1:0] pixel_m [0:PORT_NUM-1];
(*keep="true"*)wire [0:0]  hs_m    [0:PORT_NUM-1];
(*keep="true"*)wire [0:0]  vs_m    [0:PORT_NUM-1];
(*keep="true"*)wire [0:0]  de_m    [0:PORT_NUM-1];
(*keep="true"*)wire [LANE_NUM*2-1:0]  r_m     [0:PORT_NUM-1];
(*keep="true"*)wire [LANE_NUM*2-1:0]  g_m     [0:PORT_NUM-1];
(*keep="true"*)wire [LANE_NUM*2-1:0]  b_m     [0:PORT_NUM-1];
//////////////////////////////////////////////////////////////////////////////////
`SINGLE_TO_BI_RE_0((LANE_NUM*7),PORT_NUM,LVDS_DATA_I,pixel_m)
//////////////////////////////////////////////////////////////////////////////////
//https://blog.csdn.net/zhuyong006/article/details/80833108
generate 
    if(MODE == "VESA_RF")begin
        for(i=0;i<PORT_NUM;i=i+1)begin
            //VESA
            if(LANE_NUM == 4)begin
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
            else if(LANE_NUM == 5)begin
                //0+/-：R0(30), R1(25), R2(20), R3(15), R4(10) , R5(5), G0(0)
                //1+/-：G1(31), G2(26), G3(21), G4(16), G5(11) , B0(6), B1(1)
                //2+/-：B2(32), B3(27), B4(22), B5(17), HS(12) , VS(7), DE(2)
                //3+/-：R6(33), R7(28), G6(23), G7(18), B6(13) , B7(8), 0 (3)
                //4+/-：R8(34), R9(29), G8(24), G9(19), B8(14) , B9(9), 0 (4)
                assign hs_m[i] =  pixel_m[i][12];
                assign vs_m[i] =  pixel_m[i][7];
                assign de_m[i] =  pixel_m[i][2];
                assign r_m[i]  = {{DEEP10_I?{pixel_m[i][29],pixel_m[i][34]}:2'b00},pixel_m[i][28] ,pixel_m[i][33] ,pixel_m[i][5],pixel_m[i][10],pixel_m[i][15],pixel_m[i][20],pixel_m[i][25],pixel_m[i][30]};
                assign g_m[i]  = {{DEEP10_I?{pixel_m[i][19],pixel_m[i][24]}:2'b00},pixel_m[i][18] ,pixel_m[i][23],pixel_m[i][11],pixel_m[i][16],pixel_m[i][21],pixel_m[i][26],pixel_m[i][31] ,pixel_m[i][0]};
                assign b_m[i]  = {{DEEP10_I?{pixel_m[i][9] ,pixel_m[i][14]}:2'b00},pixel_m[i][8]  ,pixel_m[i][13],pixel_m[i][17],pixel_m[i][22],pixel_m[i][27] ,pixel_m[i][32],pixel_m[i][1],pixel_m[i][6] };
            end
            else begin
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
    end  
    //else if(MODE == "VESA_LF")begin
    //    for(i=0;i<PORT_NUM;i=i+1)begin
    //        //VESA
    //        if(LANE_NUM == 4)begin
    //            //0+/-：R0(0), R1(4), R2(8) , R3(12), R4(16), R5(20), G0(24)
    //            //1+/-：G1(1), G2(5), G3(9) , G4(13), G5(17), B0(21), B1(25)
    //            //2+/-：B2(2), B3(6), B4(10), B5(14), HS(18), VS(22), DE(26)
    //            //3+/-：R6(3), R7(7), G6(11), G7(15), B6(19), B7(23), 0 (27)
    //            assign hs_m[i] =  pixel_m[i][18];
    //            assign vs_m[i] =  pixel_m[i][22];
    //            assign de_m[i] =  pixel_m[i][26];
    //            assign r_m[i]  = {pixel_m[i][7] ,pixel_m[i][3] ,pixel_m[i][20],pixel_m[i][16],pixel_m[i][12],pixel_m[i][8],pixel_m[i][4] ,pixel_m[i][0] };
    //            assign g_m[i]  = {pixel_m[i][15],pixel_m[i][11],pixel_m[i][17],pixel_m[i][13],pixel_m[i][9] ,pixel_m[i][5],pixel_m[i][1] ,pixel_m[i][24]};
    //            assign b_m[i]  = {pixel_m[i][23],pixel_m[i][19],pixel_m[i][14],pixel_m[i][10],pixel_m[i][6] ,pixel_m[i][2],pixel_m[i][25],pixel_m[i][21]};
    //        end
    //        else begin
    //            //0+/-：R0(0), R1(4), R2(8) , R3(12), R4(16), R5(20), G0(24)
    //            //1+/-：G1(1), G2(5), G3(9) , G4(13), G5(17), B0(21), B1(25)
    //            //2+/-：B2(2), B3(6), B4(10), B5(14), HS(18), VS(22), DE(26)
    //            //3+/-：R6(3), R7(7), G6(11), G7(15), B6(19), B7(23), 0 (27)
    //            assign hs_m[i] =  pixel_m[i][18];
    //            assign vs_m[i] =  pixel_m[i][22];
    //            assign de_m[i] =  pixel_m[i][26];
    //            assign r_m[i]  = {pixel_m[i][7] ,pixel_m[i][3] ,pixel_m[i][20],pixel_m[i][16],pixel_m[i][12],pixel_m[i][8],pixel_m[i][4] ,pixel_m[i][0] };
    //            assign g_m[i]  = {pixel_m[i][15],pixel_m[i][11],pixel_m[i][17],pixel_m[i][13],pixel_m[i][9] ,pixel_m[i][5],pixel_m[i][1] ,pixel_m[i][24]};
    //            assign b_m[i]  = {pixel_m[i][23],pixel_m[i][19],pixel_m[i][14],pixel_m[i][10],pixel_m[i][6] ,pixel_m[i][2],pixel_m[i][25],pixel_m[i][21]};
    //        end
    //    end
    //end
    //else if(MODE == "JEIDA_RF")begin
    //    for(i=0;i<PORT_NUM;i=i+1)begin
    //        if(LANE_NUM == 4)begin
    //            //0+/-：R2(24), R3(20), R4(16), R5(12), R6(8) , R7(4), G2(0)
    //            //1+/-：G3(25), G4(21), G5(17), G6(13), G7(9) , B2(5), B3(1)
    //            //2+/-：B4(26), B5(22), B6(18), B7(14), HS(10), VS(6), DE(2)
    //            //3+/-：R0(27), R1(23), G0(19), G1(15), B0(11), B1(7), 0 (3)
    //            assign hs_m[i] =  pixel_m[i][10];
    //            assign vs_m[i] =  pixel_m[i][6];
    //            assign de_m[i] =  pixel_m[i][2];
    //            assign r_m[i]  = {pixel_m[i][4] ,pixel_m[i][8] ,pixel_m[i][12],pixel_m[i][16],pixel_m[i][20],pixel_m[i][24],pixel_m[i][23],pixel_m[i][27]};
    //            assign g_m[i]  = {pixel_m[i][9] ,pixel_m[i][13],pixel_m[i][17],pixel_m[i][21],pixel_m[i][25],pixel_m[i][0] ,pixel_m[i][15],pixel_m[i][19]};
    //            assign b_m[i]  = {pixel_m[i][14],pixel_m[i][18],pixel_m[i][22],pixel_m[i][26],pixel_m[i][1] ,pixel_m[i][5] ,pixel_m[i][7] ,pixel_m[i][11]};
    //        end
    //        else begin
    //            //0+/-：R2(24), R3(20), R4(16), R5(12), R6(8) , R7(4), G2(0)
    //            //1+/-：G3(25), G4(21), G5(17), G6(13), G7(9) , B2(5), B3(1)
    //            //2+/-：B4(26), B5(22), B6(18), B7(14), HS(10), VS(6), DE(2)
    //            //3+/-：R0(27), R1(23), G0(19), G1(15), B0(11), B1(7), 0 (3)
    //            assign hs_m[i] =  pixel_m[i][10];
    //            assign vs_m[i] =  pixel_m[i][6];
    //            assign de_m[i] =  pixel_m[i][2];
    //            assign r_m[i]  = {pixel_m[i][4] ,pixel_m[i][8] ,pixel_m[i][12],pixel_m[i][16],pixel_m[i][20],pixel_m[i][24],pixel_m[i][23],pixel_m[i][27]};
    //            assign g_m[i]  = {pixel_m[i][9] ,pixel_m[i][13],pixel_m[i][17],pixel_m[i][21],pixel_m[i][25],pixel_m[i][0] ,pixel_m[i][15],pixel_m[i][19]};
    //            assign b_m[i]  = {pixel_m[i][14],pixel_m[i][18],pixel_m[i][22],pixel_m[i][26],pixel_m[i][1] ,pixel_m[i][5] ,pixel_m[i][7] ,pixel_m[i][11]};   
    //        end
    //    end
    //end
    //else if(MODE == "JEIDA_LF")begin
    //    for(i=0;i<PORT_NUM;i=i+1)begin
    //        if(LANE_NUM == 4)begin
    //            //0+/-：R2(0), R3(4), R4(8) , R5(12), R6(16), R7(20), G2(24)
    //            //1+/-：G3(1), G4(5), G5(9) , G6(13), G7(17), B2(21), B3(25)
    //            //2+/-：B4(2), B5(6), B6(10), B7(14), HS(18), VS(22), DE(26)
    //            //3+/-：R0(3), R1(7), G0(11), G1(15), B0(19), B1(23), 0 (27)
    //            assign hs_m[i] =  pixel_m[i][18];
    //            assign vs_m[i] =  pixel_m[i][22];
    //            assign de_m[i] =  pixel_m[i][26];
    //            assign r_m[i]  = {pixel_m[i][20],pixel_m[i][16],pixel_m[i][12],pixel_m[i][8],pixel_m[i][4] ,pixel_m[i][0] ,pixel_m[i][7] ,pixel_m[i][3] };
    //            assign g_m[i]  = {pixel_m[i][17],pixel_m[i][13],pixel_m[i][9] ,pixel_m[i][5],pixel_m[i][1] ,pixel_m[i][24],pixel_m[i][15],pixel_m[i][11]};
    //            assign b_m[i]  = {pixel_m[i][14],pixel_m[i][10],pixel_m[i][6] ,pixel_m[i][2],pixel_m[i][25],pixel_m[i][21],pixel_m[i][23],pixel_m[i][19]};
    //        end
    //        else begin
    //            //0+/-：R2(0), R3(4), R4(8) , R5(12), R6(16), R7(20), G2(24)
    //            //1+/-：G3(1), G4(5), G5(9) , G6(13), G7(17), B2(21), B3(25)
    //            //2+/-：B4(2), B5(6), B6(10), B7(14), HS(18), VS(22), DE(26)
    //            //3+/-：R0(3), R1(7), G0(11), G1(15), B0(19), B1(23), 0 (27)
    //            assign hs_m[i] =  pixel_m[i][18];
    //            assign vs_m[i] =  pixel_m[i][22];
    //            assign de_m[i] =  pixel_m[i][26];
    //            assign r_m[i]  = {pixel_m[i][20],pixel_m[i][16],pixel_m[i][12],pixel_m[i][8],pixel_m[i][4] ,pixel_m[i][0] ,pixel_m[i][7] ,pixel_m[i][3] };
    //            assign g_m[i]  = {pixel_m[i][17],pixel_m[i][13],pixel_m[i][9] ,pixel_m[i][5],pixel_m[i][1] ,pixel_m[i][24],pixel_m[i][15],pixel_m[i][11]};
    //            assign b_m[i]  = {pixel_m[i][14],pixel_m[i][10],pixel_m[i][6] ,pixel_m[i][2],pixel_m[i][25],pixel_m[i][21],pixel_m[i][23],pixel_m[i][19]};
    //        end
    //   end
    //end
    else begin
        for(i=0;i<PORT_NUM;i=i+1)begin
            //VESA
            if(LANE_NUM == 4)begin
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
            else if(LANE_NUM == 5)begin
                //0+/-：R0(30), R1(25), R2(20), R3(15), R4(10) , R5(5), G0(0)
                //1+/-：G1(31), G2(26), G3(21), G4(16), G5(11) , B0(6), B1(1)
                //2+/-：B2(32), B3(27), B4(22), B5(17), HS(12) , VS(7), DE(2)
                //3+/-：R6(33), R7(28), G6(23), G7(18), B6(13) , B7(8), 0 (3)
                //4+/-：R8(34), R9(29), G8(24), G9(19), B8(14) , B9(9), 0 (4)
                assign hs_m[i] =  pixel_m[i][12];
                assign vs_m[i] =  pixel_m[i][7];
                assign de_m[i] =  pixel_m[i][2];
                assign r_m[i]  = {{DEEP10_I?{pixel_m[i][29],pixel_m[i][34]}:2'b00},pixel_m[i][28] ,pixel_m[i][33] ,pixel_m[i][5],pixel_m[i][10],pixel_m[i][15],pixel_m[i][20],pixel_m[i][25],pixel_m[i][30]};
                assign g_m[i]  = {{DEEP10_I?{pixel_m[i][19],pixel_m[i][24]}:2'b00},pixel_m[i][18] ,pixel_m[i][23],pixel_m[i][11],pixel_m[i][16],pixel_m[i][21],pixel_m[i][26],pixel_m[i][31] ,pixel_m[i][0]};
                assign b_m[i]  = {{DEEP10_I?{pixel_m[i][9] ,pixel_m[i][14]}:2'b00},pixel_m[i][8]  ,pixel_m[i][13],pixel_m[i][17],pixel_m[i][22],pixel_m[i][27] ,pixel_m[i][32],pixel_m[i][1],pixel_m[i][6] };
            end
            else begin
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
    end
endgenerate

//输出
generate for(i=0;i<PORT_NUM;i=i+1)begin
    assign DE_O[i] = de_m[i];
    assign HS_O[i] = hs_m[i];
    assign VS_O[i] = vs_m[i];
    assign R_O[i*(LANE_NUM*2)+:(LANE_NUM*2)] = r_m[i];
    assign G_O[i*(LANE_NUM*2)+:(LANE_NUM*2)] = g_m[i];
    assign B_O[i*(LANE_NUM*2)+:(LANE_NUM*2)] = b_m[i];   
end
endgenerate

endmodule