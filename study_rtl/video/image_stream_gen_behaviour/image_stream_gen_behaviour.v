`timescale 1ns / 1ps
`define VS_1 4'b1111
`define VS_0 4'b0000
`define HS_1 4'b1111
`define HS_0 4'b0000
`define DE_1 4'b1111
`define DE_0 4'b0000
`define PIXEL_0 8'b00000000
`define BI_TO_SINGLE(a,b,in,out)    generate for(i=1;i<=b;i=i+1)begin assign out[a*b-1-(a-1)*(i-1)-(i-1):a*b-1-(a-1)*(i)-(i-1)] = in[i];end endgenerate
`define SINGLE_TO_BI(a,b,in,out)    generate for(i=1;i<=b;i=i+1)begin assign out[i] = in[a*b-1-(a-1)*(i-1)-(i-1):a*b-1-(a-1)*(i)-(i-1)];end endgenerate
`define TRI_TO_SINGLE(a,b,c,in,out) generate for(i=1;i<=b;i=i+1)begin for(j=1;j<=c;j=j+1)begin assign out[a*b*c-1-(a-1)* ((i-1)*c+(j-1)) - ((i-1)*c+(j-1)) :a*b*c-1-(a-1)* ((i-1)*c+(j-1)+1) - ((i-1)*c+(j-1)) ] = in[i][j];end end endgenerate
`define SINGLE_TO_TRI(a,b,c,in,out) generate for(i=1;i<=b;i=i+1)begin for(j=1;j<=c;j=j+1)begin assign out[i][j] = in[a*b*c-1-(a-1)* ((i-1)*c+(j-1)) - ((i-1)*c+(j-1)) :a*b*c-1-(a-1)* ((i-1)*c+(j-1)+1) - ((i-1)*c+(j-1)) ];end end endgenerate
`define FOUR_TO_SINGLE(a,b,c,d,in,out) generate for(i=1;i<=b;i=i+1)begin for(j=1;j<=c;j=j+1)begin for(k=1;k<=d;k=k+1)begin assign out[(b-i)*(c*d*a)-1 +(c-j)*(d*a) +(d-k)*a +(a-1)+1:(b-i)*(c*d*a)-1 +(c-j)*(d*a) +(d-k)*a+1] = in[i][j][k]; end end end endgenerate
`define SINGLE_TO_FOUR(a,b,c,d,in,out) generate for(i=1;i<=b;i=i+1)begin for(j=1;j<=c;j=j+1)begin for(k=1;k<=d;k=k+1)begin assign out[i][j][k] = in[(b-i)*(c*d*a)-1 +(c-j)*(d*a) +(d-k)*a +(a-1)+1:(b-i)*(c*d*a)-1 +(c-j)*(d*a) +(d-k)*a+1]; end end end endgenerate

//////////////////////////////////////////////////////////////////////////////////
// Create Date: 2021/06/11 11:57:42
// Design Name: 
// Module Name: image_stream_gen_behaviour
//////////////////////////////////////////////////////////////////////////////////
//pixel_clk
//bit_clk
module image_stream_gen_behaviour(
input  PIXEL_CLK_DUTY50_I,
input  EN_I,//电平触发
output [3:0]  LVDS_CLK_O,
output [15:0] LVDS_DATA_O
);
parameter PIXEL_CLK_PERIOD  = 10;
parameter IMAGE_SOURCE = "E:/ZHUYUEFENG_PROJECT/VIT8/VIT8_EDP/rtl/image_stream_gen_behaviour/sim_data_8x8_black.txt";
parameter PORT0_DELAY_PIXEL_CLK_NUM = 0;
parameter PORT1_DELAY_PIXEL_CLK_NUM = 0;
parameter PORT2_DELAY_PIXEL_CLK_NUM = 0;
parameter PORT3_DELAY_PIXEL_CLK_NUM = 0;
//////////////////////////////////////////////////////////////////////////////////
//模拟错位数据
reg bit_clk;
delay_reg_fJD5WSJKF 
    #(.WIDTH(4),
      .LEN(PORT0_DELAY_PIXEL_CLK_NUM*7))
     delay_u1(
    .CLK_I(bit_clk),
    .IN_I(lvds_data_oo[3:0]),
    .OUT_O(LVDS_DATA_O[3:0]));

delay_reg_fJD5WSJKF 
    #(.WIDTH(4),
      .LEN(PORT1_DELAY_PIXEL_CLK_NUM*7))
     delay_u2(
    .CLK_I(bit_clk),
    .IN_I(lvds_data_oo[7:4]),
    .OUT_O(LVDS_DATA_O[7:4]));

delay_reg_fJD5WSJKF 
    #(.WIDTH(4),
      .LEN(PORT2_DELAY_PIXEL_CLK_NUM*7))
     delay_u3(
    .CLK_I(bit_clk),
    .IN_I(lvds_data_oo[11:8]),
    .OUT_O(LVDS_DATA_O[11:8]));

    delay_reg_fJD5WSJKF 
    #(.WIDTH(4),
      .LEN(PORT3_DELAY_PIXEL_CLK_NUM*7))
     delay_u4(
    .CLK_I(bit_clk),
    .IN_I(lvds_data_oo[15:12]),
    .OUT_O(LVDS_DATA_O[15:12]));
