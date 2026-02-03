`timescale 1ns / 1ps
`define BI_TO_SINGLE(a,b,in,out)    generate for(i=1;i<=b;i=i+1)begin assign out[a*b-1-(a-1)*(i-1)-(i-1):a*b-1-(a-1)*(i)-(i-1)] = in[i];end endgenerate
`define SINGLE_TO_BI(a,b,in,out)    generate for(i=1;i<=b;i=i+1)begin assign out[i] = in[a*b-1-(a-1)*(i-1)-(i-1):a*b-1-(a-1)*(i)-(i-1)];end endgenerate
`define TRI_TO_SINGLE(a,b,c,in,out) generate for(i=1;i<=b;i=i+1)begin for(j=1;j<=c;j=j+1)begin assign out[a*b*c-1-(a-1)* ((i-1)*c+(j-1)) - ((i-1)*c+(j-1)) :a*b*c-1-(a-1)* ((i-1)*c+(j-1)+1) - ((i-1)*c+(j-1)) ] = in[i][j];end end endgenerate
`define SINGLE_TO_TRI(a,b,c,in,out) generate for(i=1;i<=b;i=i+1)begin for(j=1;j<=c;j=j+1)begin assign out[i][j] = in[a*b*c-1-(a-1)* ((i-1)*c+(j-1)) - ((i-1)*c+(j-1)) :a*b*c-1-(a-1)* ((i-1)*c+(j-1)+1) - ((i-1)*c+(j-1)) ];end end endgenerate
`define FOUR_TO_SINGLE(a,b,c,d,in,out) generate for(i=1;i<=b;i=i+1)begin for(j=1;j<=c;j=j+1)begin for(k=1;k<=d;k=k+1)begin assign out[(b-i)*(c*d*a)-1 +(c-j)*(d*a) +(d-k)*a +(a-1)+1:(b-i)*(c*d*a)-1 +(c-j)*(d*a) +(d-k)*a+1] = in[i][j][k]; end end end endgenerate
`define SINGLE_TO_FOUR(a,b,c,d,in,out) generate for(i=1;i<=b;i=i+1)begin for(j=1;j<=c;j=j+1)begin for(k=1;k<=d;k=k+1)begin assign out[i][j][k] = in[(b-i)*(c*d*a)-1 +(c-j)*(d*a) +(d-k)*a +(a-1)+1:(b-i)*(c*d*a)-1 +(c-j)*(d*a) +(d-k)*a+1]; end end end endgenerate

//////////////////////////////////////////////////////////////////////////////////
// Create Date: 2021/06/11 14:29:04
// Design Name: 
// Module Name: tb_image_stream_gen_behaviour
//////////////////////////////////////////////////////////////////////////////////


module tb_image_stream_gen_behaviour();

reg clk = 0;

wire pixel_clk;
wire bit_clk;

wire [15:0]lvds_data;
wire [7:0] state;
reg En = 0;

always #2.5 clk = ~clk;

image_stream_gen_behaviour 
    #(
  //.IMAGE_SOURCE("E:/ZHUYUEFENG_PROJECT/VIT8/VIT8_EDP/rtl/image_stream_gen_behaviour/sim_data_8x8_red.txt"),
  //.IMAGE_SOURCE("E:/ZHUYUEFENG_PROJECT/VIT8/VIT8_EDP/rtl/image_stream_gen_behaviour/sim_data_8x8_green.txt"),
  //.IMAGE_SOURCE("E:/ZHUYUEFENG_PROJECT/VIT8/VIT8_EDP/rtl/image_stream_gen_behaviour/sim_data_8x8_blue.txt"),
    .IMAGE_SOURCE("E:/ZHUYUEFENG_PROJECT/VIT8/VIT8_EDP/rtl/image_stream_gen_behaviour/sim_data_8x8_black.txt"),
  //.IMAGE_SOURCE("E:/ZHUYUEFENG_PROJECT/VIT8/VIT8_EDP/rtl/image_stream_gen_behaviour/sim_data_8x8_white.txt"),
  //.IMAGE_SOURCE("E:/ZHUYUEFENG_PROJECT/VIT8/VIT8_EDP/rtl/image_stream_gen_behaviour/sim_data_8x8_random.txt"),
    .PIXEL_CLK_PERIOD(5)
  )
    uut(
    .PIXEL_CLK_DUTY50_I(clk),
    .LVDS_CLK_O( ),//[3:0]
    .LVDS_DATA_O(lvds_data),//[15:0]
    .EN_I(En)
    );

assign pixel_clk = uut.pixel_clk;
assign bit_clk =uut.bit_clk; 
assign state = uut.state;

 
top_1to7_ddr_rx #(
.LVDS_PORT = 4,
.CH_NUM    = 4
)(
.ref_Clk,
.i_rst,
.UHD_EN,                                                                                        
.lvds_clk_p,
.lvds_clk_n,                                                                                         
.lvds_data_p,
.lvds_data_n, 
.rx_pixel_clk,
.rx_mmcm_lckdpsbs,
.rxlvds_data        
);

 
 
initial begin
    En = 0;
    
    #1000;
    En = 1;
    //#200;
    //En = 0;
    //#4000;
end

endmodule







