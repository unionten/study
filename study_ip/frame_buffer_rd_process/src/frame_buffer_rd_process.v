`timescale 1ns / 1ps

`define CDC_MULTI_BIT_SIGNAL(aclk_in,adata_in,bclk_in,bdata_out,DATA_WIDTH)                   generate begin xpm_cdc_array_single #(.DEST_SYNC_FF(3),.INIT_SYNC_FF(0),.SIM_ASSERT_CHK(0),.SRC_INPUT_REG(1),.WIDTH(DATA_WIDTH)) cdc_u(.src_clk(aclk_in),.src_in(adata_in),.dest_clk(bclk_in),.dest_out(bdata_out));    end  endgenerate
`define POS_MONITOR(clk_in,rst_in,in,out)          generate  begin  reg buf_name1 = 0; always@(posedge clk_in)begin if(rst_in)buf_name1 <= 0; else  buf_name1 <= in; end assign out = (~buf_name1)&(in);  end  endgenerate
`define NEG_MONITOR(clk_in,rst_in,in,out)          generate  begin  reg buf_name1 = 0; always@(posedge clk_in)begin if(rst_in)buf_name1 <= 0; else  buf_name1 <= in; end assign out = (buf_name1)&(~in);  end  endgenerate
`define DELAY_OUTGEN(clk,rst,data_in,data_out,DATA_WIDTH,DLY)                                           generate if(DLY==0)begin  assign data_out = data_in; end  else if(DLY==1)begin  reg [DATA_WIDTH-1:0] a_temp = 0; always@(posedge clk) a_temp <= data_in; assign data_out = a_temp ; end  else begin  reg [DATA_WIDTH-1:0] a_temp [DLY-1:0] ;always@(posedge clk) begin  if(rst)a_temp[DLY-1] <= 0; else   a_temp[DLY-1] <= data_in; end  for(i=0;i<=DLY-2;i=i+1)begin  always@(posedge clk)begin  if(rst)begin  a_temp[i] <= 0; end  else begin  a_temp[i] <= a_temp[i+1]; end  end  end  assign data_out = a_temp[0]; end  endgenerate
`define DELAY_INGEN(clk,rst,data_in,data_out,DATA_WIDTH,DLY)                                            if(DLY==0)begin  assign data_out = data_in; end  else if(DLY==1)begin  reg [DATA_WIDTH-1:0] a_temp = 0; always@(posedge clk) a_temp <= data_in; assign data_out = a_temp ; end  else begin  reg [DATA_WIDTH-1:0] a_temp [DLY-1:0] ;always@(posedge clk) begin  if(rst)a_temp[DLY-1] <= 0; else   a_temp[DLY-1] <= data_in; end  for(i=0;i<=DLY-2;i=i+1)begin  always@(posedge clk)begin  if(rst)begin  a_temp[i] <= 0; end  else begin  a_temp[i] <= a_temp[i+1]; end  end  end  assign data_out = a_temp[0]; end


`define CDC_MULTI_BIT_SIGNAL_OUTGEN(aclk,adata_in,bclk,bdata_out,DATA_WIDTH,DEST_FF)                    generate begin xpm_cdc_array_single #(.DEST_SYNC_FF(DEST_FF),.INIT_SYNC_FF(0),.SIM_ASSERT_CHK(0),.SRC_INPUT_REG(1),.WIDTH(DATA_WIDTH)) cdc_u(.src_clk(aclk),.src_in(adata_in),.dest_clk(bclk),.dest_out(bdata_out));    end  endgenerate
`define CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(adata_in,bclk,bdata_out,DATA_WIDTH,DEST_FF)                    generate begin xpm_cdc_array_single #(.DEST_SYNC_FF(DEST_FF),.INIT_SYNC_FF(0),.SIM_ASSERT_CHK(0),.SRC_INPUT_REG(0),.WIDTH(DATA_WIDTH)) cdc_u(.src_clk( ),.src_in(adata_in),.dest_clk(bclk),.dest_out(bdata_out));    end  endgenerate
`define CDC_SINGLE_BIT_PULSE_OUTGEN(aclk,arst,apulse_in,bclk,brst,bpulse_out,SIM,DEST_FF)               generate if(SIM==0)begin  xpm_cdc_pulse #(.DEST_SYNC_FF(DEST_FF), .INIT_SYNC_FF(0),.REG_OUTPUT(0),.RST_USED(1),.SIM_ASSERT_CHK (0)) cdc_u (.src_clk(aclk),.src_rst(arst),.src_pulse(apulse_in),.dest_clk(bclk),.dest_rst(brst),.dest_pulse(bpulse_out));   end else begin   reg [5:0] name1 = 0;wire name2;always@(posedge aclk)if(arst)name1[0] <=0;else name1[0] <= apulse_in;assign name2 = apulse_in & ~name1[0]; always@(posedge aclk)if(arst)name1[1] <= 0;else name1[1] <= name2 ? ~name1[1]:name1[1];always@(posedge bclk)if(brst)name1[5:2]<=0;else begin name1[2]<=name1[1];name1[3]<=name1[2];name1[4]<=name1[3];name1[5]<=name1[4];end  assign bpulse_out=name1[4]^name1[5];  end  endgenerate
`define POS_MONITOR_OUTGEN(clk,rst,in,out)                                                              generate  begin  reg buf_name1 = 0; always@(posedge clk)begin if(rst)buf_name1 <= 0; else  buf_name1 <= in; end assign out = (~buf_name1)&(in);  end  endgenerate
`define NEG_MONITOR_OUTGEN(clk,rst,in,out)                                                              generate  begin  reg buf_name1 = 0; always@(posedge clk)begin if(rst)buf_name1 <= 0; else  buf_name1 <= in; end assign out = (buf_name1)&(~in);  end  endgenerate
`define XOR_MONITOR_OUTGEN(clk,rst,in,out)                                                              generate  begin  reg buf_name1 = 0; always@(posedge clk)begin if(rst)buf_name1 <= 0; else  buf_name1 <= in; end assign out = buf_name1^in;  end  endgenerate
`define POS_STRETCH_OUTGEN(clk,rst,pulse_in,pulse_out,DELAY_NUM)                                        generate  begin    reg [DELAY_NUM-2:0] temp_name = 0; always@(posedge clk)begin  if(rst)temp_name <= {(DELAY_NUM-1){1'b0}}; else temp_name <= pulse_in ? {(DELAY_NUM-1){1'b1} }: temp_name<<1 ; end  assign  pulse_out = temp_name[DELAY_NUM-2]|pulse_in;  end  endgenerate
`define NEG_STRETCH_OUTGEN(clk,rst,pulsen_in,pulsen_out,DELAY_NUM)                                      generate  begin    reg [DELAY_NUM-2:0] temp_name = 0; always@(posedge clk)begin  if(rst)temp_name <= {(DELAY_NUM-1){1'b0}}; else temp_name <= ~pulsen_in ? {(DELAY_NUM-1){1'b1} }: temp_name<<1 ; end  assign  pulsen_out = ~( temp_name[DELAY_NUM-2] | ~pulsen_in ) ;  end  endgenerate
`define HANDSHAKE_OUTGEN(aclk,arst,apulse_in,adata_in,bclk,brst,bpulse_out,bdata_out,DATA_WIDTH,SIM)    generate  if(SIM==0) begin  handshake  #(.C_DATA_WIDTH(DATA_WIDTH))  handshake_u (.SRC_CLK_I(aclk),.SRC_RST_I(arst),.SRC_DATA_I( adata_in),.SRC_SYNC_PULSE_I ( apulse_in), .DST_CLK_I ( bclk),.DST_DATA_O (bdata_out),.DST_SYNC_FINISH_O(bpulse_out) ); end  else  begin  handshake2 #(.C_DATA_WIDTH(DATA_WIDTH))  handshake_u (.SRC_CLK_I(aclk),.SRC_RST_I(arst),.SRC_DATA_I( adata_in),.SRC_SYNC_PULSE_I ( apulse_in), .DST_CLK_I (bclk),.DST_DATA_O (bdata_out ),.DST_SYNC_FINISH_O(bpulse_out) ); end  endgenerate



/////////////////////////////////REG TABLE///////////////////////////////////////
`define  ADDR_ENABLE            20'h00000
`define  ADDR_PORT_NUM          20'h00004

`define  ADDR_COLOR_SETTING     20'h00010
`define  ADDR_PIX_CLK_FREQ      20'h00014


`define  ADDR_HACTIVE           20'h00018
`define  ADDR_VACTIVE           20'h0001c
`define  ADDR_HSYNC             20'h00020
`define  ADDR_HBP               20'h00024
`define  ADDR_HFP               20'h00028
`define  ADDR_VSYNC             20'h0002c
`define  ADDR_VBP               20'h00030
`define  ADDR_VFP               20'h00034
`define  ADDR_MEM_BYTES         20'h00038
`define  ADDR_LU_HACTIVE        20'h0003c
`define  ADDR_LU_VACTIVE        20'h00040

`define  ADDR_DP_COLOR_MODE     20'h00044

`define  ADDR_OSD_H             20'h00050
`define  ADDR_OSD_V             20'h00054
`define  ADDR_OSD_SETTING       20'h00058
`define  ADDR_OSD_ENABLE        20'h0005c
`define  ADDR_OSD_X             20'h00060
`define  ADDR_OSD_Y             20'h00064


`define  ADDR_OUTPUT_SRC        20'h00068  //0:from DDR  ;  1: from inner pattern
`define  ADDR_INNER_PAT_ID      20'h0006c

`define  ADDR_DP_IRQ_STATUS_ID     20'h00070
`define  ADDR_DP_LANE_NUM_ID       20'h00074
`define  ADDR_DP_LANE_RATE_ID      20'h00078
`define  ADDR_RGB_COLOR             20'h0007C





/////////////////////////////////////////////////////////////////////////////////


`define  ADDR_OSD_OFFSET        20'h40000

//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: yzhu
//
// Create Date: 2023/07/15 16:44:07
// Design Name:
// Module Name: frame_buffer_rd_process
// Project Name:
//////////////////////////////////////////////////////////////////////////////////
//no fixed : 1640 3383
//fixed : 1209 3374

//120

