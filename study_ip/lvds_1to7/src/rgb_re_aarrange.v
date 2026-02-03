`timescale 1ns / 1ps

`define SINGLE_TO_BI_1ToN(a,b,in,out)               generate for(i=1;i<=b;i=i+1)begin assign out[i] = in[a*b-1-(a-1)*(i-1)-(i-1):a*b-1-(a-1)*(i)-(i-1)];end endgenerate
`define BI_TO_SINGLE_1ToN(a,b,in,out)               generate for(i=1;i<=b;i=i+1)begin assign out[a*b-1-(a-1)*(i-1)-(i-1):a*b-1-(a-1)*(i)-(i-1)] = in[i];end endgenerate
`define SINGLE_TO_TRI_1ToN(a,b,c,in,out)            generate for(i=1;i<=b;i=i+1)begin for(j=1;j<=c;j=j+1)begin assign out[i][j] = in[a*b*c-1-(a-1)* ((i-1)*c+(j-1)) - ((i-1)*c+(j-1)) :a*b*c-1-(a-1)* ((i-1)*c+(j-1)+1) - ((i-1)*c+(j-1)) ];end end endgenerate
`define TRI_TO_SINGLE_1ToN(a,b,c,in,out)            generate for(i=1;i<=b;i=i+1)begin for(j=1;j<=c;j=j+1)begin assign out[a*b*c-1-(a-1)* ((i-1)*c+(j-1)) - ((i-1)*c+(j-1)) :a*b*c-1-(a-1)* ((i-1)*c+(j-1)+1) - ((i-1)*c+(j-1)) ] = in[i][j];end end endgenerate
`define SINGLE_TO_FOUR_1ToN(a,b,c,d,in,out)         generate for(i=1;i<=b;i=i+1)begin for(j=1;j<=c;j=j+1)begin for(k=1;k<=d;k=k+1)begin assign out[i][j][k] = in[(b-i)*(c*d*a)-1 +(c-j)*(d*a) +(d-k)*a +(a-1)+1:(b-i)*(c*d*a)-1 +(c-j)*(d*a) +(d-k)*a+1]; end end end endgenerate
`define FOUR_TO_SINGLE_1ToN(a,b,c,d,in,out)         generate for(i=1;i<=b;i=i+1)begin for(j=1;j<=c;j=j+1)begin for(k=1;k<=d;k=k+1)begin assign out[(b-i)*(c*d*a)-1 +(c-j)*(d*a) +(d-k)*a +(a-1)+1:(b-i)*(c*d*a)-1 +(c-j)*(d*a) +(d-k)*a+1] = in[i][j][k]; end end end endgenerate
                                                    
`define SINGLE_TO_BI_Nm1To0(a,b,in,out)             generate for(i=1;i<=b;i=i+1)begin assign out[b-i] = in[a*b-1-(a-1)*(i-1)-(i-1):a*b-1-(a-1)*(i)-(i-1)];end endgenerate
`define BI_TO_SINGLE_Nm1To0(a,b,in,out)             generate for(i=1;i<=b;i=i+1)begin assign out[a*b-1-(a-1)*(i-1)-(i-1):a*b-1-(a-1)*(i)-(i-1)] = in[b-i];end endgenerate
`define SINGLE_TO_TRI_Nm1To0(a,b,c,in,out)          generate for(i=1;i<=b;i=i+1)begin for(j=1;j<=c;j=j+1)begin assign out[b-i][c-j] = in[a*b*c-1-(a-1)* ((i-1)*c+(j-1)) - ((i-1)*c+(j-1)) :a*b*c-1-(a-1)* ((i-1)*c+(j-1)+1) - ((i-1)*c+(j-1)) ];end end endgenerate
`define TRI_TO_SINGLE_Nm1To0(a,b,c,in,out)          generate for(i=1;i<=b;i=i+1)begin for(j=1;j<=c;j=j+1)begin assign out[a*b*c-1-(a-1)* ((i-1)*c+(j-1)) - ((i-1)*c+(j-1)) :a*b*c-1-(a-1)* ((i-1)*c+(j-1)+1) - ((i-1)*c+(j-1)) ] = in[b-i][c-j];end end endgenerate
`define SINGLE_TO_FOUR_Nm1To0(a,b,c,d,in,out)       generate for(i=1;i<=b;i=i+1)begin for(j=1;j<=c;j=j+1)begin for(k=1;k<=d;k=k+1)begin assign out[b-i][c-j][d-k] = in[(b-i)*(c*d*a)-1 +(c-j)*(d*a) +(d-k)*a +(a-1)+1:(b-i)*(c*d*a)-1 +(c-j)*(d*a) +(d-k)*a+1]; end end end endgenerate
`define FOUR_TO_SINGLE_Nm1To0(a,b,c,d,in,out)       generate for(i=1;i<=b;i=i+1)begin for(j=1;j<=c;j=j+1)begin for(k=1;k<=d;k=k+1)begin assign out[(b-i)*(c*d*a)-1 +(c-j)*(d*a) +(d-k)*a +(a-1)+1:(b-i)*(c*d*a)-1 +(c-j)*(d*a) +(d-k)*a+1] = in[b-i][c-j][d-k]; end end end endgenerate


//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/24 21:09:42
// Design Name: 
// Module Name: rgb_re_aarrange
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


module rgb_re_aarrange(
input  [8*C_PORT_NUM-1:0]  R_I ,
input  [8*C_PORT_NUM-1:0]  G_I ,
input  [8*C_PORT_NUM-1:0]  B_I ,

output  [8*C_PORT_NUM-1:0]  R_REARR_O ,
output  [8*C_PORT_NUM-1:0]  G_REARR_O ,
output  [8*C_PORT_NUM-1:0]  B_REARR_O


    );
parameter C_PORT_NUM = 4 ;
    
genvar i,j,k ;


//assign  G_O_1[7:0]  =  {G_O[5],G_O[4],G_O[3],G_O[2],G_O[1],G_O[0],G_O[7],G_O[6]};
//assign  B_O_1[7:0]  =  {B_O[5],B_O[4],B_O[3],B_O[2],B_O[1],B_O[0],B_O[7],B_O[6]};


wire [7:0]  R_I_m [C_PORT_NUM-1:0] ;
wire [7:0]  G_I_m [C_PORT_NUM-1:0] ;
wire [7:0]  B_I_m [C_PORT_NUM-1:0] ; 
`SINGLE_TO_BI_Nm1To0(8,C_PORT_NUM,R_I,R_I_m) 
`SINGLE_TO_BI_Nm1To0(8,C_PORT_NUM,G_I,G_I_m) 
`SINGLE_TO_BI_Nm1To0(8,C_PORT_NUM,B_I,B_I_m) 

