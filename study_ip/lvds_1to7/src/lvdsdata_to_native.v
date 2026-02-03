`timescale 1ns / 1ps
`define SINGLE_TO_BI_Nm1To0(a,b,in,out)             generate for(i=1;i<=b;i=i+1)begin assign out[b-i] = in[a*b-1-(a-1)*(i-1)-(i-1):a*b-1-(a-1)*(i)-(i-1)];end endgenerate
`define BI_TO_SINGLE_Nm1To0(a,b,in,out)             generate for(i=1;i<=b;i=i+1)begin assign out[a*b-1-(a-1)*(i-1)-(i-1):a*b-1-(a-1)*(i)-(i-1)] = in[b-i];end endgenerate
`define SINGLE_TO_TRI_Nm1To0(a,b,c,in,out)          generate for(i=1;i<=b;i=i+1)begin for(j=1;j<=c;j=j+1)begin assign out[b-i][c-j] = in[a*b*c-1-(a-1)* ((i-1)*c+(j-1)) - ((i-1)*c+(j-1)) :a*b*c-1-(a-1)* ((i-1)*c+(j-1)+1) - ((i-1)*c+(j-1)) ];end end endgenerate
`define TRI_TO_SINGLE_Nm1To0(a,b,c,in,out)          generate for(i=1;i<=b;i=i+1)begin for(j=1;j<=c;j=j+1)begin assign out[a*b*c-1-(a-1)* ((i-1)*c+(j-1)) - ((i-1)*c+(j-1)) :a*b*c-1-(a-1)* ((i-1)*c+(j-1)+1) - ((i-1)*c+(j-1)) ] = in[b-i][c-j];end end endgenerate
`define SINGLE_TO_FOUR_Nm1To0(a,b,c,d,in,out)       generate for(i=1;i<=b;i=i+1)begin for(j=1;j<=c;j=j+1)begin for(k=1;k<=d;k=k+1)begin assign out[b-i][c-j][d-k] = in[(b-i)*(c*d*a)-1 +(c-j)*(d*a) +(d-k)*a +(a-1)+1:(b-i)*(c*d*a)-1 +(c-j)*(d*a) +(d-k)*a+1]; end end end endgenerate
`define FOUR_TO_SINGLE_Nm1To0(a,b,c,d,in,out)       generate for(i=1;i<=b;i=i+1)begin for(j=1;j<=c;j=j+1)begin for(k=1;k<=d;k=k+1)begin assign out[(b-i)*(c*d*a)-1 +(c-j)*(d*a) +(d-k)*a +(a-1)+1:(b-i)*(c*d*a)-1 +(c-j)*(d*a) +(d-k)*a+1] = in[b-i][c-j][d-k]; end end end endgenerate


//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:  yzhu
// 
// Create Date: 2023/06/28 15:14:52
// Design Name: 
// Module Name: lvdsdata_to_native
//////////////////////////////////////////////////////////////////////////////////
//VESA
//0+/-：R 0(24), R 1(20), R 2(16), R 3(12), R 4(8) , R 5(4), G 0(0)
//1+/-：G 1(25), G 2(21), G 3(17), G 4(13), G 5(9) , B 0(5), B 1(1)
//2+/-：B 2(26), B 3(22), B 4(18), B 5(14), H S(10), V S(6), D E(2)
//3+/-：R 6(27), R 7(23), G 6(19), G 7(15), B 6(11), B 7(7), 0  (3)



//0+/-：R 0(30), R 1(25), R 2(20), R 3(15), R 4(10) , R 5(5), G 0(0)
//1+/-：G 1(31), G 2(26), G 3(21), G 4(16), G 5(11) , B 0(6), B 1(1)
//2+/-：B 2(32), B 3(27), B 4(22), B 5(17), H S(12),  V S(7), D E(2)
//3+/-：R 6(33), R 7(28), G 6(23), G 7(18), B 6(13),  B 7(8), 0  (3)
//4+/-：R 8(34) ,R 9(29) ,G 8(24) ,G 9(19), B 8(14),  B 9(9) ,0  (4)

module lvdsdata_to_native(
input   [C_LANE_NUM*C_PORT_NUM*7-1:0] LVDS_DATA_I,
output  [C_PORT_NUM-1:0] VS_O,
output  [C_PORT_NUM-1:0] HS_O,
output  [C_PORT_NUM-1:0] DE_O,
output  [C_LANE_NUM*2*C_PORT_NUM-1:0] R_O,
output  [C_LANE_NUM*2*C_PORT_NUM-1:0] G_O,
output  [C_LANE_NUM*2*C_PORT_NUM-1:0] B_O

    );
parameter C_PORT_NUM = 4;
parameter C_LANE_NUM = 4;//valid 4 or 5
    

genvar i,j,k;
wire [C_LANE_NUM*7-1:0] lvds_data_m [C_PORT_NUM-1:0];
`SINGLE_TO_BI_Nm1To0((C_LANE_NUM*7),C_PORT_NUM,LVDS_DATA_I,lvds_data_m)