module frame_buffer_rd_process(
input  wire                                      S_AXI_ACLK      ,
input  wire                                      S_AXI_ARESETN   ,
output wire                                      S_AXI_AWREADY   ,
input  wire [C_AXI_LITE_ADDR_WIDTH-1:0]          S_AXI_AWADDR    ,
input  wire                                      S_AXI_AWVALID   ,
input  wire [ 2:0]                               S_AXI_AWPROT    ,
output wire                                      S_AXI_WREADY    ,
input  wire [C_AXI_LITE_DATA_WIDTH-1:0]          S_AXI_WDATA     ,
input  wire [(C_AXI_LITE_DATA_WIDTH/8)-1 :0]     S_AXI_WSTRB     ,
input  wire                                      S_AXI_WVALID    ,
output wire [ 1:0]                               S_AXI_BRESP     ,
output wire                                      S_AXI_BVALID    ,
input  wire                                      S_AXI_BREADY    ,
output wire                                      S_AXI_ARREADY   ,
input  wire [C_AXI_LITE_ADDR_WIDTH-1:0]          S_AXI_ARADDR    ,
input  wire                                      S_AXI_ARVALID   ,
input  wire [ 2:0]                               S_AXI_ARPROT    ,
output wire [ 1:0]                               S_AXI_RRESP     ,
output wire                                      S_AXI_RVALID    ,
output wire [C_AXI_LITE_DATA_WIDTH-1:0]          S_AXI_RDATA     ,
input  wire                                      S_AXI_RREADY    ,


input                                     AXI4_CLK_I   ,
input                                     AXI4_RSTN_I  ,

input  [C_RAW_DATA_WIDTH-1:0]             WDATA   ,//~AXI4_CLK_I
input                                     WREQ    ,
input                                     WSOF    ,
input                                     WEOF    ,
output                                    WREADY  ,

input                                     VID_CLK_I        ,
input                                     VID_RSTN_I       ,
input                                     VID_VS_I         ,
input                                     VID_HS_I         ,
input                                     VID_DE_I         ,
output  [C_MAX_PORT_NUM-1:0]              VID_VS_O         ,
output  [C_MAX_PORT_NUM-1:0]              VID_HS_O         ,
output  [C_MAX_PORT_NUM-1:0]              VID_DE_O         ,
output  [C_MAX_PORT_NUM*C_MAX_BPC-1:0]    VID_R_O          ,
output  [C_MAX_PORT_NUM*C_MAX_BPC-1:0]    VID_G_O          ,
output  [C_MAX_PORT_NUM*C_MAX_BPC-1:0]    VID_B_O          ,

output                                    ENABLE_O         ,


output reg      [1:0]    polar    = 2'b00   ,
output reg      [7:0]    misc0    = 8'b0    ,
output reg      [7:0]    misc1    = 8'b0    ,

output  reg  [31:0]  PIX_CLK_FREQ   ,
output  reg  [15:0]  HACTIVE        ,
output  reg  [15:0]  HFP            ,
output  reg  [15:0]  HSYNC          ,
output  reg  [15:0]  HBP            ,
output  reg  [15:0]  VACTIVE        ,
output  reg  [15:0]  VFP            ,
output  reg  [15:0]  VSYNC          ,
output  reg  [15:0]  VBP            ,

output   YUV420  ,

input  [C_AXI_LITE_ADDR_WIDTH-1:0]  LB_WADDR   ,
input  [C_AXI_LITE_DATA_WIDTH-1:0]  LB_WDATA   ,
input                               LB_WREQ    ,
input  [C_AXI_LITE_ADDR_WIDTH-1:0]  LB_RADDR   ,
input                               LB_RREQ     ,
output [C_AXI_LITE_DATA_WIDTH-1:0]  LB_RDATA   ,
output                              LB_RFINISH  ,


output  [15:0]   CNT_H,

output       irq_status_rd_clr,
input [31:0] irq_status ,
input [3:0]  i_lnk_cnt  ,
input [7:0]  i_lnk_bw


//input   [7:0]    PATSEL_I


);
//4ports,max bytes 2; resource LUT 1300  FF2900
//4ports,max bytes 2 no osd: LUT 1200  FF 2500
parameter  C_LU_HACTIVE_DEFAULT          = 600 ; //归 左上角 逻辑中 实际tpg中读取数量
parameter  C_LU_VACTIVE_DEFAULT          = 480 ; //归 左上角 逻辑中  实际tpg中读取数量


parameter  [0:0] C_FIXED_MAX_PARA  =  1;
parameter  [0:0] C_LB_ENABLE       =  0;

parameter  C_AXI_LITE_ADDR_WIDTH    = 20;
parameter  C_AXI_LITE_DATA_WIDTH    = 32;
parameter  C_RAW_DATA_WIDTH         = 256;
parameter  C_MAX_PORT_NUM           = 4;
parameter  C_MAX_BPC                = 8;
parameter  C_DDR_PIXEL_MAX_BYTE_NUM = 2;
parameter  C_OUT_FORMAT             = 1;//0:RGB  1:YUV

parameter  [0:0] C_OSD_BLOCK_EN     = 0;
parameter  [0:0] C_INNER_PATTERN_BLOCK_EN = 1 ;

parameter  [0:0] C_TPG_SRC          = 1;//0:inner  1:outer
//parameter  [0:0] C_INNER_PATTERN_ENABLE = 0 ;
//////////////////////////////////////////////////////////////////////
parameter  C_ENABLE_DEFAULT              = 1 ;
parameter  C_PORT_NUM_DEFAULT            = 4 ;
parameter  C_RGB_DEFAULT            = 32'h0017aa65;
parameter  C_COLOR_DEPTH_DEFAULT         = 8 ;
parameter  C_COLOR_SPACE_DEFAULT         = 0 ;
parameter  C_DP_COLOR_DEPTH_DEFAULT      = 8 ;
parameter  C_DP_COLOR_SPACE_DEFAULT      = 0 ;
parameter  C_MEM_BYTES_DEFAULT        = 4 ;
parameter  C_HACTIVE_DEFAULT          = 600 ;
parameter  C_VACTIVE_DEFAULT          = 480 ;
parameter  C_HSYNC_DEFAULT            = 20 ;
parameter  C_HBP_DEFAULT              = 20 ;
parameter  C_HFP_DEFAULT              = 20 ;
parameter  C_VSYNC_DEFAULT            = 20 ;
parameter  C_VBP_DEFAULT              = 20 ;
parameter  C_VFP_DEFAULT              = 20 ;
parameter  C_PIX_CLK_FREQ_DEFAULT     =   297000 ;

parameter  C_OSD_HPIXEL_DEFAULT       = 500 ;
parameter  C_OSD_VPIXEL_DEFAULT       = 400 ;
parameter  C_OSD_X_DEFAULT            = 0 ;
parameter  C_OSD_Y_DEFAULT            = 0 ;
parameter  C_OSD_ENABLE_DEFAULT       = 1 ;
parameter  C_OSD_SETTING_DEFAULT      = 1 ; //[3:0]  [0:0]:0 覆盖  1:透明

parameter  C_OUTPUT_SRC_DEFAULT       = 0 ; //0:from ddr ; 1:from inner pattern
parameter  C_INNER_PATTERN_ID_DEFAULT = 6 ;//0黑1白2红3绿4蓝5灰6 32灰阶7 256灰阶8五方格18 椭圆

//////////////////////////////////////////////////////////////////////
//hardware select
parameter [0:0] C_YUV2RGB_BLOCK_EN = 1;
parameter [0:0] C_RGB2YUV_BLOCK_EN = 0;
parameter [0:0] C_420FIFO_BLOCK_EN = 0;

parameter [0:0] C_AXI_ILA_EN = 0;
parameter [0:0] C_RAW_ILA_EN = 0;//debug fifo
parameter [0:0] C_VID_ILA_EN = 0;
parameter [0:0] C_VID_OSD_ILA_EN = 0;

parameter [0:0] C_PARA_NATIVE_ILA_EN_AXICLK = 0  ;

parameter C_FIFO_DEPTH = 2048 ;
parameter C_FIFO_WREADY_THRESH = 256;


parameter       DDR_Video_Format = "xRGB888";
//////////////////////////////////////////////////////////////////////
localparam C_FIFO_OUT_WIDTH = f_upper(C_DDR_PIXEL_MAX_BYTE_NUM*8*C_MAX_PORT_NUM);

genvar i,j,k;
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



