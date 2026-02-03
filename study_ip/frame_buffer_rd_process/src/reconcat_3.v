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
// Create Date: 2023/07/13 13:02:35
// Design Name: 
// Module Name: reconcat_3
// Project Name: 
// Target Devices: 
//////////////////////////////////////////////////////////////////////////////////

module reconcat_3(
input                                  RST_I,
input                                  CLK_I,
input   [3:0]                          TARGET_BPC_I,
input                                  PIXEL_VS_I,
input                                  PIXEL_HS_I,
input                                  PIXEL_DE_I, //
output   [C_MAX_BPC*3*C_MAX_PORT_NUM-1:0] PIXEL_DATA_O,  //例如，将6位色深填充为10位，适配native接口
                                                        //{R10  G10   B10},{R10  G10   B10},{R10  G10   B10},{R10  G10   B10}
output   reg                            PIXEL_VS_O=0,
output   reg                            PIXEL_HS_O=0,
output   reg                            PIXEL_DE_O=0,
input   [C_MAX_BPC*3*C_MAX_PORT_NUM-1:0] PIXEL_DATA_I //输入为像素内紧凑数据
                                                      //   {R10  G10   B10},{R10  G10   B10},{R10  G10   B10},{R10  G10   B10}
                                                      //   {R8 G8 B8  6'b0},{R8 G8 B8  6'b0},{R8 G8 B8  6'b0},{R8 G8 B8  6'b0}  
                                                      //or {R6 G6 B6 12'b0},{R6 G6 B6 12'b0},{R6 G6 B6 12'b0},{R6 G6 B6 12'b0} 
);

parameter C_MAX_PORT_NUM        = 4;//valid: 1 2 4 8
parameter C_MAX_BPC             = 8;//valid : 6 8 10 12 16

genvar i,j,k;

always@(posedge CLK_I)PIXEL_VS_O <= PIXEL_VS_I;
always@(posedge CLK_I)PIXEL_HS_O <= PIXEL_HS_I;
always@(posedge CLK_I)PIXEL_DE_O <= PIXEL_DE_I;


wire [C_MAX_BPC*3-1:0] pixel_data_i_m [C_MAX_PORT_NUM-1:0];
`SINGLE_TO_BI_Nm1To0((C_MAX_BPC*3),C_MAX_PORT_NUM,PIXEL_DATA_I,pixel_data_i_m)


reg [C_MAX_BPC*3-1:0] pixel_data_o_m [C_MAX_PORT_NUM-1:0];


generate for(i=0;i<=C_MAX_PORT_NUM-1;i=i+1)begin
    always@(posedge CLK_I)begin
        if(RST_I)begin
            pixel_data_o_m[i] <= 0;
        end
        case(TARGET_BPC_I)
           // 6 :pixel_data_o_m[i] <= C_MAX_BPC>=6 ? {{(C_MAX_BPC-6){1'b0}},pixel_data_i_m[i][17:12],{(C_MAX_BPC-6){1'b0}},pixel_data_i_m[i][11:6],{(C_MAX_BPC-6){1'b0}},pixel_data_i_m[i][5:0]}       : pixel_data_o_m[i];
            8 :pixel_data_o_m[i] <= C_MAX_BPC>=8 ? {{(C_MAX_BPC-8){1'b0}},pixel_data_i_m[i][23:16],{(C_MAX_BPC-8){1'b0}},pixel_data_i_m[i][15:8],{(C_MAX_BPC-8){1'b0}},pixel_data_i_m[i][7:0]}       : pixel_data_o_m[i];
            10:pixel_data_o_m[i] <= C_MAX_BPC>=10 ?{{(C_MAX_BPC-10){1'b0}},pixel_data_i_m[i][29:20],{(C_MAX_BPC-10){1'b0}},pixel_data_i_m[i][19:10],{(C_MAX_BPC-10){1'b0}},pixel_data_i_m[i][9:0]}   : pixel_data_o_m[i];
            12:pixel_data_o_m[i] <= C_MAX_BPC>=12 ? {{(C_MAX_BPC-12){1'b0}},pixel_data_i_m[i][35:24],{(C_MAX_BPC-12){1'b0}},pixel_data_i_m[i][23:12],{(C_MAX_BPC-12){1'b0}},pixel_data_i_m[i][11:0]} : pixel_data_o_m[i];
            16:pixel_data_o_m[i] <= C_MAX_BPC>=16 ? {{(C_MAX_BPC-16){1'b0}},pixel_data_i_m[i][47:32],{(C_MAX_BPC-16){1'b0}},pixel_data_i_m[i][31:16],{(C_MAX_BPC-16){1'b0}},pixel_data_i_m[i][15:0]} : pixel_data_o_m[i];
            default:pixel_data_o_m[i] <= C_MAX_BPC>=8 ? {{(C_MAX_BPC-8){1'b0}},pixel_data_i_m[i][23:16],{(C_MAX_BPC-8){1'b0}},pixel_data_i_m[i][15:8],{(C_MAX_BPC-8){1'b0}},pixel_data_i_m[i][7:0]}       : pixel_data_o_m[i];
        endcase
    end
end
endgenerate

  
`BI_TO_SINGLE_Nm1To0((C_MAX_BPC*3),C_MAX_PORT_NUM,pixel_data_o_m,PIXEL_DATA_O)

   
    
endmodule