//////////////////////////////////////////////////////////////////////////////////
wire [15:0] lvds_data_oo;//原始正确数据
wire [15:0] lvds_data_0;
reg [15:0] Lvds_data_1;
reg [15:0] Lvds_data_2;
always@(posedge bit_clk)Lvds_data_1 <= lvds_data_0;
always@(posedge bit_clk)Lvds_data_2 <= Lvds_data_1;
assign lvds_data_oo = Lvds_data_2;
//////////////////////////////////////////////////////////////////////////////////
genvar i,j,k;
//////////////////////////////////////////////////////////////////////////////////
localparam FREQ_MUTIPLY_NUM = 7; 
localparam RIGHT_SHIFT_TIME = PIXEL_CLK_PERIOD / 2.0 / FREQ_MUTIPLY_NUM;
localparam RIGHT_SHIFT_NUM  = 13;
//////////////////////////////////////////////////////////////////////////////////
//reg Start_buf;
//wire start_flag;
//always@(posedge bit_clk)Start_buf <= EN_I;
//assign start_flag = (EN_I == 1 && Start_buf==0)?1:0;
//////////////////////////////////////////////////////////////////////////////////

wire  [1:13] lvds_clk ;

assign #(1*RIGHT_SHIFT_TIME) lvds_clk[1]  = PIXEL_CLK_DUTY50_I;
assign #(2*RIGHT_SHIFT_TIME) lvds_clk[2]  = PIXEL_CLK_DUTY50_I;
assign #(3*RIGHT_SHIFT_TIME) lvds_clk[3]  = PIXEL_CLK_DUTY50_I;
assign #(4*RIGHT_SHIFT_TIME) lvds_clk[4]  = PIXEL_CLK_DUTY50_I;
assign #(5*RIGHT_SHIFT_TIME) lvds_clk[5]  = PIXEL_CLK_DUTY50_I;
assign #(6*RIGHT_SHIFT_TIME) lvds_clk[6]  = PIXEL_CLK_DUTY50_I;
assign #(7*RIGHT_SHIFT_TIME) lvds_clk[7]  = PIXEL_CLK_DUTY50_I;
assign #(1*RIGHT_SHIFT_TIME) lvds_clk[8]  = lvds_clk[7];
assign #(2*RIGHT_SHIFT_TIME) lvds_clk[9]  = lvds_clk[7];
assign #(3*RIGHT_SHIFT_TIME) lvds_clk[10] = lvds_clk[7];
assign #(4*RIGHT_SHIFT_TIME) lvds_clk[11] = lvds_clk[7];
assign #(5*RIGHT_SHIFT_TIME) lvds_clk[12] = lvds_clk[7];
assign #(6*RIGHT_SHIFT_TIME) lvds_clk[13] = lvds_clk[7];
                                 


always@(*)begin
    case({PIXEL_CLK_DUTY50_I,lvds_clk})
        14'b10000000111111: bit_clk = 1;
        14'b11000000011111: bit_clk = 0;
        14'b11100000001111: bit_clk = 1;
        14'b11110000000111: bit_clk = 0;
        14'b11111000000011: bit_clk = 1;
        14'b11111100000001: bit_clk = 0;
        14'b11111110000000: bit_clk = 1;
        14'b01111111000000: bit_clk = 0;
        14'b00111111100000: bit_clk = 1;
        14'b00011111110000: bit_clk = 0;
        14'b00001111111000: bit_clk = 1;
        14'b00000111111100: bit_clk = 0;
        14'b00000011111110: bit_clk = 1;
        14'b00000001111111: bit_clk = 0;
        default:bit_clk = 0;
    endcase
end

wire pixel_clk;
assign pixel_clk = lvds_clk[1] | PIXEL_CLK_DUTY50_I;
assign LVDS_CLK_O[0] = pixel_clk;
assign LVDS_CLK_O[1] = pixel_clk;
assign LVDS_CLK_O[2] = pixel_clk;
assign LVDS_CLK_O[3] = pixel_clk;
//////////////////////////////////////////////////////////////////////////////////
reg [23:0] data_row1[1:8];
reg [23:0] data_row2[1:8];
reg [23:0] data_row3[1:8];
reg [23:0] data_row4[1:8];
reg [23:0] data_row5[1:8];
reg [23:0] data_row6[1:8];
reg [23:0] data_row7[1:8];
reg [23:0] data_row8[1:8];

