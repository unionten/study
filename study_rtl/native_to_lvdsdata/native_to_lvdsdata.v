`timescale 1ns / 1ps
`define SINGLE_TO_BI_Nm1To0(a,b,in,out)             generate for(i=1;i<=b;i=i+1)begin assign out[b-i] = in[a*b-1-(a-1)*(i-1)-(i-1):a*b-1-(a-1)*(i)-(i-1)];end endgenerate
`define REVERSE_INGEN(data_in,data_out,BYTE_NUM,BITS_PER_BYTE)                                          for(i=0;i<BYTE_NUM;i=i+1)begin assign data_out[i*BITS_PER_BYTE+:BITS_PER_BYTE] = data_in[(BYTE_NUM-1-i)*BITS_PER_BYTE+:BITS_PER_BYTE]; end  


//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:  yzhu
// 
// Create Date: 2024/09/26 10:18:35
// Design Name: 
// Module Name: native_to_lvds
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//////////////////////////////////////////////////////////////////////////////////

//native to vesa

module native_to_lvdsdata(
input  [C_PORT_NUM*8-1:0] R_I,
input  [C_PORT_NUM*8-1:0] G_I,
input  [C_PORT_NUM*8-1:0] B_I,
input  VS_I,
input  HS_I,
input  DE_I ,

output [28*C_PORT_NUM-1:0] LVDS_DATA_O ,
output [7*C_PORT_NUM-1:0]  LANE0_O     ,   //低位bit对应实际先输出的bit
output [7*C_PORT_NUM-1:0]  LANE1_O     ,  
output [7*C_PORT_NUM-1:0]  LANE2_O     ,   
output [7*C_PORT_NUM-1:0]  LANE3_O     

);
    
parameter C_PORT_NUM    = 4 ;

genvar i,j,k;

//VESA//(#)即解析出的lvds数据的高低顺序
//     ————————————————|______________________|——————————————   左为时间起始
//0+/-：R0(24), R1(20), R2(16), R3(12), R4(8) , R5(4), G0(0)   
//1+/-：G1(25), G2(21), G3(17), G4(13), G5(9) , B0(5), B1(1)
//2+/-：B2(26), B3(22), B4(18), B5(14), HS(10), VS(6), DE(2)
//3+/-：R6(27), R7(23), G6(19), G7(15), B6(11), B7(7), 0 (3)    



wire [27:0] lvds_data_m [C_PORT_NUM-1:0] ;
wire [6:0]  lane0_m [C_PORT_NUM-1:0] ;
wire [6:0]  lane1_m [C_PORT_NUM-1:0] ;
wire [6:0]  lane2_m [C_PORT_NUM-1:0] ;
wire [6:0]  lane3_m [C_PORT_NUM-1:0] ;



wire [28*C_PORT_NUM-1:0] lvds_s [C_PORT_NUM-1:0];
wire [7*C_PORT_NUM-1:0] lane0_s [C_PORT_NUM-1:0];
wire [7*C_PORT_NUM-1:0] lane1_s [C_PORT_NUM-1:0];
wire [7*C_PORT_NUM-1:0] lane2_s [C_PORT_NUM-1:0];
wire [7*C_PORT_NUM-1:0] lane3_s [C_PORT_NUM-1:0];




wire [7:0] R_I_m [C_PORT_NUM-1:0] ;
wire [7:0] G_I_m [C_PORT_NUM-1:0] ;
wire [7:0] B_I_m [C_PORT_NUM-1:0] ;
`SINGLE_TO_BI_Nm1To0(8,C_PORT_NUM,R_I,R_I_m)
`SINGLE_TO_BI_Nm1To0(8,C_PORT_NUM,G_I,G_I_m)
`SINGLE_TO_BI_Nm1To0(8,C_PORT_NUM,B_I,B_I_m)