wire [7:0] PATSEL_I_pclk ;
`CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(PATSEL_I,VID_CLK_I,PATSEL_I_pclk,8,3)



reg [31:0] R_PIX_CLK_FREQ     =  C_PIX_CLK_FREQ_DEFAULT ;
reg [0:0]  R_ENABLE           = C_ENABLE_DEFAULT     ;
reg [0:0]  R_DP_EN           = 0     ;
reg [3:0]  R_PORT_NUM         = C_PORT_NUM_DEFAULT   ;
(* keep="true" *)reg [31:0]  R_RGB         = C_RGB_DEFAULT   ;
reg [3:0]  R_COLOR_DEPTH      = C_COLOR_DEPTH_DEFAULT;     // 默认的ddr内的颜色色深
reg [3:0]  R_COLOR_SPACE      = C_COLOR_SPACE_DEFAULT;     // 默认的ddr内的色域空间
reg [3:0]  R_DP_COLOR_DEPTH      = C_DP_COLOR_DEPTH_DEFAULT;     // 默认告知DP模块的颜色色深
reg [3:0]  R_DP_COLOR_SPACE      = C_DP_COLOR_SPACE_DEFAULT;     // 默认告知DP模块的色域空间

reg [3:0]  R_MEM_BYTES        = C_MEM_BYTES_DEFAULT  ;
reg [15:0] R_HACTIVE         =  C_HACTIVE_DEFAULT    ;
reg [15:0] R_VACTIVE         =  C_VACTIVE_DEFAULT    ;
reg [15:0] R_LU_HACTIVE      =  C_LU_HACTIVE_DEFAULT   ;
reg [15:0] R_LU_VACTIVE      =  C_LU_VACTIVE_DEFAULT    ;
reg [15:0] R_HSYNC           =  C_HSYNC_DEFAULT      ;
reg [15:0] R_HBP             =  C_HBP_DEFAULT        ;
reg [15:0] R_HFP             =  C_HFP_DEFAULT        ;
reg [15:0] R_VSYNC           =  C_VSYNC_DEFAULT      ;
reg [15:0] R_VBP             =  C_VBP_DEFAULT        ;
reg [15:0] R_VFP             =  C_VFP_DEFAULT        ;
reg [15:0] R_OSD_H          =  C_OSD_HPIXEL_DEFAULT      ;
reg [15:0] R_OSD_V          =  C_OSD_VPIXEL_DEFAULT      ;
reg [15:0] R_OSD_X          =  C_OSD_X_DEFAULT ;
reg [15:0] R_OSD_Y          =  C_OSD_Y_DEFAULT ;
reg [0:0]  R_OSD_ENABLE     =  C_OSD_ENABLE_DEFAULT  ;
reg [3:0]  R_OSD_SETTING    =  C_OSD_SETTING_DEFAULT ;


reg [0:0]  R_OUTPUT_SRC        =  C_OUTPUT_SRC_DEFAULT ;
reg [7:0]  R_INNER_PATTERN_ID   = C_INNER_PATTERN_ID_DEFAULT ;


//wire [2:0] color_setting_space__default;
//wire [2:0] color_setting_depth__default;
//assign color_setting_space__default  = C_COLOR_SPACE_DEFAULT==0 ? 3'b000 :
//                              C_COLOR_SPACE_DEFAULT==1 ? 3'b010 :
//                              C_COLOR_SPACE_DEFAULT==2 ? 3'b001 :
//                              C_COLOR_SPACE_DEFAULT==3 ? 3'b100 :  3'b001 ;
//
//
//assign color_setting_depth__default  = C_COLOR_DEPTH_DEFAULT==6  ? 3'b000 :
//                              C_COLOR_DEPTH_DEFAULT==8  ? 3'b001 :
//                              C_COLOR_DEPTH_DEFAULT==10 ? 3'b010 :
//                              C_COLOR_DEPTH_DEFAULT==12 ? 3'b011 :
//                              C_COLOR_DEPTH_DEFAULT==16 ? 3'b100 : 3'b001 ;


wire [2:0] dp_color_setting_space__default;
wire [2:0] dp_color_setting_depth__default;
assign dp_color_setting_space__default  = C_DP_COLOR_SPACE_DEFAULT==0 ? 3'b000 : // 自然值 转 编码值
                              C_DP_COLOR_SPACE_DEFAULT==1 ? 3'b010 :
                              C_DP_COLOR_SPACE_DEFAULT==2 ? 3'b001 :
                              C_DP_COLOR_SPACE_DEFAULT==3 ? 3'b100 :  3'b001 ;


assign dp_color_setting_depth__default  = C_DP_COLOR_DEPTH_DEFAULT==6  ? 3'b000 :
                              C_DP_COLOR_DEPTH_DEFAULT==8  ? 3'b001 :
                              C_DP_COLOR_DEPTH_DEFAULT==10 ? 3'b010 :
                              C_DP_COLOR_DEPTH_DEFAULT==12 ? 3'b011 :
                              C_DP_COLOR_DEPTH_DEFAULT==16 ? 3'b100 : 3'b001 ;



reg [31:0] R_DP_COLOR_SETTING ;


wire  tpg_vs_mclk ;
wire  tpg_vs_aclk ;
wire  tpg_vs_mclk_pos ;
wire  tpg_vs_aclk_pos ;


wire prog_full;
wire [15:0] WR_DATA_COUNT;
wire WR_FULL;
wire WR_RST_BUSY;

wire RD_EMPTY;
wire [15:0] RD_DATA_COUNT;
wire RD_RST_BUSY;


wire write_req_cpu_to_axi   ;
wire [C_AXI_LITE_ADDR_WIDTH-1:0] write_addr_cpu_to_axi ;
wire [C_AXI_LITE_DATA_WIDTH-1:0] write_data_cpu_to_axi ;
wire read_req_cpu_to_axi  ;
wire [C_AXI_LITE_ADDR_WIDTH-1:0] read_addr_cpu_to_axi ;
wire  [C_AXI_LITE_DATA_WIDTH-1:0] read_data_axi_to_cpu ;
wire  read_finish_axi_to_cpu;


wire                       write_req_cpu_to_axi_ll   ;
wire [C_AXI_LITE_ADDR_WIDTH-1:0]  write_addr_cpu_to_axi_ll  ;
wire [C_AXI_LITE_DATA_WIDTH-1:0]  write_data_cpu_to_axi_ll  ;
wire                       read_req_cpu_to_axi_ll    ;
wire  [C_AXI_LITE_ADDR_WIDTH-1:0] read_addr_cpu_to_axi_ll   ;
reg  [C_AXI_LITE_DATA_WIDTH-1:0]  read_data_axi_to_cpu_ll    = 0;
reg                        read_finish_axi_to_cpu_ll  = 0;




wire [0:0]  R_ENABLE_vidclk       ;
wire [0:0]  R_ENABLE_mclk         ;
wire [3:0]  R_PORT_NUM_vidclk     ;
(* keep="true" *)wire [31:0]  R_RGB_vidclk     ;
wire [3:0]  R_COLOR_DEPTH_vidclk  ;
wire [3:0]  R_COLOR_SPACE_vidclk  ;
wire [3:0]  R_MEM_BYTES_vidclk    ;
wire [15:0] R_HACTIVE_vidclk      ;
wire [15:0] R_VACTIVE_vidclk      ;
wire [15:0] R_LU_HACTIVE_vidclk  ;
wire [15:0] R_LU_VACTIVE_vidclk  ;
wire [15:0] R_HSYNC_vidclk        ;
wire [15:0] R_HBP_vidclk          ;
wire [15:0] R_HFP_vidclk          ;
wire [15:0] R_VSYNC_vidclk        ;
wire [15:0] R_VBP_vidclk          ;
wire [15:0] R_VFP_vidclk          ;
wire [15:0] R_OSD_HPIXEL_vidclk   ;
wire [15:0] R_OSD_VPIXEL_vidclk   ;
wire [0:0]  R_OUTPUT_SRC_vidclk      ;
wire [7:0]  R_INNER_PATTERN_ID_vidclk ;


wire [15:0] R_OSD_X_vidclk       ;
wire [15:0] R_OSD_Y_vidclk       ;
wire [0:0]  R_OSD_ENABLE_vidclk   ;
wire [3:0]  R_OSD_SETTING_vidclk  ;


wire [17:0] OSD_WADDR;
wire [31:0] OSD_WDATA;
wire        OSD_WREQ ;



wire tpg_hs   ;  //vidvlk
wire tpg_vs   ;  //vidvlk
wire tpg_de   ;  //vidvlk
wire tpg_de_odd   ;
wire tpg_vs_vclk_pos;
wire tpg_de_neg;
wire [31:0] tpg_activex;
wire [31:0] tpg_activey;

wire [7:0] tpg_r_inner_ori  ;
wire [7:0] tpg_g_inner_ori  ;
wire [7:0] tpg_b_inner_ori  ;


wire [7:0] tpg_r_inner  ;
wire [7:0] tpg_g_inner  ;
wire [7:0] tpg_b_inner  ;

wire tpg_de_lu ;


//(*keep="true"*)wire [C_FIFO_OUT_WIDTH-1:0] pixel_data_0; //width > C_DDR_PIXEL_MAX_BYTE_NUM*8*C_MAX_PORT_NUM
//(*keep="true"*)wire [C_FIFO_OUT_WIDTH-1:0] pixel_data_1; //width > C_DDR_PIXEL_MAX_BYTE_NUM*8*C_MAX_PORT_NUM

wire [C_FIFO_OUT_WIDTH-1:0] pixel_data_0; //width > C_DDR_PIXEL_MAX_BYTE_NUM*8*C_MAX_PORT_NUM
wire [C_FIFO_OUT_WIDTH-1:0] pixel_data_1; //width > C_DDR_PIXEL_MAX_BYTE_NUM*8*C_MAX_PORT_NUM



wire [C_DDR_PIXEL_MAX_BYTE_NUM*8*C_MAX_PORT_NUM-1:0] pixel_data_2;//  pixel_temp1;
wire [C_MAX_BPC*3*C_MAX_PORT_NUM-1:0] pixel_data_3; //pixel_temp2;
assign pixel_data_2 = reconcat_rd_u.pixel_temp1;
assign pixel_data_3 = reconcat_rd_u.pixel_temp2;



//(*keep="true"*)wire pixel_rd_0;
//(*keep="true"*)wire [C_MAX_BPC*3*C_MAX_PORT_NUM-1:0]  pixel_data_4;
wire pixel_rd_0;
wire [C_MAX_BPC*3*C_MAX_PORT_NUM-1:0]  pixel_data_4;



wire pixel_hs_1;
wire pixel_vs_1;
wire pixel_de_1_lu;
wire pixel_hs_2;
wire pixel_vs_2;
wire pixel_de_2;
wire pixel_hs_3;
wire pixel_vs_3;
wire pixel_de_3;
wire pixel_hs_4;
wire pixel_vs_4;
wire pixel_de_4_lu;

assign pixel_vs_2 = reconcat_rd_u.vs1;
assign pixel_hs_2 = reconcat_rd_u.hs1;
assign pixel_de_2 = reconcat_rd_u.de1;

assign pixel_vs_3 = reconcat_rd_u.vs2;
assign pixel_hs_3 = reconcat_rd_u.hs2;
assign pixel_de_3 = reconcat_rd_u.de2;


wire vs_5;
wire hs_5;
wire de_5;

wire [C_MAX_PORT_NUM*C_MAX_BPC-1:0] r_5;
wire [C_MAX_PORT_NUM*C_MAX_BPC-1:0] g_5;
wire [C_MAX_PORT_NUM*C_MAX_BPC-1:0] b_5;


wire WR_ERR;
wire RD_ERR;

wire [31:0] WR_EN_NAMES ;
wire [31:0] WR_EN_ACCUS ;
wire [31:0] RD_EN_NAMES ;
wire [31:0] RD_EN_ACCUS ;

wire vs_osd ;
wire hs_osd ;
wire de_osd ;
wire [C_MAX_PORT_NUM*C_MAX_BPC-1:0] r_osd ;
wire [C_MAX_PORT_NUM*C_MAX_BPC-1:0] g_osd ;
wire [C_MAX_PORT_NUM*C_MAX_BPC-1:0] b_osd ;


//(*keep="true"*)reg [15:0] R_HSYNC_vidclk_div  ;
//(*keep="true"*)reg [15:0] R_HBP_vidclk_div    ;
//(*keep="true"*)reg [15:0] R_HACTIVE_vidclk_div;
//(*keep="true"*)reg [15:0] R_HFP_vidclk_div    ;


reg [15:0] R_HSYNC_vidclk_div  ;
reg [15:0] R_HBP_vidclk_div    ;
reg [15:0] R_HACTIVE_vidclk_div;
reg [15:0] R_HFP_vidclk_div    ;


wire tpg_hs_inner ;
wire tpg_vs_inner ;
wire tpg_de_inner ;

reg flag = 0;
reg [3:0] R_MEM_BYTES_vidclk_mult;


wire rst_fifo_wr;
wire rst_fifo_rd;//vid_clk
wire rst_rd_station;//vid_clk
wire rst_reconcat;//vid_clk
wire rst_csc;//vid_clk
wire rst_osd;//vid_clk
wire rst_tpg;//vid_clk

reg tpg_enable_vid = 0;
reg fifo_wr_latch_axi4 = 0; //1 使能写入  0 关闭写入


wire [7:0] tpg_r_inner_s7 ;
wire [7:0] tpg_g_inner_s7 ;
wire [7:0] tpg_b_inner_s7  ;

wire [7:0] tpg_r_inner_s11 ;
wire [7:0] tpg_g_inner_s11 ;
wire [7:0] tpg_b_inner_s11 ;

wire [15:0] active_x;
wire [15:0] active_y;


reg [15:0] cnt_h ;
reg [15:0] cnt_v ;

wire VID_HS_O_pos;




assign rst_fifo_wr    = ~AXI4_RSTN_I | tpg_vs_mclk_pos | ~R_ENABLE_mclk  ;
assign rst_fifo_rd    = ~VID_RSTN_I  | tpg_vs_aclk_pos | ~R_ENABLE_vidclk;
assign rst_rd_station = ~VID_RSTN_I  | tpg_vs_vclk_pos | ~R_ENABLE_vidclk;
assign rst_reconcat   = ~VID_RSTN_I  | tpg_vs_vclk_pos | ~R_ENABLE_vidclk;
assign rst_csc        = ~VID_RSTN_I  | tpg_vs_vclk_pos | ~R_ENABLE_vidclk;
assign rst_osd        = ~VID_RSTN_I  | tpg_vs_vclk_pos | ~R_ENABLE_vidclk;
assign rst_tpg        = ~VID_RSTN_I  | ~R_ENABLE_vidclk ;


assign write_req_cpu_to_axi_ll  =  C_LB_ENABLE ? LB_WREQ  : write_req_cpu_to_axi  ;
assign write_addr_cpu_to_axi_ll =  C_LB_ENABLE ? LB_WADDR : write_addr_cpu_to_axi ;
assign write_data_cpu_to_axi_ll =  C_LB_ENABLE ? LB_WDATA : write_data_cpu_to_axi ;
assign read_req_cpu_to_axi_ll   =  C_LB_ENABLE ? LB_RREQ  : read_req_cpu_to_axi ;
assign read_addr_cpu_to_axi_ll  =  C_LB_ENABLE ? LB_RADDR : read_addr_cpu_to_axi ;

assign read_data_axi_to_cpu     =  C_LB_ENABLE ? 0 : read_data_axi_to_cpu_ll   ;
assign read_finish_axi_to_cpu   =  C_LB_ENABLE ? 0 : read_finish_axi_to_cpu_ll ;
assign LB_RDATA                 =  C_LB_ENABLE ? read_data_axi_to_cpu_ll   : 0 ;
assign LB_RFINISH               =  C_LB_ENABLE ? read_finish_axi_to_cpu_ll : 0 ;



///////////////////////////////////////////////////////////////////////////////////////////////////

// assign ENABLE_O = R_ENABLE;
assign ENABLE_O = R_DP_EN;

`POS_MONITOR(VID_CLK_I,0,tpg_vs,tpg_vs_vclk_pos)
`NEG_MONITOR(VID_CLK_I,0,tpg_de,tpg_de_neg)


always@(posedge VID_CLK_I)begin
    if(~VID_RSTN_I | tpg_vs_vclk_pos)begin
        flag <= 0;
    end
    else begin
        flag <=  tpg_de_neg ? ~flag : flag;

    end
end

assign tpg_de_odd = flag==0 ? tpg_de : 0;



`CDC_MULTI_BIT_SIGNAL(S_AXI_ACLK,R_ENABLE      ,VID_CLK_I,R_ENABLE_vidclk      ,1)
`CDC_MULTI_BIT_SIGNAL(S_AXI_ACLK,R_ENABLE      ,AXI4_CLK_I,R_ENABLE_mclk      ,1)
`CDC_MULTI_BIT_SIGNAL(S_AXI_ACLK,R_PORT_NUM    ,VID_CLK_I,R_PORT_NUM_vidclk    ,4)
`CDC_MULTI_BIT_SIGNAL(S_AXI_ACLK,R_RGB    ,VID_CLK_I,R_RGB_vidclk    ,32)
`CDC_MULTI_BIT_SIGNAL(S_AXI_ACLK,R_COLOR_DEPTH ,VID_CLK_I,R_COLOR_DEPTH_vidclk ,4)
`CDC_MULTI_BIT_SIGNAL(S_AXI_ACLK,R_COLOR_SPACE ,VID_CLK_I,R_COLOR_SPACE_vidclk ,4)
`CDC_MULTI_BIT_SIGNAL(S_AXI_ACLK,R_MEM_BYTES   ,VID_CLK_I,R_MEM_BYTES_vidclk   ,4)
`CDC_MULTI_BIT_SIGNAL(S_AXI_ACLK,R_HACTIVE     ,VID_CLK_I,R_HACTIVE_vidclk     ,16)
`CDC_MULTI_BIT_SIGNAL(S_AXI_ACLK,R_VACTIVE     ,VID_CLK_I,R_VACTIVE_vidclk     ,16)
`CDC_MULTI_BIT_SIGNAL(S_AXI_ACLK,R_LU_HACTIVE     ,VID_CLK_I,R_LU_HACTIVE_vidclk     ,16)
`CDC_MULTI_BIT_SIGNAL(S_AXI_ACLK,R_LU_VACTIVE     ,VID_CLK_I,R_LU_VACTIVE_vidclk     ,16)