wire [24*8*8-1:0] data_iamge_8x8; 
wire [23:0] image[1:8][1:8];/////usefull  
assign data_iamge_8x8
       = {data_row1[1],data_row1[2],data_row1[3],data_row1[4],data_row1[5],data_row1[6],data_row1[7],data_row1[8]
         ,data_row2[1],data_row2[2],data_row2[3],data_row2[4],data_row2[5],data_row2[6],data_row2[7],data_row2[8]
         ,data_row3[1],data_row3[2],data_row3[3],data_row3[4],data_row3[5],data_row3[6],data_row3[7],data_row3[8]
         ,data_row4[1],data_row4[2],data_row4[3],data_row4[4],data_row4[5],data_row4[6],data_row4[7],data_row4[8]
         ,data_row5[1],data_row5[2],data_row5[3],data_row5[4],data_row5[5],data_row5[6],data_row5[7],data_row5[8]
         ,data_row6[1],data_row6[2],data_row6[3],data_row6[4],data_row6[5],data_row6[6],data_row6[7],data_row6[8]
         ,data_row7[1],data_row7[2],data_row7[3],data_row7[4],data_row7[5],data_row7[6],data_row7[7],data_row7[8]
         ,data_row8[1],data_row8[2],data_row8[3],data_row8[4],data_row8[5],data_row8[6],data_row8[7],data_row8[8]
         }; 
