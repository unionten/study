`timescale 1ns / 1ps
`define SINGLE_TO_BI_Nm1To0(a,b,in,out)             generate for(i=1;i<=b;i=i+1)begin assign out[b-i] = in[a*b-1-(a-1)*(i-1)-(i-1):a*b-1-(a-1)*(i)-(i-1)];end endgenerate

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/09/26 10:18:16
// Design Name: 
// Module Name: lvds_to_native
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// 
//////////////////////////////////////////////////////////////////////////////////


module lvdsdata_to_native(
output  [C_PORT_NUM*8-1:0] R_O,
output  [C_PORT_NUM*8-1:0] G_O,
output  [C_PORT_NUM*8-1:0] B_O,
output  VS_O,
output  HS_O,
output  DE_O ,

input [28*C_PORT_NUM-1:0] LVDS_DATA_I
    );

parameter C_PORT_NUM = 4; 


genvar i,j,k;

wire [27:0] lvds_data_m [C_PORT_NUM-1:0] ;
`SINGLE_TO_BI_Nm1To0(28,C_PORT_NUM,LVDS_DATA_I,lvds_data_m)     

wire [7:0] r_m [C_PORT_NUM-1:0] ;
wire [7:0] g_m [C_PORT_NUM-1:0] ;
wire [7:0] b_m [C_PORT_NUM-1:0] ;
wire [0:0] hs_m [C_PORT_NUM-1:0] ;
wire [0:0] vs_m [C_PORT_NUM-1:0] ;
wire [0:0] de_m [C_PORT_NUM-1:0] ;

    
generate for(i=0;i<C_PORT_NUM;i=i+1) begin
    assign hs_m[i] =  lvds_data_m[i][10];
    assign vs_m[i] =  lvds_data_m[i][6];
    assign de_m[i] =  lvds_data_m[i][2];
    assign r_m[i]  = {lvds_data_m[i][23],lvds_data_m[i][27],lvds_data_m[i][4] ,lvds_data_m[i][8] ,lvds_data_m[i][12],lvds_data_m[i][16],lvds_data_m[i][20],lvds_data_m[i][24]};
    assign g_m[i]  = {lvds_data_m[i][15],lvds_data_m[i][19],lvds_data_m[i][9] ,lvds_data_m[i][13],lvds_data_m[i][17],lvds_data_m[i][21],lvds_data_m[i][25],lvds_data_m[i][0] };
    assign b_m[i]  = {lvds_data_m[i][7] ,lvds_data_m[i][11],lvds_data_m[i][14],lvds_data_m[i][18],lvds_data_m[i][22],lvds_data_m[i][26],lvds_data_m[i][1] ,lvds_data_m[i][5] };
    
    
end
endgenerate    
    
    
////////////////////////////////////////////////////////
wire [8*C_PORT_NUM-1:0] r_ss [C_PORT_NUM-1:0];
assign r_ss[0] = r_m[0] ;
generate for(i=1;i<=C_PORT_NUM-1;i=i+1)begin
    assign r_ss[i] = {r_m[i],r_ss[i-1][i*8-1:0]}; 
    
end
endgenerate  
assign R_O = r_ss[C_PORT_NUM-1] ;


////////////////////////////////////////////////////////
wire [8*C_PORT_NUM-1:0] g_ss [C_PORT_NUM-1:0];
assign g_ss[0] = g_m[0] ;
generate for(i=1;i<=C_PORT_NUM-1;i=i+1)begin
    assign g_ss[i] = {g_m[i],g_ss[i-1][i*8-1:0]}; 
    
end
endgenerate  
assign G_O = g_ss[C_PORT_NUM-1] ;



////////////////////////////////////////////////////////
wire [8*C_PORT_NUM-1:0] b_ss [C_PORT_NUM-1:0];
assign b_ss[0] = b_m[0] ;
generate for(i=1;i<=C_PORT_NUM-1;i=i+1)begin
    assign b_ss[i] = {b_m[i],b_ss[i-1][i*8-1:0]}; 
    
end
endgenerate  
assign B_O = b_ss[C_PORT_NUM-1] ;  

////////////////////////////////////////////////////////
assign VS_O = vs_m[0];
assign HS_O = hs_m[0];
assign DE_O = de_m[0];


////////////////////////////////////////////////////////


    
endmodule