`CDC_MULTI_BIT_SIGNAL(S_AXI_ACLK,R_HSYNC       ,VID_CLK_I,R_HSYNC_vidclk       ,16)
`CDC_MULTI_BIT_SIGNAL(S_AXI_ACLK,R_HBP         ,VID_CLK_I,R_HBP_vidclk         ,16)
`CDC_MULTI_BIT_SIGNAL(S_AXI_ACLK,R_HFP         ,VID_CLK_I,R_HFP_vidclk         ,16)
`CDC_MULTI_BIT_SIGNAL(S_AXI_ACLK,R_VSYNC       ,VID_CLK_I,R_VSYNC_vidclk       ,16)
`CDC_MULTI_BIT_SIGNAL(S_AXI_ACLK,R_VBP         ,VID_CLK_I,R_VBP_vidclk         ,16)
`CDC_MULTI_BIT_SIGNAL(S_AXI_ACLK,R_VFP         ,VID_CLK_I,R_VFP_vidclk         ,16)
`CDC_MULTI_BIT_SIGNAL(S_AXI_ACLK,R_OSD_H       ,VID_CLK_I,R_OSD_HPIXEL_vidclk  ,16)
`CDC_MULTI_BIT_SIGNAL(S_AXI_ACLK,R_OSD_V       ,VID_CLK_I,R_OSD_VPIXEL_vidclk  ,16)
`CDC_MULTI_BIT_SIGNAL(S_AXI_ACLK,R_OSD_X       ,VID_CLK_I,R_OSD_X_vidclk         ,16)
`CDC_MULTI_BIT_SIGNAL(S_AXI_ACLK,R_OSD_Y       ,VID_CLK_I,R_OSD_Y_vidclk         ,16)
`CDC_MULTI_BIT_SIGNAL(S_AXI_ACLK,R_OSD_ENABLE  ,VID_CLK_I,R_OSD_ENABLE_vidclk    ,1)
`CDC_MULTI_BIT_SIGNAL(S_AXI_ACLK,R_OSD_SETTING ,VID_CLK_I,R_OSD_SETTING_vidclk   ,4)

`CDC_MULTI_BIT_SIGNAL(S_AXI_ACLK,R_OUTPUT_SRC     ,VID_CLK_I,R_OUTPUT_SRC_vidclk   ,1)
`CDC_MULTI_BIT_SIGNAL(S_AXI_ACLK,R_INNER_PATTERN_ID     ,VID_CLK_I,R_INNER_PATTERN_ID_vidclk   ,8)



///////////////////////////////////////////////////////////////////////////////////////////////////////////////

//assign WREADY = ~prog_full;
//assign WREADY = WR_RST_BUSY ? 0 : (~fifo_wr_latch_axi4) |  (fifo_wr_latch_axi4 & (~WR_FULL) ) ;
assign WREADY = WR_RST_BUSY ? 0 : ~prog_full ;
//assign  dma_rready = wr_rst_busy ? 1'b0 : (wr_usedw < WR_DEPTH - M_MAX_BURST_LEN*2);


always @(posedge VID_CLK_I)begin
	if( (~VID_RSTN_I) | (~R_ENABLE_vidclk))begin
		tpg_enable_vid <= 0;
    end
	else if(RD_DATA_COUNT >= ((R_HACTIVE_vidclk*4)/(C_RAW_DATA_WIDTH/8))  &&  (RD_RST_BUSY!=1) )begin
		tpg_enable_vid <= 1;
	end
end


always @(posedge AXI4_CLK_I)begin
	if(~AXI4_RSTN_I)begin
		fifo_wr_latch_axi4 <= 0;
    end
	else if(R_ENABLE_mclk) begin
		fifo_wr_latch_axi4 <= WEOF ? 1 : fifo_wr_latch_axi4;
    end
	else begin
		fifo_wr_latch_axi4 <= 0;
    end
end



////////////////////////////////////////////////AXI-LITE///////////////////////////////////////////////////////
// axi_lite_slave
//    #(.C_S_AXI_DATA_WIDTH (C_AXI_LITE_DATA_WIDTH ),
//      .C_S_AXI_ADDR_WIDTH (C_AXI_LITE_ADDR_WIDTH )
//     )
//     axi_lite_slave_u(
//     .S_AXI_ACLK           (S_AXI_ACLK     ) ,
//     .S_AXI_ARESETN        (S_AXI_ARESETN  ) ,
//     .S_AXI_AWREADY        (S_AXI_AWREADY  ) ,
//     .S_AXI_AWADDR         (S_AXI_AWADDR   ) ,
//     .S_AXI_AWVALID        (S_AXI_AWVALID  ) ,
//     .S_AXI_AWPROT         (S_AXI_AWPROT   ) ,
//     .S_AXI_WREADY         (S_AXI_WREADY   ) ,
//     .S_AXI_WDATA          (S_AXI_WDATA    ) ,
//     .S_AXI_WSTRB          (S_AXI_WSTRB    ) ,
//     .S_AXI_WVALID         (S_AXI_WVALID   ) ,
//     .S_AXI_BRESP          (S_AXI_BRESP    ) ,
//     .S_AXI_BVALID         (S_AXI_BVALID   ) ,
//     .S_AXI_BREADY         (S_AXI_BREADY   ) ,
//     .S_AXI_ARREADY        (S_AXI_ARREADY  ) ,
//     .S_AXI_ARADDR         (S_AXI_ARADDR   ) ,
//     .S_AXI_ARVALID        (S_AXI_ARVALID  ) ,
//     .S_AXI_ARPROT         (S_AXI_ARPROT   ) ,
//     .S_AXI_RRESP          (S_AXI_RRESP    ) ,
//     .S_AXI_RVALID         (S_AXI_RVALID   ) ,
//     .S_AXI_RDATA          (S_AXI_RDATA    ) ,
//     .S_AXI_RREADY         (S_AXI_RREADY   ) ,