wire vs_m [C_PORT_NUM-1:0];
wire hs_m [C_PORT_NUM-1:0];
wire de_m [C_PORT_NUM-1:0];
wire [C_LANE_NUM*2-1:0] r_m [C_PORT_NUM-1:0];
wire [C_LANE_NUM*2-1:0] g_m [C_PORT_NUM-1:0];
wire [C_LANE_NUM*2-1:0] b_m [C_PORT_NUM-1:0];


generate for(i=0;i<=C_PORT_NUM-1;i=i+1)begin
    if(C_LANE_NUM==4)begin
        assign hs_m[i] =  lvds_data_m[i][10];
        assign vs_m[i] =  lvds_data_m[i][6];
        assign de_m[i] =  lvds_data_m[i][2];
        assign r_m[i]  = {lvds_data_m[i][23],lvds_data_m[i][27],lvds_data_m[i][4] ,lvds_data_m[i][8] ,lvds_data_m[i][12],lvds_data_m[i][16],lvds_data_m[i][20],lvds_data_m[i][24]};
        assign g_m[i]  = {lvds_data_m[i][15],lvds_data_m[i][19],lvds_data_m[i][9] ,lvds_data_m[i][13],lvds_data_m[i][17],lvds_data_m[i][21],lvds_data_m[i][25],lvds_data_m[i][0] };
        assign b_m[i]  = {lvds_data_m[i][7] ,lvds_data_m[i][11],lvds_data_m[i][14],lvds_data_m[i][18],lvds_data_m[i][22],lvds_data_m[i][26],lvds_data_m[i][1] ,lvds_data_m[i][5] };
    end
    else if(C_LANE_NUM==5)begin
        assign hs_m[i] =  lvds_data_m[i][12];
        assign vs_m[i] =  lvds_data_m[i][7];
        assign de_m[i] =  lvds_data_m[i][2];
        assign r_m[i]  = {lvds_data_m[i][29],lvds_data_m[i][34],lvds_data_m[i][28],lvds_data_m[i][33],lvds_data_m[i][5] ,lvds_data_m[i][10] ,lvds_data_m[i][15],lvds_data_m[i][20],lvds_data_m[i][25],lvds_data_m[i][30]};
        assign g_m[i]  = {lvds_data_m[i][19],lvds_data_m[i][24],lvds_data_m[i][18],lvds_data_m[i][23],lvds_data_m[i][11] ,lvds_data_m[i][16],lvds_data_m[i][21],lvds_data_m[i][26],lvds_data_m[i][31],lvds_data_m[i][0] };
        assign b_m[i]  = {lvds_data_m[i][9],lvds_data_m[i][14],lvds_data_m[i][8],lvds_data_m[i][13],lvds_data_m[i][17],lvds_data_m[i][22],lvds_data_m[i][27],lvds_data_m[i][32],lvds_data_m[i][1] ,lvds_data_m[i][5] };
    end
    else begin
        assign hs_m[i] =  lvds_data_m[i][10];
        assign vs_m[i] =  lvds_data_m[i][6];
        assign de_m[i] =  lvds_data_m[i][2];
        assign r_m[i]  = {lvds_data_m[i][23],lvds_data_m[i][27],lvds_data_m[i][4] ,lvds_data_m[i][8] ,lvds_data_m[i][12],lvds_data_m[i][16],lvds_data_m[i][20],lvds_data_m[i][24]};
        assign g_m[i]  = {lvds_data_m[i][15],lvds_data_m[i][19],lvds_data_m[i][9] ,lvds_data_m[i][13],lvds_data_m[i][17],lvds_data_m[i][21],lvds_data_m[i][25],lvds_data_m[i][0] };
        assign b_m[i]  = {lvds_data_m[i][7] ,lvds_data_m[i][11],lvds_data_m[i][14],lvds_data_m[i][18],lvds_data_m[i][22],lvds_data_m[i][26],lvds_data_m[i][1] ,lvds_data_m[i][5] }; 
    end
end
endgenerate 


`BI_TO_SINGLE_Nm1To0(1,C_PORT_NUM,hs_m,HS_O)
`BI_TO_SINGLE_Nm1To0(1,C_PORT_NUM,vs_m,VS_O)
`BI_TO_SINGLE_Nm1To0(1,C_PORT_NUM,de_m,DE_O)
`BI_TO_SINGLE_Nm1To0((C_LANE_NUM*2),C_PORT_NUM,r_m,R_O)
`BI_TO_SINGLE_Nm1To0((C_LANE_NUM*2),C_PORT_NUM,g_m,G_O)
`BI_TO_SINGLE_Nm1To0((C_LANE_NUM*2),C_PORT_NUM,b_m,B_O)
    
endmodule



