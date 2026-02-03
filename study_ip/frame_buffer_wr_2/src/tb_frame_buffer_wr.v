`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/10 10:16:48
// Design Name: 
// Module Name: tb_frame_buffer_wr

//////////////////////////////////////////////////////////////////////////////////


module tb_frame_buffer_wr(

    );

parameter C_MAX_PORT_NUM           =  4 ;
parameter C_MAX_BPC                =  8 ;
parameter C_MAX_MEM_BYTES          =  8 ;
parameter C_MEM_BYTES_DEFAULT      =  3 ;//<= C_MAX_MEM_BYTES
parameter C_COLOR_SPACE_DEFAULT    =  3 ;//out format
parameter C_HACTIVE_DEFAULT        =  600 ;
parameter C_VACTIVE_DEFAULT        =  480 ;

localparam [15:0] C_DATA_IN_WIDTH        =  C_MAX_MEM_BYTES*8 * C_MAX_PORT_NUM;
localparam [15:0] C_FIFO_IN_WIDTH        =  f_upper(C_DATA_IN_WIDTH) ; //向上找最近的典型值

reg pclk;
always #5 pclk =~pclk;

wire hs;
wire vs;
wire de;
wire [3:0] hs2;
wire [3:0] vs2;
wire [3:0] de2;

wire [31:0] r2;
wire [31:0] g2;
wire [31:0] b2;

reg reset ;

reg mclk;
always #1 mclk = ~mclk;


wire pixel_vs_0 ;
wire pixel_hs_0 ;
wire pixel_de_0 ;
wire [C_MAX_BPC*3*C_MAX_PORT_NUM-1:0] pixel_data_0;

wire pixel_vs_1 ;
wire pixel_hs_1 ;
wire pixel_de_1 ;
wire [C_MAX_BPC*3*C_MAX_PORT_NUM-1:0] pixel_data_1;

wire pixel_vs_2 ;
wire pixel_hs_2 ;
wire pixel_de_2 ;
wire [C_MAX_MEM_BYTES*8*C_MAX_PORT_NUM-1:0] pixel_data_2;
   
wire pixel_vs_3 ;
wire pixel_hs_3 ;
wire pixel_de_3 ;
wire [C_MAX_MEM_BYTES*8*C_MAX_PORT_NUM-1:0] pixel_data_3;

assign pixel_vs_0   = frame_buffer_wr_u.pixel_vs_0;
assign pixel_hs_0   = frame_buffer_wr_u.pixel_hs_0;
assign pixel_de_0   = frame_buffer_wr_u.pixel_de_0;
assign pixel_data_0 = frame_buffer_wr_u.pixel_data_0;

assign pixel_vs_1   = frame_buffer_wr_u.pixel_vs_1;
assign pixel_hs_1   = frame_buffer_wr_u.pixel_hs_1;
assign pixel_de_1   = frame_buffer_wr_u.pixel_de_1;
assign pixel_data_1 = frame_buffer_wr_u.pixel_data_1;

assign pixel_vs_2   = frame_buffer_wr_u.pixel_vs_2;
assign pixel_hs_2   = frame_buffer_wr_u.pixel_hs_2;
assign pixel_de_2   = frame_buffer_wr_u.pixel_de_2;
assign pixel_data_2 = frame_buffer_wr_u.pixel_data_2;


assign pixel_vs_3   = frame_buffer_wr_u.pixel_vs_3;
assign pixel_hs_3   = frame_buffer_wr_u.pixel_hs_3;
assign pixel_de_3   = frame_buffer_wr_u.pixel_de_3;
assign pixel_data_3 = frame_buffer_wr_u.pixel_data_3;


wire [C_FIFO_IN_WIDTH-1:0] fifo_wr_data ;
wire fifo_wr_en;
wire [$clog2( C_FIFO_IN_WIDTH/8):0] fifo_wr_byte_num;
assign  fifo_wr_byte_num = frame_buffer_wr_u.fifo_wr_byte_num;
assign fifo_wr_data = frame_buffer_wr_u.fifo_wr_data;
assign fifo_wr_en   = frame_buffer_wr_u.fifo_wr_en;


initial begin
    mclk = 0;
    pclk  = 0;
    reset = 1;
    #500;
    reset = 0;
    #500;
    
end   
    
tpg 
#(.OUTPUT_REGISTER_EN(0),
  .MODE( "NORMAL") // "NORMAL"  "PHIYO_DP"
)
tpg_u
(
.PIXEL_CLK_I     (pclk),//像素时钟
.RESET_I         (0),//复位时输出钳制为0,释放复位后自动从头启动
.VS_ALLIGN_I     (0),//内部检测上沿,然后从头启动
.DE_VALID_I      (0),//电平信号,DE_O等待DE_VALID_I拉高后才启动

.HSYNC_I         (4/C_MAX_PORT_NUM),//参数 [15:0] 
.HBP_I           (8/C_MAX_PORT_NUM),//参数 [15:0] 
.HACTIVE_I       (C_HACTIVE_DEFAULT/C_MAX_PORT_NUM),//参数 [15:0]
.HFP_I           (20/C_MAX_PORT_NUM),//参数 [15:0] 

.VSYNC_I         (5),//参数 [15:0]
.VBP_I           (4),//参数 [15:0]
.VACTIVE_I       (C_VACTIVE_DEFAULT),//参数 [15:0] 
.VFP_I           (4),//参数 [15:0] 
.HS_O            (hs),//输出-时序(正极性)
.VS_O            (vs),//输出-时序(正极性)
.DE_O            (de),//输出-时序(正极性)
.TOTAL_X_O       (),//输出-辅助信息(DE_O低时为0)
.TOTAL_Y_O       (),//输出-辅助信息(DE_O低时为0)
.ACTIVE_X_O      (),//输出-辅助信息(DE_O低时为0)
.ACTIVE_Y_O      (),//输出-辅助信息(DE_O低时为0)
.BEFORE_DE_O     (),//输出-辅助信息
.AFTER_DE_O      (),//输出-辅助信息
.VS_ALLIGN_EN_I  (0),//是否开启VS对齐功能
.DE_ALLIGN_EN_I  (0)   //是否开启DE对齐功能
);   
    
    
pattern  
    #(.C_PORT_NUM(4))
    pattern_u(
    .CLK_I(pclk),
    .RST_I(0),
    .VS_I (vs),
    .HS_I (hs),
    .DE_I (de),
    .VS_O (vs2 ),
    .HS_O (hs2 ),
    .DE_O (de2 ),
    .R_O  (r2  ),
    .G_O  (g2  ),
    .B_O  (b2  )

);
 
    
frame_buffer_wr_2 
  // #(
  // .C_AXI_LITE_ADDR_WIDTH  ( 16 ),
  // .C_AXI_LITE_DATA_WIDTH  ( 32 ),
  // .C_AXI4_ADDR_WIDTH      ( 32 ),
  // .C_AXI4_DATA_WIDTH      ( 256 ),
  // .C_MAX_PORT_NUM         ( C_MAX_PORT_NUM ),
  // .C_MAX_BPC              ( C_MAX_BPC ),
  // .C_DDR_BASE_ADDR        ( 32'h80000000 ),
  // .C_FRAME_OFFSET_ADDR    ( 32'h00000000 ),
  // .C_FRAME_BYTE_NUM       ( 32'h08000000 ),
  // .C_FRAME_BUF_NUM        ( 2 ),
  // .C_MAX_MEM_BYTES        ( C_MAX_MEM_BYTES ),
  // .C_CSC_RGB2YUV_ENABLE   ( 1 ),
  // .C_CSC_FIFO_ENABLE      ( 1 ),
  // .C_PCLK_ILA_ENABLE      ( 0 ),
  // .C_AXI_LITE_ILA_ENABLE  ( 0 ),
  // .C_AXI4_ILA_ENABLE      ( 0 ),
  // .C_ENABLE_DEFAULT       ( 1 ),
  // .C_PORT_NUM_DEFAULT     ( C_MAX_PORT_NUM ),
  // .C_COLOR_DEPTH_DEFAULT  ( C_MAX_BPC ),
  // .C_COLOR_SPACE_DEFAULT  ( C_COLOR_SPACE_DEFAULT ),//
  // .C_MEM_BYTES_DEFAULT    ( C_MEM_BYTES_DEFAULT ),//
  // .C_STRIP_NUM_DEFAULT    ( 1 ),
  // .C_STRIP_ID_DEFAULT     ( 0 ),
  // .C_HACTIVE_DEFAULT      ( C_HACTIVE_DEFAULT ),//
  // .C_VACTIVE_DEFAULT      ( C_VACTIVE_DEFAULT ),//
  // .C_DDR_WR_SIM_ENABLE    ( 1  ),
  // .C_DDR_BURST_LEN        ( 32 )
  // 
  // )
    frame_buffer_wr_u(
    .S_AXI_ACLK     (mclk),
    .S_AXI_ARESETN  (~reset),
    .VID_CLK_I      (pclk),
    .VID_RSTN_I     (~reset),
    .VID_LOCKED_I   (~reset),
    .VS_I           (vs2),
    .HS_I           (hs2),
    .DE_I           (de2),
    .R_I            (r2),
    .G_I            (g2),
    .B_I            (b2),                          
    .M_AXI_ACLK     (mclk  ), 
    .M_AXI_ARESETN  (~reset)
    );


 //用于计算fifo输入位宽, 向上调整为最接近的fifo宽度
function [15:0] f_upper;
input  [15:0] in;
begin
         if(in>0 && in<=2)     f_upper = 2 ;
    else if(in>2 && in<=4)     f_upper = 4 ;
    else if(in>4 && in<=8)     f_upper = 8 ;
    else if(in>8 && in<=16)    f_upper = 16;
    else if(in>16 && in<=32)   f_upper = 32;
    else if(in>32 && in<=64)   f_upper = 64;
    else if(in>64 && in<=128)  f_upper = 128;
    else if(in>128 && in<=256) f_upper = 256;
    else if(in>256 && in<=512) f_upper = 512;
    else                       f_upper = 128;
end
endfunction   
    
    
endmodule