//     .write_req_cpu_to_axi   (write_req_cpu_to_axi   ),
//     .write_addr_cpu_to_axi  (write_addr_cpu_to_axi  ),
//     .write_data_cpu_to_axi  (write_data_cpu_to_axi  ),
//     .read_req_cpu_to_axi    (read_req_cpu_to_axi    ),
//     .read_addr_cpu_to_axi   (read_addr_cpu_to_axi   ),
//     .read_data_axi_to_cpu   (read_data_axi_to_cpu   ),
//     .read_finish_axi_to_cpu (read_finish_axi_to_cpu )

//     );

    AXI_Lite_Slave #(
	.C_S_AXI_DATA_WIDTH  	(C_AXI_LITE_DATA_WIDTH),
    .C_S_AXI_ADDR_WIDTH		(C_AXI_LITE_ADDR_WIDTH)
)AXI_Lite_Slave_inst
(
	////////////////////////////////////////////////////
	// AXI4 Lite Slave interface
	.S_AXI_ACLK				(S_AXI_ACLK		),
	.S_AXI_ARESETN			(S_AXI_ARESETN	),
	.S_AXI_AWREADY			(S_AXI_AWREADY	),
	.S_AXI_AWADDR			(S_AXI_AWADDR	),
	.S_AXI_AWVALID			(S_AXI_AWVALID	),
	.S_AXI_AWPROT			(S_AXI_AWPROT	),
	.S_AXI_WREADY			(S_AXI_WREADY	),
	.S_AXI_WDATA			(S_AXI_WDATA	),
	.S_AXI_WSTRB			(S_AXI_WSTRB	),
	.S_AXI_WVALID			(S_AXI_WVALID	),
	.S_AXI_BRESP			(S_AXI_BRESP	),
	.S_AXI_BVALID			(S_AXI_BVALID	),
	.S_AXI_BREADY			(S_AXI_BREADY	),
	.S_AXI_ARREADY			(S_AXI_ARREADY	),
	.S_AXI_ARADDR			(S_AXI_ARADDR	),
	.S_AXI_ARVALID			(S_AXI_ARVALID	),
	.S_AXI_ARPROT			(S_AXI_ARPROT	),
	.S_AXI_RRESP			(S_AXI_RRESP	),
	.S_AXI_RVALID			(S_AXI_RVALID	),
	.S_AXI_RDATA			(S_AXI_RDATA	),
	.S_AXI_RREADY			(S_AXI_RREADY	),

	.o_rx_dval				(write_req_cpu_to_axi  		),
	.o_rx_addr				(write_addr_cpu_to_axi 		),
	.o_rx_data				(write_data_cpu_to_axi 		),
	.o_tx_req 				(read_req_cpu_to_axi   		),
	.o_tx_addr				(read_addr_cpu_to_axi  		),
	.i_tx_data				(read_data_axi_to_cpu  		),
	.i_tx_dval				(read_finish_axi_to_cpu		)
);

////////////////////////////////////////////////CPU WRITE////////////////////////////////////////////////////////

always@(posedge S_AXI_ACLK)begin
    if(~S_AXI_ARESETN)begin
        R_ENABLE           <= C_ENABLE_DEFAULT     ;
        R_DP_EN           <= 2'B0     ;
        R_PORT_NUM         <= C_PORT_NUM_DEFAULT   ;
        R_COLOR_DEPTH      <= C_COLOR_DEPTH_DEFAULT;
        R_COLOR_SPACE      <= C_COLOR_SPACE_DEFAULT;
        R_MEM_BYTES        <= C_MEM_BYTES_DEFAULT  ;
        R_HACTIVE         <=  C_HACTIVE_DEFAULT    ;
        R_VACTIVE         <=  C_VACTIVE_DEFAULT    ;
        R_HSYNC           <=  C_HSYNC_DEFAULT      ;
        R_HBP             <=  C_HBP_DEFAULT        ;
        R_HFP             <=  C_HFP_DEFAULT        ;
        R_VSYNC           <=  C_VSYNC_DEFAULT      ;
        R_VBP             <=  C_VBP_DEFAULT        ;
        R_VFP             <=  C_VFP_DEFAULT        ;
        R_OSD_H           <=  C_OSD_HPIXEL_DEFAULT      ;
        R_OSD_V           <=  C_OSD_VPIXEL_DEFAULT      ;
        R_OSD_X           <=  C_OSD_X_DEFAULT  ;
        R_OSD_Y           <=  C_OSD_Y_DEFAULT  ;
        R_OSD_ENABLE      <=  C_OSD_ENABLE_DEFAULT ;
        R_OSD_SETTING     <=  C_OSD_SETTING_DEFAULT ;
        R_DP_COLOR_SETTING   <=  { dp_color_setting_space__default , dp_color_setting_depth__default };
        R_PIX_CLK_FREQ    <=  C_PIX_CLK_FREQ_DEFAULT ;
        R_OUTPUT_SRC         <= C_OUTPUT_SRC_DEFAULT ;
        R_RGB         <= C_RGB_DEFAULT ;
    end
    else if(write_req_cpu_to_axi_ll)begin
        case(write_addr_cpu_to_axi_ll)
            `ADDR_ENABLE          :  {R_DP_EN,R_ENABLE}           <= {0,write_data_cpu_to_axi_ll[1:0]}   ;
            `ADDR_PORT_NUM        :  R_PORT_NUM         <= {0,write_data_cpu_to_axi_ll}   ;
            `ADDR_COLOR_SETTING   :  begin
                                        R_COLOR_DEPTH  <=  write_data_cpu_to_axi_ll[2:0]==3'b000 ? 6 :    //自然值
                                                           write_data_cpu_to_axi_ll[2:0]==3'b001 ? 8 :
                                                           write_data_cpu_to_axi_ll[2:0]==3'b010 ? 10 :
                                                           write_data_cpu_to_axi_ll[2:0]==3'b011 ? 12 :
                                                           write_data_cpu_to_axi_ll[2:0]==3'b100 ? 16 :  8 ;

                                        R_COLOR_SPACE  <=  write_data_cpu_to_axi_ll[5:3]==3'b000 ? 0 : //RGB888
                                                           write_data_cpu_to_axi_ll[5:3]==3'b001 ? 2 : //YUV422
                                                           write_data_cpu_to_axi_ll[5:3]==3'b010 ? 1 : //YUV888
                                                           write_data_cpu_to_axi_ll[5:3]==3'b100 ? 3 : 2 ;  //YUV420



                                     end
            `ADDR_DP_COLOR_MODE   : begin  // 专门通知DP模块，颜色的色域空间
                                        R_DP_COLOR_SETTING <= write_data_cpu_to_axi_ll ;  // 编码值
                                    end

            `ADDR_PIX_CLK_FREQ    :  R_PIX_CLK_FREQ    <=  {0,write_data_cpu_to_axi_ll}   ;
            `ADDR_MEM_BYTES       :  R_MEM_BYTES        <= {0,write_data_cpu_to_axi_ll}   ;
            `ADDR_HACTIVE         :  R_HACTIVE         <=  {0,write_data_cpu_to_axi_ll}   ;
            `ADDR_VACTIVE         :  R_VACTIVE         <=  {0,write_data_cpu_to_axi_ll}   ;
            `ADDR_LU_HACTIVE      :  R_LU_HACTIVE      <=  {0,write_data_cpu_to_axi_ll}   ;
            `ADDR_LU_VACTIVE      :  R_LU_VACTIVE      <=  {0,write_data_cpu_to_axi_ll}   ;

            `ADDR_HSYNC           :  R_HSYNC           <=  {0,write_data_cpu_to_axi_ll}   ;
            `ADDR_HBP             :  R_HBP             <= {0,write_data_cpu_to_axi_ll}   ;
            `ADDR_HFP             :  R_HFP             <= {0,write_data_cpu_to_axi_ll}   ;
            `ADDR_VSYNC           :  R_VSYNC           <= {0,write_data_cpu_to_axi_ll}   ;
            `ADDR_VBP             :  R_VBP             <= {0,write_data_cpu_to_axi_ll}   ;
            `ADDR_VFP             :  R_VFP             <= {0,write_data_cpu_to_axi_ll}   ;
            `ADDR_OSD_H           :  R_OSD_H           <= {0,write_data_cpu_to_axi_ll}   ;
            `ADDR_OSD_V           :  R_OSD_V           <= {0,write_data_cpu_to_axi_ll}   ;
            `ADDR_OSD_X           :  R_OSD_X           <= {0,write_data_cpu_to_axi_ll}   ;
            `ADDR_OSD_Y           :  R_OSD_Y           <= {0,write_data_cpu_to_axi_ll}   ;
            `ADDR_OSD_ENABLE      :  R_OSD_ENABLE      <= {0,write_data_cpu_to_axi_ll}   ;
            `ADDR_OSD_SETTING     :  R_OSD_SETTING     <= {0,write_data_cpu_to_axi_ll}   ;


            `ADDR_OUTPUT_SRC       :  R_OUTPUT_SRC      <= {0,write_data_cpu_to_axi_ll}   ;
            `ADDR_INNER_PAT_ID     :  R_INNER_PATTERN_ID <= {0,write_data_cpu_to_axi_ll}   ;
            `ADDR_RGB_COLOR        :  R_RGB              <= write_data_cpu_to_axi_ll   ;

            default:;
        endcase
    end
end

assign  OSD_WREQ   = write_req_cpu_to_axi_ll  & write_addr_cpu_to_axi_ll[18]==1'b1 ;//'h40000
assign  OSD_WADDR  = write_addr_cpu_to_axi_ll[17:0] ;
assign  OSD_WDATA  = write_data_cpu_to_axi_ll;

////////////////////////////////////////////////CPU READ////////////////////////////////////////////////////////

always@(posedge S_AXI_ACLK)begin
    if(~S_AXI_ARESETN)begin
        read_data_axi_to_cpu_ll   <= 0;
        read_finish_axi_to_cpu_ll <= 0;
    end
    else if(read_req_cpu_to_axi_ll)begin
        read_finish_axi_to_cpu_ll <= 1;
        case(read_addr_cpu_to_axi_ll)
            `ADDR_ENABLE          : read_data_axi_to_cpu_ll <= {0,R_ENABLE      };
            `ADDR_PORT_NUM        : read_data_axi_to_cpu_ll <= {0,R_PORT_NUM    };
            `ADDR_COLOR_SETTING   : read_data_axi_to_cpu_ll <=  R_DP_COLOR_SETTING ;
            `ADDR_PIX_CLK_FREQ    : read_data_axi_to_cpu_ll <= R_PIX_CLK_FREQ  ;
            `ADDR_MEM_BYTES       : read_data_axi_to_cpu_ll <= {0,R_MEM_BYTES   };
            `ADDR_HACTIVE         : read_data_axi_to_cpu_ll <= {0,R_HACTIVE     };
            `ADDR_VACTIVE         : read_data_axi_to_cpu_ll <= {0,R_VACTIVE     };
            `ADDR_HSYNC           : read_data_axi_to_cpu_ll <= {0,R_HSYNC       };
            `ADDR_HBP             : read_data_axi_to_cpu_ll <= {0, R_HBP        };
            `ADDR_HFP             : read_data_axi_to_cpu_ll <= {0, R_HFP        };
            `ADDR_VSYNC           : read_data_axi_to_cpu_ll <= {0, R_VSYNC      };
            `ADDR_VBP             : read_data_axi_to_cpu_ll <= {0, R_VBP        };
            `ADDR_VFP             : read_data_axi_to_cpu_ll <= {0, R_VFP        };
            `ADDR_OSD_H           : read_data_axi_to_cpu_ll <= {0, R_OSD_H      };
            `ADDR_OSD_V           : read_data_axi_to_cpu_ll <= {0, R_OSD_V      };
            `ADDR_OSD_X           : read_data_axi_to_cpu_ll <= {0, R_OSD_X      };
            `ADDR_OSD_Y           : read_data_axi_to_cpu_ll <= {0, R_OSD_Y      };
            `ADDR_OSD_ENABLE      : read_data_axi_to_cpu_ll <= {0, R_OSD_ENABLE };
            `ADDR_OSD_SETTING     : read_data_axi_to_cpu_ll <= {0, R_OSD_SETTING};
            `ADDR_OUTPUT_SRC      : read_data_axi_to_cpu_ll <= {0, R_OUTPUT_SRC  };
            `ADDR_INNER_PAT_ID    : read_data_axi_to_cpu_ll <= {0,R_INNER_PATTERN_ID};

            `ADDR_DP_IRQ_STATUS_ID  : read_data_axi_to_cpu_ll <= irq_status   ;
            `ADDR_DP_LANE_NUM_ID    : read_data_axi_to_cpu_ll <= i_lnk_cnt    ;
            `ADDR_DP_LANE_RATE_ID   : read_data_axi_to_cpu_ll <= i_lnk_bw     ;
            `ADDR_RGB_COLOR         : read_data_axi_to_cpu_ll <= R_RGB     ;
            default:;
        endcase
    end
    else begin
        read_finish_axi_to_cpu_ll <= 0;
    end
