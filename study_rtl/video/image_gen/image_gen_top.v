`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/05/09 15:17:44
// Design Name: 
// Module Name: image_gen
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

module image_gen_top
#( parameter PIXELS_PER_CLOCK = 4//相当于路数
)
(
input CLK_50M_I,
input RESET_I,
output [PIXELS_PER_CLOCK-1:0] lvds_clk_p ,//[PORT_NUM-1:0]
output [PIXELS_PER_CLOCK-1:0] lvds_clk_n ,//[PORT_NUM-1:0] 
output [4*PIXELS_PER_CLOCK-1:0] lvds_data_p,//[LANE_NUM*PORT_NUM-1:0]
output [4*PIXELS_PER_CLOCK-1:0] lvds_data_n//[LANE_NUM*PORT_NUM-1:0]

);
genvar i,j,k;


assign HACTIVE   = 960;
assign HFP       = 44;
assign HSYNC     = 74;   
assign HBP       = 22;            
assign VACTIVE   = 4320;
assign VFP       = 6 ;        
assign VSYNC     = 10;
assign VBP       = 164;

  
clk_wiz_image_gen_0 clk_wiz_image_gen_0_u
(
.clk_out1(pixel_clk_div2_mult7),
.clk_out2(pixel_clk_div2),
.clk_out3(pixel_clk),
.reset(RESET_I),
.locked(locked),
.clk_in1(CLK_50M_I)
); 

wire [PIXELS_PER_CLOCK-1:0] hs;
wire [PIXELS_PER_CLOCK-1:0] vs;
wire [PIXELS_PER_CLOCK-1:0] de;

generate for(i=0;i<=(PIXELS_PER_CLOCK-1);i=i+1)begin:CORE_TPG  
tpg_core_image_gen core_tpg_u(
    .PIXEL_CLK_I(pixel_clk),//像素时钟
    .RESET_I    (locked),
    .ALLIGN_VS_I(0),//____|———————— 内部会做缓存处理，之所以这样做是等待一行结束
    .ALLIGN_DE_I(0),//____|———————— 内部会做缓存处理，之所以这样做是等待一行结束
    .HS_O       (hs[i]),//目标输出
    .VS_O       (vs[i]),//目标输出
    .DE_O       (de[i]),//目标输出
    .HACTIVE_I  (HACTIVE/PIXELS_PER_CLOCK),//参数
    .HFP_I      (HFP    /PIXELS_PER_CLOCK),//参数 
    .HBP_I      (HBP    /PIXELS_PER_CLOCK),//参数 
    .HSYNC_I    (HSYNC  /PIXELS_PER_CLOCK),//参数 
    .VACTIVE_I  (VACTIVE                 ),//参数 
    .VFP_I      (VFP                     ),//参数 
    .VBP_I      (VBP                     ),//参数 
    .VSYNC_I    (VSYNC                   ),//参数
    .active_x   (),//辅助信息
    .active_y   (),//辅助信息
    .enable_de_allign(0),
    .enable_vs_allign(0),
    .de_delay_num(0), //额外延时的DE数量；默认为0
    .vs_delay_num(0)  //额外延时的HS数量；默认为0
    );   
end
endgenerate   
    

wire [7:0] rgb_r; assign rgb_r = 8'b11111111;
wire [7:0] rgb_g; assign rgb_g = 8'b10101010;
wire [7:0] rgb_b; assign rgb_b = 8'b01010101;


reg [4*PIXELS_PER_CLOCK*7-1:0] lvds_data;
generate for(i=0;i<=(PIXELS_PER_CLOCK-1);i=i+1)begin:LVDS_DATA  
    always@(posedge pixel_clk)begin
        if(~locked) begin 
            lvds_data[i*28+:28] <= 28'b0;
        end 
        else begin
            lvds_data[i*28+:28] <= {rgb_r[6],rgb_b[2],rgb_g[1],rgb_r[0],rgb_r[7],rgb_b[3],rgb_g[2],
                                    rgb_r[1],rgb_g[6],rgb_b[4],rgb_g[3],rgb_r[2],rgb_g[7],rgb_b[5], 
                                    rgb_g[4],rgb_r[3],rgb_b[6],hs[i],rgb_g[5],rgb_r[4],rgb_b[7],
                                    vs[i],rgb_b[0],rgb_r[5],1'b0,de[i],rgb_b[1],rgb_g[0]};
        end                       
    end
end
endgenerate


//0+/-：R0(24), R1(20), R2(16), R3(12), R4(8) , R5(4), G0(0)
//1+/-：G1(25), G2(21), G3(17), G4(13), G5(9) , B0(5), B1(1)
//2+/-：B2(26), B3(22), B4(18), B5(14), HS(10), VS(6), DE(2)
//3+/-：R6(27), R7(23), G6(19), G7(15), B6(11), B7(7), 0 (3)


lvds_7to1_ddr_unify_image_gen 
#(.PORT_NUM(PIXELS_PER_CLOCK),
  .LANE_NUM(4))
lvds_7to1_ddr_unify_v2_u(
    .pixel_clk_div2_mult7(pixel_clk_div2_mult7),
    .pixel_clk_div2      (pixel_clk_div2),
    .pixel_clk           (pixel_clk),
    .pixel_clk_locked    (locked),
    .in_lvds_data        (lvds_data),//[LANE_NUM*PORT_NUM*7-1:0] ~pixel_clk
    .lvds_clk_p          (lvds_clk_p ),//[PORT_NUM-1:0]
    .lvds_clk_n          (lvds_clk_n ),//[PORT_NUM-1:0] 
    .lvds_data_p         (lvds_data_p),//[LANE_NUM*PORT_NUM-1:0]
    .lvds_data_n         (lvds_data_n)//[LANE_NUM*PORT_NUM-1:0]
    );
 
    
endmodule