`SINGLE_TO_TRI(24,8,8,data_iamge_8x8,image)  
integer h;
initial begin
    h = $fopen(IMAGE_SOURCE,"r");
    $fscanf(h,"%h",data_row1);
    $fscanf(h,"%h",data_row2);
    $fscanf(h,"%h",data_row3);
    $fscanf(h,"%h",data_row4);
    $fscanf(h,"%h",data_row5);
    $fscanf(h,"%h",data_row6);
    $fscanf(h,"%h",data_row7);
    $fscanf(h,"%h",data_row8);
    $fclose(h);
end  
//////////////////////////////////////////////////////////////////////////////////
//pixel_clk
//bit_clk

reg [6:0] pixel1_lane1_7bit;
reg [6:0] pixel1_lane2_7bit;
reg [6:0] pixel1_lane3_7bit;
reg [6:0] pixel1_lane4_7bit;

reg [6:0] pixel2_lane1_7bit;
reg [6:0] pixel2_lane2_7bit;
reg [6:0] pixel2_lane3_7bit;
reg [6:0] pixel2_lane4_7bit;

reg [6:0] pixel3_lane1_7bit;
reg [6:0] pixel3_lane2_7bit;
reg [6:0] pixel3_lane3_7bit;
reg [6:0] pixel3_lane4_7bit;

reg [6:0] pixel4_lane1_7bit;
reg [6:0] pixel4_lane2_7bit;
reg [6:0] pixel4_lane3_7bit;
reg [6:0] pixel4_lane4_7bit;

assign lvds_data_0[0]  = pixel1_lane1_7bit[6];
assign lvds_data_0[1]  = pixel1_lane2_7bit[6];
assign lvds_data_0[2]  = pixel1_lane3_7bit[6];
assign lvds_data_0[3]  = pixel1_lane4_7bit[6];
                                          
assign lvds_data_0[4]  = pixel2_lane1_7bit[6];
assign lvds_data_0[5]  = pixel2_lane2_7bit[6];
assign lvds_data_0[6]  = pixel2_lane3_7bit[6];
assign lvds_data_0[7]  = pixel2_lane4_7bit[6];
                                         
assign lvds_data_0[8]  = pixel3_lane1_7bit[6];
assign lvds_data_0[9]  = pixel3_lane2_7bit[6];
assign lvds_data_0[10] = pixel3_lane3_7bit[6];
assign lvds_data_0[11] = pixel3_lane4_7bit[6];
                                          
assign lvds_data_0[12] = pixel4_lane1_7bit[6];
assign lvds_data_0[13] = pixel4_lane2_7bit[6];
assign lvds_data_0[14] = pixel4_lane3_7bit[6];
assign lvds_data_0[15] = pixel4_lane4_7bit[6];

reg [7:0] state = 0;
always@(negedge bit_clk)begin
    //if(start_flag==1)begin
    if(EN_I==1)begin
        //1~8行
        state = 11;
        repeat(8)begin//vs=1
            
            t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_1,`HS_1,`DE_0);//vs=1 hs=1 等待pixel_clk的上升沿
            t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_1,`HS_1,`DE_0);
            
            t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_1,`HS_0,`DE_0);//vs=1 hs=0
            t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_1,`HS_0,`DE_0);
            
            t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_1,`HS_0,`DE_0);//null data
            t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_1,`HS_0,`DE_0);
            
            t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_1,`HS_0,`DE_0);//vs=1 hs=0
            t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_1,`HS_0,`DE_0);
            
            t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_1,`HS_0,`DE_0);//vs=1 hs=0
            t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_1,`HS_0,`DE_0);
        end
        
        //8~16行
        state = 12;
        repeat(8)begin
            t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_1,`DE_0);//vs=1 hs=1
            t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_1,`DE_0);
            
            t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_0,`DE_0);//vs=1 hs=0
            t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_0,`DE_0);
            
            t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_0,`DE_0);//null data
            t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_0,`DE_0);
            
            t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_0,`DE_0);//vs=1 hs=0
            t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_0,`DE_0);
            
            t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_0,`DE_0);//vs=1 hs=0
            t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_0,`DE_0);
        end

        //数据第1行
        state = 1;
        t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_1,`DE_0);//vs=0 hs=1
        t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_1,`DE_0);
        
        t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_0,`DE_0);//vs=0 hs=0
        t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_0,`DE_0);
        
        t_send_4_pixel_vhd(image[1][1],image[1][2],image[1][3],image[1][4],`VS_0,`HS_0,`DE_1);
        t_send_4_pixel_vhd(image[1][5],image[1][6],image[1][7],image[1][8],`VS_0,`HS_0,`DE_1);
        t_send_4_pixel_vhd(image[1][1],image[1][2],image[1][3],image[1][4],`VS_0,`HS_0,`DE_1);
        t_send_4_pixel_vhd(image[1][5],image[1][6],image[1][7],image[1][8],`VS_0,`HS_0,`DE_1);
        t_send_4_pixel_vhd(image[1][1],image[1][2],image[1][3],image[1][4],`VS_0,`HS_0,`DE_1);
        t_send_4_pixel_vhd(image[1][5],image[1][6],image[1][7],image[1][8],`VS_0,`HS_0,`DE_1);
        t_send_4_pixel_vhd(image[1][1],image[1][2],image[1][3],image[1][4],`VS_0,`HS_0,`DE_1);
        t_send_4_pixel_vhd(image[1][5],image[1][6],image[1][7],image[1][8],`VS_0,`HS_0,`DE_1);
        
        t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_0,`DE_0);//vs=0 hs=0
        t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_0,`DE_0);
        
        t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_0,`DE_0);//vs=0 hs=0
        t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_0,`DE_0);
        
        //数据第2行
        state = 2;
        t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_1,`DE_0);//vs=0 hs=1
        t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_1,`DE_0);
        
        t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_0,`DE_0);//vs=0 hs=0
        t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_0,`DE_0);
        
        t_send_4_pixel_vhd(image[2][1],image[2][2],image[2][3],image[2][4],`VS_0,`HS_0,`DE_1);
        t_send_4_pixel_vhd(image[2][5],image[2][6],image[2][7],image[2][8],`VS_0,`HS_0,`DE_1);
        t_send_4_pixel_vhd(image[2][1],image[2][2],image[2][3],image[2][4],`VS_0,`HS_0,`DE_1);
        t_send_4_pixel_vhd(image[2][5],image[2][6],image[2][7],image[2][8],`VS_0,`HS_0,`DE_1);
        t_send_4_pixel_vhd(image[2][1],image[2][2],image[2][3],image[2][4],`VS_0,`HS_0,`DE_1);
        t_send_4_pixel_vhd(image[2][5],image[2][6],image[2][7],image[2][8],`VS_0,`HS_0,`DE_1);
        t_send_4_pixel_vhd(image[2][1],image[2][2],image[2][3],image[2][4],`VS_0,`HS_0,`DE_1);
        t_send_4_pixel_vhd(image[2][5],image[2][6],image[2][7],image[2][8],`VS_0,`HS_0,`DE_1);
        
        t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_0,`DE_0);//vs=0 hs=0
        t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_0,`DE_0);
        
        t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_0,`DE_0);//vs=0 hs=0
        t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_0,`DE_0);
        
        //数据第3行
        state = 3;
        t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_1,`DE_0);//vs=0 hs=1
        t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_1,`DE_0);
        
        t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_0,`DE_0);//vs=0 hs=0
        t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_0,`DE_0);
        
        t_send_4_pixel_vhd(image[3][1],image[3][2],image[3][3],image[3][4],`VS_0,`HS_0,`DE_1);
        t_send_4_pixel_vhd(image[3][5],image[3][6],image[3][7],image[3][8],`VS_0,`HS_0,`DE_1);
        t_send_4_pixel_vhd(image[3][1],image[3][2],image[3][3],image[3][4],`VS_0,`HS_0,`DE_1);
        t_send_4_pixel_vhd(image[3][5],image[3][6],image[3][7],image[3][8],`VS_0,`HS_0,`DE_1);
        t_send_4_pixel_vhd(image[3][1],image[3][2],image[3][3],image[3][4],`VS_0,`HS_0,`DE_1);
        t_send_4_pixel_vhd(image[3][5],image[3][6],image[3][7],image[3][8],`VS_0,`HS_0,`DE_1);
        t_send_4_pixel_vhd(image[3][1],image[3][2],image[3][3],image[3][4],`VS_0,`HS_0,`DE_1);
        t_send_4_pixel_vhd(image[3][5],image[3][6],image[3][7],image[3][8],`VS_0,`HS_0,`DE_1);
        
        t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_0,`DE_0);//vs=0 hs=0
        t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_0,`DE_0);
        
        t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_0,`DE_0);//vs=0 hs=0
        t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_0,`DE_0);
        
        //数据第4行
        state = 4;
        t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_1,`DE_0);//vs=0 hs=1
        t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_1,`DE_0);
        
        t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_0,`DE_0);//vs=0 hs=0
        t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_0,`DE_0);
        
        t_send_4_pixel_vhd(image[4][1],image[4][2],image[4][3],image[4][4],`VS_0,`HS_0,`DE_1);
        t_send_4_pixel_vhd(image[4][5],image[4][6],image[4][7],image[4][8],`VS_0,`HS_0,`DE_1);
        t_send_4_pixel_vhd(image[4][1],image[4][2],image[4][3],image[4][4],`VS_0,`HS_0,`DE_1);
        t_send_4_pixel_vhd(image[4][5],image[4][6],image[4][7],image[4][8],`VS_0,`HS_0,`DE_1);
        t_send_4_pixel_vhd(image[4][1],image[4][2],image[4][3],image[4][4],`VS_0,`HS_0,`DE_1);
        t_send_4_pixel_vhd(image[4][5],image[4][6],image[4][7],image[4][8],`VS_0,`HS_0,`DE_1);
        t_send_4_pixel_vhd(image[4][1],image[4][2],image[4][3],image[4][4],`VS_0,`HS_0,`DE_1);
        t_send_4_pixel_vhd(image[4][5],image[4][6],image[4][7],image[4][8],`VS_0,`HS_0,`DE_1);
        
        t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_0,`DE_0);//vs=0 hs=0
        t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_0,`DE_0);
        
        t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_0,`DE_0);//vs=0 hs=0
        t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_0,`DE_0);
        
        //数据第5行
        state = 5;
        t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_1,`DE_0);//vs=0 hs=1
        t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_1,`DE_0);
        
        t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_0,`DE_0);//vs=0 hs=0
        t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_0,`DE_0);
        
        t_send_4_pixel_vhd(image[5][1],image[5][2],image[5][3],image[5][4],`VS_0,`HS_0,`DE_1);
        t_send_4_pixel_vhd(image[5][5],image[5][6],image[5][7],image[5][8],`VS_0,`HS_0,`DE_1);
        t_send_4_pixel_vhd(image[5][1],image[5][2],image[5][3],image[5][4],`VS_0,`HS_0,`DE_1);
        t_send_4_pixel_vhd(image[5][5],image[5][6],image[5][7],image[5][8],`VS_0,`HS_0,`DE_1);
        t_send_4_pixel_vhd(image[5][1],image[5][2],image[5][3],image[5][4],`VS_0,`HS_0,`DE_1);
        t_send_4_pixel_vhd(image[5][5],image[5][6],image[5][7],image[5][8],`VS_0,`HS_0,`DE_1);
        t_send_4_pixel_vhd(image[5][1],image[5][2],image[5][3],image[5][4],`VS_0,`HS_0,`DE_1);
        t_send_4_pixel_vhd(image[5][5],image[5][6],image[5][7],image[5][8],`VS_0,`HS_0,`DE_1);
        
        t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_0,`DE_0);//vs=0 hs=0
        t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_0,`DE_0);
        
        t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_0,`DE_0);//vs=0 hs=0
        t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_0,`DE_0);
        
        //数据第6行
        state = 6;
        t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_1,`DE_0);//vs=0 hs=1
        t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_1,`DE_0);
        
        t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_0,`DE_0);//vs=0 hs=0
        t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_0,`DE_0);
        
        t_send_4_pixel_vhd(image[6][1],image[6][2],image[6][3],image[6][4],`VS_0,`HS_0,`DE_1);
        t_send_4_pixel_vhd(image[6][5],image[6][6],image[6][7],image[6][8],`VS_0,`HS_0,`DE_1);
        t_send_4_pixel_vhd(image[6][1],image[6][2],image[6][3],image[6][4],`VS_0,`HS_0,`DE_1);
        t_send_4_pixel_vhd(image[6][5],image[6][6],image[6][7],image[6][8],`VS_0,`HS_0,`DE_1);
        t_send_4_pixel_vhd(image[6][1],image[6][2],image[6][3],image[6][4],`VS_0,`HS_0,`DE_1);
        t_send_4_pixel_vhd(image[6][5],image[6][6],image[6][7],image[6][8],`VS_0,`HS_0,`DE_1);
        t_send_4_pixel_vhd(image[6][1],image[6][2],image[6][3],image[6][4],`VS_0,`HS_0,`DE_1);
        t_send_4_pixel_vhd(image[6][5],image[6][6],image[6][7],image[6][8],`VS_0,`HS_0,`DE_1);
        
        t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_0,`DE_0);//vs=0 hs=0
        t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_0,`DE_0);
        
        t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_0,`DE_0);//vs=0 hs=0
        t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_0,`DE_0);
        
        //数据第7行
        state = 7;
        t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_1,`DE_0);//vs=0 hs=1
        t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_1,`DE_0);
        
        t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_0,`DE_0);//vs=0 hs=0
        t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_0,`DE_0);
        
        t_send_4_pixel_vhd(image[7][1],image[7][2],image[7][3],image[7][4],`VS_0,`HS_0,`DE_1);
        t_send_4_pixel_vhd(image[7][5],image[7][6],image[7][7],image[7][8],`VS_0,`HS_0,`DE_1);
        t_send_4_pixel_vhd(image[7][1],image[7][2],image[7][3],image[7][4],`VS_0,`HS_0,`DE_1);
        t_send_4_pixel_vhd(image[7][5],image[7][6],image[7][7],image[7][8],`VS_0,`HS_0,`DE_1);
        t_send_4_pixel_vhd(image[7][1],image[7][2],image[7][3],image[7][4],`VS_0,`HS_0,`DE_1);
        t_send_4_pixel_vhd(image[7][5],image[7][6],image[7][7],image[7][8],`VS_0,`HS_0,`DE_1);
        t_send_4_pixel_vhd(image[7][1],image[7][2],image[7][3],image[7][4],`VS_0,`HS_0,`DE_1);
        t_send_4_pixel_vhd(image[7][5],image[7][6],image[7][7],image[7][8],`VS_0,`HS_0,`DE_1);
        
        t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_0,`DE_0);//vs=0 hs=0
        t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_0,`DE_0);
        
        t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_0,`DE_0);//vs=0 hs=0
        t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_0,`DE_0);
        
        //数据第8行
        state = 8;
        t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_1,`DE_0);//vs=0 hs=1
        t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_1,`DE_0);
        
        t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_0,`DE_0);//vs=0 hs=0
        t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_0,`DE_0);
        
        t_send_4_pixel_vhd(image[8][1],image[8][2],image[8][3],image[8][4],`VS_0,`HS_0,`DE_1);
        t_send_4_pixel_vhd(image[8][5],image[8][6],image[8][7],image[8][8],`VS_0,`HS_0,`DE_1);
        t_send_4_pixel_vhd(image[8][1],image[8][2],image[8][3],image[8][4],`VS_0,`HS_0,`DE_1);
        t_send_4_pixel_vhd(image[8][5],image[8][6],image[8][7],image[8][8],`VS_0,`HS_0,`DE_1);
        t_send_4_pixel_vhd(image[8][1],image[8][2],image[8][3],image[8][4],`VS_0,`HS_0,`DE_1);
        t_send_4_pixel_vhd(image[8][5],image[8][6],image[8][7],image[8][8],`VS_0,`HS_0,`DE_1);
        t_send_4_pixel_vhd(image[8][1],image[8][2],image[8][3],image[8][4],`VS_0,`HS_0,`DE_1);
        t_send_4_pixel_vhd(image[8][5],image[8][6],image[8][7],image[8][8],`VS_0,`HS_0,`DE_1);
        
        t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_0,`DE_0);//vs=0 hs=0
        t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_0,`DE_0);
        
        t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_0,`DE_0);//vs=0 hs=0
        t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_0,`DE_0);
        
        //最后16行
        state = 20;
        repeat(16)begin
            t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_1,`DE_0);//vs=1 hs=1
            t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_1,`DE_0);
            
            t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_0,`DE_0);//vs=1 hs=0
            t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_0,`DE_0);
            
            t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_0,`DE_0);//null data
            t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_0,`DE_0);
            
            t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_0,`DE_0);//vs=1 hs=0
            t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_0,`DE_0);
            
            t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_0,`DE_0);//vs=1 hs=0
            t_send_4_pixel_vhd(`PIXEL_0,`PIXEL_0,`PIXEL_0,`PIXEL_0,`VS_0,`HS_0,`DE_0);
        end
        state = 0;

    end
end


reg flag_for_test = 0;
task t_send_4_pixel_vhd;//send lvds 4 lanes
input [23:0] pixel_1;
input [23:0] pixel_2;
input [23:0] pixel_3;
input [23:0] pixel_4;
input [3:0] vs_1_2_3_4;
input [3:0] hs_1_2_3_4;
input [3:0] de_1_2_3_4;

reg [7:0] pixel1_r;
reg [7:0] pixel1_g;
reg [7:0] pixel1_b;
reg [0:0] pixel1_hs;
reg [0:0] pixel1_vs;
reg [0:0] pixel1_de;

reg [7:0] pixel2_r;
reg [7:0] pixel2_g;
reg [7:0] pixel2_b;
reg [0:0] pixel2_hs;
reg [0:0] pixel2_vs;
reg [0:0] pixel2_de;

reg [7:0] pixel3_r;
reg [7:0] pixel3_g;
reg [7:0] pixel3_b;
reg [0:0] pixel3_hs;
reg [0:0] pixel3_vs;
reg [0:0] pixel3_de;

reg [7:0] pixel4_r;
reg [7:0] pixel4_g;
reg [7:0] pixel4_b;
reg [0:0] pixel4_hs;
reg [0:0] pixel4_vs;
reg [0:0] pixel4_de;

begin 
    pixel1_r  = pixel_1[23:16];
    pixel1_g  = pixel_1[15:8];
    pixel1_b  = pixel_1[7:0];
    pixel1_hs = hs_1_2_3_4[3];
    pixel1_vs = vs_1_2_3_4[3];
    pixel1_de = de_1_2_3_4[3];
    
    pixel2_r  = pixel_2[23:16];
    pixel2_g  = pixel_2[15:8];
    pixel2_b  = pixel_2[7:0];
    pixel2_hs = hs_1_2_3_4[2];
    pixel2_vs = vs_1_2_3_4[2];
    pixel2_de = de_1_2_3_4[2];
    
    pixel3_r  = pixel_3[23:16];
    pixel3_g  = pixel_3[15:8];
    pixel3_b  = pixel_3[7:0];
    pixel3_hs = hs_1_2_3_4[1];
    pixel3_vs = vs_1_2_3_4[1];
    pixel3_de = de_1_2_3_4[1];
    
    pixel4_r  = pixel_4[23:16];
    pixel4_g  = pixel_4[15:8];
    pixel4_b  = pixel_4[7:0];
    pixel4_hs = hs_1_2_3_4[0];
    pixel4_vs = vs_1_2_3_4[0];
    pixel4_de = de_1_2_3_4[0];
    
    @(posedge pixel_clk)begin
        pixel1_lane1_7bit = f_reverse ({pixel1_r[0],pixel1_r[1],pixel1_r[2],pixel1_r[3],pixel1_r[4],pixel1_r[5],pixel1_g[0]});//data[0]
        pixel1_lane2_7bit = f_reverse ({pixel1_g[1],pixel1_g[2],pixel1_g[3],pixel1_g[4],pixel1_g[5],pixel1_b[0],pixel1_b[1]});
        pixel1_lane3_7bit = f_reverse ({pixel1_b[2],pixel1_b[3],pixel1_b[4],pixel1_b[5],pixel1_hs  ,pixel1_vs  ,pixel1_de  });
        pixel1_lane4_7bit = f_reverse ({pixel1_r[6],pixel1_r[7],pixel1_g[6],pixel1_g[7],pixel1_b[6],pixel1_b[7],1'b0       });
        
        pixel2_lane1_7bit = f_reverse({pixel2_r[0],pixel2_r[1],pixel2_r[2],pixel2_r[3],pixel2_r[4],pixel2_r[5],pixel2_g[0]});
        pixel2_lane2_7bit = f_reverse({pixel2_g[1],pixel2_g[2],pixel2_g[3],pixel2_g[4],pixel2_g[5],pixel2_b[0],pixel2_b[1]});
        pixel2_lane3_7bit = f_reverse({pixel2_b[2],pixel2_b[3],pixel2_b[4],pixel2_b[5],pixel2_hs  ,pixel2_vs  ,pixel2_de  });
        pixel2_lane4_7bit = f_reverse({pixel2_r[6],pixel2_r[7],pixel2_g[6],pixel2_g[7],pixel2_b[6],pixel2_b[7],1'b0       });

        pixel3_lane1_7bit = f_reverse({pixel3_r[0],pixel3_r[1],pixel3_r[2],pixel3_r[3],pixel3_r[4],pixel3_r[5],pixel3_g[0]});
        pixel3_lane2_7bit = f_reverse({pixel3_g[1],pixel3_g[2],pixel3_g[3],pixel3_g[4],pixel3_g[5],pixel3_b[0],pixel3_b[1]});
        pixel3_lane3_7bit = f_reverse({pixel3_b[2],pixel3_b[3],pixel3_b[4],pixel3_b[5],pixel3_hs  ,pixel3_vs  ,pixel3_de  });
        pixel3_lane4_7bit = f_reverse({pixel3_r[6],pixel3_r[7],pixel3_g[6],pixel3_g[7],pixel3_b[6],pixel3_b[7],1'b0       });

        pixel4_lane1_7bit = f_reverse({pixel4_r[0],pixel4_r[1],pixel4_r[2],pixel4_r[3],pixel4_r[4],pixel4_r[5],pixel4_g[0]});
        pixel4_lane2_7bit = f_reverse({pixel4_g[1],pixel4_g[2],pixel4_g[3],pixel4_g[4],pixel4_g[5],pixel4_b[0],pixel4_b[1]});
        pixel4_lane3_7bit = f_reverse({pixel4_b[2],pixel4_b[3],pixel4_b[4],pixel4_b[5],pixel4_hs  ,pixel4_vs  ,pixel4_de  });
        pixel4_lane4_7bit = f_reverse({pixel4_r[6],pixel4_r[7],pixel4_g[6],pixel4_g[7],pixel4_b[6],pixel4_b[7],1'b0       });
        
        flag_for_test = ~flag_for_test;
        pixel1_lane1_7bit = pixel1_lane1_7bit;//<<1
        pixel1_lane2_7bit = pixel1_lane2_7bit;//<<1
        pixel1_lane3_7bit = pixel1_lane3_7bit;//<<1
        pixel1_lane4_7bit = pixel1_lane4_7bit;//<<1
        pixel2_lane1_7bit = pixel2_lane1_7bit;//<<1
        pixel2_lane2_7bit = pixel2_lane2_7bit;//<<1
        pixel2_lane3_7bit = pixel2_lane3_7bit;//<<1
        pixel2_lane4_7bit = pixel2_lane4_7bit;//<<1
        pixel3_lane1_7bit = pixel3_lane1_7bit;//<<1
        pixel3_lane2_7bit = pixel3_lane2_7bit;//<<1
        pixel3_lane3_7bit = pixel3_lane3_7bit;//<<1
        pixel3_lane4_7bit = pixel3_lane4_7bit;//<<1
        pixel4_lane1_7bit = pixel4_lane1_7bit;//<<1
        pixel4_lane2_7bit = pixel4_lane2_7bit;//<<1
        pixel4_lane3_7bit = pixel4_lane3_7bit;//<<1
        pixel4_lane4_7bit = pixel4_lane4_7bit;//<<1
    end
    repeat(6)begin
        @(posedge bit_clk)begin
            flag_for_test = ~flag_for_test;
            pixel1_lane1_7bit = pixel1_lane1_7bit<<1;
            pixel1_lane2_7bit = pixel1_lane2_7bit<<1;
            pixel1_lane3_7bit = pixel1_lane3_7bit<<1;
            pixel1_lane4_7bit = pixel1_lane4_7bit<<1;
            pixel2_lane1_7bit = pixel2_lane1_7bit<<1;
            pixel2_lane2_7bit = pixel2_lane2_7bit<<1;
            pixel2_lane3_7bit = pixel2_lane3_7bit<<1;
            pixel2_lane4_7bit = pixel2_lane4_7bit<<1;
            pixel3_lane1_7bit = pixel3_lane1_7bit<<1;
            pixel3_lane2_7bit = pixel3_lane2_7bit<<1;
            pixel3_lane3_7bit = pixel3_lane3_7bit<<1;
            pixel3_lane4_7bit = pixel3_lane4_7bit<<1;
            pixel4_lane1_7bit = pixel4_lane1_7bit<<1;
            pixel4_lane2_7bit = pixel4_lane2_7bit<<1;
            pixel4_lane3_7bit = pixel4_lane3_7bit<<1;
            pixel4_lane4_7bit = pixel4_lane4_7bit<<1;
        end
    end


end    
endtask


function [6:0] f_reverse;
input [6:0] in;
begin
    f_reverse[0] = in[6];
    f_reverse[1] = in[5];
    f_reverse[2] = in[4];
    f_reverse[3] = in[3];
    f_reverse[4] = in[2];
    f_reverse[5] = in[1];
    f_reverse[6] = in[0];
end
endfunction

endmodule




module reg_array_inst_ATGDGYA9(
CLK_I,
IN_I,
OUT_O
);
parameter WIDTH = 8;
///////////////////////////////////////////////////////////////////////////////
input CLK_I;
input [WIDTH-1:0] IN_I;
output [WIDTH-1:0] OUT_O;

reg [WIDTH-1:0] OUT_O;

always@(posedge CLK_I)begin
	OUT_O <= IN_I;
end

endmodule



module delay_reg_fJD5WSJKF(
CLK_I,
IN_I,
OUT_O
);
parameter WIDTH = 1;
parameter LEN   = 2;

input CLK_I;
input  [WIDTH-1:0] IN_I;
output [WIDTH-1:0] OUT_O;

wire [WIDTH-1:0] D [1:LEN+1];//1 ~ LEN+1

genvar i;
generate 
    if(LEN==0) assign OUT_O = IN_I;
    else begin
	for(i=1;i<=LEN;i=i+1)begin
		if(LEN>1)begin
			if(i==1)begin
				reg_array_inst_ATGDGYA9
					#(.WIDTH(WIDTH))
				reg_inst_array_u
				(
					.CLK_I(CLK_I),
					.IN_I(IN_I),
					.OUT_O(D[2])
				);
			end
			else if(i==LEN)begin
				reg_array_inst_ATGDGYA9
					#(.WIDTH(WIDTH))
				reg_inst_array_u
				(
					.CLK_I(CLK_I),
					.IN_I(D[i]),
					.OUT_O(OUT_O)
				);
			end
			else if(i<=LEN-1)begin
				reg_array_inst_ATGDGYA9
					#(.WIDTH(WIDTH))
				reg_inst_array_u
				(
					.CLK_I(CLK_I),
					.IN_I(D[i]),
					.OUT_O(D[i+1])
				);
			end
		end
		else if(LEN==1)begin
			reg_array_inst_ATGDGYA9
					#(.WIDTH(WIDTH))
				reg_inst_array_u
				(
					.CLK_I(CLK_I),
					.IN_I(IN_I),
					.OUT_O(OUT_O)
				);
		end	
	end
    end
endgenerate

endmodule