end



assign irq_status_rd_clr = (read_addr_cpu_to_axi_ll== `ADDR_DP_IRQ_STATUS_ID ) & read_finish_axi_to_cpu_ll;




//COLOR_SPACE_OFFSET:
//[6]  : VEDIO 输出使能
//[5:3]:颜色格式设置 000,001,010,100(RGB,YUV422,YUV444,YUV420)
//[2:0] :色深设置 000,001,010,011,100(6,8,10,12,16bpc)
//     *暂不支持YUV420
//      暂时只支持8bpc

wire BT601 = (R_DP_COLOR_SETTING[4:3]!=0) ;//YUV 使用BT601
assign  YUV420 = R_DP_COLOR_SETTING[5];



always @(posedge S_AXI_ACLK)
  if(~S_AXI_ARESETN) begin
      misc0   <= {R_DP_COLOR_SETTING[2:0],~BT601,1'b0,YUV420 ? 2'd2 : R_DP_COLOR_SETTING[4:3],1'b1};    //0x21
      misc1   <= {1'b0,R_DP_COLOR_SETTING[5],6'b0};
      polar   <= 2'b00;
  end else begin
      misc0    <= {R_DP_COLOR_SETTING[2:0],~BT601,1'b0,YUV420 ? 2'd2 : R_DP_COLOR_SETTING[4:3],1'b1};    //0x21
      misc1    <= {1'b0,R_DP_COLOR_SETTING[5],6'b0};
      polar    <= 2'b00;
  end


always @(posedge S_AXI_ACLK) begin
  PIX_CLK_FREQ <= R_PIX_CLK_FREQ  ;
  HACTIVE      <= R_HACTIVE       ;
  HFP          <= R_HFP           ;
  HSYNC        <= R_HSYNC         ;
  HBP          <= R_HBP           ;
  VACTIVE      <= R_VACTIVE       ;
  VFP          <= R_VFP           ;
  VSYNC        <= R_VSYNC         ;
  VBP          <= R_VBP           ;
end




fifo_async_xpm
    #(.C_WR_WIDTH             (C_RAW_DATA_WIDTH ),// ratio must be 1:1, 1:2, 1:4, 1:8,
      .C_WR_DEPTH             (C_FIFO_DEPTH),// must>=16 ; actual depth = C_WR_DEPTH - 1;  must be power of 2
      .C_RD_WIDTH             (C_FIFO_OUT_WIDTH),
      .C_WR_COUNT_WIDTH       (16),
      .C_RD_COUNT_WIDTH       (16),
      //.C_RD_PROG_EMPTY_THRESH (),
      .C_WR_PROG_FULL_THRESH  (C_FIFO_DEPTH-C_FIFO_WREADY_THRESH),
      .C_RD_MODE              ("fwft" ) //"std" "fwft"
     )
    fifo_rd_u(
    .WR_RST_I         (rst_fifo_wr     ),
    .WR_CLK_I         (AXI4_CLK_I      ),
    .WR_EN_I          (WREQ   ),
    .WR_DATA_I        (WDATA           ),
    .WR_FULL_O        (WR_FULL         ),
    .WR_DATA_COUNT_O  (WR_DATA_COUNT   ),
    .WR_PROG_FULL_O   (prog_full       ),
    .WR_RST_BUSY_O    (WR_RST_BUSY),
    .WR_EN_NAMES_O    (WR_EN_NAMES )  ,
    .WR_EN_ACCUS_O    (WR_EN_ACCUS )   , //total valid wr num
    .WR_ERR_O         (WR_ERR),

    .RD_RST_I         (rst_fifo_rd     ),
    .RD_CLK_I         (VID_CLK_I       ),
    .RD_EN_I          (pixel_rd_0    ),
    .RD_DATA_VALID_O  (RD_DATA_VALID ),
    .RD_DATA_O        (pixel_data_0  ),
    .RD_EMPTY_O       (RD_EMPTY),
    .RD_DATA_COUNT_O  (RD_DATA_COUNT),
    .RD_PROG_EMPTY_O  (),
    .RD_RST_BUSY_O    (RD_RST_BUSY),
    .RD_EN_NAMES_O    (RD_EN_NAMES )  ,
    .RD_EN_ACCUS_O    (RD_EN_ACCUS )   ,
    .RD_ERR_O         (RD_ERR)

    );


reg [15:0] R_LU_HACTIVE_div_vidclk  ;
always@(*)begin
    case(R_PORT_NUM_vidclk)
        1:begin
            R_MEM_BYTES_vidclk_mult = R_MEM_BYTES_vidclk;
            R_LU_HACTIVE_div_vidclk = R_LU_HACTIVE_vidclk;
        end
        2:begin
            R_MEM_BYTES_vidclk_mult = R_MEM_BYTES_vidclk<<1;
            R_LU_HACTIVE_div_vidclk = R_LU_HACTIVE_vidclk[15:1];
        end
        4:begin
            R_MEM_BYTES_vidclk_mult = R_MEM_BYTES_vidclk<<2;
            R_LU_HACTIVE_div_vidclk = R_LU_HACTIVE_vidclk[15:2];
        end
        8:begin
            R_MEM_BYTES_vidclk_mult = R_MEM_BYTES_vidclk<<3;
            R_LU_HACTIVE_div_vidclk = R_LU_HACTIVE_vidclk[15:3];
        end
        default:begin
            R_MEM_BYTES_vidclk_mult = R_MEM_BYTES_vidclk;
            R_LU_HACTIVE_div_vidclk = R_LU_HACTIVE_vidclk;
        end
    endcase
end




// assign tpg_de_lu  =  tpg_de_inner & (  active_x>=1 && active_x<=R_LU_HACTIVE_vidclk/C_MAX_PORT_NUM   &&    active_y>=1 && active_y<=R_LU_VACTIVE_vidclk  ) ;
assign tpg_de_lu  =  tpg_de_inner & (  active_x>=1 && active_x<=R_LU_HACTIVE_div_vidclk   &&    active_y>=1 && active_y<=R_LU_VACTIVE_vidclk  ) ;

//(*KEEP_HIERARCHY ="TURE"*)

rd_station  //delay 2
    #(.C_MAX_UNIT_NUM(C_FIFO_OUT_WIDTH/8),
      .C_BIT_NUM_PER_UNIT (8)
      )
    station_rd_u(
    .CLK_I              (VID_CLK_I      ),
    .RST_I              (rst_rd_station ),
    .HS_I               (tpg_hs),
    .VS_I               (tpg_vs),
    //.DE_I               ( tpg_de ), // 如果为420，则此处砍掉一半

    .DE_I               (tpg_de_lu       ),// left up
    .DE_I_TOTAL         (tpg_de          ),
    .UNITS_I            ( C_FIXED_MAX_PARA ? C_DDR_PIXEL_MAX_BYTE_NUM * C_MAX_PORT_NUM :  R_MEM_BYTES_vidclk_mult ),

    .RD_O               (pixel_rd_0   ),
    .DATA_I             (pixel_data_0 ),
    .HS_O               (pixel_hs_1   ),
    .VS_O               (pixel_vs_1   ),
    .DE_O               (pixel_de_1_lu      ),
    .DE_O_TOTAL         (pixel_de_1_total   ),
    .DATA_O             (pixel_data_1 )
    );




//assign   pixel_rd_0   =  tpg_de ;
//assign   pixel_data_1 =  pixel_data_0 ;
//assign   pixel_hs_1   =  tpg_hs ;
//assign   pixel_vs_1   =  tpg_vs ;
//assign   pixel_de_1_lu   =  tpg_de ;
//assign   pixel_de_1_total = tpg_de ;


//(*KEEP_HIERARCHY ="TURE"*)
reconcat_rd //delay 2
    #(.C_MAX_PORT_NUM(C_MAX_PORT_NUM),
      .C_DDR_PIXEL_MAX_BYTE_NUM(C_DDR_PIXEL_MAX_BYTE_NUM),
      .C_MAX_BPC(C_MAX_BPC))
    reconcat_rd_u  (
    .CLK_I                 (VID_CLK_I),
    .RST_I                 (rst_reconcat ),
    .PIXEL_VS_I            (pixel_vs_1   ),
    .PIXEL_HS_I            (pixel_hs_1   ),
    .PIXEL_DE_I            (pixel_de_1_lu   ),  //left up valid de
    .PIXEL_DE_I_TOTAL      (pixel_de_1_total   ),
    .PIXEL_DATA_I          (pixel_data_1 ),// [C_DDR_PIXEL_MAX_BYTE_NUM*8*C_MAX_PORT_NUM-1:0] 像素紧凑
    .ACTUAL_DDR_BYTE_NUM_I (C_FIXED_MAX_PARA ?  C_DDR_PIXEL_MAX_BYTE_NUM :  {0,R_MEM_BYTES_vidclk}),// [7:0]  mean how to analyze PIXEL_DATA_I
    .TARGET_BPC_I          (C_FIXED_MAX_PARA ?  C_MAX_BPC  :   R_COLOR_DEPTH_vidclk),// [3:0] mean how to analyze PIXEL_DATA_I
    .PIXEL_VS_O            (pixel_vs_4),
    .PIXEL_HS_O            (pixel_hs_4),
    .PIXEL_DE_O            ( pixel_de_4_lu ),
    .PIXEL_DE_O_TOTAL      (pixel_de_4_total),
    .PIXEL_DATA_O          (pixel_data_4)// [C_MAX_BPC*3*C_MAX_PORT_NUM-1:0] {R G B } or  {0 U Y } or {U Y Y}/{V Y Y}

    );



//(*KEEP_HIERARCHY ="TURE"*)
csc_rd  //delay 3
    #(.C_YUV2RGB_EN(C_YUV2RGB_BLOCK_EN),
      .C_RGB2YUV_EN(C_RGB2YUV_BLOCK_EN),
      .C_420FIFO_EN(C_420FIFO_BLOCK_EN),

      .C_PORT_NUM        (C_MAX_PORT_NUM),
      .C_BPC             (C_MAX_BPC),
      .C_OUTPUT_FORMAT   (C_OUT_FORMAT), //0: RGB  1:YUV
      .DDR_Video_Format  (DDR_Video_Format))
    csc_rd_u(
    .CLK_I             (VID_CLK_I),
    .RST_I             (rst_csc ),
   // .ISPACE_I          ( 2  ), //[3:0] input color space :  0:RGB(也可以理解为不做转换) , 1:YUV444 , 2:YUV422 , 3:YUV420
    .ISPACE_I          (R_COLOR_SPACE_vidclk  ),  // in color space
    .VS_O              (vs_5),//1bit
    .HS_O              (hs_5),
    .DE_O              (de_5),
    .R_O               (r_5 ), // [C_BPC*C_PORT_NUM-1:0]
    .G_O               (g_5 ),
    .B_O               (b_5 ),
    .PIXEL_VS_I        (pixel_vs_4), //simulate vs hs de
    .PIXEL_HS_I        (pixel_hs_4),
    .PIXEL_DE_I        (pixel_de_4_total ), //__|——————|____________________ (420), 内存数据为420时，需要一个少一半的DE信号
    .PIXEL_DE_TOTAL_I  (pixel_de_4_total ), //__|——————|_______|——————|_____
    .PIXEL_DATA_I      (pixel_de_4_lu ? pixel_data_4 : 0 )  // [C_BPC*3*C_PORT_NUM-1:0] exp: {BGR}{BGR}{BGR}{BGR} ; {VUY}{VUY}{VUY}{VUY} ; {0UY}{0UY}{0UY}{0UY} ; {VYY}{UYY}{VYY}{UYY}

    );




generate if(C_OSD_BLOCK_EN==0)begin



assign  VID_VS_O = {C_MAX_PORT_NUM{vs_5}};
assign  VID_HS_O = {C_MAX_PORT_NUM{hs_5}};
assign  VID_DE_O = {C_MAX_PORT_NUM{de_5}};
//assign  VID_R_O  = ~C_INNER_PATTERN_ENABLE ? r_5 :  {C_MAX_PORT_NUM{tpg_r_inner_s7}};
//assign  VID_G_O  = ~C_INNER_PATTERN_ENABLE ? g_5 :  {C_MAX_PORT_NUM{tpg_g_inner_s7}};
//assign  VID_B_O  = ~C_INNER_PATTERN_ENABLE ? b_5 :  {C_MAX_PORT_NUM{tpg_b_inner_s7}};

assign  VID_R_O  = ~R_OUTPUT_SRC_vidclk ? r_5 :  {C_MAX_PORT_NUM{tpg_r_inner_s7}}; //tpg_r_inner_s7 在独立tpg和patterngen之间硬选择
assign  VID_G_O  = ~R_OUTPUT_SRC_vidclk ? g_5 :  {C_MAX_PORT_NUM{tpg_g_inner_s7}};
assign  VID_B_O  = ~R_OUTPUT_SRC_vidclk ? b_5 :  {C_MAX_PORT_NUM{tpg_b_inner_s7}};


end
else begin
  osd
   #( .C_MAX_PORT_NUM   (C_MAX_PORT_NUM),
      .C_MAX_BPC        (C_MAX_BPC),
      .C_VID_OSD_ILA_EN (C_VID_OSD_ILA_EN)
     )
      osd_u(
      .VID_CLK_I     (VID_CLK_I),
      .VID_RST_I     (rst_osd),
      .VS_I          (vs_5  ),
      .HS_I          (hs_5  ),
      .DE_I          (de_5  ),
      .R_I           (r_5   ),//[C_MAX_BPC*8*C_MAX_PORT_NUM-1:0]
      .G_I           (g_5   ),
      .B_I           (b_5   ),
      .VS_O          (vs_osd),
      .HS_O          (hs_osd),
      .DE_O          (de_osd),
      .R_O           (r_osd ),//[C_MAX_BPC*8*C_MAX_PORT_NUM-1:0]
      .G_O           (g_osd ),
      .B_O           (b_osd ),
      .OSD_AXI_CLK_I (S_AXI_ACLK     ),//mostly AXI CLK
      .OSD_AXI_RST_I (~S_AXI_ARESETN ),
      .OSD_ENABLE_I  (R_OSD_ENABLE   ),
      .OSD_TRANSPARENT_I ( R_OSD_SETTING[0] ) ,
      .OSD_PORTS_I   (C_FIXED_MAX_PARA ?  C_MAX_PORT_NUM  :  R_PORT_NUM     ), //[3:0]  also actual valid input port num
      .OSD_X_I       (R_OSD_X        ),//[15:0] from 0
      .OSD_Y_I       (R_OSD_Y        ),//[15:0] from 0
      .OSD_H_I       (R_OSD_H        ),//[15:0]
      .OSD_V_I       (R_OSD_V        ),//[15:0]
      .OSD_WADDR_I   (OSD_WADDR >> 2 ),//[15:0]
      .OSD_WDATA_I   (OSD_WDATA      ),//[15:0]
      .OSD_WREQ_I    (OSD_WREQ       )

      );


assign  VID_VS_O = {C_MAX_PORT_NUM{vs_osd}};
assign  VID_HS_O = {C_MAX_PORT_NUM{hs_osd}};
assign  VID_DE_O = {C_MAX_PORT_NUM{de_osd}};
//assign  VID_R_O  = ~C_INNER_PATTERN_ENABLE ? r_osd :  {C_MAX_PORT_NUM{tpg_r_inner_s11}};
//assign  VID_G_O  = ~C_INNER_PATTERN_ENABLE ? g_osd :  {C_MAX_PORT_NUM{tpg_g_inner_s11}};
//assign  VID_B_O  = ~C_INNER_PATTERN_ENABLE ? b_osd :  {C_MAX_PORT_NUM{tpg_b_inner_s11}};


assign  VID_R_O  = ~R_OUTPUT_SRC_vidclk[7] ? r_osd :  {C_MAX_PORT_NUM{tpg_r_inner_s11}};
assign  VID_G_O  = ~R_OUTPUT_SRC_vidclk[7] ? g_osd :  {C_MAX_PORT_NUM{tpg_g_inner_s11}};
assign  VID_B_O  = ~R_OUTPUT_SRC_vidclk[7] ? b_osd :  {C_MAX_PORT_NUM{tpg_b_inner_s11}};


end
endgenerate



always@(*)begin
    case(R_PORT_NUM_vidclk)
        1:begin
            R_HSYNC_vidclk_div    = R_HSYNC_vidclk;
            R_HBP_vidclk_div      = R_HBP_vidclk;
            R_HACTIVE_vidclk_div  = R_HACTIVE_vidclk;
            R_HFP_vidclk_div      = R_HFP_vidclk;
        end
        2:begin
            R_HSYNC_vidclk_div    = R_HSYNC_vidclk>>1;
            R_HBP_vidclk_div      = R_HBP_vidclk>>1;
            R_HACTIVE_vidclk_div  = R_HACTIVE_vidclk>>1;
            R_HFP_vidclk_div      = R_HFP_vidclk>>1;
        end
        4:begin
            R_HSYNC_vidclk_div    = R_HSYNC_vidclk>>2;
            R_HBP_vidclk_div      = R_HBP_vidclk>>2;
            R_HACTIVE_vidclk_div  = R_HACTIVE_vidclk>>2;
            R_HFP_vidclk_div      = R_HFP_vidclk>>2;
        end
        8:begin
            R_HSYNC_vidclk_div    = R_HSYNC_vidclk>>3;
            R_HBP_vidclk_div      = R_HBP_vidclk>>3;
            R_HACTIVE_vidclk_div  = R_HACTIVE_vidclk>>3;
            R_HFP_vidclk_div      = R_HFP_vidclk>>3;
        end
        default : begin
            R_HSYNC_vidclk_div    = R_HSYNC_vidclk;
            R_HBP_vidclk_div      = R_HBP_vidclk;
            R_HACTIVE_vidclk_div  = R_HACTIVE_vidclk;
            R_HFP_vidclk_div      = R_HFP_vidclk;
        end
    endcase
end



//generate if( C_INNER_PATTERN_ENABLE )begin
//`DELAY_INGEN(VID_CLK_I,0,tpg_r_inner,tpg_r_inner_s7,8,7)
//`DELAY_INGEN(VID_CLK_I,0,tpg_g_inner,tpg_g_inner_s7,8,7)
//`DELAY_INGEN(VID_CLK_I,0,tpg_b_inner,tpg_b_inner_s7,8,7)
//end
//endgenerate

`DELAY_INGEN(VID_CLK_I,0,tpg_r_inner,tpg_r_inner_s7,8,7)
`DELAY_INGEN(VID_CLK_I,0,tpg_g_inner,tpg_g_inner_s7,8,7)
`DELAY_INGEN(VID_CLK_I,0,tpg_b_inner,tpg_b_inner_s7,8,7)




//generate if( C_INNER_PATTERN_ENABLE & C_OSD_BLOCK_EN)begin
//`DELAY_INGEN(VID_CLK_I,0,tpg_r_inner_s7,tpg_r_inner_s11,8,4)
//`DELAY_INGEN(VID_CLK_I,0,tpg_g_inner_s7,tpg_g_inner_s11,8,4)
//`DELAY_INGEN(VID_CLK_I,0,tpg_b_inner_s7,tpg_b_inner_s11,8,4)
//end
//endgenerate

`DELAY_INGEN(VID_CLK_I,0,tpg_r_inner_s7,tpg_r_inner_s11,8,4)
`DELAY_INGEN(VID_CLK_I,0,tpg_g_inner_s7,tpg_g_inner_s11,8,4)
`DELAY_INGEN(VID_CLK_I,0,tpg_b_inner_s7,tpg_b_inner_s11,8,4)



generate if(C_INNER_PATTERN_BLOCK_EN==0)begin
(*keep_hierarchy="yes"*)
tpg
    #(.OUTPUT_REGISTER_EN(1),  // 改善时序
      .HARD_TIMING_EN    (0),
      .PORT_NUM          (1)
      )
    tpg_u(
    .PIXEL_CLK_I     (VID_CLK_I  ),
    .RESETN_I         (~rst_tpg  ),  //do not need rst when VS come
    .HSYNC_I         (C_FIXED_MAX_PARA  ?  R_HSYNC_vidclk/C_MAX_PORT_NUM   : R_HSYNC_vidclk_div    ),
    .HBP_I           (C_FIXED_MAX_PARA  ?  R_HBP_vidclk/C_MAX_PORT_NUM     : R_HBP_vidclk_div      ),
    .HACTIVE_I       (C_FIXED_MAX_PARA  ?  R_HACTIVE_vidclk/C_MAX_PORT_NUM : R_HACTIVE_vidclk_div  ),
    .HFP_I           (C_FIXED_MAX_PARA  ?  R_HFP_vidclk/C_MAX_PORT_NUM     : R_HFP_vidclk_div      ),
    .VSYNC_I         (R_VSYNC_vidclk),
    .VBP_I           (R_VBP_vidclk),
    .VACTIVE_I       (R_VACTIVE_vidclk),
    .VFP_I           (R_VFP_vidclk),
    .HS_O            (tpg_hs_inner     ),// tpg driver
    .VS_O            (tpg_vs_inner     ),
    .DE_O            (tpg_de_inner     ),
    .R_O             (tpg_r_inner_ori      ),  //内部pattern打开后，此处出pattern内容
    .G_O             (tpg_g_inner_ori      ),
    .B_O             (tpg_b_inner_ori      ),
    .ACTIVE_X_O      (active_x   ),//16bit    from 1
    .ACTIVE_Y_O      (active_y   ) //16bit    from 1
    );
end
else begin

pattern_gen_core #(.C_PORT_NUM (C_MAX_PORT_NUM)   )
    pattern_gen_core (
    .CLK_I               ( VID_CLK_I          ),
    .RST_I               ( rst_tpg            ),
    // .PORT_NUM_I          ( C_MAX_PORT_NUM           ), //[2:0]
    .PORT_NUM_I          ( R_PORT_NUM_vidclk[2:0]           ), //[2:0]
    //.PATSEL_I            ( PATSEL_I_pclk      ), // [7:0]
    .PATSEL_I            ( R_INNER_PATTERN_ID_vidclk  ),
    .HACTIVE_I           ( R_HACTIVE_vidclk   ),
    .HFP_I               ( R_HFP_vidclk       ),
    .HSYNC_I             ( R_HSYNC_vidclk     ),
    .HBP_I               ( R_HBP_vidclk       ),
    .VACTIVE_I           ( R_VACTIVE_vidclk   ),
    .VFP_I               ( R_VFP_vidclk       ),
    .VSYNC_I             ( R_VSYNC_vidclk     ),
    .VBP_I               ( R_VBP_vidclk       ),
    .CYCLE_VAL_I         ( 4 ), //[31:0]
    .UART_R_I            ( R_RGB_vidclk[23:16] ), //[7:0] input
    // .UART_R_I            ( 8'h17 ), //[7:0] input
    .UART_G_I            ( R_RGB_vidclk[15:8] ), //[7:0] input
    // .UART_G_I            ( 8'haa ), //[7:0] input
    .UART_B_I            ( R_RGB_vidclk[7:0] ), //[7:0] input
    // .UART_B_I            ( 8'h65 ), //[7:0] input
    .VS_O                (tpg_vs_inner        ),  //[PIXELS_PER_CLOCK-1:0]
    .HS_O                (tpg_hs_inner        ), //[PIXELS_PER_CLOCK-1:0]
    .DE_O                (tpg_de_inner        ), //[PIXELS_PER_CLOCK-1:0]
    .R_O                 (tpg_r_inner_ori         ), //[8*PIXELS_PER_CLOCK-1:0]
    .G_O                 (tpg_g_inner_ori         ), //[8*PIXELS_PER_CLOCK-1:0]
    .B_O                 (tpg_b_inner_ori         ),
    .ACTIVE_X_O          (active_x            ) ,
    .ACTIVE_Y_O          (active_y            )

);

end
endgenerate


assign  tpg_r_inner  = C_INNER_PATTERN_BLOCK_EN ?   tpg_r_inner_ori : 0  ;
assign  tpg_g_inner  = C_INNER_PATTERN_BLOCK_EN ?   tpg_g_inner_ori : 0  ;
assign  tpg_b_inner  = C_INNER_PATTERN_BLOCK_EN ?   tpg_b_inner_ori : 0  ;




assign tpg_vs  = C_TPG_SRC ?  VID_VS_I : tpg_vs_inner ;
assign tpg_hs  = C_TPG_SRC ?  VID_HS_I : tpg_hs_inner ;
assign tpg_de  = C_TPG_SRC ?  VID_DE_I : tpg_de_inner ;


`POS_MONITOR(VID_CLK_I,0,tpg_vs,tpg_vs_vclk_pos)


`CDC_MULTI_BIT_SIGNAL(VID_CLK_I,tpg_vs,S_AXI_ACLK,tpg_vs_aclk,1)
`CDC_MULTI_BIT_SIGNAL(VID_CLK_I,tpg_vs,AXI4_CLK_I,tpg_vs_mclk,1)
`POS_MONITOR(S_AXI_ACLK,0,tpg_vs_aclk,tpg_vs_aclk_pos)
`POS_MONITOR(AXI4_CLK_I,0,tpg_vs_mclk,tpg_vs_mclk_pos)


//////////////////////////////////////////////////////////////////////////////////////////////


`POS_MONITOR(VID_CLK_I,0,VID_HS_O,VID_HS_O_pos)


always@(posedge VID_CLK_I)begin
    cnt_h <= VID_VS_O ? 0 :  VID_HS_O_pos ?  cnt_h + 1 : cnt_h ;
end

assign CNT_H = cnt_h ;


//////////////////////////////////////////////////////////////////////////////////////////////



generate  if(C_AXI_ILA_EN) begin
    ila_axi_lite ila_axi_lite_u (
        .clk    (S_AXI_ACLK),
        .probe0 (R_ENABLE),
        .probe1 (R_PORT_NUM),
        .probe2 (R_COLOR_DEPTH),
        .probe3 (R_COLOR_SPACE),
        .probe4 (R_MEM_BYTES),
        .probe5 (write_req_cpu_to_axi  ),
        .probe6 (write_addr_cpu_to_axi ),
        .probe7 (write_data_cpu_to_axi ),
        .probe8 (R_OSD_ENABLE ),
        .probe9 (OSD_WREQ   ),
        .probe10 (OSD_WADDR ),
        .probe11 (OSD_WDATA )

    );

end
endgenerate


generate if(C_RAW_ILA_EN)begin
       ila_raw_fifo ila_raw_fifo_u (
        .clk    (AXI4_CLK_I),
        .probe0 (WREQ),
        .probe1 ({prog_full,fifo_wr_latch_axi4}),
        .probe2 (tpg_vs_mclk),
        .probe3 (WEOF),
        .probe4 (WR_RST_BUSY),
        .probe5 (WR_DATA_COUNT),
        .probe6 (WR_FULL),
        .probe7 (WR_ERR),
        .probe8 (WR_EN_NAMES ),
        .probe9 (WR_EN_ACCUS ),
        .probe10(WDATA )


    );

end
endgenerate


generate if(C_VID_ILA_EN) begin
    ila_vid_clk ila_vid_clk_u (
        .clk     (VID_CLK_I),
        .probe0  (tpg_de),
        .probe1  (pixel_rd_0),
        .probe2  (pixel_data_0),
        .probe3  (pixel_de_1_lu),
        .probe4  (pixel_data_1),
        .probe5  (pixel_de_2),
        .probe6  (pixel_data_2),
        .probe7  (pixel_de_3),
        .probe8  (pixel_data_3),
        .probe9  (pixel_de_4_lu),
        .probe10 (pixel_data_4),
        .probe11 (VID_R_O),
        .probe12 (VID_G_O),
        .probe13 (VID_B_O),
        .probe14 ({RD_EMPTY ,tpg_enable_vid} ),
        .probe15 (RD_DATA_COUNT ),
        .probe16 (RD_ERR),
        .probe17 (RD_EN_NAMES ),
        .probe18 (RD_EN_ACCUS ),
        .probe19 ({VID_DE_O,VID_VS_O,VID_HS_O} )

    );



end
endgenerate


generate if(C_PARA_NATIVE_ILA_EN_AXICLK)begin
    ila_1  ila_1_u
    (
    .clk    ( S_AXI_ACLK ) ,
    .probe0 (  polar ) ,
    .probe1 (  misc0 ) ,
    .probe2 (  misc1 ) ,
    .probe3 ( PIX_CLK_FREQ ) ,
    .probe4 ( YUV420  ) ,
    .probe5  (PIX_CLK_FREQ   ) ,
    .probe6  (HACTIVE        ) ,
    .probe7  (HFP            ) ,
    .probe8  (HSYNC          ) ,
    .probe9  (HBP            ) ,
    .probe10 (VACTIVE        ) ,
    .probe11 (VFP            ) ,
    .probe12 ( VSYNC         )  ,
    .probe13 (  VBP          )
) ;

end
endgenerate



endmodule