generate for(i=0;i<C_PORT_NUM;i=i+1)begin
    assign lvds_data_m[i] = {  R_I_m[i][6],B_I_m[i][2],G_I_m[i][1],R_I_m[i][0],R_I_m[i][7],B_I_m[i][3],G_I_m[i][2],
                               R_I_m[i][1],G_I_m[i][6],B_I_m[i][4],G_I_m[i][3],R_I_m[i][2],G_I_m[i][7],B_I_m[i][5], 
                               G_I_m[i][4],R_I_m[i][3],B_I_m[i][6],HS_I,G_I_m[i][5],R_I_m[i][4],B_I_m[i][7],
                               VS_I ,B_I_m[i][0],R_I_m[i][5],1'b0,DE_I,B_I_m[i][1],G_I_m[i][0]     } ;
end
endgenerate  
    


assign lvds_s[0] = lvds_data_m[0] ;
generate for(i=1;i<=C_PORT_NUM-1;i=i+1)begin
    assign lvds_s[i] = {lvds_data_m[i],lvds_s[i-1][i*28-1:0]}; 
end
endgenerate  


assign LVDS_DATA_O = lvds_s[C_PORT_NUM-1] ;


////////////////////////////////////////////////////////////////////////////////////////

wire [7*C_PORT_NUM-1:0] lane0_s [C_PORT_NUM-1:0];
wire [7*C_PORT_NUM-1:0] lane1_s [C_PORT_NUM-1:0];
wire [7*C_PORT_NUM-1:0] lane2_s [C_PORT_NUM-1:0];
wire [7*C_PORT_NUM-1:0] lane3_s [C_PORT_NUM-1:0];



generate for(i=0;i<C_PORT_NUM;i=i+1)begin
    assign lane0_m[i] = { G_I_m[i][0],R_I_m[i][5],R_I_m[i][4],R_I_m[i][3],R_I_m[i][2],R_I_m[i][1],R_I_m[i][0] } ;
end
endgenerate  


generate for(i=0;i<C_PORT_NUM;i=i+1)begin
    assign lane1_m[i] = { B_I_m[i][1],B_I_m[i][0],G_I_m[i][5],G_I_m[i][4],G_I_m[i][3],G_I_m[i][2],G_I_m[i][1] } ;
end
endgenerate  


generate for(i=0;i<C_PORT_NUM;i=i+1)begin
    assign lane2_m[i] = { DE_I,VS_I ,HS_I,B_I_m[i][5],B_I_m[i][4],B_I_m[i][3],B_I_m[i][2]   } ;
end
endgenerate  


generate for(i=0;i<C_PORT_NUM;i=i+1)begin
    assign lane3_m[i] = {  1'b0,B_I_m[i][7],B_I_m[i][6],G_I_m[i][7],G_I_m[i][6],R_I_m[i][7],R_I_m[i][6] } ;
end
endgenerate  


assign lane0_s[0] = lane0_m[0] ;
generate for(i=1;i<=C_PORT_NUM-1;i=i+1)begin
    assign lane0_s[i] = {lane0_m[i],lane0_s[i-1][i*7-1:0]}; 
end
endgenerate  

assign lane1_s[0] = lane1_m[0] ;
generate for(i=1;i<=C_PORT_NUM-1;i=i+1)begin
    assign lane1_s[i] = {lane1_m[i],lane1_s[i-1][i*7-1:0]}; 
end
endgenerate  


assign lane2_s[0] = lane2_m[0] ;
generate for(i=1;i<=C_PORT_NUM-1;i=i+1)begin
    assign lane2_s[i] = {lane2_m[i],lane2_s[i-1][i*7-1:0]}; 
end
endgenerate  

assign lane3_s[0] = lane3_m[0] ;
generate for(i=1;i<=C_PORT_NUM-1;i=i+1)begin
    assign lane3_s[i] = {lane3_m[i],lane3_s[i-1][i*7-1:0]}; 
end
endgenerate  




assign  LANE0_O  =   lane0_s[C_PORT_NUM-1]  ;
assign  LANE1_O  =   lane1_s[C_PORT_NUM-1]  ;
assign  LANE2_O  =   lane2_s[C_PORT_NUM-1]  ;
assign  LANE3_O  =   lane3_s[C_PORT_NUM-1]  ;  


    
endmodule