wire [7:0]  R_I_rearr_m [C_PORT_NUM-1:0] ;
wire [7:0]  G_I_rearr_m [C_PORT_NUM-1:0] ;
wire [7:0]  B_I_rearr_m [C_PORT_NUM-1:0] ; 


generate for(i=0;i<=(C_PORT_NUM-1);i=i+1)begin
    assign  R_I_rearr_m[i] =  {R_I_m[5],R_I_m[4],R_I_m[3],R_I_m[2],R_I_m[1],R_I_m[0],R_I_m[7],R_I_m[6]} ;
    assign  G_I_rearr_m[i] =  {G_I_m[5],G_I_m[4],G_I_m[3],G_I_m[2],G_I_m[1],G_I_m[0],G_I_m[7],G_I_m[6]} ;
    assign  B_I_rearr_m[i] =  {B_I_m[5],B_I_m[4],B_I_m[3],B_I_m[2],B_I_m[1],B_I_m[0],B_I_m[7],B_I_m[6]} ;
    
end
endgenerate 


`BI_TO_SINGLE_Nm1To0(8,C_PORT_NUM,R_I_rearr_m,R_REARR_O) 
`BI_TO_SINGLE_Nm1To0(8,C_PORT_NUM,G_I_rearr_m,G_REARR_O) 
`BI_TO_SINGLE_Nm1To0(8,C_PORT_NUM,B_I_rearr_m,B_REARR_O) 



    
endmodule


