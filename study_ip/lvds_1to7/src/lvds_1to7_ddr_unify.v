
`define CDC_MULTI_BIT_SIGNAL_OUTGEN(aclk,adata_in,bclk,bdata_out,DATA_WIDTH,DEST_FF)                    generate begin xpm_cdc_array_single #(.DEST_SYNC_FF(DEST_FF),.INIT_SYNC_FF(0),.SIM_ASSERT_CHK(0),.SRC_INPUT_REG(1),.WIDTH(DATA_WIDTH)) cdc_u(.src_clk(aclk),.src_in(adata_in),.dest_clk(bclk),.dest_out(bdata_out));    end  endgenerate  
`define DELAY_OUTGEN(clk,rst,data_in,data_out,DATA_WIDTH,DLY)                                           generate if(DLY==0)begin  assign data_out = data_in; end  else if(DLY==1)begin  reg [DATA_WIDTH-1:0] a_temp = 0; always@(posedge clk) a_temp <= data_in; assign data_out = a_temp ; end  else begin  reg [DATA_WIDTH-1:0] a_temp [DLY-1:0] ;always@(posedge clk) begin  if(rst)a_temp[DLY-1] <= 0; else   a_temp[DLY-1] <= data_in; end  for(i=0;i<=DLY-2;i=i+1)begin  always@(posedge clk)begin  if(rst)begin  a_temp[i] <= 0; end  else begin  a_temp[i] <= a_temp[i+1]; end  end  end  assign data_out = a_temp[0]; end  endgenerate
`define CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(adata_in,bclk,bdata_out,DATA_WIDTH,DEST_FF)                    generate begin xpm_cdc_array_single #(.DEST_SYNC_FF(DEST_FF),.INIT_SYNC_FF(0),.SIM_ASSERT_CHK(0),.SRC_INPUT_REG(0),.WIDTH(DATA_WIDTH)) cdc_u(.src_clk( ),.src_in(adata_in),.dest_clk(bclk),.dest_out(bdata_out));    end  endgenerate  


`define CDC_MULTI_BIT_SIGNAL_INGEN(aclk,adata_in,bclk,bdata_out,DATA_WIDTH,DEST_FF)                     begin xpm_cdc_array_single #(.DEST_SYNC_FF(DEST_FF),.INIT_SYNC_FF(0),.SIM_ASSERT_CHK(0),.SRC_INPUT_REG(1),.WIDTH(DATA_WIDTH)) cdc_u(.src_clk(aclk),.src_in(adata_in),.dest_clk(bclk),.dest_out(bdata_out));    end    
`define DELAY_INGEN(clk,rst,data_in,data_out,DATA_WIDTH,DLY)                                            if(DLY==0)begin  assign data_out = data_in; end  else if(DLY==1)begin  reg [DATA_WIDTH-1:0] a_temp = 0; always@(posedge clk) a_temp <= data_in; assign data_out = a_temp ; end  else begin  reg [DATA_WIDTH-1:0] a_temp [DLY-1:0] ;always@(posedge clk) begin  if(rst)a_temp[DLY-1] <= 0; else   a_temp[DLY-1] <= data_in; end  for(i=0;i<=DLY-2;i=i+1)begin  always@(posedge clk)begin  if(rst)begin  a_temp[i] <= 0; end  else begin  a_temp[i] <= a_temp[i+1]; end  end  end  assign data_out = a_temp[0]; end  
`define CDC_MULTI_BIT_SIGNAL_INGEN_NOIN(adata_in,bclk,bdata_out,DATA_WIDTH,DEST_FF)                     begin xpm_cdc_array_single #(.DEST_SYNC_FF(DEST_FF),.INIT_SYNC_FF(0),.SIM_ASSERT_CHK(0),.SRC_INPUT_REG(0),.WIDTH(DATA_WIDTH)) cdc_u(.src_clk( ),.src_in(adata_in),.dest_clk(bclk),.dest_out(bdata_out));    end    


//by  yzhu 
/////////////////////////////reg space///////////////////////////////////////
`define  ADDR_ENABLE                  16'h0000
`define  ADDR_CLK_PN_SWAP             16'h0004
`define  ADDR_DATAIN_PN_SWAP          16'h0008  //not support
`define  ADDR_DATAOUT_PN_SWAP         16'h000c
`define  ADDR_PORT_NUM                16'h0010 //各port检测锁定，还是需要对应的输入clk波形正常才可
//debug reg
`define  ADDR_STATUS_DBG              16'h0014  //{3'b000,DETECT_MISALLIGN, rx_mmcm_lckdpsbs_m__aclk[port_num-1:0],  3'b000,mmcm_locked__aclk,3'b000,rx_pixel_clk_locked__aclk};
`define  ADDR_MIS_ALIGNED_ACCUS_DBG   16'h0018
`define  ADDR_MIS_ALIGNED_ROUNDS_DBG  16'h001c
`define  ADDR_MIS_ALIGNED_RETRYS_DBG  16'h0020
`define  ADDR_PCLK_MHZ_DBG            16'h0024
`define  ADDR_PIXEL_ARR_MODE          16'h0028



//////////////////////////////////////////////////////////////////////////////
//  /   /\/   /
// /___/  \  /   Vendor: Xilinx
// \   \   \/    Version: 1.2
//  \   \        Filename: top5x2_7to1_ddr_rx.v
//  /   /        Date Last Modified:  21JAN2015
// /___/   /\    Date Created: 30SEP2013
// \   \  /  \
//  \___\/\___\
//Device:     7-Series
//Purpose:      DDR top level receiver example - 2 channels of 5-bits each
//Reference:    XAPP585
//////////////////////////////////////////////////////////////////////////////
`timescale 1ps/1ps
(*KEEP_HIERARCHY  = "TRUE"*) 
module lvds_1to7_ddr_unify #(
    parameter PORT_NUM    = 4,
    parameter LANE_NUM    = 4,
    parameter SAMPL_CLOCK = "BUFIO",          // default:"BUFIO"
    parameter INTER_CLOCK = "BUF_R",          // default:"BUF_R"
    parameter PIXEL_CLOCK = "BUF_G",          // default:"BUF_G"
    parameter USE_PLL     = "FALSE",          // default:"FALSE" use PLL or MMCM
    parameter AXICLK_PRD_NS = 10 ,
    
	parameter [0:0] LVDS_ENABLE_DEFAULT = 0 ,
    parameter [0:0] LVDS_CLK_PN_SWAP_DEFAULT      = 0 ,  
    parameter [0:0] LVDS_DATAIN_PN_SWAP_DEFAULT   = 0 , //注意：内部固定位0，修改无效； 数据IN PN反向只能硬配置，不能软配置
	parameter [0:0] LVDS_DATAOUT_PN_SWAP_DEFAULT  = 0 ,
	parameter [3:0] LVDS_LOCKED_PORT_NUM_DEFAULT  = 4 , 
    parameter [0:0] PIXEL_ARR_MODE_DEFAULT        = 0 ,
    parameter [0:0] DETECT_MISALLIGN              = 1  ,//内部加入对齐和自动复位逻辑
    parameter C_MISALIGN_RST_THRESHOLD_PCLK_NUM   = 200 , 
    parameter C_1TO7_RST_ACLK_NUM                 = 300 ,
    parameter C_MISALIGN_PCLK_PROTECT             = 3000,
    //////////////////////////////////////////////////////////////////////////////
    parameter [0:0] PCLK_ILA_ENABLE    = 0 ,//pclk
    parameter [0:0] ACLK_ILA_ENABLE    = 0 ,//aclk
    parameter [0:0] DESKEW_ILA_ENABLE  = 0 ,//pclk
    //////////////////////////////////////////////////////////////////////////////
    parameter ENABLE_PHASE_DETECTOR = 1'b0,       // enable phase detector operation
    parameter ENABLE_MONITOR        = 1'b0,       // enables data eye monitoring
    parameter DCD_CORRECT           = 1'b0,       // enables clock duty cycle correction
    parameter HIGH_PERFORMANCE_MODE = "FALSE",    // default:"FALSE"
    parameter MMCM_MODE             = 1,          // default:1; fixed 1 
    parameter REF_FREQ              = 200.0,      // default:200.0
    parameter CLKIN_PERIOD          = 6.734,      // default:6.734; please enter max value
    parameter BIT_RATE_VALUE        = 16'h1050 ,   // default:16'h1050
	parameter C_AXI_LITE_DATA_WIDTH = 32  ,
	parameter C_AXI_LITE_ADDR_WIDTH = 16  ,
    
    parameter [0:0] C_LB_ENABLE     = 0  ,
    parameter [0:0] C_BLANK_EN      = 0  , //1 :使模块成为一个空模块, 但不影响axilite总线读写
    
    parameter [0:0] C_CONTAIN_DLY_CTRL  = 1 ,
    parameter [0:0] C_PCLK_DET_BLOCK_EN = 1 ,
    parameter       C_DEVICE_TYPE = "K7"   ,//"A7" "K7"(default) "KU" "KUP"
    parameter       C_IMPL_MECHANISM  =  "DDR"  , // "DDR" "SDR"
    parameter [0:0] C_PIXEL_ARR_MODE =  0  //0:normal 1:other 
    

)(
perm_clk            ,//a constant clk for generating reset to rx0
ref_clk             ,//200M(default) or 300M
lvds_clk_p          ,//[PORT_NUM-1:0]
lvds_clk_n          ,//[PORT_NUM-1:0] 
lvds_data_p         ,//[LANE_NUM*PORT_NUM-1:0]
lvds_data_n         ,//[LANE_NUM*PORT_NUM-1:0]
video_pixel_clk     ,
video_enable        ,
video_misalign      ,//indecate DE_O misalign
VS_O                ,
HS_O                ,
DE_O                ,
R_O                 ,
G_O                 ,
B_O                 ,

S_AXI_ACLK      ,
S_AXI_ARESETN   ,
S_AXI_AWREADY   ,
S_AXI_AWADDR    ,
S_AXI_AWVALID   ,
S_AXI_AWPROT    ,
S_AXI_WREADY    ,
S_AXI_WDATA     ,
S_AXI_WSTRB     ,
S_AXI_WVALID    ,
S_AXI_BRESP     ,
S_AXI_BVALID    ,
S_AXI_BREADY    ,
S_AXI_ARREADY   ,
S_AXI_ARADDR    ,
S_AXI_ARVALID   ,
S_AXI_ARPROT    ,
S_AXI_RRESP     ,
S_AXI_RVALID    ,
S_AXI_RDATA     ,
S_AXI_RREADY    ,


MODULE_ENABLE_O  ,

LB_WADDR   ,
LB_WDATA   ,
LB_WREQ    ,
LB_RADDR   ,
LB_RREQ    ,
LB_RDATA   ,
LB_RFINISH ,


DLY_READY_I

);


///////////////////////////////////////////////////////////////////////////////////////////
input DLY_READY_I;
input  perm_clk;
input  ref_clk;
input  [PORT_NUM-1:0]  lvds_clk_p;
input  [PORT_NUM-1:0]  lvds_clk_n;                                                                                         
input  [LANE_NUM*PORT_NUM-1:0]  lvds_data_p;
input  [LANE_NUM*PORT_NUM-1:0]  lvds_data_n; 
output  video_pixel_clk;
output  video_enable;   //经过port数屏蔽
output  video_misalign; //经过port数屏蔽
output reg [PORT_NUM-1:0]            VS_O = 0;
output reg [PORT_NUM-1:0]            HS_O = 0;
output reg [PORT_NUM-1:0]            DE_O = 0;
output reg [LANE_NUM*2*PORT_NUM-1:0] R_O  = 0;
output reg [LANE_NUM*2*PORT_NUM-1:0] G_O  = 0;
output reg [LANE_NUM*2*PORT_NUM-1:0] B_O  = 0;

input  wire                                      S_AXI_ACLK      ;
input  wire                                      S_AXI_ARESETN   ;
output wire                                      S_AXI_AWREADY   ;
input  wire [C_AXI_LITE_ADDR_WIDTH-1:0]          S_AXI_AWADDR    ;
input  wire                                      S_AXI_AWVALID   ;
input  wire [ 2:0]                               S_AXI_AWPROT    ;
output wire                                      S_AXI_WREADY    ;
input  wire [C_AXI_LITE_DATA_WIDTH-1:0]          S_AXI_WDATA     ;
input  wire [(C_AXI_LITE_DATA_WIDTH/8)-1 :0]     S_AXI_WSTRB     ;
input  wire                                      S_AXI_WVALID    ;
output wire [ 1:0]                               S_AXI_BRESP     ;
output wire                                      S_AXI_BVALID    ;
input  wire                                      S_AXI_BREADY    ;
output wire                                      S_AXI_ARREADY   ;
input  wire [C_AXI_LITE_ADDR_WIDTH-1:0]          S_AXI_ARADDR    ;
input  wire                                      S_AXI_ARVALID   ;
input  wire [ 2:0]                               S_AXI_ARPROT    ;
output wire [ 1:0]                               S_AXI_RRESP     ;
output wire                                      S_AXI_RVALID    ;
output wire [C_AXI_LITE_DATA_WIDTH-1:0]          S_AXI_RDATA     ;
input  wire                                      S_AXI_RREADY    ;

output MODULE_ENABLE_O  ;

input  [C_AXI_LITE_ADDR_WIDTH-1:0]  LB_WADDR   ;
input  [C_AXI_LITE_DATA_WIDTH-1:0]  LB_WDATA   ;
input                        LB_WREQ    ;
input  [C_AXI_LITE_ADDR_WIDTH-1:0]  LB_RADDR   ;
input                        LB_RREQ    ;
output [C_AXI_LITE_DATA_WIDTH-1:0]  LB_RDATA   ;
output                       LB_RFINISH ;
///////////////////////////////////////////////////////////////////////////////////////////

genvar i,j,k;

wire [1:0] rx_pixel_clk_locked ; //最低位有效
wire refclkint ;         
wire rx_mmcm_lckdps ;        
wire video_pixel_clk ;                   
(*keep = "ture"*)wire  DLY_READY_I ;        
wire rx_mmcm_lckd;    
wire locked;
wire   [LANE_NUM*PORT_NUM*7-1:0] rx_lvds_data    ;
(*keep = "ture"*)wire [15:0]  bit_rate_value;
wire  enable_phase_detector;

wire  [PORT_NUM-1:0] vs_ori;
wire  [PORT_NUM-1:0] hs_ori;
wire  [PORT_NUM-1:0] de_ori;
wire  [LANE_NUM*2*PORT_NUM-1:0] rgb_r_ori;
wire  [LANE_NUM*2*PORT_NUM-1:0] rgb_g_ori;
wire  [LANE_NUM*2*PORT_NUM-1:0] rgb_b_ori;

wire m1to7_reset_aclk_b;
wire m1to7_reset_aclk;

wire MIS_ALIGNED;       
wire [31:0] MIS_ALIGNED_ACCUS ;
wire [15:0] MIS_ALIGNED_ROUNDS;
wire [15:0] MIS_ALIGNED_RETRYS;

wire mmcm_locked ;//pure MMCM/PLL locked


wire   [PORT_NUM-1:0]            VS_des;
wire   [PORT_NUM-1:0]            HS_des;
wire   [PORT_NUM-1:0]            DE_des;
wire   [LANE_NUM*2*PORT_NUM-1:0] R_des;
wire   [LANE_NUM*2*PORT_NUM-1:0] G_des;
wire   [LANE_NUM*2*PORT_NUM-1:0] B_des;

wire [PORT_NUM-1:0] rx_mmcm_lckdpsbs_m ;


wire write_req_cpu_to_axi  ;
wire [C_AXI_LITE_ADDR_WIDTH-1:0] write_addr_cpu_to_axi ;
wire [C_AXI_LITE_DATA_WIDTH-1:0] write_data_cpu_to_axi ;
wire read_req_cpu_to_axi   ;
wire [C_AXI_LITE_ADDR_WIDTH-1:0] read_addr_cpu_to_axi  ;
wire [C_AXI_LITE_DATA_WIDTH-1:0] read_data_axi_to_cpu  ;
wire  read_finish_axi_to_cpu ;



wire                       write_req_cpu_to_axi_ll   ;
wire [C_AXI_LITE_ADDR_WIDTH-1:0]  write_addr_cpu_to_axi_ll  ;
wire [C_AXI_LITE_DATA_WIDTH-1:0]  write_data_cpu_to_axi_ll  ;
wire                       read_req_cpu_to_axi_ll    ;
wire  [C_AXI_LITE_ADDR_WIDTH-1:0] read_addr_cpu_to_axi_ll   ;
reg  [C_AXI_LITE_DATA_WIDTH-1:0]  read_data_axi_to_cpu_ll    = 0;  
reg                        read_finish_axi_to_cpu_ll  = 0;


wire [LANE_NUM-1:0] RX_SWAP_MASK;   
reg [7:0] mask;
reg [3:0] R_PORT_NUM = LVDS_LOCKED_PORT_NUM_DEFAULT;
wire [3:0] R_PORT_NUM_pclk ;

wire                   mmcm_locked__aclk;//pll 原始锁定  垮到cpu时钟
wire  [3:0]  rx_mmcm_lckdpsbs_m__aclk_for_cpu_read;
wire  [PORT_NUM-1:0] rx_mmcm_lckdpsbs_m__aclk; //4路各自 逻辑上锁定  垮到cpu时钟
wire                   rx_pixel_clk_locked__aclk;//考虑路数后，总体锁定  垮到cpu时钟
assign rx_mmcm_lckdpsbs_m__aclk_for_cpu_read  = {0,rx_mmcm_lckdpsbs_m__aclk} ;


wire [31:0] MIS_ALIGNED_ACCUS_aclk  ;
wire [15:0] MIS_ALIGNED_ROUNDS_aclk ;
wire [15:0] MIS_ALIGNED_RETRYS_aclk ;

wire [9:0] video_pixel_clk_mhz_aclk ;


`CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(MIS_ALIGNED_ACCUS  ,S_AXI_ACLK,MIS_ALIGNED_ACCUS_aclk  ,32,3)
`CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(MIS_ALIGNED_ROUNDS ,S_AXI_ACLK,MIS_ALIGNED_ROUNDS_aclk ,16,3)
`CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(MIS_ALIGNED_RETRYS ,S_AXI_ACLK,MIS_ALIGNED_RETRYS_aclk ,16,3)


assign write_req_cpu_to_axi_ll  =  C_LB_ENABLE ? LB_WREQ  : write_req_cpu_to_axi  ;
assign write_addr_cpu_to_axi_ll =  C_LB_ENABLE ? LB_WADDR : write_addr_cpu_to_axi ;
assign write_data_cpu_to_axi_ll =  C_LB_ENABLE ? LB_WDATA : write_data_cpu_to_axi ;
assign read_req_cpu_to_axi_ll   =  C_LB_ENABLE ? LB_RREQ  : read_req_cpu_to_axi ;
assign read_addr_cpu_to_axi_ll  =  C_LB_ENABLE ? LB_RADDR : read_addr_cpu_to_axi ;

assign read_data_axi_to_cpu     =  C_LB_ENABLE ? 0 : read_data_axi_to_cpu_ll   ;
assign read_finish_axi_to_cpu   =  C_LB_ENABLE ? 0 : read_finish_axi_to_cpu_ll ;
assign LB_RDATA                 =  C_LB_ENABLE ? read_data_axi_to_cpu_ll   : 0 ;
assign LB_RFINISH               =  C_LB_ENABLE ? read_finish_axi_to_cpu_ll : 0 ;



///////////////////////////////////////////////////////////////////////////////////////////
wire video_enable_ss;
`DELAY_OUTGEN(video_pixel_clk,0,rx_pixel_clk_locked,video_enable_ss,1,2)  //打拍优化时序
assign video_enable   =  video_enable_ss;//rx_pixel_clk_locked 已经根据有效port数做调整了

reg [PORT_NUM-1:0] misalign_mask;
always@(*)begin
    case(R_PORT_NUM_pclk)
        1:misalign_mask = {{PORT_NUM{1'b1}},1'b0};
        2:misalign_mask = {{PORT_NUM{1'b1}},2'b00};
        4:misalign_mask = {{PORT_NUM{1'b1}},4'b0000};
        5:misalign_mask = {{PORT_NUM{1'b1}},5'b00000};
        default:misalign_mask = {{PORT_NUM{1'b1}},4'b0000};
    endcase
end

//不对齐生成逻辑 ：de不等于全1或不等于全0
//方法：构造两个de变量，一个用于检测全1，一个用于检测全0
// 
wire [PORT_NUM-1:0] de_check1;
wire [PORT_NUM-1:0] de_check0;
assign de_check1 = misalign_mask  | DE_O ; //按位或，让被屏蔽的位始终为1
assign de_check0 = ~misalign_mask & DE_O ;


assign video_misalign = MIS_ALIGNED ;
assign RX_SWAP_MASK = 0;


(*keep="true"*)wire m1to7_reset_aclk_b_pclk_db;
`CDC_MULTI_BIT_SIGNAL_OUTGEN(perm_clk,m1to7_reset_aclk_b,video_pixel_clk,m1to7_reset_aclk_b_pclk_db,1,3)



axi_lite_slave #(
    .C_S_AXI_DATA_WIDTH (C_AXI_LITE_DATA_WIDTH ),
    .C_S_AXI_ADDR_WIDTH (C_AXI_LITE_ADDR_WIDTH )   
    )
    axi_lite_slave_u(

    .S_AXI_ACLK            (S_AXI_ACLK     ),     //input  wire                              
    .S_AXI_ARESETN         (S_AXI_ARESETN  ),     //input  wire                              
    .S_AXI_AWREADY         (S_AXI_AWREADY  ),     //output wire                              
    .S_AXI_AWADDR          (S_AXI_AWADDR   ),     //input  wire [C_S_AXI_ADDR_WIDTH-1:0]     
    .S_AXI_AWVALID         (S_AXI_AWVALID  ),     //input  wire                              
    .S_AXI_AWPROT          (S_AXI_AWPROT   ),     //input  wire [ 2:0]                       
    .S_AXI_WREADY          (S_AXI_WREADY   ),     //output wire                              
    .S_AXI_WDATA           (S_AXI_WDATA    ),     //input  wire [C_S_AXI_DATA_WIDTH-1:0]     
    .S_AXI_WSTRB           (S_AXI_WSTRB    ),         //input  wire [(C_S_AXI_DATA_WIDTH/8)-1 :0]
    .S_AXI_WVALID          (S_AXI_WVALID   ),     //input  wire                              
    .S_AXI_BRESP           (S_AXI_BRESP    ),     //output wire [ 1:0]                       
    .S_AXI_BVALID          (S_AXI_BVALID   ),     //output wire                              
    .S_AXI_BREADY          (S_AXI_BREADY   ),     //input  wire                              
    .S_AXI_ARREADY         (S_AXI_ARREADY  ),     //output wire                              
    .S_AXI_ARADDR          (S_AXI_ARADDR   ),     //input  wire [C_S_AXI_ADDR_WIDTH-1:0]     
    .S_AXI_ARVALID         (S_AXI_ARVALID  ),     //input  wire                              
    .S_AXI_ARPROT          (S_AXI_ARPROT   ),     //input  wire [ 2:0]                       
    .S_AXI_RRESP           (S_AXI_RRESP    ),     //output wire [ 1:0]                       
    .S_AXI_RVALID          (S_AXI_RVALID   ),     //output wire                              
    .S_AXI_RDATA           (S_AXI_RDATA    ),     //output wire [C_S_AXI_DATA_WIDTH-1:0]     
    .S_AXI_RREADY          (S_AXI_RREADY   ),     //input  wire                              
    
    .write_req_cpu_to_axi  (write_req_cpu_to_axi  ),    //wire                              
    .write_addr_cpu_to_axi (write_addr_cpu_to_axi ),   //wire [C_S_AXI_ADDR_WIDTH-1:0]     
    .write_data_cpu_to_axi (write_data_cpu_to_axi ),   //wire [C_S_AXI_DATA_WIDTH-1:0]     
    .read_req_cpu_to_axi   (read_req_cpu_to_axi   ),     //wire                              
    .read_addr_cpu_to_axi  (read_addr_cpu_to_axi  ),    //wire [C_S_AXI_ADDR_WIDTH-1:0]     
    .read_data_axi_to_cpu  (read_data_axi_to_cpu  ),    //wire [C_S_AXI_DATA_WIDTH-1:0]     
    .read_finish_axi_to_cpu(read_finish_axi_to_cpu)   //wire                              
      
);





reg [0:0] R_ENABLE = LVDS_ENABLE_DEFAULT;
reg [0:0] R_CLK_PN_SWAP  = LVDS_CLK_PN_SWAP_DEFAULT;
reg [0:0] R_DATAIN_PN_SWAP = LVDS_DATAIN_PN_SWAP_DEFAULT ;//not support 
reg [0:0] R_DATAOUT_PN_SWAP = LVDS_DATAOUT_PN_SWAP_DEFAULT ;

reg [0:0] R_PIXEL_ARR_MODE = PIXEL_ARR_MODE_DEFAULT ;

wire [0:0]  R_PIXEL_ARR_MODE_pclk;




wire R_CLK_PN_SWAP_pclk ;
wire R_DATAIN_PN_SWAP_pclk;
wire R_DATAOUT_PN_SWAP_pclk;

`CDC_MULTI_BIT_SIGNAL_OUTGEN(S_AXI_ACLK,R_CLK_PN_SWAP ,video_pixel_clk,R_CLK_PN_SWAP_pclk ,1,3)
`CDC_MULTI_BIT_SIGNAL_OUTGEN(S_AXI_ACLK,R_DATAIN_PN_SWAP,video_pixel_clk,R_DATAIN_PN_SWAP_pclk,1,3)
`CDC_MULTI_BIT_SIGNAL_OUTGEN(S_AXI_ACLK,R_DATAOUT_PN_SWAP,video_pixel_clk,R_DATAOUT_PN_SWAP_pclk,1,3)
`CDC_MULTI_BIT_SIGNAL_OUTGEN(S_AXI_ACLK,R_PORT_NUM,video_pixel_clk,R_PORT_NUM_pclk,4,3) 
`CDC_MULTI_BIT_SIGNAL_OUTGEN(S_AXI_ACLK,R_PIXEL_ARR_MODE,video_pixel_clk,R_PIXEL_ARR_MODE_pclk,1,3) 


always@(posedge S_AXI_ACLK)begin
	if(~S_AXI_ARESETN)begin
		R_ENABLE       <=  LVDS_ENABLE_DEFAULT;
		R_CLK_PN_SWAP  <=  LVDS_CLK_PN_SWAP_DEFAULT;
		R_DATAIN_PN_SWAP <=  LVDS_DATAIN_PN_SWAP_DEFAULT;
		R_DATAOUT_PN_SWAP <= LVDS_DATAOUT_PN_SWAP_DEFAULT;
		R_PORT_NUM <= LVDS_LOCKED_PORT_NUM_DEFAULT;
        R_PIXEL_ARR_MODE <= PIXEL_ARR_MODE_DEFAULT ;
	end
	else if(write_req_cpu_to_axi_ll)begin
		case(write_addr_cpu_to_axi_ll)
			`ADDR_ENABLE       : R_ENABLE <= write_data_cpu_to_axi_ll;
			`ADDR_CLK_PN_SWAP  : R_CLK_PN_SWAP  <= write_data_cpu_to_axi_ll;
			`ADDR_DATAIN_PN_SWAP : R_DATAIN_PN_SWAP <= write_data_cpu_to_axi_ll;
			`ADDR_DATAOUT_PN_SWAP : R_DATAOUT_PN_SWAP <= write_data_cpu_to_axi_ll;
			`ADDR_PORT_NUM : R_PORT_NUM <= write_data_cpu_to_axi_ll;
            `ADDR_PIXEL_ARR_MODE  : R_PIXEL_ARR_MODE <= write_data_cpu_to_axi_ll ;
			default:;
		endcase
	end
end


assign MODULE_ENABLE_O = R_ENABLE ;


`CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(mmcm_locked,S_AXI_ACLK,mmcm_locked__aclk,1,3)
`CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(rx_mmcm_lckdpsbs_m,S_AXI_ACLK,rx_mmcm_lckdpsbs_m__aclk,PORT_NUM,3)  
`CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(rx_pixel_clk_locked,S_AXI_ACLK,rx_pixel_clk_locked__aclk,1,3)  


always@(posedge S_AXI_ACLK)begin
	if(~S_AXI_ARESETN)begin
		read_data_axi_to_cpu_ll <= 0;
		read_finish_axi_to_cpu_ll <= 0;
	end
	else if(read_req_cpu_to_axi_ll)begin
		read_finish_axi_to_cpu_ll <= 1;
		case(read_addr_cpu_to_axi_ll)
			`ADDR_ENABLE       : read_data_axi_to_cpu_ll <= {0,R_ENABLE      };
			`ADDR_CLK_PN_SWAP  : read_data_axi_to_cpu_ll <= {0,R_CLK_PN_SWAP };
			`ADDR_DATAIN_PN_SWAP : read_data_axi_to_cpu_ll <= {0,R_DATAIN_PN_SWAP};
			`ADDR_DATAOUT_PN_SWAP : read_data_axi_to_cpu_ll <= {0,R_DATAOUT_PN_SWAP};
			`ADDR_PORT_NUM : read_data_axi_to_cpu_ll <= {0,R_PORT_NUM} ;
            //debug
            `ADDR_STATUS_DBG   : read_data_axi_to_cpu_ll <= {3'b000,DETECT_MISALLIGN,  
                                                      rx_mmcm_lckdpsbs_m__aclk_for_cpu_read,  
                                                     3'b000,mmcm_locked__aclk,  
                                                     3'b000,rx_pixel_clk_locked__aclk};
            `ADDR_MIS_ALIGNED_ACCUS_DBG  : read_data_axi_to_cpu_ll <= {0,MIS_ALIGNED_ACCUS_aclk};
            `ADDR_MIS_ALIGNED_ROUNDS_DBG : read_data_axi_to_cpu_ll <= {0,MIS_ALIGNED_ROUNDS_aclk};
            `ADDR_MIS_ALIGNED_RETRYS_DBG : read_data_axi_to_cpu_ll <= {0,MIS_ALIGNED_RETRYS_aclk};   
            `ADDR_PCLK_MHZ_DBG           : read_data_axi_to_cpu_ll <= C_PCLK_DET_BLOCK_EN ? {0,video_pixel_clk_mhz_aclk} : 32'hffff;
			`ADDR_PIXEL_ARR_MODE         : read_data_axi_to_cpu_ll <=  {0,R_PIXEL_ARR_MODE };
            
            default : read_data_axi_to_cpu_ll <= 0;
		endcase
	end
	else begin
		read_finish_axi_to_cpu_ll <= 0;
	end
end



wire  [LANE_NUM*2*PORT_NUM-1:0] rgb_r_ori_0;
wire  [LANE_NUM*2*PORT_NUM-1:0] rgb_g_ori_0;
wire  [LANE_NUM*2*PORT_NUM-1:0] rgb_b_ori_0;

wire  [LANE_NUM*2*PORT_NUM-1:0] rgb_r_ori_rearr;
wire  [LANE_NUM*2*PORT_NUM-1:0] rgb_g_ori_rearr;
wire  [LANE_NUM*2*PORT_NUM-1:0] rgb_b_ori_rearr;


generate if(  (~C_BLANK_EN) )begin
lvdsdata_to_native  
    #(.C_PORT_NUM(PORT_NUM),
      .C_LANE_NUM(LANE_NUM))
    lvdsdata_to_native_u(
    .LVDS_DATA_I(rx_lvds_data),
    .VS_O       (vs_ori      ),
    .HS_O       (hs_ori      ),
    .DE_O       (de_ori      ),
    .R_O        (rgb_r_ori_0 ),
    .G_O        (rgb_g_ori_0 ),
    .B_O        (rgb_b_ori_0 )
    );
end
endgenerate

//assign  R_O_1[7:0]  =  {R_O[5],R_O[4],R_O[3],R_O[2],R_O[1],R_O[0],R_O[7],R_O[6]};
//assign  G_O_1[7:0]  =  {G_O[5],G_O[4],G_O[3],G_O[2],G_O[1],G_O[0],G_O[7],G_O[6]};
//assign  B_O_1[7:0]  =  {B_O[5],B_O[4],B_O[3],B_O[2],B_O[1],B_O[0],B_O[7],B_O[6]};
//
rgb_re_aarrange   
    #(.C_PORT_NUM(PORT_NUM))
    rgb_re_aarrange_u(
    .R_I        (rgb_r_ori_0 ),
    .G_I        (rgb_g_ori_0 ),
    .B_I        (rgb_b_ori_0 ),
    .R_REARR_O  (rgb_r_ori_rearr ),
    .G_REARR_O  (rgb_g_ori_rearr ),
    .B_REARR_O  (rgb_b_ori_rearr )

    );




assign   rgb_r_ori = R_PIXEL_ARR_MODE_pclk ? rgb_r_ori_rearr : rgb_r_ori_0 ;
assign   rgb_g_ori = R_PIXEL_ARR_MODE_pclk ? rgb_g_ori_rearr : rgb_g_ori_0 ;
assign   rgb_b_ori = R_PIXEL_ARR_MODE_pclk ? rgb_b_ori_rearr : rgb_b_ori_0 ;



generate if(DETECT_MISALLIGN & (~C_BLANK_EN))begin
native_deskew
    #(.C_LANE_NUM(LANE_NUM), 
      .C_PORT_NUM(PORT_NUM),
      .C_MISALIGN_PCLK_PROTECT(C_MISALIGN_PCLK_PROTECT), //~pclk  need be small as possible ;  NOTE
      .C_1TO7_RESET_ACLK_NUM(C_1TO7_RST_ACLK_NUM),   //~aclk   as you wish 
      .C_MISALIGNED_RST_THRESHOLD(C_MISALIGN_RST_THRESHOLD_PCLK_NUM)//~pclk   
      )
    native_deskew_u(
    .PCLK_I(video_pixel_clk),
    .PRST_I(~rx_pixel_clk_locked),//mask后
    .VS_I(vs_ori    ),
    .HS_I(hs_ori    ),
    .DE_I(de_ori    ),
    .R_I (rgb_r_ori ),
    .G_I (rgb_g_ori ),
    .B_I (rgb_b_ori ),
    .VS_O(VS_des      ),
    .HS_O(HS_des      ),
    .DE_O(DE_des      ),
    .R_O (R_des       ),
    .G_O (G_des       ),
    .B_O (B_des       ),
    .MIS_ALIGNED_O       (MIS_ALIGNED       ),//
    .MIS_ALIGNED_ACCUS_O (MIS_ALIGNED_ACCUS ),//32  mis aligned num of  total produce
    .MIS_ALIGNED_ROUNDS_O(MIS_ALIGNED_ROUNDS),//16  mis aligned num of  this round
    .MIS_ALIGNED_RETRYS_O(MIS_ALIGNED_RETRYS),//16  
    
    .PORT_NUM_I  (R_PORT_NUM_pclk),//[3:0]
    //////////////////////////////////////////////////////////////////////////
    .SYS_CLK_I   (perm_clk         ),
    .RESET_1TO7_O(m1to7_reset_aclk_b)
    );
    
assign  m1to7_reset_aclk =  m1to7_reset_aclk_b | ~R_ENABLE ;

always@(posedge video_pixel_clk)  VS_O <= R_DATAOUT_PN_SWAP_pclk ? ~VS_des : VS_des ;
always@(posedge video_pixel_clk)  HS_O <= R_DATAOUT_PN_SWAP_pclk ? ~HS_des : HS_des ;
always@(posedge video_pixel_clk)  DE_O <= R_DATAOUT_PN_SWAP_pclk ? ~DE_des : DE_des ;
always@(posedge video_pixel_clk)  R_O  <= R_DATAOUT_PN_SWAP_pclk ? ~R_des  : R_des  ;    
always@(posedge video_pixel_clk)  G_O  <= R_DATAOUT_PN_SWAP_pclk ? ~G_des  : G_des  ;    
always@(posedge video_pixel_clk)  B_O  <= R_DATAOUT_PN_SWAP_pclk ? ~B_des  : B_des  ;    



end
else begin

always@(posedge video_pixel_clk)  VS_O <= R_DATAOUT_PN_SWAP_pclk ? ~vs_ori    : vs_ori    ;
always@(posedge video_pixel_clk)  HS_O <= R_DATAOUT_PN_SWAP_pclk ? ~hs_ori    : hs_ori    ;
always@(posedge video_pixel_clk)  DE_O <= R_DATAOUT_PN_SWAP_pclk ? ~de_ori    : de_ori    ;
always@(posedge video_pixel_clk)  R_O  <= R_DATAOUT_PN_SWAP_pclk ? ~rgb_r_ori : rgb_r_ori ;    
always@(posedge video_pixel_clk)  G_O  <= R_DATAOUT_PN_SWAP_pclk ? ~rgb_g_ori : rgb_g_ori ;    
always@(posedge video_pixel_clk)  B_O  <= R_DATAOUT_PN_SWAP_pclk ? ~rgb_b_ori : rgb_b_ori ;  


assign m1to7_reset_aclk = ~R_ENABLE ;


end

endgenerate




///////////////////////////////////////////////////////////////////////////////
//VESA
//0+/-：R0(24), R1(20), R2(16), R3(12), R4(8) , R5(4), G0(0)
//1+/-：G1(25), G2(21), G3(17), G4(13), G5(9) , B0(5), B1(1)
//2+/-：B2(26), B3(22), B4(18), B5(14), HS(10), VS(6), DE(2)
//3+/-：R6(27), R7(23), G6(19), G7(15), B6(11), B7(7), 0 (3)
//R8()  ,R9 , G8 , G9, B8, B9 ,0 


wire delay_ready_inner ; 
wire delay_ready_ff ;
assign   delay_ready_ff =  C_CONTAIN_DLY_CTRL  ?  delay_ready_inner :  DLY_READY_I ;

generate if(C_CONTAIN_DLY_CTRL & (~C_BLANK_EN))begin
  (*KEEP_HIERARCHY  = "TRUE"*)    
   IDELAYCTRL icontrol(// Instantiate input delay control block
      .REFCLK (ref_clk),
      .RST    (m1to7_reset_aclk),
      //.RST    (0),
      .RDY    (delay_ready_inner)
      );
end
endgenerate
    
    
    
generate if( (~C_BLANK_EN) )begin
if(C_IMPL_MECHANISM == "DDR")begin
(*KEEP_HIERARCHY  = "TRUE"*)        
n_x_serdes_1_to_7_mmcm_idelay_ddr #(
    .N                      (PORT_NUM),
    .SAMPL_CLOCK            (SAMPL_CLOCK),
    .INTER_CLOCK            (INTER_CLOCK),
    .PIXEL_CLOCK            (PIXEL_CLOCK),
    .USE_PLL                (USE_PLL),
    .HIGH_PERFORMANCE_MODE  (HIGH_PERFORMANCE_MODE),
    .D                      (LANE_NUM),      // Number of data lines
    .REF_FREQ               (REF_FREQ),    // Set idelay control reference frequency
    .CLKIN_PERIOD           (CLKIN_PERIOD),// Set input clock period
    .MMCM_MODE              (MMCM_MODE),   // Parameter to set multiplier for MMCM to get VCO in correct operating range. 1 multiplies input clock by 7, 2 multiplies clock by 14, etc
    .DIFF_TERM              ("TRUE"),
    .DATA_FORMAT            ("PER_CLOCK")) // PER_CLOCK or PER_CHANL data formatting
    rx0 (                      
    .clkin_p                (lvds_clk_p),
    .clkin_n                (lvds_clk_n),
    .datain_p               (lvds_data_p),
    .datain_n               (lvds_data_n),
    .enable_phase_detector  (ENABLE_PHASE_DETECTOR),          // enable phase detector operation
    .enable_monitor         (ENABLE_MONITOR),          // enables data eye monitoring
    .dcd_correct            (DCD_CORRECT),          // enables clock duty cycle correction
    .rxclk                  (),
    .rxclk_d4               (),              // intermediate clock, use with data monitoring logic
    .idelay_rdy             (delay_ready_ff),
    .pixel_clk              (video_pixel_clk),
    .reset                  (m1to7_reset_aclk),
    //.reset                  (0),
    
    .rx_mmcm_lckd           (rx_mmcm_lckd),
    .rx_mmcm_lckdps         (rx_mmcm_lckdps),
    .rx_mmcm_lckdpsbs       (rx_mmcm_lckdpsbs_m ),//[PORT_NUM-1:0] changed by yzhu
    .clk_data               (),
    .rx_data                (rx_lvds_data),
    .bit_rate_value         (BIT_RATE_VALUE),      // required bit rate value in BCD 
           
                                  //maximum for 4K@60Hz quad piexl mode for 148.5Mhz
    .bit_time_value         (),
    .mmcm_locked            (mmcm_locked),
    .status                 (),
    .eye_info               (),              // data eye monitor per line
    .m_delay_1hot           (),              // sample point monitor per line
    .debug                  (),             // debug bus
	.LVDS_CLK_PN_SWAP_I       (R_CLK_PN_SWAP_pclk),
	.RX_SWAP_MASK_I           (RX_SWAP_MASK)
	) ;     
end
else begin


n_x_serdes_1_to_7_mmcm_idelay_sdr 
    #(
    .N                    ( PORT_NUM ) ,				// Set the number of channels
    .D                    ( LANE_NUM ) ,   			// Parameter to set the number of data lines per channel
    .MMCM_MODE            ( MMCM_MODE ) ,   		// Parameter to set multiplier for MMCM to get VCO in correct operating range. 1 multiplies input clock by 7, 2 multiplies clock by 14, etc
    .CLKIN_PERIOD         (CLKIN_PERIOD ) ,	// clock period (ns) of input clock on clkin_p
    .HIGH_PERFORMANCE_MODE(HIGH_PERFORMANCE_MODE  ) ,// Parameter to set HIGH_PERFORMANCE_MODE of input delays to reduce jitter
    .DIFF_TERM            ( "TRUE" ), 		// Parameter to enable internal differential termination
    .SAMPL_CLOCK          ( SAMPL_CLOCK  ),   	// Parameter to set sampling clock buffer type, BUFIO, BUF_H, BUF_G
    .PIXEL_CLOCK          ( PIXEL_CLOCK ),       	// Parameter to set pixel clock buffer type, BUF_R, BUF_H, BUF_G
    .USE_PLL              ( USE_PLL ),          	// Parameter to enable PLL use rather than MMCM use, overides SAMPL_CLOCK and INTER_CLOCK to be both BUFH
    .DATA_FORMAT         ( "PER_CLOCK" ) ,
    .REF_FREQ               (REF_FREQ) 
    
    )     // Parameter Used to determine method for mapping input parallel word to output serial words
    rx0  (                        	
    .clkin_p              (lvds_clk_p) ,			// Input from LVDS clock receiver pin
    .clkin_n              (lvds_clk_n) ,			// Input from LVDS clock receiver pin
    .datain_p             (lvds_data_p ) ,			// Input from LVDS clock data pins
    .datain_n             (lvds_data_n ) ,			// Input from LVDS clock data pins
    .enable_phase_detector  (ENABLE_PHASE_DETECTOR), 
    .enable_monitor       (ENABLE_MONITOR) ,		// Enables the monitor logic when high, note time-shared with phase detector function
    .reset                  (m1to7_reset_aclk),
    //.reset                  (0),
    
    
    .idelay_rdy             (delay_ready_ff),
    .rxclk  				(),// Global/BUFIO rx clock network
    .rxclk_div  			(video_pixel_clk  ),// Global/Regional clock output
    .rx_mmcm_lckd           (rx_mmcm_lckd),
    .rx_mmcm_lckdps         (rx_mmcm_lckdps),
    .rx_mmcm_lckdpsbs       (rx_mmcm_lckdpsbs_m ),//[PORT_NUM-1:0] changed by yzhuoutput 
    .rx_data                (rx_lvds_data),
    .debug  (),	 			// debug info
    .status (),	  		// clock status
    .mmcm_locked            (mmcm_locked),
    .bit_rate_value         (BIT_RATE_VALUE),      // required bit rate value in BCD output	[4:0]		bit_time_value ;		// Calculated bit time value for slave devices
    .eye_info (),	 		// Eye info
    .m_delay_1hot () 


    );
    

end



end
else begin
    for(i=0;i<PORT_NUM;i=i+1)begin    
    IBUFDS #(
      .DIFF_TERM("FALSE"),       // Differential Termination
      .IBUF_LOW_PWR("TRUE"),     // Low power="TRUE", Highest performance="FALSE" 
      .IOSTANDARD("DEFAULT")     // Specify the input I/O standard
    ) IBUFDS_inst (
      .O( ),  // Buffer output
      .I(lvds_clk_p[i]),  // Diff_p buffer input (connect directly to top-level port)
      .IB(lvds_clk_n[i]) // Diff_n buffer input (connect directly to top-level port)
    );    
    end  
    
    for(i=0;i<LANE_NUM*PORT_NUM;i=i+1)begin    
    IBUFDS #(
      .DIFF_TERM("FALSE"),       // Differential Termination
      .IBUF_LOW_PWR("TRUE"),     // Low power="TRUE", Highest performance="FALSE" 
      .IOSTANDARD("DEFAULT")     // Specify the input I/O standard
    ) IBUFDS_inst (
      .O( ),  // Buffer output
      .I(lvds_data_p[i]),  // Diff_p buffer input (connect directly to top-level port)
      .IB(lvds_data_n[i]) // Diff_n buffer input (connect directly to top-level port)
    );    
    end  

        
        

end



endgenerate




assign  rx_pixel_clk_locked = &( rx_mmcm_lckdpsbs_m | mask ); 


always@(*)begin
	case(R_PORT_NUM_pclk)
		1:  mask = 8'b11111110;
		2:  mask = 8'b11111100;
		4:  mask = 8'b11110000;
		8:  mask = 8'b00000000;
		default: mask = 8'b11110000;
	endcase
end



generate if(PCLK_ILA_ENABLE  & (~C_BLANK_EN) )begin
    ila_pclk  ila_pclku(
    .clk     (video_pixel_clk      ),
    .probe0  (VS_O                 ),//[3:0]
    .probe1  (HS_O                 ),//[3:0]
    .probe2  (DE_O                 ),//[3:0]
    .probe3  (rx_mmcm_lckdpsbs_m   ),//[PORT_NUM-1:0] iserdes logic locked
    .probe4  (mmcm_locked          ),//[0:0] original pll locked
    .probe5  (rx_pixel_clk_locked  ),//[0:0] total locked
    .probe6  (MIS_ALIGNED          ),
    .probe7  (MIS_ALIGNED_ROUNDS   ),//[15:0]
    .probe8  (MIS_ALIGNED_ACCUS    )  //[15:0]
  //.probe9  (DETECT_MISALLIGN ? native_deskew_u.mis_aligned_rst_pclk : 0 ),
  //.probe10 (DETECT_MISALLIGN ? native_deskew_u.mis_aligned_rst_axiclk_pos__protect  : 0 ),
  //.probe11 (MIS_ALIGNED_RETRYS   ),//[15:0]
  //.probe12 (m1to7_reset_aclk_b_pclk_db   ),
   //.probe13 (DETECT_MISALLIGN ? native_deskew_u.de_start_flag : 0 ),//[3:0]
   //.probe14 (DETECT_MISALLIGN ? native_deskew_u.wr_en          : 0     ), //[3:0]
   //.probe15 (DETECT_MISALLIGN ? native_deskew_u.fifo_read_unf  : 0     ),
   //.probe16 (DETECT_MISALLIGN ? native_deskew_u.fifo_rd_rst_busy : 0 ) ,
   //.probe17 (DETECT_MISALLIGN ? native_deskew_u.fifo_wr_rst_busy : 0 )  ,
   //.probe18 (DETECT_MISALLIGN ? native_deskew_u.fifo_rd_empty_mask : 0 ) 
    
    );
end
endgenerate
 

 
 
 
generate if(ACLK_ILA_ENABLE  & (~C_BLANK_EN) )begin
    ila_aclk ila_aclku(
     .clk     (S_AXI_ACLK ) ,
     .probe0  (R_ENABLE ),
     .probe1  (R_CLK_PN_SWAP ),
     .probe2  (R_DATAIN_PN_SWAP ),
     .probe3  (R_DATAOUT_PN_SWAP ),
     .probe4  (R_PORT_NUM ),
     .probe5  (m1to7_reset_aclk_b ),
     .probe6  (rx_mmcm_lckdpsbs_m__aclk),
     .probe7  (mmcm_locked__aclk),
     .probe8  (rx_pixel_clk_locked__aclk),
     .probe9  (MIS_ALIGNED_ACCUS_aclk),
     .probe10 (MIS_ALIGNED_ROUNDS_aclk),
     .probe11 (MIS_ALIGNED_RETRYS_aclk),
     .probe12 (video_pixel_clk_mhz_aclk )     
     
);

 
 
end
endgenerate
 



generate if(C_PCLK_DET_BLOCK_EN & (~C_BLANK_EN) )begin

    freq_test_value 
        #(.SYS_PRD_NS (AXICLK_PRD_NS)  ,
          .CLK_BE_TESTED_MHZ_WIDTH (10)
        )
    freq_test_value_u(
    .SYS_CLK_I                   (S_AXI_ACLK    ), //用于生成内部秒脉冲 时钟域1
    .SYS_RSTN_I                  (S_AXI_ARESETN ), //时钟域1
    .CLK_BE_TESTED_I             (video_pixel_clk  ), //时钟域2
    .CLK_BE_TESTED_MHZ_O         (),  //时钟域2  最多到1000M 偏小
    .CLK_BE_TESTED_MHZ_O_SYSCLK  (video_pixel_clk_mhz_aclk )
    );


end
endgenerate


endmodule


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
//  /   /\/   /
// /___/  \  /   Vendor: Xilinx
// \   \   \/    Version: 1.2
//  \   \        Filename: n_x_serdes_1_to_7_mmcm_idelay_ddr.v
//  /   /        Date Last Modified:  20JAN2015
// /___/   /\    Date Created: 5MAR2010
// \   \  /  \
//  \___\/\___\
//Device:     7 Series
//Purpose:      Wrapper for multiple 1 to 7 receiver clock and data receiver using one MMCM for clock multiplication
//Reference:    XAPP585
//    
//Revision History:
//    Rev 1.0 - First created (nicks)
//    Rev 1.1 - rxclk_d4 output added
//    Rev 1.2 - master and slaves gearbox sync added, updated format
//////////////////////////////////////////////////////////////////////////////
`timescale 1ps/1ps
module n_x_serdes_1_to_7_mmcm_idelay_ddr (clkin_p, clkin_n, datain_p, datain_n, enable_phase_detector, rxclk, rxclk_d4, idelay_rdy, reset, pixel_clk, enable_monitor, 
                                          rx_mmcm_lckdps, rx_mmcm_lckd, rx_mmcm_lckdpsbs, clk_data, rx_data, status, debug, dcd_correct, bit_rate_value, bit_time_value, m_delay_1hot, eye_info, mmcm_locked,LVDS_CLK_PN_SWAP_I,RX_SWAP_MASK_I) ;

parameter integer  N = 8 ;                // Set the number of channels    一般 4
parameter integer  D = 6 ;                // Parameter to set the number of data lines per channel  一般 4
parameter integer  MMCM_MODE = 1 ;        // Parameter to set multiplier for MMCM to get VCO in correct operating range. 1 multiplies input clock by 7, 2 multiplies clock by 14, etc
parameter real     CLKIN_PERIOD = 6.000 ; // clock period (ns) of input clock on clkin_p
parameter real     REF_FREQ = 200.0 ;     // Parameter to set reference frequency used by idelay controller
parameter          HIGH_PERFORMANCE_MODE = "FALSE";// Parameter to set HIGH_PERFORMANCE_MODE of input delays to reduce jitter
parameter          DIFF_TERM = "FALSE" ;  // Parameter to enable internal differential termination
parameter          SAMPL_CLOCK = "BUFIO" ;// Parameter to set sampling clock buffer type, BUFIO, BUF_H, BUF_G
parameter          INTER_CLOCK = "BUF_R" ;// Parameter to set intermediate clock buffer type, BUFR, BUF_H, BUF_G
parameter          PIXEL_CLOCK = "BUF_G" ;// Parameter to set pixel clock buffer type, BUF_R, BUF_H, BUF_G
parameter          USE_PLL = "FALSE" ;    // Parameter to enable PLL use rather than MMCM use, overides SAMPL_CLOCK and INTER_CLOCK to be both BUFH
parameter          DATA_FORMAT = "PER_CLOCK" ;     // Parameter Used to determine method for mapping input parallel word to output serial words
//parameter [0:0]    PN_SWAP     = 0;


input  [D-1:0]   RX_SWAP_MASK_I; // [D-1:0] 
input  [0:0]  LVDS_CLK_PN_SWAP_I ; 
                
input  [N-1:0]   clkin_p ;           // Input from LVDS clock receiver pin
input  [N-1:0]   clkin_n ;           // Input from LVDS clock receiver pin
input  [N*D-1:0] datain_p ;          // Input from LVDS clock data pins
input  [N*D-1:0] datain_n ;          // Input from LVDS clock data pins
input  enable_phase_detector ;       // Enables the phase detector logic when high
input  enable_monitor ;       // Enable monitoring function
input  reset ;                // Reset line
input  idelay_rdy ;           // input delays are ready
output rxclk ;                // Global/BUFIO rx clock network
output rxclk_d4 ;             // Global/BUFIO rx clock network
output pixel_clk ;            // Global/Regional clock output
output rx_mmcm_lckd ;         // MMCM locked, synchronous to rxclk_d4
output rx_mmcm_lckdps ;       // MMCM locked and phase shifting finished, synchronous to rxclk_d4
output [N-1:0]     rx_mmcm_lckdpsbs ;  // MMCM locked and phase shifting finished and bitslipping finished, synchronous to pixel_clk
output [7*N-1:0]   clk_data ;          // Clock Data
output [N*D*7-1:0] rx_data ;           // Received Data
output [(10*D+6)*N-1:0]debug ;         // debug info
output [6:0] status ;                  // clock status
input  dcd_correct ;                   // '0' = square, '1' = assume 10% DCD
input  [15:0] bit_rate_value ;         // Bit rate in Mbps, for example 16'h0585
output [4:0]  bit_time_value ;         // Calculated bit time value for slave devices
output [32*D*N-1:0] m_delay_1hot ;     // Master delay control value as a one-hot vector
output [32*D*N-1:0] eye_info ;         // eye info
output  mmcm_locked ;



genvar i ;
genvar j ;
wire   rxclk_d4 ;
wire   [1:0] gb_rst_out ;
wire   mmcm_locked;

serdes_1_to_7_mmcm_idelay_ddr #(
    .SAMPL_CLOCK  (SAMPL_CLOCK),
    .INTER_CLOCK  (INTER_CLOCK),
    .PIXEL_CLOCK  (PIXEL_CLOCK),
    .USE_PLL      (USE_PLL),
    .REF_FREQ     (REF_FREQ),
    .HIGH_PERFORMANCE_MODE (HIGH_PERFORMANCE_MODE),
    .D            (D),  // Number of data lines
    .CLKIN_PERIOD (CLKIN_PERIOD), // Set input clock period
    .MMCM_MODE    (MMCM_MODE),    // Set mmcm vco, either 1 or 2
    .DIFF_TERM    (DIFF_TERM),
    .DATA_FORMAT  (DATA_FORMAT))
    rx0 (
    .clkin_p      (clkin_p[0]),
    .clkin_n      (clkin_n[0]),
    .datain_p     (datain_p[D-1:0]),
    .datain_n     (datain_n[D-1:0]),
    .enable_phase_detector (enable_phase_detector),
    .enable_monitor(enable_monitor),
    .rxclk         (rxclk),
    .idelay_rdy    (idelay_rdy),
    .pixel_clk     (pixel_clk),
    .rxclk_d4      (rxclk_d4),
    .reset         (reset),
    .rx_mmcm_lckd  (rx_mmcm_lckd),
    .rx_mmcm_lckdps(rx_mmcm_lckdps),
    .rx_mmcm_lckdpsbs (rx_mmcm_lckdpsbs[0]),
    .clk_data      (clk_data[6:0]),
    .rx_data       (rx_data[7*D-1:0]),
    .dcd_correct   (dcd_correct),
    .bit_rate_value(bit_rate_value),
    .bit_time_value(bit_time_value),
    .del_mech      (del_mech), 
    .status        (status),
    .debug         (debug[10*D+5:0]),
    .rst_iserdes   (rst_iserdes),
    .gb_rst_out    (gb_rst_out),
    .m_delay_1hot  (m_delay_1hot[32*D-1:0]),
    .eye_info      (eye_info[32*D-1:0]),
    .mmcm_locked   (mmcm_locked),
	.LVDS_CLK_PN_SWAP_I(LVDS_CLK_PN_SWAP_I),
	.RX_SWAP_MASK_I (RX_SWAP_MASK_I)
    
    );

generate
for (i = 1 ; i <= (N-1) ; i = i+1)
begin : loop0

serdes_1_to_7_slave_idelay_ddr #(
    .D          (D),   // Number of data lines
    .REF_FREQ   (REF_FREQ),
    .HIGH_PERFORMANCE_MODE (HIGH_PERFORMANCE_MODE),
    .DIFF_TERM  (DIFF_TERM),
    .DATA_FORMAT(DATA_FORMAT))
    rxn (
    .clkin_p     (clkin_p[i]),
    .clkin_n     (clkin_n[i]),
    .datain_p    (datain_p[D*(i+1)-1:D*i]),
    .datain_n    (datain_n[D*(i+1)-1:D*i]),
    .enable_phase_detector (enable_phase_detector),
    .enable_monitor (enable_monitor),
    .rxclk          (rxclk),
    .idelay_rdy     (idelay_rdy),
    .pixel_clk      (pixel_clk),
    .rxclk_d4       (rxclk_d4),
    .reset          (~rx_mmcm_lckdps),
    .bitslip_finished (rx_mmcm_lckdpsbs[i]),
    .clk_data         (clk_data[7*i+6:7*i]),
    .rx_data          (rx_data[(D*(i+1)*7)-1:D*i*7]),
    .bit_time_value   (bit_time_value),
    .del_mech         (del_mech), 
    .debug            (debug[(10*D+6)*(i+1)-1:(10*D+6)*i]),
    .rst_iserdes      (rst_iserdes),
    .gb_rst_in        (gb_rst_out),
    .m_delay_1hot     (m_delay_1hot[(32*D)*(i+1)-1:(32*D)*i]),
    .eye_info         (eye_info[(32*D)*(i+1)-1:(32*D)*i]),
	.LVDS_CLK_PN_SWAP_I (LVDS_CLK_PN_SWAP_I  ),
	.RX_SWAP_MASK_I   (RX_SWAP_MASK_I)
	
	);

end
endgenerate
endmodule

//////////////////////////////////////////////////////////////////////////////
// /___/  \  /   Vendor: Xilinx
// \   \   \/    Version: 1.2
//  \   \        Filename: serdes_1_to_7_mmcm_idelay_ddr.v
//  /   /        Date Last Modified:  21JAN2015
// /___/   /\    Date Created: 5MAR2010
// \   \  /  \
//Device:     7 Series
//Purpose:      1 to 7 DDR receiver clock and data receiver using an MMCM for clock multiplication
//        Data formatting is set by the DATA_FORMAT parameter. 
//        PER_CLOCK (default) format receives bits for 0, 1, 2 .. on the same sample edge
//        PER_CHANL format receives bits for 0, 7, 14 ..  on the same sample edge
//Reference:    XAPP585
//Revision History:
//    Rev 1.0 - First created (nicks)
//    Rev 1.1 - PER_CLOCK and PER_CHANL descriptions swapped
//    Rev 1.2 - State machine moved to a new level of hierarchy, eye monitor added, gearbox sync added, updated format
/////////////////////////////////////////////////////////////////////////////
`timescale 1ps/1ps

module serdes_1_to_7_mmcm_idelay_ddr (clkin_p, clkin_n, datain_p, datain_n, enable_phase_detector, rxclk, idelay_rdy, reset, pixel_clk, rxclk_d4, enable_monitor,
                                      rx_mmcm_lckdps, rx_mmcm_lckd, rx_mmcm_lckdpsbs, clk_data, rx_data, status, debug, bit_rate_value, dcd_correct, bit_time_value, rst_iserdes, del_mech, gb_rst_out, m_delay_1hot, eye_info,mmcm_locked,LVDS_CLK_PN_SWAP_I,RX_SWAP_MASK_I) ;

parameter integer  D = 8 ;                 // Parameter to set the number of data lines
parameter integer  MMCM_MODE = 1 ;         // Parameter to set multiplier for MMCM to get VCO in correct operating range. 1 multiplies input clock by 7, 2 multiplies clock by 14, etc
parameter real     REF_FREQ = 200 ;        // Parameter to set reference frequency used by idelay controller
parameter          HIGH_PERFORMANCE_MODE = "FALSE";// Parameter to set HIGH_PERFORMANCE_MODE of input delays to reduce jitter
parameter real     CLKIN_PERIOD = 6.000 ;  // clock period (ns) of input clock on clkin_p
parameter          DIFF_TERM = "FALSE" ;   // Parameter to enable internal differential termination
parameter          SAMPL_CLOCK = "BUFIO" ; // Parameter to set sampling clock buffer type, BUFIO, BUF_H, BUF_G
parameter          INTER_CLOCK = "BUF_R" ; // Parameter to set intermediate clock buffer type, BUFR, BUF_H, BUF_G
parameter          PIXEL_CLOCK = "BUF_G" ; // Parameter to set final pixel buffer type, BUF_R, BUF_H, BUF_G
parameter          USE_PLL = "FALSE" ;     // Parameter to enable PLL use rather than MMCM use, note, PLL does not support BUFIO and BUFR
parameter          DATA_FORMAT = "PER_CLOCK" ; // Parameter Used to determine method for mapping input parallel word to output serial words
//parameter [0:0]    PN_SWAP = 0;
input [0:0] LVDS_CLK_PN_SWAP_I   ;
          
input  clkin_p ;            // Input from LVDS clock receiver pin
input  clkin_n ;            // Input from LVDS clock receiver pin
input  [D-1:0] datain_p ;            // Input from LVDS clock data pins
input  [D-1:0] datain_n ;            // Input from LVDS clock data pins
input  enable_phase_detector ;        // Enables the phase detector logic when high
input  enable_monitor ;        // Enable monitoring function
input  reset ;                // Reset line
input  idelay_rdy ;            // input delays are ready
output rxclk ;                // Global/BUFIO rx clock network
output pixel_clk ;            // Global/Regional clock output
output rxclk_d4 ;            // Global/Regional clock output
output rx_mmcm_lckd ;             // MMCM locked, synchronous to rxclk_d4
output rx_mmcm_lckdps ;         // MMCM locked and phase shifting finished, synchronous to pixel_clk
output rx_mmcm_lckdpsbs ;         // MMCM locked and phase shifting finished and bitslipping finished, synchronous to pixel_clk
output [6:0] clk_data ;             // Clock Data
output [D*7-1:0]  rx_data ;             // Received Data
output [10*D+5:0] debug ;                 // debug info
output [6:0] status ;             // clock status
input  dcd_correct ;            // '0' = square, '1' = assume 10% DCD
input  [15:0] bit_rate_value ;         // Bit rate in Mbps, for example 16'h0585 16'h1050 ..
output [4:0]  bit_time_value ;        // Calculated bit time value for slave devices
output reg  del_mech ;            // DCD correct cascade to slaves
output reg  rst_iserdes ;            // serdes reset signal to slaves
output [1:0] gb_rst_out ;            // gearbox reset signals to slaves
output [32*D-1:0] m_delay_1hot ;            // Master delay control value as a one-hot vector
output [D*32-1:0] eye_info ;             // eye info
output mmcm_locked ;

input [D-1:0] RX_SWAP_MASK_I  ; // pinswap mask for input data bits (0 = no swap (default), 1 = swap). Allows inputs to be connected the wrong way round to ease PCB routing.


wire   [D*5-1:0] m_delay_val_in ;
wire   [D*5-1:0] s_delay_val_in ;
wire   [3:0] cdataout ;            
reg    [3:0] cdataouta ;            
reg    [3:0] cdataoutb ;            
reg    [3:0] cdataoutc ;            
wire   rx_clk_in_p ;     
wire   rx_clk_in_n  ;       
reg    [1:0] bsstate ;                     
reg    bslip ;                     
reg    bslipreq ;                     
reg    bslipr_dom_ch ;                     
reg    [3:0] bcount ;                     
reg    [6*D-1:0] pdcount ;                     
wire   [6:0] clk_iserdes_data ;          
reg    [6:0] clk_iserdes_data_d ;        
reg    enable ;                    
reg    flag1 ;                     
reg    flag2 ;                     
reg    [2:0] state2 ;            
reg    [4:0] state2_count ;            
reg    [5:0] scount ;            
reg    locked_out ;    
reg    locked_out_dom_ch ;    
reg    chfound ;    
reg    chfoundc ;
reg    rx_mmcm_lckd_int ;
reg    not_rx_mmcm_lckd_intd4 ;
reg    [4:0] c_delay_in ;
reg    [4:0] c_delay_in_target ;
reg    c_delay_in_ud ;
wire   [D-1:0] rx_data_in_p ;            
wire   [D-1:0] rx_data_in_n ; 

wire   [D-1:0] DIFF_data_O  ;            
wire   [D-1:0] DIFF_data_OB ; 
           
wire   [D-1:0] rx_data_in_m ;            
wire   [D-1:0] rx_data_in_s ;        
wire   [D-1:0] rx_data_in_md ;            
wire   [D-1:0] rx_data_in_sd ;                
wire   [(4*D)-1:0] mdataout ;                        
wire   [(4*D)-1:0] mdataoutd ;            
wire   [(4*D)-1:0] sdataout ;                        
wire   [(7*D)-1:0] dataout ;                    
reg    jog;        
reg    [2:0]  slip_count ;                    
reg    bslip_ack_dom_ch ;        
reg    bslip_ack ;        
reg    [1:0] bstate ;
reg    data_different ;
reg    data_different_dom_ch ;
reg    [D-1:0] s_ovflw ;        
reg    [D-1:0] s_hold ;        
reg    bs_finished ;
reg    not_bs_finished_dom_ch ;
reg    [4:0] bt_val ;  
wire   mmcm_locked ;
(*keep="true"*)wire rxpllmmcm_x1 ;
(*keep="true"*)wire rxpllmmcm_xs ;
(*keep="true"*)wire rxpllmmcm_d4 ;
reg    rstcserdes ;
reg    [1:0] c_loop_cnt ;  


assign clk_data = clk_iserdes_data ;
assign debug = {s_delay_val_in, m_delay_val_in, bslip, c_delay_in} ;
assign rx_mmcm_lckdpsbs = bs_finished & mmcm_locked ;
assign rx_mmcm_lckd = ~not_rx_mmcm_lckd_intd4 & mmcm_locked ;
assign rx_mmcm_lckdps = locked_out_dom_ch & mmcm_locked ;
assign bit_time_value = bt_val ;

if (REF_FREQ < 210.0) begin
  always @ (bit_rate_value) begin   // Generate tap number to be used for input bit rate (200 MHz ref clock)
      if      (bit_rate_value > 16'h1984) begin bt_val <= 5'h07 ; del_mech <= 1'b1 ; end
      else if (bit_rate_value > 16'h1717) begin bt_val <= 5'h08 ; del_mech <= 1'b1 ; end
      else if (bit_rate_value > 16'h1514) begin bt_val <= 5'h09 ; del_mech <= 1'b1 ; end
      else if (bit_rate_value > 16'h1353) begin bt_val <= 5'h0A ; del_mech <= 1'b1 ; end
      else if (bit_rate_value > 16'h1224) begin bt_val <= 5'h0B ; del_mech <= 1'b1 ; end
      else if (bit_rate_value > 16'h1117) begin bt_val <= 5'h0C ; del_mech <= 1'b1 ; end
      else if (bit_rate_value > 16'h1027) begin bt_val <= 5'h0D ; del_mech <= 1'b1 ; end
      else if (bit_rate_value > 16'h0951) begin bt_val <= 5'h0E ; del_mech <= 1'b1 ; end
      else if (bit_rate_value > 16'h0885) begin bt_val <= 5'h0F ; del_mech <= 1'b1 ; end
      else if (bit_rate_value > 16'h0828) begin bt_val <= 5'h10 ; del_mech <= 1'b1 ; end
      else if (bit_rate_value > 16'h0778) begin bt_val <= 5'h11 ; del_mech <= 1'b1 ; end
      else if (bit_rate_value > 16'h0733) begin bt_val <= 5'h12 ; del_mech <= 1'b1 ; end
      else if (bit_rate_value > 16'h0694) begin bt_val <= 5'h13 ; del_mech <= 1'b1 ; end
      else if (bit_rate_value > 16'h0658) begin bt_val <= 5'h14 ; del_mech <= 1'b1 ; end
      else if (bit_rate_value > 16'h0626) begin bt_val <= 5'h15 ; del_mech <= 1'b1 ; end
      else if (bit_rate_value > 16'h0597) begin bt_val <= 5'h16 ; del_mech <= 1'b0 ; end
      else if (bit_rate_value > 16'h0570) begin bt_val <= 5'h17 ; del_mech <= 1'b0 ; end
      else if (bit_rate_value > 16'h0546) begin bt_val <= 5'h18 ; del_mech <= 1'b0 ; end
      else if (bit_rate_value > 16'h0524) begin bt_val <= 5'h19 ; del_mech <= 1'b0 ; end
      else if (bit_rate_value > 16'h0503) begin bt_val <= 5'h1A ; del_mech <= 1'b0 ; end
      else if (bit_rate_value > 16'h0484) begin bt_val <= 5'h1B ; del_mech <= 1'b0 ; end
      else if (bit_rate_value > 16'h0466) begin bt_val <= 5'h1C ; del_mech <= 1'b0 ; end
      else if (bit_rate_value > 16'h0450) begin bt_val <= 5'h1D ; del_mech <= 1'b0 ; end
      else if (bit_rate_value > 16'h0435) begin bt_val <= 5'h1E ; del_mech <= 1'b0 ; end
      else                                begin bt_val <= 5'h1F ; del_mech <= 1'b0 ; end        // min bit rate 420 Mbps
  end
end else begin
  always @ (bit_rate_value or dcd_correct) begin                        // Generate tap number to be used for input bit rate (300 MHz ref clock)
      if      ((bit_rate_value > 16'h2030 && dcd_correct == 1'b0) || (bit_rate_value > 16'h1845 && dcd_correct == 1'b1)) begin bt_val <= 5'h0A ; del_mech <= 1'b1 ; end
      else if ((bit_rate_value > 16'h1836 && dcd_correct == 1'b0) || (bit_rate_value > 16'h1669 && dcd_correct == 1'b1)) begin bt_val <= 5'h0B ; del_mech <= 1'b1 ; end
      else if ((bit_rate_value > 16'h1675 && dcd_correct == 1'b0) || (bit_rate_value > 16'h1523 && dcd_correct == 1'b1)) begin bt_val <= 5'h0C ; del_mech <= 1'b1 ; end
      else if ((bit_rate_value > 16'h1541 && dcd_correct == 1'b0) || (bit_rate_value > 16'h1401 && dcd_correct == 1'b1)) begin bt_val <= 5'h0D ; del_mech <= 1'b1 ; end
      else if ((bit_rate_value > 16'h1426 && dcd_correct == 1'b0) || (bit_rate_value > 16'h1297 && dcd_correct == 1'b1)) begin bt_val <= 5'h0E ; del_mech <= 1'b1 ; end
      else if ((bit_rate_value > 16'h1328 && dcd_correct == 1'b0) || (bit_rate_value > 16'h1207 && dcd_correct == 1'b1)) begin bt_val <= 5'h0F ; del_mech <= 1'b1 ; end
      else if ((bit_rate_value > 16'h1242 && dcd_correct == 1'b0) || (bit_rate_value > 16'h1129 && dcd_correct == 1'b1)) begin bt_val <= 5'h10 ; del_mech <= 1'b1 ; end
      else if ((bit_rate_value > 16'h1167 && dcd_correct == 1'b0) || (bit_rate_value > 16'h1061 && dcd_correct == 1'b1)) begin bt_val <= 5'h11 ; del_mech <= 1'b1 ; end
      else if ((bit_rate_value > 16'h1100 && dcd_correct == 1'b0) || (bit_rate_value > 16'h0999 && dcd_correct == 1'b1)) begin bt_val <= 5'h12 ; del_mech <= 1'b1 ; end
      else if ((bit_rate_value > 16'h1040 && dcd_correct == 1'b0) || (bit_rate_value > 16'h0946 && dcd_correct == 1'b1)) begin bt_val <= 5'h13 ; del_mech <= 1'b1 ; end
      else if ((bit_rate_value > 16'h0987 && dcd_correct == 1'b0) || (bit_rate_value > 16'h0897 && dcd_correct == 1'b1)) begin bt_val <= 5'h14 ; del_mech <= 1'b1 ; end
      else if ((bit_rate_value > 16'h0939 && dcd_correct == 1'b0) || (bit_rate_value > 16'h0853 && dcd_correct == 1'b1)) begin bt_val <= 5'h15 ; del_mech <= 1'b1 ; end
      else if ((bit_rate_value > 16'h0895 && dcd_correct == 1'b0) || (bit_rate_value > 16'h0814 && dcd_correct == 1'b1)) begin bt_val <= 5'h16 ; del_mech <= 1'b0 ; end
      else if ((bit_rate_value > 16'h0855 && dcd_correct == 1'b0) || (bit_rate_value > 16'h0777 && dcd_correct == 1'b1)) begin bt_val <= 5'h17 ; del_mech <= 1'b0 ; end
      else if ((bit_rate_value > 16'h0819 && dcd_correct == 1'b0) || (bit_rate_value > 16'h0744 && dcd_correct == 1'b1)) begin bt_val <= 5'h18 ; del_mech <= 1'b0 ; end
      else if ((bit_rate_value > 16'h0785 && dcd_correct == 1'b0) || (bit_rate_value > 16'h0714 && dcd_correct == 1'b1)) begin bt_val <= 5'h19 ; del_mech <= 1'b0 ; end
      else if ((bit_rate_value > 16'h0754 && dcd_correct == 1'b0) || (bit_rate_value > 16'h0686 && dcd_correct == 1'b1)) begin bt_val <= 5'h1A ; del_mech <= 1'b0 ; end
      else if ((bit_rate_value > 16'h0726 && dcd_correct == 1'b0) || (bit_rate_value > 16'h0660 && dcd_correct == 1'b1)) begin bt_val <= 5'h1B ; del_mech <= 1'b0 ; end
      else if ((bit_rate_value > 16'h0700 && dcd_correct == 1'b0) || (bit_rate_value > 16'h0636 && dcd_correct == 1'b1)) begin bt_val <= 5'h1C ; del_mech <= 1'b0 ; end
      else if ((bit_rate_value > 16'h0675 && dcd_correct == 1'b0) || (bit_rate_value > 16'h0614 && dcd_correct == 1'b1)) begin bt_val <= 5'h1D ; del_mech <= 1'b0 ; end
      else if ((bit_rate_value > 16'h0652 && dcd_correct == 1'b0) || (bit_rate_value > 16'h0593 && dcd_correct == 1'b1)) begin bt_val <= 5'h1E ; del_mech <= 1'b0 ; end
      else                                                                           begin bt_val <= 5'h1F ;   del_mech <= 1'b0 ; end        // min bit rate 631 Mbps
  end
end

// Bitslip state machine, split over two clock domains
always @ (posedge pixel_clk)begin
begin
locked_out_dom_ch <= locked_out ;
if (locked_out_dom_ch == 1'b0) begin
    bsstate <= 2 ;
    enable <= 1'b0 ;
    bslipreq <= 1'b0 ;
    bcount <= 4'h0 ;
    jog <= 1'b0 ;
    slip_count <= 3'h0 ;
    bs_finished <= 1'b0 ;
end
else begin
       bslip_ack_dom_ch <= bslip_ack ;
    enable <= 1'b1 ;
       if (enable == 1'b1) begin
           
           //ori
           //if (clk_iserdes_data != 7'b1100001) begin flag1 <= 1'b1 ; end else begin flag1 <= 1'b0 ; end 
           //if (clk_iserdes_data != 7'b1100011) begin flag2 <= 1'b1 ; end else begin flag2 <= 1'b0 ; end 
           
           //yzhu
           if (clk_iserdes_data != (LVDS_CLK_PN_SWAP_I ? 7'b0011110 : 7'b1100001) ) begin flag1 <= 1'b1 ; end else begin flag1 <= 1'b0 ; end 
           if (clk_iserdes_data != (LVDS_CLK_PN_SWAP_I ? 7'b0011100 : 7'b1100011) ) begin flag2 <= 1'b1 ; end else begin flag2 <= 1'b0 ; end 
           
           
           if (bsstate == 0) begin
               if (flag1 == 1'b1 && flag2 == 1'b1) begin
                    bslipreq <= 1'b1 ;                    // bitslip needed
                    bsstate <= 1 ;
               end
               else begin
                   bs_finished <= 1'b1 ;                    // bitslip done
               end
        end
        else if (bsstate == 1) begin                        // wait for bitslip ack from other clock domain
            if (bslip_ack_dom_ch == 1'b1) begin
                bslipreq <= 1'b0 ;                    // bitslip low
                bcount <= 4'h0 ;
                slip_count <= slip_count + 3'h1 ;
                bsstate <= 2 ;
            end
        end
        else if (bsstate == 2) begin                
            bcount <= bcount + 4'h1 ;
            if (bcount == 4'hF) begin
                if (slip_count == 3'h5) begin
                    jog <= ~jog ;
                end
                bsstate <= 0 ;
            end
        end
    end
end
end
end

always @ (posedge rxclk_d4)begin
begin
    not_bs_finished_dom_ch <= ~bs_finished ;
    bslipr_dom_ch <= bslipreq ;
    if (locked_out == 1'b0) begin
        bslip <= 1'b0 ;
        bslip_ack <= 1'b0 ;
        bstate <= 0 ;    
    end    
    else if (bstate == 0 && bslipr_dom_ch == 1'b1) begin
        bslip <= 1'b1 ;
        bslip_ack <= 1'b1 ;
        bstate <= 1 ;
    end
    else if (bstate == 1) begin
        bslip <= 1'b0 ;
        bslip_ack <= 1'b1 ;
        bstate <= 2 ;
    end
    else if (bstate == 2 && bslipr_dom_ch == 1'b0) begin
        bslip_ack <= 1'b0 ;
        bstate <= 0 ;
    end        
end
end

//master  Clock input 

IBUFGDS_DIFF_OUT #(
    .DIFF_TERM        (DIFF_TERM), 
    .IBUF_LOW_PWR     ("FALSE"))
    iob_clk_in (
    .I                (clkin_p),
    .IB               (clkin_n) ,
    .O                ( DIFF_O  ),
    .OB               ( DIFF_OB ));

//assign rx_clk_in_p = PN_SWAP==0 ? DIFF_O : DIFF_OB ;
//assign rx_clk_in_n = PN_SWAP==0 ? DIFF_OB : DIFF_O ;
assign rx_clk_in_p = DIFF_O  ;
assign rx_clk_in_n = DIFF_OB ;

genvar i ;
genvar j ;

IDELAYE2 #(
    .REFCLK_FREQUENCY    (REF_FREQ),
    .HIGH_PERFORMANCE_MODE (HIGH_PERFORMANCE_MODE),
          .IDELAY_VALUE    (1),
          .DELAY_SRC       ("IDATAIN"),
          .IDELAY_TYPE     ("VAR_LOAD"))
    idelay_cm(                   
    .DATAOUT        (rx_clkin_p_d),
    .C              (rxclk_d4),
    .CE             (1'b0),
    .INC            (1'b0),
    .DATAIN         (1'b0),
    //.IDATAIN        (PN_SWAP==0 ? rx_clk_in_p : rx_clk_in_n),
    .IDATAIN        (rx_clk_in_p ),
    .LD             (1'b1),
    .LDPIPEEN        (1'b0),
    .REGRST          (1'b0),
    .CINVCTRL        (1'b0),
    .CNTVALUEIN      (c_delay_in),
    .CNTVALUEOUT     ());
        
IDELAYE2 #(
    .REFCLK_FREQUENCY    (REF_FREQ),
    .HIGH_PERFORMANCE_MODE  (HIGH_PERFORMANCE_MODE),
          .IDELAY_VALUE     (1),
          .DELAY_SRC        ("IDATAIN"),
          .IDELAY_TYPE      ("VAR_LOAD"))
    idelay_cs(                   
    .DATAOUT        (rx_clk_in_n_d),
    .C            (rxclk_d4),
    .CE            (1'b0),
    .INC           (1'b0),
    .DATAIN        (1'b0),
    //.IDATAIN       (PN_SWAP==0 ? ~rx_clk_in_n : ~rx_clk_in_p ),
    .IDATAIN       (~rx_clk_in_n  ),
    .LD            (1'b1),
    .LDPIPEEN        (1'b0),
    .REGRST          (1'b0),
    .CINVCTRL        (1'b0),
    .CNTVALUEIN      ({1'b0, bt_val[4:1]}),
    .CNTVALUEOUT     ());

ISERDESE2 #(
    .DATA_WIDTH        (4),                 
    .DATA_RATE         ("DDR"),             
//    .SERDES_MODE     ("MASTER"),             
    .IOBDELAY          ("IFD"),             
    .INTERFACE_TYPE    ("NETWORKING"),
    .NUM_CE            (1))        
    iserdes_cs (
    .D              (1'b0),
    .DDLY           (rx_clk_in_n_d),
    .CE1            (1'b1),
    .CE2            (1'b1),
    .CLK            (rxclk),
    .CLKB           (~rxclk),
    .RST            (rstcserdes),
    .CLKDIV         (rxclk_d4),
    .CLKDIVP        (1'b0),
    .OCLK           (1'b0),
    .OCLKB          (1'b0),
    .DYNCLKSEL      (1'b0),
    .DYNCLKDIVSEL   (1'b0),
    .SHIFTIN1       (1'b0),
    .SHIFTIN2       (1'b0),
    .BITSLIP        (bslip),
    .O              (),
    .Q8             (),
    .Q7             (),
    .Q6             (),
    .Q5             (),
    .Q4             (cdataout[0]),
    .Q3             (cdataout[1]),
    .Q2             (cdataout[2]),
    .Q1             (cdataout[3]),
    .OFB            (),
    .SHIFTOUT1      (),
    .SHIFTOUT2      ());

generate
if (USE_PLL == "FALSE") begin : loop8                    // use an MMCM
assign status[6] = 1'b1 ; 
(*KEEP_HIERARCHY  = "TRUE"*)    
MMCME2_ADV #(
    .BANDWIDTH          ("OPTIMIZED"),          
    .CLKFBOUT_MULT_F     (7*MMCM_MODE),                   
    .CLKFBOUT_PHASE      (0.0),                 
    .CLKIN1_PERIOD       (CLKIN_PERIOD),          
    .CLKIN2_PERIOD       (CLKIN_PERIOD),          
    .CLKOUT0_DIVIDE_F    (2*MMCM_MODE),                   
    .CLKOUT0_DUTY_CYCLE  (0.5),                 
    .CLKOUT0_PHASE       (0.0),                
    .CLKOUT0_USE_FINE_PS    ("FALSE"),
    .CLKOUT1_PHASE       (11.25),                
    .CLKOUT1_DIVIDE      (4*MMCM_MODE),                   
    .CLKOUT1_DUTY_CYCLE  (0.5),                 
    .CLKOUT1_USE_FINE_PS       ("FALSE"),                
    .COMPENSATION        ("ZHOLD"),        
    .DIVCLK_DIVIDE       (1),                
    .REF_JITTER1        (0.100))                
    rx_mmcm_adv_inst (
    .CLKFBOUT       (rxpllmmcm_x1),                      
    .CLKFBOUTB      (),                      
    .CLKFBSTOPPED   (),                      
    .CLKINSTOPPED   (),                      
    .CLKOUT0        (rxpllmmcm_xs),              
    .CLKOUT0B       (),                  
    .CLKOUT1        (rxpllmmcm_d4),               
    .PSCLK          (1'b0),  
    .PSEN           (1'b0),  
    .PSINCDEC       (1'b0),  
    .PWRDWN         (1'b0), 
    .LOCKED         (mmcm_locked),                
    .CLKFBIN        (pixel_clk),            
    .CLKIN1         (rx_clkin_p_d),         
    .CLKIN2         (rx_clkin_p_d),                     
    .CLKINSEL       (1'b1),                     
    .DADDR          (7'h00),                    
    .DCLK           (1'b0),                       
    .DEN            (1'b0),                        
    .DI             (16'h0000),                
    .DWE            (1'b0),                        
    .RST            (reset)) ;                   

   if (PIXEL_CLOCK == "BUF_G") begin                         // Final clock selection
      BUFG    bufg_mmcm_x1 (.I(rxpllmmcm_x1), .O(pixel_clk)) ;
      assign status[1:0] = 2'b00 ;
   end
   else if (PIXEL_CLOCK == "BUF_R") begin
      BUFR #(.BUFR_DIVIDE("1"),.SIM_DEVICE("7SERIES"))bufr_mmcm_x1 (.I(rxpllmmcm_x1),.CE(1'b1),.O(pixel_clk),.CLR(1'b0)) ;
      assign status[1:0] = 2'b01 ;
   end
   else begin 
      BUFH    bufh_mmcm_x1 (.I(rxpllmmcm_x1), .O(pixel_clk)) ;
      assign status[1:0] = 2'b10 ;
   end

   if (INTER_CLOCK == "BUF_G") begin                         // Intermediate clock selection
      BUFG    bufg_mmcm_d4 (.I(rxpllmmcm_d4), .O(rxclk_d4)) ;
      assign status[3:2] = 2'b00 ;
   end
   else if (INTER_CLOCK == "BUF_R") begin
      BUFR #(.BUFR_DIVIDE("2"),.SIM_DEVICE("7SERIES"))bufr_mmcm_d4 (.I(rxpllmmcm_xs),.CE(1'b1),.O(rxclk_d4),.CLR(1'b0)) ;
      assign status[3:2] = 2'b01 ;
   end
   else begin 
      BUFH    bufh_mmcm_d4 (.I(rxpllmmcm_d4), .O(rxclk_d4)) ;
      assign status[3:2] = 2'b10 ;
   end
      
   if (SAMPL_CLOCK == "BUF_G") begin                        // Sample clock selection
      BUFG    bufg_mmcm_xn (.I(rxpllmmcm_xs), .O(rxclk)) ;
      assign status[5:4] = 2'b00 ;
   end
   else if (SAMPL_CLOCK == "BUFIO") begin
      BUFIO      bufio_mmcm_xn (.I (rxpllmmcm_xs), .O(rxclk)) ;
      assign status[5:4] = 2'b11 ;
   end
   else begin 
      BUFH    bufh_mmcm_xn (.I(rxpllmmcm_xs), .O(rxclk)) ;
      assign status[5:4] = 2'b10 ;
   end
   
end 
else begin                                    // Use a PLL
assign status[6] = 1'b0 ; 

PLLE2_ADV #(
    .BANDWIDTH           ("OPTIMIZED"),          
    .CLKFBOUT_MULT       (7*MMCM_MODE),                   
    .CLKFBOUT_PHASE      (0.0),                 
    .CLKIN1_PERIOD       (CLKIN_PERIOD),          
    .CLKIN2_PERIOD       (CLKIN_PERIOD),          
    .CLKOUT0_DIVIDE      (2*MMCM_MODE),                   
    .CLKOUT0_DUTY_CYCLE  (0.5),                 
    .CLKOUT0_PHASE       (0.0),                 
    .CLKOUT1_DIVIDE      (4*MMCM_MODE),                   
    .CLKOUT1_DUTY_CYCLE  (0.5),                 
    .CLKOUT1_PHASE       (11.25),                                                   
    .COMPENSATION        ("ZHOLD"),        
    .DIVCLK_DIVIDE       (1),                
    .REF_JITTER1         (0.100))                
    rx_plle2_adv_inst (
    .CLKFBOUT       (rxpllmmcm_x1),                      
    .CLKOUT0        (rxpllmmcm_xs),              
    .CLKOUT1        (rxpllmmcm_d4),                                        
    .PWRDWN         (1'b0), 
    .LOCKED         (mmcm_locked),                
    .CLKFBIN        (pixel_clk),            
    .CLKIN1         (rx_clkin_p_d),         
    .CLKIN2         (rx_clkin_p_d),                     
    .CLKINSEL       (1'b1),                     
    .DADDR          (7'h00),                    
    .DCLK           (1'b0),                       
    .DEN            (1'b0),                        
    .DI             (16'h0000),                
    .DWE            (1'b0),                        
    .RST            (reset)) ;  

   if (PIXEL_CLOCK == "BUF_G") begin                         // Final clock selection
      BUFG    bufg_pll_x1 (.I(rxpllmmcm_x1), .O(pixel_clk)) ;
      assign status[1:0] = 2'b00 ;
   end
   else if (PIXEL_CLOCK == "BUF_R") begin
      BUFR #(.BUFR_DIVIDE("1"),.SIM_DEVICE("7SERIES"))bufr_pll_x1 (.I(rxpllmmcm_x1),.CE(1'b1),.O(pixel_clk),.CLR(1'b0)) ;
      assign status[1:0] = 2'b01 ;
   end
   else begin 
      BUFH    bufh_pll_x1 (.I(rxpllmmcm_x1), .O(pixel_clk)) ;
      assign status[1:0] = 2'b10 ;
   end

   if (INTER_CLOCK == "BUF_G") begin                         // Intermediate clock selection
      BUFG    bufg_pll_d4 (.I(rxpllmmcm_d4), .O(rxclk_d4)) ;
      assign status[3:2] = 2'b00 ;
   end
   else if (INTER_CLOCK == "BUF_R") begin
      BUFR #(.BUFR_DIVIDE("2"),.SIM_DEVICE("7SERIES"))bufr_pll_d4 (.I(rxpllmmcm_xs),.CE(1'b1),.O(rxclk_d4),.CLR(1'b0)) ;
      assign status[3:2] = 2'b01 ;
   end
   else begin 
      BUFH    bufh_pll_d4 (.I(rxpllmmcm_d4), .O(rxclk_d4)) ;
      assign status[3:2] = 2'b10 ;
   end
      
   if (SAMPL_CLOCK == "BUF_G") begin                        // Sample clock selection
      BUFG    bufg_pll_xn (.I(rxpllmmcm_xs), .O(rxclk)) ;
      assign status[5:4] = 2'b00 ;
   end
   else if (SAMPL_CLOCK == "BUFIO") begin
      BUFIO      bufio_pll_xn (.I (rxpllmmcm_xs), .O(rxclk)) ;
      assign status[5:4] = 2'b11 ;
   end
   else begin 
      BUFH    bufh_pll_xn (.I(rxpllmmcm_xs), .O(rxclk)) ;
      assign status[5:4] = 2'b10 ;
   end

end
endgenerate

always @ (posedge pixel_clk) begin                    // retiming
    clk_iserdes_data_d <= clk_iserdes_data ;
    if ((clk_iserdes_data != clk_iserdes_data_d) && (clk_iserdes_data != 7'h00) && (clk_iserdes_data != 7'h7F)) begin
        data_different <= 1'b1 ;
    end
    else begin
        data_different <= 1'b0 ;
    end
end
    
always @ (posedge rxclk_d4) begin                            // clock delay shift state machine
    not_rx_mmcm_lckd_intd4 <= ~(mmcm_locked & idelay_rdy) ;
    rstcserdes <= not_rx_mmcm_lckd_intd4 | rst_iserdes ;
    if (not_rx_mmcm_lckd_intd4 == 1'b1) begin
        scount <= 6'h00 ;
        state2 <= 0 ;
        state2_count <= 5'h00 ;
        locked_out <= 1'b0 ;
        chfoundc <= 1'b1 ;
        c_delay_in <= bt_val ;                            // Start the delay line at the current bit period
        rst_iserdes <= 1'b0 ;
        c_loop_cnt <= 2'b00 ;    
    end
    else begin
        if (scount[5] == 1'b0) begin
            scount <= scount + 6'h01 ;
        end
        state2_count <= state2_count + 5'h01 ;
        data_different_dom_ch <= data_different ;
        if (chfoundc == 1'b1) begin
            chfound <= 1'b0 ;
        end
        else if (chfound == 1'b0 && data_different_dom_ch == 1'b1) begin
            chfound <= 1'b1 ;
        end
        if ((state2_count == 5'h1F && scount[5] == 1'b1)) begin
            case(state2)                     
            0    : begin                            // decrement delay and look for a change
                  if (chfound == 1'b1 || (c_loop_cnt == 2'b11 && c_delay_in == 5'h00)) begin  // quit loop if we've been around a few times
                    chfoundc <= 1'b1 ;
                    state2 <= 1 ;
                  end
                  else begin
                    chfoundc <= 1'b0 ;
                    if (c_delay_in != 5'h00) begin            // check for underflow
                        c_delay_in <= c_delay_in - 5'h01 ;
                    end
                    else begin
                        c_delay_in <= bt_val ;
                        c_loop_cnt <= c_loop_cnt + 2'b01 ;
                    end
                  end
                  end
            1    : begin                            // add half a bit period using input information
                  state2 <= 2 ; 
                  if (c_delay_in < {1'b0, bt_val[4:1]}) begin        // choose the lowest delay value to minimise jitter
                       c_delay_in_target <= c_delay_in + {1'b0, bt_val[4:1]} ;
                  end
                  else begin
                       c_delay_in_target <= c_delay_in - {1'b0, bt_val[4:1]} ;
                  end
                  end
            2     : begin
                  if (c_delay_in == c_delay_in_target) begin
                       state2 <= 3 ;
                  end
                  else begin
                       if (c_delay_in_ud == 1'b1) begin        // move gently to end position to stop MMCM unlocking
                        c_delay_in <= c_delay_in + 5'h01 ;
                           c_delay_in_ud <= 1'b1 ;
                       end
                       else begin
                        c_delay_in <= c_delay_in - 5'h01 ;
                           c_delay_in_ud <= 1'b0 ;
                       end
                  end
                  end
            3     : begin rst_iserdes <= 1'b1 ; state2 <= 4 ; end        // remove serdes reset
            default    : begin                            // issue locked out signal 
                  rst_iserdes <= 1'b0 ;  locked_out <= 1'b1 ;
                   end
            endcase
        end
    end
end
    
generate
for (i = 0 ; i <= D-1 ; i = i+1)
begin : loop3

delay_controller_wrap # (.S(4))
    dc_inst (                       
    .m_datain        (mdataout[4*i+3:4*i]),
    .s_datain        (sdataout[4*i+3:4*i]),
    .enable_phase_detector (enable_phase_detector),
    .enable_monitor        (enable_monitor),
    .reset          (not_bs_finished_dom_ch),
    .clk            (rxclk_d4),
    .c_delay_in     ({1'b0, bt_val[4:1]}),
    .m_delay_out    (m_delay_val_in[5*i+4:5*i]),
    .s_delay_out    (s_delay_val_in[5*i+4:5*i]),
    .data_out       (mdataoutd[4*i+3:4*i]),
    .bt_val         (bt_val),
    .results        (eye_info[32*i+31:32*i]),
    .m_delay_1hot   (m_delay_1hot[32*i+31:32*i]),
    .del_mech       (del_mech)) ;

end
endgenerate 

always @ (posedge rxclk_d4) begin                            // clock balancing
    if (enable_phase_detector == 1'b1) begin
        cdataouta[3:0] <= cdataout[3:0] ;
        cdataoutb[3:0] <= cdataouta[3:0] ;
        cdataoutc[3:0] <= cdataoutb[3:0] ;
    end
    else begin
        cdataoutc[3:0] <= cdataout[3:0] ;
    end
end

// Data gearbox (includes clock data) - this is a master and will generate reset for the slaves

gearbox_4_to_7 # (.D (D+1))         
    gb0 (                           
    .input_clock    (rxclk_d4),
    .output_clock   (pixel_clk),
    .datain         ({cdataoutc, mdataoutd}),
    .reset          (not_rx_mmcm_lckd_intd4),
    .reset_out      (gb_rst_out),
    .jog            (jog),
    .dataout        ({clk_iserdes_data, dataout})) ;
    
// Data bit Receivers 

generate
for (i = 0 ; i <= D-1 ; i = i+1) begin : loop0
for (j = 0 ; j <= 6 ; j = j+1) begin : loop1            // Assign data bits to correct serdes according to required format
    if (DATA_FORMAT == "PER_CLOCK") begin
        assign rx_data[D*j+i] = dataout[7*i+j] ;
    end 
    else begin
        assign rx_data[7*i+j] = dataout[7*i+j] ;
    end
end

IBUFDS_DIFF_OUT #(
    .DIFF_TERM         (DIFF_TERM),
    .IBUF_LOW_PWR      ("FALSE")) 
    data_in (
    .I                (datain_p[i]),
    .IB               (datain_n[i]),
    .O                (DIFF_data_O[i]  ),
    .OB               (DIFF_data_OB[i] ));


//assign rx_data_in_p[i] = PN_SWAP==0 ? DIFF_data_O[i]  : DIFF_data_OB[i] ;
//assign rx_data_in_n[i] = PN_SWAP==0 ? DIFF_data_OB[i] : DIFF_data_O[i]  ;
assign rx_data_in_p[i] = DIFF_data_O[i]   ;
assign rx_data_in_n[i] = DIFF_data_OB[i]  ;



assign rx_data_in_m[i] = rx_data_in_p[i]  ^ RX_SWAP_MASK_I[i] ;
assign rx_data_in_s[i] = ~rx_data_in_n[i] ^ RX_SWAP_MASK_I[i] ;

IDELAYE2 #(
    .REFCLK_FREQUENCY    (REF_FREQ),
    .HIGH_PERFORMANCE_MODE(HIGH_PERFORMANCE_MODE),
          .IDELAY_VALUE   (0),
          .DELAY_SRC      ("IDATAIN"),
          .IDELAY_TYPE    ("VAR_LOAD"))
    idelay_m(                   
    .DATAOUT      (rx_data_in_md[i]),
    .C            (rxclk_d4),
    .CE           (1'b0),
    .INC          (1'b0),
    .DATAIN       (1'b0),
    .IDATAIN      (rx_data_in_m[i]),
    .LD           (1'b1),
    .LDPIPEEN     (1'b0),
    .REGRST       (1'b0),
    .CINVCTRL     (1'b0),
    .CNTVALUEIN   (m_delay_val_in[5*i+4:5*i]),
    .CNTVALUEOUT  ());
        
ISERDESE2 #(
    .DATA_WIDTH        (4),             
    .DATA_RATE         ("DDR"),         
    .SERDES_MODE       ("MASTER"),         
    .IOBDELAY          ("IFD"),         
    .INTERFACE_TYPE    ("NETWORKING"),
    .NUM_CE            (1))     
    iserdes_m (
    .D               (1'b0),
    .DDLY            (rx_data_in_md[i]),
    .CE1             (1'b1),
    .CE2             (1'b1),
    .CLK             (rxclk),
    .CLKB            (~rxclk),
    .RST             (rst_iserdes),
    .CLKDIV          (rxclk_d4),
    .CLKDIVP         (1'b0),
    .OCLK            (1'b0),
    .OCLKB           (1'b0),
    .DYNCLKSEL       (1'b0),
    .DYNCLKDIVSEL    (1'b0),
    .SHIFTIN1        (1'b0),
    .SHIFTIN2        (1'b0),
    .BITSLIP         (bslip),
    .O               (),
    .Q8              (),
    .Q7              (),
    .Q6              (),
    .Q5              (),
    .Q4              (mdataout[4*i+0]),
    .Q3              (mdataout[4*i+1]),
    .Q2              (mdataout[4*i+2]),
    .Q1              (mdataout[4*i+3]),
    .OFB             (),
    .SHIFTOUT1       (),
    .SHIFTOUT2       ());

IDELAYE2 #(
    .REFCLK_FREQUENCY   (REF_FREQ),
    .HIGH_PERFORMANCE_MODE(HIGH_PERFORMANCE_MODE),
          .IDELAY_VALUE   (0),
          .DELAY_SRC      ("IDATAIN"),
          .IDELAY_TYPE    ("VAR_LOAD"))
    idelay_s(                   
    .DATAOUT      (rx_data_in_sd[i]),
    .C            (rxclk_d4),
    .CE           (1'b0),
    .INC          (1'b0),
    .DATAIN       (1'b0),
    .IDATAIN      (rx_data_in_s[i]),
    .LD           (1'b1),
    .LDPIPEEN     (1'b0),
    .REGRST       (1'b0),
    .CINVCTRL     (1'b0),
    .CNTVALUEIN   (s_delay_val_in[5*i+4:5*i]),
    .CNTVALUEOUT  ());
    
ISERDESE2 #(
    .DATA_WIDTH   (4),             
    .DATA_RATE    ("DDR"),         
    .SERDES_MODE  ("MASTER"),         
    .IOBDELAY     ("IFD"),         
    .INTERFACE_TYPE ("NETWORKING"),
    .NUM_CE       (1))     
    iserdes_s (
    .D            (1'b0),
    .DDLY         (rx_data_in_sd[i]),
    .CE1          (1'b1),
    .CE2          (1'b1),
    .CLK          (rxclk),
    .CLKB         (~rxclk),
    .RST          (rst_iserdes),
    .CLKDIV       (rxclk_d4),
    .CLKDIVP      (1'b0),
    .OCLK         (1'b0),
    .OCLKB        (1'b0),
    .DYNCLKSEL    (1'b0),
    .DYNCLKDIVSEL (1'b0),
    .SHIFTIN1     (1'b0),
    .SHIFTIN2     (1'b0),
    .BITSLIP      (bslip),
    .O            (),
    .Q8           (),
    .Q7           (),
    .Q6           (),
    .Q5           (),
    .Q4           (sdataout[4*i+0]),
    .Q3           (sdataout[4*i+1]),
    .Q2           (sdataout[4*i+2]),
    .Q1           (sdataout[4*i+3]),
    .OFB          (),
    .SHIFTOUT1    (),
    .SHIFTOUT2    ());
    
end
endgenerate

endmodule

//////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2012-2015 Xilinx, Inc.
// This design is confidential and proprietary of Xilinx, All Rights Reserved.
//////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /   Vendor: Xilinx
// \   \   \/    Version: 1.2
//  \   \        Filename: delay_controller_wrap.v
//  /   /        Date Last Modified: 21JAN2015
// /___/   /\    Date Created: 8JAN2013
// \   \  /  \
//  \___\/\___\
// 
//Device: 	7 Series
//Purpose:  	Controls delays on a per-bit basis
//		Number of bits from each seres set via an attribute
//
//Reference:	XAPP585
//    
//Revision History:
//    Rev 1.0 - First created (nicks)
//    Rev 1.2 - Updated format (brandond)
//////////////////////////////////////////////////////////////////////////////

`timescale 1ps/1ps

module delay_controller_wrap (m_datain, s_datain, enable_phase_detector, enable_monitor, reset, clk, c_delay_in, m_delay_out, s_delay_out, data_out, bt_val, results, m_delay_1hot, del_mech) ;

parameter integer 	S = 4 ;   			// Set the number of bits

input		[S-1:0]	m_datain ;			// Inputs from master serdes
input		[S-1:0]	s_datain ;			// Inputs from slave serdes
input		enable_phase_detector ;		// Enables the phase detector logic when high
input		enable_monitor ;		// Enables the eye monitoring logic when high
input		reset ;				// Reset line synchronous to clk 
input		clk ;				// Global/Regional clock 
input		[4:0]	c_delay_in ;			// delay value found on clock line
output		[4:0]	m_delay_out ;			// Master delay control value
output		[4:0]	s_delay_out ;			// Master delay control value
output	reg	[S-1:0]	data_out ;			// Output data
input		[4:0]	bt_val ;			// Calculated bit time value for slave devices
output	reg	[31:0]	results ;			// eye monitor result data	
output	reg	[31:0]	m_delay_1hot ;			// Master delay control value as a one-hot vector	
input		del_mech ;			// changes delay mechanism slightly at higher bit rates

reg	[S-1:0]	mdataouta ;		
reg			mdataoutb ;		
reg	[S-1:0]	mdataoutc ;		
reg	[S-1:0]	sdataouta ;		
reg			sdataoutb ;		
reg	[S-1:0]	sdataoutc ;		
reg			s_ovflw ; 		
reg	[1:0]	m_delay_mux ;				
reg	[1:0]	s_delay_mux ;				
reg			data_mux ;		
reg			dec_run ;			
reg			inc_run ;			
reg			eye_run ;			
reg	[4:0]	s_state ;					
reg	[5:0]	pdcount ;					
reg	[4:0]	m_delay_val_int ;	
reg	[4:0]	s_delay_val_int ;	
reg	[4:0]	s_delay_val_eye ;	
reg			meq_max	;		
reg			meq_min	;		
reg			pd_max	;		
reg			pd_min	;		
reg			delay_change ;		
wire	[S-1:0]	all_high ;		
wire	[S-1:0]	all_low	;		
wire	[7:0]	msxoria	;		
wire	[7:0]	msxorda	;		
reg	[1:0]		action	;		
reg	[1:0]		msxor_cti ;
reg	[1:0]		msxor_ctd ;
reg	[1:0]		msxor_ctix ;
reg	[1:0]		msxor_ctdx ;
wire	[2:0]	msxor_ctiy ;
wire	[2:0]	msxor_ctdy ;
reg	[7:0]		match ;	
reg	[31:0]		shifter ;	
reg	[7:0]		pd_hold ;	
	
assign m_delay_out = m_delay_val_int ;
assign s_delay_out = s_delay_val_int ;
genvar i ;

generate

for (i = 0 ; i <= S-2 ; i = i+1) begin : loop0

assign msxoria[i+1] = ((~s_ovflw & ((mdataouta[i] & ~mdataouta[i+1] & ~sdataouta[i])   | (~mdataouta[i] & mdataouta[i+1] &  sdataouta[i]))) | 
	               ( s_ovflw & ((mdataouta[i] & ~mdataouta[i+1] & ~sdataouta[i+1]) | (~mdataouta[i] & mdataouta[i+1] &  sdataouta[i+1])))) ; // early bits                   
assign msxorda[i+1] = ((~s_ovflw & ((mdataouta[i] & ~mdataouta[i+1] &  sdataouta[i])   | (~mdataouta[i] & mdataouta[i+1] & ~sdataouta[i])))) | 
	               ( s_ovflw & ((mdataouta[i] & ~mdataouta[i+1] &  sdataouta[i+1]) | (~mdataouta[i] & mdataouta[i+1] & ~sdataouta[i+1]))) ;	// late bits
end 
endgenerate

assign msxoria[0] = ((~s_ovflw & ((mdataoutb & ~mdataouta[0] & ~sdataoutb)    | (~mdataoutb & mdataouta[0] &  sdataoutb))) | 			// first early bit
	             ( s_ovflw & ((mdataoutb & ~mdataouta[0] & ~sdataouta[0]) | (~mdataoutb & mdataouta[0] &  sdataouta[0])))) ;
assign msxorda[0] = ((~s_ovflw & ((mdataoutb & ~mdataouta[0] &  sdataoutb)    | (~mdataoutb & mdataouta[0] & ~sdataoutb)))) | 			// first late bit
	             ( s_ovflw & ((mdataoutb & ~mdataouta[0] &  sdataouta[0]) | (~mdataoutb & mdataouta[0] & ~sdataouta[0]))) ;

always @ (posedge clk) begin				// generate number of incs or decs for low 4 bits
	case (msxoria[3:0])
		4'h0    : msxor_cti <= 2'h0 ;
		4'h1    : msxor_cti <= 2'h1 ;
		4'h2    : msxor_cti <= 2'h1 ;
		4'h3    : msxor_cti <= 2'h2 ;
		4'h4    : msxor_cti <= 2'h1 ;
		4'h5    : msxor_cti <= 2'h2 ;
		4'h6    : msxor_cti <= 2'h2 ;
		4'h8    : msxor_cti <= 2'h1 ;
		4'h9    : msxor_cti <= 2'h2 ;
		4'hA    : msxor_cti <= 2'h2 ;
		4'hC    : msxor_cti <= 2'h2 ;
		default : msxor_cti <= 2'h3 ;
	endcase
	case (msxorda[3:0])
		4'h0    : msxor_ctd <= 2'h0 ;
		4'h1    : msxor_ctd <= 2'h1 ;
		4'h2    : msxor_ctd <= 2'h1 ;
		4'h3    : msxor_ctd <= 2'h2 ;
		4'h4    : msxor_ctd <= 2'h1 ;
		4'h5    : msxor_ctd <= 2'h2 ;
		4'h6    : msxor_ctd <= 2'h2 ;
		4'h8    : msxor_ctd <= 2'h1 ;
		4'h9    : msxor_ctd <= 2'h2 ;
		4'hA    : msxor_ctd <= 2'h2 ;
		4'hC    : msxor_ctd <= 2'h2 ;
		default : msxor_ctd <= 2'h3 ;
	endcase
	case (msxoria[7:4])				// generate number of incs or decs for high n bits, max 4
		4'h0    : msxor_ctix <= 2'h0 ;
		4'h1    : msxor_ctix <= 2'h1 ;
		4'h2    : msxor_ctix <= 2'h1 ;
		4'h3    : msxor_ctix <= 2'h2 ;
		4'h4    : msxor_ctix <= 2'h1 ;
		4'h5    : msxor_ctix <= 2'h2 ;
		4'h6    : msxor_ctix <= 2'h2 ;
		4'h8    : msxor_ctix <= 2'h1 ;
		4'h9    : msxor_ctix <= 2'h2 ;
		4'hA    : msxor_ctix <= 2'h2 ;
		4'hC    : msxor_ctix <= 2'h2 ;
		default : msxor_ctix <= 2'h3 ;
	endcase
	case (msxorda[7:4])
		4'h0    : msxor_ctdx <= 2'h0 ;
		4'h1    : msxor_ctdx <= 2'h1 ;
		4'h2    : msxor_ctdx <= 2'h1 ;
		4'h3    : msxor_ctdx <= 2'h2 ;
		4'h4    : msxor_ctdx <= 2'h1 ;
		4'h5    : msxor_ctdx <= 2'h2 ;
		4'h6    : msxor_ctdx <= 2'h2 ;
		4'h8    : msxor_ctdx <= 2'h1 ;
		4'h9    : msxor_ctdx <= 2'h2 ;
		4'hA    : msxor_ctdx <= 2'h2 ;
		4'hC    : msxor_ctdx <= 2'h2 ;
		default : msxor_ctdx <= 2'h3 ;
	endcase
end

assign msxor_ctiy = {1'b0, msxor_cti} + {1'b0, msxor_ctix} ;
assign msxor_ctdy = {1'b0, msxor_ctd} + {1'b0, msxor_ctdx} ;

always @ (posedge clk) begin
	if (msxor_ctiy == msxor_ctdy) begin
		action <= 2'h0 ;
	end
	else if (msxor_ctiy > msxor_ctdy) begin
		action <= 2'h1 ;
	end 
	else begin
		action <= 2'h2 ;
	end
end
		       	       
generate
for (i = 0 ; i <= S-1 ; i = i+1) begin : loop1
assign all_high[i] = 1'b1 ;
assign all_low[i] = 1'b0 ;
end 
endgenerate

always @ (posedge clk) begin
	mdataouta <= m_datain ;
	mdataoutb <= mdataouta[S-1] ;
	sdataouta <= s_datain ;
	sdataoutb <= sdataouta[S-1] ;
end
	
always @ (posedge clk) begin
	if (reset == 1'b1) begin
		s_ovflw <= 1'b0 ;
		pdcount <= 6'b100000 ;
		m_delay_val_int <= c_delay_in ; 			// initial master delay
		s_delay_val_int <= c_delay_in ; 			// initial slave delay
		data_mux <= 1'b0 ;
		m_delay_mux <= 2'b01 ;
		s_delay_mux <= 2'b01 ;
		s_state <= 5'b00000 ;
		inc_run <= 1'b0 ;
		dec_run <= 1'b0 ;
		eye_run <= 1'b0 ;
		s_delay_val_eye <= 5'h00 ;
		shifter <= 32'h00000001 ;
		delay_change <= 1'b0 ;
		results <= 32'h00000000 ;
		pd_hold <= 8'h00 ;
	end
	else begin
		case (m_delay_mux)
			2'b00   : mdataoutc <= {mdataouta[S-2:0], mdataoutb} ;
			2'b10   : mdataoutc <= {m_datain[0],      mdataouta[S-1:1]} ;
			default : mdataoutc <= mdataouta ;
		endcase 
		case (s_delay_mux)  
			2'b00   : sdataoutc <= {sdataouta[S-2:0], sdataoutb} ;
			2'b10   : sdataoutc <= {s_datain[0],      sdataouta[S-1:1]} ;
			default : sdataoutc <= sdataouta ;
		endcase
		if (m_delay_val_int == bt_val) begin
			meq_max <= 1'b1 ;
		end else begin 
			meq_max <= 1'b0 ;
		end 
		if (m_delay_val_int == 5'h00) begin
			meq_min <= 1'b1 ;
		end else begin 
			meq_min <= 1'b0 ;
		end 
		if (pdcount == 6'h3F && pd_max == 1'b0 && delay_change == 1'b0) begin
			pd_max <= 1'b1 ;
		end else begin 
			pd_max <= 1'b0 ;
		end 
		if (pdcount == 6'h00 && pd_min == 1'b0 && delay_change == 1'b0) begin
			pd_min <= 1'b1 ;
		end else begin 
			pd_min <= 1'b0 ;
		end
		if (delay_change == 1'b1 || inc_run == 1'b1 || dec_run == 1'b1 || eye_run == 1'b1) begin
			pd_hold <= 8'hFF ;
			pdcount <= 6'b100000 ; 
		end													// increment filter count
		else if (pd_hold[7] == 1'b1) begin
			pdcount <= 6'b100000 ; 
			pd_hold <= {pd_hold[6:0], 1'b0} ;
		end
		else if (action[0] == 1'b1 && pdcount != 6'b111111) begin 
			pdcount <= pdcount + 6'h01 ; 
		end													// decrement filter count
		else if (action[1] == 1'b1 && pdcount != 6'b000000) begin 
			pdcount <= pdcount - 6'h01 ; 
		end
		if ((enable_phase_detector == 1'b1 && pd_max == 1'b1 && delay_change == 1'b0) || inc_run == 1'b1) begin					// increment delays, check for master delay = max
			delay_change <= 1'b1 ;
			if (meq_max == 1'b0 && inc_run == 1'b0) begin
				m_delay_val_int <= m_delay_val_int + 5'h01 ;
			end 
			else begin											// master is max
				s_state[3:0] <= s_state[3:0] + 4'h1 ;
				case (s_state[3:0]) 
				4'b0000 : begin inc_run <= 1'b1 ; s_delay_val_int <= bt_val ; end			// indicate state machine running and set slave delay to bit time 
				4'b0110 : begin data_mux <= 1'b1 ; m_delay_val_int <= 5'b00000 ; end			// change data mux over to forward slave data and set master delay to zero
				4'b1001 : begin m_delay_mux <= m_delay_mux - 2'h1 ; end 				// change delay mux over to forward with a 1-bit less advance
				4'b1110 : begin data_mux <= 1'b0 ; end 							// change data mux over to forward master data
				4'b1111 : begin s_delay_mux <= m_delay_mux ; inc_run <= 1'b0 ; end			// change delay mux over to forward with a 1-bit less advance
				default : begin inc_run <= 1'b1 ; end
				endcase 
			end
		end
		else if ((enable_phase_detector == 1'b1 && pd_min == 1'b1 && delay_change == 1'b0) || dec_run == 1'b1) begin				// decrement delays, check for master delay = 0
			delay_change <= 1'b1 ;
			if (meq_min == 1'b0 && dec_run == 1'b0) begin
				m_delay_val_int <= m_delay_val_int - 5'h01 ;
			end
			else begin 											// master is zero
				s_state[3:0] <= s_state[3:0] + 4'h1 ;
				case (s_state[3:0]) 
				4'b0000 : begin dec_run <= 1'b1 ; s_delay_val_int <= 5'b00000 ; end			// indicate state machine running and set slave delay to zero 
				4'b0110 : begin data_mux <= 1'b1 ;  m_delay_val_int <= bt_val ;	end			// change data mux over to forward slave data and set master delay to bit time 
				4'b1001 : begin m_delay_mux <= m_delay_mux + 2'h1 ; end  				// change delay mux over to forward with a 1-bit more advance
				4'b1110 : begin data_mux <= 1'b0 ; end 							// change data mux over to forward master data
				4'b1111 : begin s_delay_mux <= m_delay_mux ; dec_run <= 1'b0 ; end			// change delay mux over to forward with a 1-bit less advance
				default : begin dec_run <= 1'b1 ; end
				endcase 
			end
		end
		else if (enable_monitor == 1'b1 && (eye_run == 1'b1 || delay_change == 1'b1)) begin
			delay_change <= 1'b0 ;
			s_state <= s_state + 5'h01 ;
			case (s_state) 
				5'b00000 : begin eye_run <= 1'b1 ; s_delay_val_int <= s_delay_val_eye ; end						// indicate state machine running and set slave delay to monitor value 
				5'b10110 : begin 
				           if (match == 8'hFF) begin results <= results | shifter ; end			//. set or clear result bit
				           else begin results <= results & ~shifter ; end 							 
				           if (s_delay_val_eye == bt_val) begin 					// only monitor active taps, ie as far as btval
				          	shifter <= 32'h00000001 ; s_delay_val_eye <= 5'h00 ; end
				           else begin shifter <= {shifter[30:0], shifter[31]} ; 
				          	s_delay_val_eye <= s_delay_val_eye + 5'h01 ; end			// 
				          	eye_run <= 1'b0 ; s_state <= 5'h00 ; end
				default :  begin eye_run <= 1'b1 ; end
			endcase 
		end
		else begin
			delay_change <= 1'b0 ;
			if (m_delay_val_int >= {1'b0, bt_val[4:1]} &&  del_mech == 1'b0) begin 						// set slave delay to 1/2 bit period beyond or behind the master delay
				s_delay_val_int <= m_delay_val_int - {1'b0, bt_val[4:1]} ;
				s_ovflw <= 1'b0 ;
			end
			else begin
				s_delay_val_int <= m_delay_val_int + {1'b0, bt_val[4:1]} ;
				s_ovflw <= 1'b1 ;
			end 
		end 
		if (enable_phase_detector == 1'b0 && delay_change == 1'b0) begin
			delay_change <= 1'b1 ;
		end
	end
	if (enable_phase_detector == 1'b1) begin
		if (data_mux == 1'b0) begin
			data_out <= mdataoutc ;
		end else begin 
			data_out <= sdataoutc ;
		end
	end
	else begin
		data_out <= m_datain ;	
	end
end

always @ (posedge clk) begin
	if ((mdataouta == sdataouta)) begin
		match <= {match[6:0], 1'b1} ;
	end else begin
		match <= {match[6:0], 1'b0} ;
	end
end

always @ (m_delay_val_int) begin
	case (m_delay_val_int)
	    	5'b00000	: m_delay_1hot <= 32'h00000001 ;
	    	5'b00001	: m_delay_1hot <= 32'h00000002 ;
	    	5'b00010	: m_delay_1hot <= 32'h00000004 ;
	    	5'b00011	: m_delay_1hot <= 32'h00000008 ;
	    	5'b00100	: m_delay_1hot <= 32'h00000010 ;
	    	5'b00101	: m_delay_1hot <= 32'h00000020 ;
	    	5'b00110	: m_delay_1hot <= 32'h00000040 ;
	    	5'b00111	: m_delay_1hot <= 32'h00000080 ;
	    	5'b01000	: m_delay_1hot <= 32'h00000100 ;
	    	5'b01001	: m_delay_1hot <= 32'h00000200 ;
	    	5'b01010	: m_delay_1hot <= 32'h00000400 ;
	    	5'b01011	: m_delay_1hot <= 32'h00000800 ;
	    	5'b01100	: m_delay_1hot <= 32'h00001000 ;
	    	5'b01101	: m_delay_1hot <= 32'h00002000 ;
	    	5'b01110	: m_delay_1hot <= 32'h00004000 ;
	    	5'b01111	: m_delay_1hot <= 32'h00008000 ;
            5'b10000	: m_delay_1hot <= 32'h00010000 ;
            5'b10001	: m_delay_1hot <= 32'h00020000 ;
            5'b10010	: m_delay_1hot <= 32'h00040000 ;
            5'b10011	: m_delay_1hot <= 32'h00080000 ;
            5'b10100	: m_delay_1hot <= 32'h00100000 ;
            5'b10101	: m_delay_1hot <= 32'h00200000 ;
            5'b10110	: m_delay_1hot <= 32'h00400000 ;
            5'b10111	: m_delay_1hot <= 32'h00800000 ;
            5'b11000	: m_delay_1hot <= 32'h01000000 ;
            5'b11001	: m_delay_1hot <= 32'h02000000 ;
            5'b11010	: m_delay_1hot <= 32'h04000000 ;
            5'b11011	: m_delay_1hot <= 32'h08000000 ;
            5'b11100	: m_delay_1hot <= 32'h10000000 ;
            5'b11101	: m_delay_1hot <= 32'h20000000 ;
            5'b11110	: m_delay_1hot <= 32'h40000000 ;
            default		: m_delay_1hot <= 32'h80000000 ; 
         endcase
end
   	
endmodule


//////////////////////////////////////////////////////////////////////////////
//  /   /\/   /
// /___/  \  /   Vendor: Xilinx
// \   \   \/    Version: 1.2
//  \   \        Filename: gearbox_4_to_7.v
//  /   /        Date Last Modified:  21JAN2015
// /___/   /\    Date Created: 5MAR2010
//Device:     7 Series
//Purpose:      multiple 4 to 7 bit gearbox
//Reference:    XAPP585
//Revision History:
//    Rev 1.0 - First created (nicks)
//    Rev 1.1 - reset outputs added
//    Rev 1.2 - Updated format (brandond)
//////////////////////////////////////////////////////////////////////////////
`timescale 1ps/1ps

module gearbox_4_to_7 (input_clock, output_clock, datain, reset, jog, reset_out, dataout) ;

parameter integer  D = 8 ;           // Parameter to set the number of data lines  

input  input_clock ;        // high speed clock input
input  output_clock ;        // low speed clock input
input  [D*4-1:0] datain ;        // data inputs
input  reset ;            // Reset line
input  jog ;            // jog input, slips by 4 bits
output reg [1:0] reset_out ;        // reset out signal
output reg [D*7-1:0]  dataout ;        // data outputs
                    
reg    [3:0] read_addra ;            
reg    [3:0] read_addrb ;            
reg    [3:0] read_addrc ;            
reg    [3:0] write_addr ;            
reg    read_enable ;    
reg    read_enable_dom_ch ;    
wire   [D*4-1:0] ramouta ;             
wire   [D*4-1:0] ramoutb ;            
wire   [D*4-1:0] ramoutc ;            
reg    local_reset ;    
reg    local_reset_dom_ch ;    
reg    [1:0] mux ;        
wire   [D*4-1:0] dummy ;            
reg    jog_int ;    
reg    rst_int ;    

genvar i ;

always @ (posedge input_clock) begin                // generate local sync reset
    if (reset == 1'b1) begin
        local_reset <= 1'b1 ;
        reset_out[0] <= 1'b1 ;
    end else begin
        local_reset <= 1'b0 ;
        reset_out[0] <= 1'b0 ;
    end
end 

always @ (posedge input_clock) begin                // Gearbox input - 4 bit data at input clock frequency
    if (local_reset == 1'b1) begin
        write_addr <= 4'h0 ;
        read_enable <= 1'b0 ;
    end 
    else begin
        if (write_addr == 4'hD) begin
            write_addr <= 4'h0 ;
        end 
        else begin
            write_addr <= write_addr + 4'h1 ;
        end
        if (write_addr == 4'h3) begin
            read_enable <= 1'b1 ;
        end
    end
end

always @ (posedge output_clock) begin    
    read_enable_dom_ch <= read_enable ;
    local_reset_dom_ch <= local_reset ;
end

always @ (posedge output_clock) begin                // Gearbox output - 10 bit data at output clock frequency
    reset_out[1] <= rst_int ;
    if (local_reset_dom_ch == 1'b1 || read_enable_dom_ch == 1'b0) begin
        rst_int <= 1'b1 ; 
    end
    else begin
        rst_int <= 1'b0 ; 
    end
    if (reset_out[1] == 1'b1) begin
        read_addra <= 4'h0 ;
        read_addrb <= 4'h1 ;
        read_addrc <= 4'h2 ;
        jog_int <= 1'b0 ;
    end
    else begin
        case (jog_int)
        1'b0 : begin
            case (read_addra)
            4'h0    : begin read_addra <= 4'h1 ; read_addrb <= 4'h2 ; read_addrc <= 4'h3 ; mux <= 2'h1 ; end
            4'h1    : begin read_addra <= 4'h3 ; read_addrb <= 4'h4 ; read_addrc <= 4'h5 ; mux <= 2'h2 ; end
            4'h3    : begin read_addra <= 4'h5 ; read_addrb <= 4'h6 ; read_addrc <= 4'h7 ; mux <= 2'h3 ; end
            4'h5    : begin read_addra <= 4'h7 ; read_addrb <= 4'h8 ; read_addrc <= 4'h9 ; mux <= 2'h0 ; end
            4'h7    : begin read_addra <= 4'h8 ; read_addrb <= 4'h9 ; read_addrc <= 4'hA ; mux <= 2'h1 ; end
            4'h8    : begin read_addra <= 4'hA ; read_addrb <= 4'hB ; read_addrc <= 4'hC ; mux <= 2'h2 ; end
            4'hA    : begin read_addra <= 4'hC ; read_addrb <= 4'hD ; read_addrc <= 4'hD ; mux <= 2'h3 ; jog_int <= jog ; end
            default : begin read_addra <= 4'h0 ; read_addrb <= 4'h1 ; read_addrc <= 4'h2 ; mux <= 2'h0 ; end
            endcase 
        end
        1'b1 : begin
            case (read_addra)
            4'h1    : begin read_addra <= 4'h2 ; read_addrb <= 4'h3 ; read_addrc <= 4'h4 ; mux <= 2'h1 ; end
            4'h2    : begin read_addra <= 4'h4 ; read_addrb <= 4'h5 ; read_addrc <= 4'h6 ; mux <= 2'h2 ; end
            4'h4    : begin read_addra <= 4'h6 ; read_addrb <= 4'h7 ; read_addrc <= 4'h8 ; mux <= 2'h3 ; end
            4'h6    : begin read_addra <= 4'h8 ; read_addrb <= 4'h9 ; read_addrc <= 4'hA ; mux <= 2'h0 ; end
            4'h8    : begin read_addra <= 4'h9 ; read_addrb <= 4'hA ; read_addrc <= 4'hB ; mux <= 2'h1 ; end
            4'h9    : begin read_addra <= 4'hB ; read_addrb <= 4'hC ; read_addrc <= 4'hD ; mux <= 2'h2 ; end
            4'hB    : begin read_addra <= 4'hD ; read_addrb <= 4'h0 ; read_addrc <= 4'h1 ; mux <= 2'h3 ; jog_int <= jog ; end
            default : begin read_addra <= 4'h1 ; read_addrb <= 4'h2 ; read_addrc <= 4'h3 ; mux <= 2'h0 ; end
            endcase 
        end
        endcase
    end
end

generate for (i = 0 ; i <= D-1 ; i = i+1)
begin : loop0

always @ (posedge output_clock) begin
    case (mux)
    2'h0    : dataout[7*i+6:7*i] <= {                      ramoutb[4*i+2:4*i+0], ramouta[4*i+3:4*i+0]} ;
    2'h1    : dataout[7*i+6:7*i] <= {ramoutc[4*i+1:4*i+0], ramoutb[4*i+3:4*i+0], ramouta[4*i+3]} ;    
    2'h2    : dataout[7*i+6:7*i] <= {ramoutc[4*i+0],       ramoutb[4*i+3:4*i+0], ramouta[4*i+3:4*i+2]} ; 
    default : dataout[7*i+6:7*i] <= {                      ramoutb[4*i+3:4*i+0], ramouta[4*i+3:4*i+1]} ; 
    endcase 
end 
end
endgenerate 
                     
// Data gearboxes
generate
for (i = 0 ; i <= D*2-1 ; i = i+1)
begin : loop2

RAM32M ram_inst ( 
    .DOA    (ramouta[2*i+1:2*i]), 
    .DOB    (ramoutb[2*i+1:2*i]),
    .DOC    (ramoutc[2*i+1:2*i]), 
    .DOD    (dummy[2*i+1:2*i]),
    .ADDRA  ({1'b0, read_addra}), 
    .ADDRB  ({1'b0, read_addrb}), 
    .ADDRC  ({1'b0, read_addrc}), 
    .ADDRD  ({1'b0, write_addr}),
    .DIA    (datain[2*i+1:2*i]), 
    .DIB    (datain[2*i+1:2*i]),
    .DIC    (datain[2*i+1:2*i]),
    .DID    (dummy[2*i+1:2*i]),
    .WE     (1'b1), 
    .WCLK   (input_clock));

end
endgenerate 

endmodule
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
// /___/  \  /   Vendor: Xilinx
// \   \   \/    Version: 1.2
//  \   \        Filename: serdes_1_to_7_slave_idelay_ddr.v
//  /   /        Date Last Modified:  21JAN2015
// /___/   /\    Date Created: 5MAR2010
//Device:     7 Series
//Purpose:      1 to 7 DDR receiver slave data receiver
//        Data formatting is set by the DATA_FORMAT parameter. 
//        PER_CLOCK (default) format receives bits for 0, 1, 2 .. on the same sample edge
//        PER_CHANL format receives bits for 0, 7, 14 ..  on the same sample edge
//Revision History:
//    Rev 1.0 - First created (nicks)
//    Rev 1.1 - PER_CLOCK and PER_CHANL descriptions swapped
//    Rev 1.2 - State machine moved to a new level of hierarchy, eye monitor added, gearbox sync added, updated format
//////////////////////////////////////////////////////////////////////////////
`timescale 1ps/1ps

module serdes_1_to_7_slave_idelay_ddr (clkin_p, clkin_n, datain_p, datain_n, enable_phase_detector, rxclk, idelay_rdy, reset, pixel_clk, enable_monitor,
                                       rxclk_d4, bitslip_finished, clk_data, rx_data, debug, del_mech, bit_time_value, rst_iserdes, gb_rst_in, eye_info, m_delay_1hot,LVDS_CLK_PN_SWAP_I,RX_SWAP_MASK_I) ;

parameter integer D = 8 ;               // Parameter to set the number of data lines
parameter real    REF_FREQ = 200 ;           // Parameter to set reference frequency used by idelay controller (not currently used - functionality to be added)
parameter         HIGH_PERFORMANCE_MODE = "FALSE";// Parameter to set HIGH_PERFORMANCE_MODE of input delays to reduce jitter
parameter         DIFF_TERM = "FALSE" ;         // Parameter to enable internal differential termination
parameter         DATA_FORMAT = "PER_CLOCK" ;     // Parameter Used to determine method for mapping input parallel word to output serial words
//parameter [0:0]  PN_SWAP = 0;

input  [0:0] LVDS_CLK_PN_SWAP_I ;                    
input  clkin_p ;    // Input from LVDS clock receiver pin
input  clkin_n ;    // Input from LVDS clock receiver pin
input  [D-1:0]  datain_p ;            // Input from LVDS clock data pins
input  [D-1:0]  datain_n ;            // Input from LVDS clock data pins
input  enable_phase_detector ;        // Enables the phase detector logic when high
input  enable_monitor ;        // Enable monitoring function
input  reset ;                // Reset line
input  idelay_rdy ;            // input delays are ready
input  rxclk ;                // Global/BUFIO rx clock network
input  pixel_clk ;            // Global/Regional clock input
input  rxclk_d4 ;            // Global/Regional clock input
output bitslip_finished ;         // bitslipping finished
output [6:0]  clk_data ;             // Clock Data
output [D*7-1:0] rx_data ;             // Received Data
output [10*D+5:0]debug ;                 // debug info
input  del_mech ;            // DCD correct cascade from master
input  [4:0] bit_time_value ;        // Calculated bit time value from 'master'
input  rst_iserdes ;            // reset serdes input
input  [1:0] gb_rst_in ;            // gearbox reset signal in
output [D*32-1:0] eye_info ;             // eye info
output [32*D-1:0] m_delay_1hot ;            // Master delay control value as a one-hot vector
input [D-1:0] RX_SWAP_MASK_I ;    // pinswap mask for input data bits (0 = no swap (default), 1 = swap). Allows inputs to be connected the wrong way round to ease PCB routing.



wire   [D*5-1:0] m_delay_val_in ;
wire   [D*5-1:0] s_delay_val_in ;
wire   [3:0] cdataout ;            
reg    [3:0] cdataouta ;            
reg    [3:0] cdataoutb ;            
reg    [3:0] cdataoutc ;            
wire   rx_clk_in ;     
wire  rx_clk_in_ob;       
reg    [1:0] bsstate ;                     
reg    bslip ;                     
reg    bslipreq ;                     
reg    bslipr_dom_ch ;                     
reg    [3:0] bcount ;                     
reg    [6*D-1:0] pdcount ;                     
wire   [6:0] clk_iserdes_data ;          
reg    [6:0] clk_iserdes_data_d ;        
reg    enable ;                    
reg    flag1 ;                     
reg    flag2 ;                     
reg    [1:0] state2 ;            
reg    [3:0] state2_count ;            
reg    [5:0] scount ;            
reg    locked_out ;    
reg    locked_out_dom_ch ;    
reg    chfound ;    
reg    chfoundc ;
wire   DLY_READY_I ;
reg    [4:0] c_delay_in ;
reg    local_reset_dom_ch ;
wire   [D-1:0]  rx_data_in_p ;            
wire   [D-1:0]  rx_data_in_n ;  

wire   [D-1:0]  DIFF_data_O ;            
wire   [D-1:0]  DIFF_data_OB ;  
          
wire   [D-1:0]  rx_data_in_m ;            
wire   [D-1:0]  rx_data_in_s ;        
wire   [D-1:0]  rx_data_in_md ;            
wire   [D-1:0]  rx_data_in_sd ;    
wire   [(4*D)-1:0] mdataout ;                        
wire   [(4*D)-1:0] mdataoutd ;            
wire   [(4*D)-1:0] sdataout ;                        
wire   [(7*D)-1:0] dataout ;                                      
reg    jog ;        
wire   [(D*6)-1:0] ramouta ;            
wire   [(D*6)-1:0] ramoutb ;            
reg    [2:0] slip_count ;                    
reg    bslip_ack_dom_ch ;        
reg    bslip_ack ;        
reg    [1:0] bstate ;
reg    data_different ;
reg    data_different_dom_ch ;
reg     [D-1:0] s_ovflw ;        
reg     [D-1:0] s_hold ;        
reg    bs_finished ;
reg    not_bs_finished_dom_ch ;
wire    [4:0] bt_val ;  
reg    retry ;
reg    no_clock ;
reg    no_clock_dom_ch ;
reg    [1:0] c_loop_cnt ;  


assign clk_data = clk_iserdes_data ;
assign debug = {s_delay_val_in, m_delay_val_in, bslip, c_delay_in} ;

assign bitslip_finished = bs_finished & ~reset ;
assign bt_val = bit_time_value ;

always @ (posedge rxclk_d4 or posedge reset or posedge retry) begin            // generate local async assert, sync release reset
if (reset == 1'b1 || retry == 1'b1) begin
    local_reset_dom_ch <= 1'b1 ;
end
else begin
    if (idelay_rdy == 1'b0) begin
        local_reset_dom_ch <= 1'b1 ;
    end
    else begin
        local_reset_dom_ch <= 1'b0 ;
    end
end
end

// Bitslip state machine, split over two clock domains
always @ (posedge pixel_clk)
begin
locked_out_dom_ch <= locked_out ;
if (locked_out_dom_ch == 1'b0) begin
    bsstate <= 2 ;
    enable <= 1'b0 ;
    bslipreq <= 1'b0 ;
    bcount <= 4'h0 ;
    jog <= 1'b0 ;
    slip_count <= 3'h0 ;
    bs_finished <= 1'b0 ;
    retry <= 1'b0 ;
end
else begin
       bslip_ack_dom_ch <= bslip_ack ;
    enable <= 1'b1 ;
       if (enable == 1'b1) begin
          
           //ori
           //if (clk_iserdes_data != 7'b1100001) begin flag1 <= 1'b1 ; end else begin flag1 <= 1'b0 ; end
           //if (clk_iserdes_data != 7'b1100011) begin flag2 <= 1'b1 ; end else begin flag2 <= 1'b0 ; end
           
           
           if (clk_iserdes_data != (LVDS_CLK_PN_SWAP_I ? 7'b0011110 : 7'b1100001) ) begin flag1 <= 1'b1 ; end else begin flag1 <= 1'b0 ; end
           if (clk_iserdes_data != (LVDS_CLK_PN_SWAP_I ? 7'b0011100 : 7'b1100011) ) begin flag2 <= 1'b1 ; end else begin flag2 <= 1'b0 ; end
           
           
           if (bsstate == 0) begin
               if (flag1 == 1'b1 && flag2 == 1'b1) begin
                    bslipreq <= 1'b1 ;                    // bitslip needed
                    bsstate <= 1 ;
               end
               else begin
                    bs_finished <= 1'b1 ;                    // bitslip done
               end
           end
           else if (bsstate == 1) begin                        // wait for bitslip ack from other clock domain
                if (bslip_ack_dom_ch == 1'b1) begin
                    bslipreq <= 1'b0 ;                    // bitslip low
                    bcount <= 4'h0 ;
                    slip_count <= slip_count + 3'h1 ;
                    bsstate <= 2 ;
                end
           end
           else if (bsstate == 2) begin                
                bcount <= bcount + 4'h1 ;
                if (bcount == 4'hF) begin
                    if (slip_count == 3'h5) begin
                        jog <= ~jog ;
                        if (jog == 1'b1) begin
                            retry <= 1'b1 ;
                        end
                    end
                    bsstate <= 0 ;
                end
           end
       end
    end
end

always @ (posedge rxclk_d4)
begin
    not_bs_finished_dom_ch <= ~bs_finished ;
    bslipr_dom_ch <= bslipreq ;
    if (locked_out == 1'b0) begin
        bslip <= 1'b0 ;
        bslip_ack <= 1'b0 ;
        bstate <= 0 ;    
    end    
    else if (bstate == 0 && bslipr_dom_ch == 1'b1) begin
        bslip <= 1'b1 ;
        bslip_ack <= 1'b1 ;
        bstate <= 1 ;
    end
    else if (bstate == 1) begin
        bslip <= 1'b0 ;
        bslip_ack <= 1'b1 ;
        bstate <= 2 ;
    end
    else if (bstate == 2 && bslipr_dom_ch == 1'b0) begin
        bslip_ack <= 1'b0 ;
        bstate <= 0 ;
    end        
end

// Clock input 

//yzhu
//IBUFGDS #(
//    .DIFF_TERM         (DIFF_TERM),
//    .IBUF_LOW_PWR        ("FALSE")) 
//iob_clk_in (
//    .I                (clkin_p),
//    .IB               (clkin_n),
//    .O                (rx_clk_in));

IBUFGDS_DIFF_OUT #(
    .DIFF_TERM        (DIFF_TERM), 
    .IBUF_LOW_PWR     ("FALSE"))
    iob_clk_in (
    .I                (clkin_p),
    .IB               (clkin_n) ,
    .O                ( rx_clk_in  ),
    .OB               ( rx_clk_in_ob ));
  

genvar i ;
genvar j ;

IDELAYE2 #(
    .REFCLK_FREQUENCY    (REF_FREQ),
    .HIGH_PERFORMANCE_MODE     (HIGH_PERFORMANCE_MODE),
          .IDELAY_VALUE        (1),
          .DELAY_SRC        ("IDATAIN"),
          .IDELAY_TYPE        ("VAR_LOAD"))
    idelay_cm(                   
    .DATAOUT      (rx_clk_in_d),
    .C            (rxclk_d4),
    .CE           (1'b0),
    .INC          (1'b0),
    .DATAIN       (1'b0),
    //.IDATAIN      (PN_SWAP==0 ? rx_clk_in : rx_clk_in_ob ),
    .IDATAIN      (rx_clk_in  ),
    .LD           (1'b1),
    .LDPIPEEN     (1'b0),
    .REGRST       (1'b0),
    .CINVCTRL     (1'b0),
    .CNTVALUEIN   (c_delay_in),
    .CNTVALUEOUT  ());
    
ISERDESE2 #(
    .DATA_WIDTH     (4),                 
    .DATA_RATE      ("DDR"),             
    .SERDES_MODE    ("MASTER"),             
    .IOBDELAY       ("IFD"),             
    .INTERFACE_TYPE ("NETWORKING"))         
    iserdes_cm (
    .D             (1'b0),
    .DDLY          (rx_clk_in_d),
    .CE1           (1'b1),
    .CE2           (1'b1),
    .CLK           (rxclk),
    .CLKB          (~rxclk),
    .RST           (local_reset_dom_ch),
    .CLKDIV        (rxclk_d4),
    .CLKDIVP       (1'b0),
    .OCLK          (1'b0),
    .OCLKB         (1'b0),
    .DYNCLKSEL     (1'b0),
    .DYNCLKDIVSEL  (1'b0),
    .SHIFTIN1      (1'b0),
    .SHIFTIN2      (1'b0),
    .BITSLIP       (bslip),
    .O          (),
    .Q8         (),
    .Q7         (),
    .Q6         (),
    .Q5         (),
    .Q4         (cdataout[0]),
    .Q3         (cdataout[1]),
    .Q2         (cdataout[2]),
    .Q1         (cdataout[3]),
    .OFB        (),
    .SHIFTOUT1  (),
    .SHIFTOUT2  ());    

always @ (posedge pixel_clk) begin                            // retiming
    clk_iserdes_data_d <= clk_iserdes_data ;
    if ((clk_iserdes_data != clk_iserdes_data_d) && (clk_iserdes_data != 7'h00) && (clk_iserdes_data != 7'h7F)) begin
        data_different <= 1'b1 ;
    end
    else begin
        data_different <= 1'b0 ;
    end
    if ((clk_iserdes_data == 7'h00) || (clk_iserdes_data == 7'h7F)) begin
        no_clock <= 1'b1 ;
    end
    else begin
        no_clock <= 1'b0 ;
    end
end
    
always @ (posedge rxclk_d4) begin                        // clock delay shift state machine
    if (local_reset_dom_ch == 1'b1) begin
        scount <= 6'h00 ;
        state2 <= 0 ;
        state2_count <= 4'h0 ;
        locked_out <= 1'b0 ;
        chfoundc <= 1'b1 ;
        c_delay_in <= bt_val ;                        // Start the delay line at the current bit period
        c_loop_cnt <= 2'b00 ;    
    end
    else begin
        if (scount[5] == 1'b0) begin
            if (no_clock_dom_ch == 1'b0) begin
                scount <= scount + 6'h01 ;
            end
            else begin
                scount <= 6'h00 ;
            end
        end
        state2_count <= state2_count + 4'h1 ;
        data_different_dom_ch <= data_different ;
        no_clock_dom_ch <= no_clock ;
        if (chfoundc == 1'b1) begin
            chfound <= 1'b0 ;
        end
        else if (chfound == 1'b0 && data_different_dom_ch == 1'b1) begin
            chfound <= 1'b1 ;
        end
        if ((state2_count == 4'hF && scount[5] == 1'b1)) begin
            case(state2)                     
            0    : begin                            // decrement delay and look for a change
                  if (chfound == 1'b1 || (c_loop_cnt == 2'b11 && c_delay_in == 5'h00)) begin  // quit loop if we've been around a few times
                    chfoundc <= 1'b1 ;                // change found
                    state2 <= 1 ;
                  end
                  else begin
                    chfoundc <= 1'b0 ;
                    if (c_delay_in != 5'h00) begin            // check for underflow
                        c_delay_in <= c_delay_in - 5'h01 ;
                    end
                    else begin
                        c_delay_in <= bt_val ;
                        c_loop_cnt <= c_loop_cnt + 2'b01 ;
                    end
                  end
                  end
            1    : begin                            // add half a bit period using input information
                  state2 <= 2 ;
                  if (c_delay_in < {1'b0, bt_val[4:1]}) begin        // choose the lowest delay value to minimise jitter
                       c_delay_in <= c_delay_in + {1'b0, bt_val[4:1]} ;
                  end
                  else begin
                       c_delay_in <= c_delay_in - {1'b0, bt_val[4:1]} ;
                  end
                  end
            default    : begin                            // issue locked out signal
                  locked_out <= 1'b1 ;
                   end
            endcase
        end
    end
end
    
generate for (i = 0 ; i <= D-1 ; i = i+1)
begin : loop3
delay_controller_wrap
 # (.S (4))
    dc_inst (                       
    .m_datain        (mdataout[4*i+3:4*i]),
    .s_datain        (sdataout[4*i+3:4*i]),
    .enable_phase_detector (enable_phase_detector),
    .enable_monitor        (enable_monitor),
    .reset          (not_bs_finished_dom_ch),
    .clk            (rxclk_d4),
    .c_delay_in     (c_delay_in),
    .m_delay_out    (m_delay_val_in[5*i+4:5*i]),
    .s_delay_out    (s_delay_val_in[5*i+4:5*i]),
    .data_out       (mdataoutd[4*i+3:4*i]),
    .bt_val         (bt_val),
    .del_mech       (del_mech), 
    .results        (eye_info[32*i+31:32*i]),
    .m_delay_1hot   (m_delay_1hot[32*i+31:32*i])) ;
end
endgenerate 

always @ (posedge rxclk_d4) begin                            // clock balancing
    if (enable_phase_detector == 1'b1) begin
        cdataouta[3:0] <= cdataout[3:0] ;
        cdataoutb[3:0] <= cdataouta[3:0] ;
        cdataoutc[3:0] <= cdataoutb[3:0] ;
    end
    else begin
        cdataoutc[3:0] <= cdataout[3:0] ;
    end
end

// Data gearbox (includes clock data)

gearbox_4_to_7_slave # (
    .D             (D+1))         
gb0 (                           
    .input_clock    (rxclk_d4),
    .output_clock   (pixel_clk),
    .datain         ({cdataoutc, mdataoutd}),
    .reset          (gb_rst_in),
    .jog            (jog),
    .dataout        ({clk_iserdes_data, dataout})) ;
    
// Data bit Receivers 

generate for (i = 0 ; i <= D-1 ; i = i+1) begin : loop0
for (j = 0 ; j <= 6 ; j = j+1) begin : loop1            // Assign data bits to correct serdes according to required format
    if (DATA_FORMAT == "PER_CLOCK") begin
        assign rx_data[D*j+i] = dataout[7*i+j] ;
    end 
    else begin
        assign rx_data[7*i+j] = dataout[7*i+j] ;
    end
end

IBUFDS_DIFF_OUT #(
    .DIFF_TERM    (DIFF_TERM), 
    .IBUF_LOW_PWR ("FALSE")) 
data_in (
    .I             (datain_p[i]),
    .IB            (datain_n[i]),
    .O             (DIFF_data_O[i]  ),
    .OB            (DIFF_data_OB[i] ) );

//assign DIFF_data_O[i]  = PN_SWAP==0 ? rx_data_in_p[i] : rx_data_in_n[i] ;
//assign DIFF_data_OB[i] = PN_SWAP==0 ? rx_data_in_n[i] : rx_data_in_p[i] ;
assign DIFF_data_O[i]  = rx_data_in_p[i]  ;
assign DIFF_data_OB[i] = rx_data_in_n[i]  ;



assign rx_data_in_m[i] =  (DIFF_data_O[i])  ^ RX_SWAP_MASK_I[i] ;
assign rx_data_in_s[i] =  (~DIFF_data_OB[i]) ^ RX_SWAP_MASK_I[i] ;

IDELAYE2 #(
    .REFCLK_FREQUENCY      (REF_FREQ),
    .HIGH_PERFORMANCE_MODE (HIGH_PERFORMANCE_MODE),
          .IDELAY_VALUE    (0),
          .DELAY_SRC       ("IDATAIN"),
          .IDELAY_TYPE     ("VAR_LOAD"))
    idelay_m(                   
    .DATAOUT      (rx_data_in_md[i]),
    .C            (rxclk_d4),
    .CE           (1'b0),
    .INC          (1'b0),
    .DATAIN       (1'b0),
    .IDATAIN      (rx_data_in_m[i]),
    .LD           (1'b1),
    .LDPIPEEN     (1'b0),
    .REGRST       (1'b0),
    .CINVCTRL     (1'b0),
    .CNTVALUEIN   (m_delay_val_in[5*i+4:5*i]),
    .CNTVALUEOUT  ());
        
ISERDESE2 #(
    .DATA_WIDTH     (4),             
    .DATA_RATE      ("DDR"),         
    .SERDES_MODE    ("MASTER"),         
    .IOBDELAY       ("IFD"),         
    .INTERFACE_TYPE ("NETWORKING"))     
    iserdes_m (
    .D               (1'b0),
    .DDLY            (rx_data_in_md[i]),
    .CE1             (1'b1),
    .CE2             (1'b1),
    .CLK             (rxclk),
    .CLKB            (~rxclk),
    .RST             (rst_iserdes),
    .CLKDIV          (rxclk_d4),
    .CLKDIVP         (1'b0),
    .OCLK            (1'b0),
    .OCLKB           (1'b0),
    .DYNCLKSEL       (1'b0),
    .DYNCLKDIVSEL    (1'b0),
    .SHIFTIN1        (1'b0),
    .SHIFTIN2        (1'b0),
    .BITSLIP         (bslip),
    .O               (),
    .Q8              (),
    .Q7              (),
    .Q6              (),
    .Q5              (),
    .Q4              (mdataout[4*i+0]),
    .Q3              (mdataout[4*i+1]),
    .Q2              (mdataout[4*i+2]),
    .Q1              (mdataout[4*i+3]),
    .OFB             (),
    .SHIFTOUT1       (),
    .SHIFTOUT2       ());

IDELAYE2 #(
    .REFCLK_FREQUENCY      (REF_FREQ),
    .HIGH_PERFORMANCE_MODE (HIGH_PERFORMANCE_MODE),
          .IDELAY_VALUE    (0),
          .DELAY_SRC       ("IDATAIN"),
          .IDELAY_TYPE     ("VAR_LOAD"))
    idelay_s(                   
    .DATAOUT      (rx_data_in_sd[i]),
    .C            (rxclk_d4),
    .CE           (1'b0),
    .INC          (1'b0),
    .DATAIN       (1'b0),
    .IDATAIN      (rx_data_in_s[i]),
    .LD           (1'b1),
    .LDPIPEEN     (1'b0),
    .REGRST       (1'b0),
    .CINVCTRL     (1'b0),
    .CNTVALUEIN   (s_delay_val_in[5*i+4:5*i]),
    .CNTVALUEOUT  ());
    
ISERDESE2 #(
    .DATA_WIDTH      (4),             
    .DATA_RATE       ("DDR"),         
//    .SERDES_MODE   ("SLAVE"),         
    .IOBDELAY        ("IFD"),         
    .INTERFACE_TYPE  ("NETWORKING"))     
    iserdes_s (
    .D               (1'b0),
    .DDLY            (rx_data_in_sd[i]),
    .CE1             (1'b1),
    .CE2             (1'b1),
    .CLK             (rxclk),
    .CLKB            (~rxclk),
    .RST             (rst_iserdes),
    .CLKDIV          (rxclk_d4),
    .CLKDIVP         (1'b0),
    .OCLK            (1'b0),
    .OCLKB           (1'b0),
    .DYNCLKSEL       (1'b0),
    .DYNCLKDIVSEL    (1'b0),
    .SHIFTIN1        (1'b0),
    .SHIFTIN2        (1'b0),
    .BITSLIP         (bslip),
    .O               (),
    .Q8              (),
    .Q7              (),
    .Q6              (),
    .Q5              (),
    .Q4              (sdataout[4*i+0]),
    .Q3              (sdataout[4*i+1]),
    .Q2              (sdataout[4*i+2]),
    .Q1              (sdataout[4*i+3]),
    .OFB             (),
    .SHIFTOUT1       (),
    .SHIFTOUT2       ());  
end
endgenerate


endmodule

//////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2012-2015 Xilinx, Inc.
// This design is confidential and proprietary of Xilinx, All Rights Reserved.
//////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /   Vendor: Xilinx
// \   \   \/    Version: 1.2
//  \   \        Filename: gearbox_4_to_7_slave.v
//  /   /        Date Last Modified:  21JAN2015
// /___/   /\    Date Created: 30SEP2010
// \   \  /  \
//  \___\/\___\
// 
//Device: 	7 Series
//Purpose:  	multiple 4 to 7 bit gearbox
//
//Reference:	XAPP585
//    
//Revision History:
//    Rev 1.0 - First created (nicks)
//    Rev 1.2 - Updated format (brandond)
//////////////////////////////////////////////////////////////////////////////
`timescale 1ps/1ps
module gearbox_4_to_7_slave (input_clock, output_clock, datain, reset, jog, dataout) ;

parameter integer 		D = 8 ;   		// Parameter to set the number of data lines  

input				input_clock ;		// high speed clock input
input				output_clock ;		// low speed clock input
input		[D*4-1:0]	datain ;		// data inputs
input		[1:0]		reset ;			// Reset line
input				jog ;			// jog input, slips by 4 bits
output	reg	[D*7-1:0]	dataout ;		// data outputs
					
reg	[3:0]		read_addra ;			
reg	[3:0]		read_addrb ;			
reg	[3:0]		read_addrc ;			
reg	[3:0]		write_addr ;			
wire	[D*4-1:0]	ramouta ; 			
wire	[D*4-1:0]	ramoutb ;			
wire	[D*4-1:0]	ramoutc ;			
reg	[1:0]		mux ;		
wire	[D*4-1:0]	dummy ;			
reg			jog_int ;	

genvar i ;

always @ (posedge input_clock) begin				// Gearbox input - 4 bit data at input clock frequency
	if (reset[0] == 1'b1) begin
		write_addr <= 4'h0 ;
	end 
	else begin
		if (write_addr == 4'hD) begin
			write_addr <= 4'h0 ;
		end 
		else begin
			write_addr <= write_addr + 4'h1 ;
		end
	end
end

always @ (posedge output_clock) begin				// Gearbox output - 10 bit data at output clock frequency
	if (reset[1] == 1'b1) begin
		read_addra <= 4'h0 ;
		read_addrb <= 4'h1 ;
		read_addrc <= 4'h2 ;
		jog_int <= 1'b0 ;
	end
	else begin
		case (jog_int)
		1'b0 : begin
			case (read_addra)
			4'h0    : begin read_addra <= 4'h1 ; read_addrb <= 4'h2 ; read_addrc <= 4'h3 ; mux <= 2'h1 ; end
			4'h1    : begin read_addra <= 4'h3 ; read_addrb <= 4'h4 ; read_addrc <= 4'h5 ; mux <= 2'h2 ; end
			4'h3    : begin read_addra <= 4'h5 ; read_addrb <= 4'h6 ; read_addrc <= 4'h7 ; mux <= 2'h3 ; end
			4'h5    : begin read_addra <= 4'h7 ; read_addrb <= 4'h8 ; read_addrc <= 4'h9 ; mux <= 2'h0 ; end
			4'h7    : begin read_addra <= 4'h8 ; read_addrb <= 4'h9 ; read_addrc <= 4'hA ; mux <= 2'h1 ; end
			4'h8    : begin read_addra <= 4'hA ; read_addrb <= 4'hB ; read_addrc <= 4'hC ; mux <= 2'h2 ; end
			4'hA    : begin read_addra <= 4'hC ; read_addrb <= 4'hD ; read_addrc <= 4'hD ; mux <= 2'h3 ; jog_int <= jog ; end
			default : begin read_addra <= 4'h0 ; read_addrb <= 4'h1 ; read_addrc <= 4'h2 ; mux <= 2'h0 ; end
			endcase 
		end
		1'b1 : begin
			case (read_addra)
			4'h1    : begin read_addra <= 4'h2 ; read_addrb <= 4'h3 ; read_addrc <= 4'h4 ; mux <= 2'h1 ; end
			4'h2    : begin read_addra <= 4'h4 ; read_addrb <= 4'h5 ; read_addrc <= 4'h6 ; mux <= 2'h2 ; end
			4'h4    : begin read_addra <= 4'h6 ; read_addrb <= 4'h7 ; read_addrc <= 4'h8 ; mux <= 2'h3 ; end
			4'h6    : begin read_addra <= 4'h8 ; read_addrb <= 4'h9 ; read_addrc <= 4'hA ; mux <= 2'h0 ; end
			4'h8    : begin read_addra <= 4'h9 ; read_addrb <= 4'hA ; read_addrc <= 4'hB ; mux <= 2'h1 ; end
			4'h9    : begin read_addra <= 4'hB ; read_addrb <= 4'hC ; read_addrc <= 4'hD ; mux <= 2'h2 ; end
			4'hB    : begin read_addra <= 4'hD ; read_addrb <= 4'h0 ; read_addrc <= 4'h1 ; mux <= 2'h3 ; jog_int <= jog ; end
			default : begin read_addra <= 4'h1 ; read_addrb <= 4'h2 ; read_addrc <= 4'h3 ; mux <= 2'h0 ; end
			endcase 
		end
		endcase
	end
end

generate for (i = 0 ; i <= D-1 ; i = i+1) begin : loop0
always @ (posedge output_clock) begin
	case (mux)
	2'h0    : dataout[7*i+6:7*i] <= {                      ramoutb[4*i+2:4*i+0], ramouta[4*i+3:4*i+0]} ;
	2'h1    : dataout[7*i+6:7*i] <= {ramoutc[4*i+1:4*i+0], ramoutb[4*i+3:4*i+0], ramouta[4*i+3]} ;    
	2'h2    : dataout[7*i+6:7*i] <= {ramoutc[4*i+0],       ramoutb[4*i+3:4*i+0], ramouta[4*i+3:4*i+2]} ; 
	default : dataout[7*i+6:7*i] <= {                      ramoutb[4*i+3:4*i+0], ramouta[4*i+3:4*i+1]} ; 
	endcase 
end 
end
endgenerate 
			     	
// Data gearboxes

generate for (i = 0 ; i <= D*2-1 ; i = i+1) begin : loop2

RAM32M ram_inst ( 
	.DOA	(ramouta[2*i+1:2*i]), 
	.DOB	(ramoutb[2*i+1:2*i]),
	.DOC    (ramoutc[2*i+1:2*i]), 
	.DOD    (dummy[2*i+1:2*i]),
	.ADDRA	({1'b0, read_addra}), 
	.ADDRB	({1'b0, read_addrb}), 
	.ADDRC  ({1'b0, read_addrc}), 
	.ADDRD  ({1'b0, write_addr}),
	.DIA	(datain[2*i+1:2*i]), 
	.DIB	(datain[2*i+1:2*i]),
	.DIC    (datain[2*i+1:2*i]),
	.DID    (dummy[2*i+1:2*i]),
	.WE 	(1'b1), 
	.WCLK	(input_clock));
end
endgenerate 


endmodule



//////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2012-2015 Xilinx, Inc.
// This design is confidential and proprietary of Xilinx, All Rights Reserved.
//////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /   Vendor: Xilinx
// \   \   \/    Version: 1.2
//  \   \        Filename: n_x_serdes_1_to_7_mmcm_idelay_sdr.v
//  /   /        Date Last Modified:  21JAN2015
// /___/   /\    Date Created: 5MAR2010
// \   \  /  \
//  \___\/\___\
// 
//Device: 	7 Series
//Purpose:  	Wrapper for multiple 1 to 7 SDR clock and data receiver using one PLL/MMCM for clock multiplication
//
//Reference:	XAPP585
//    
//Revision History:
//    Rev 1.0 - First created (nicks)
//    Rev 1.1 - Generate loop changed to correct problem when only one channel
//    Rev 1.2 - Eye monitoring added, upated format
//
//////////////////////////////////////////////////////////////////////////////
//
//  Disclaimer: 
//
//		This disclaimer is not a license and does not grant any rights to the materials 
//              distributed herewith. Except as otherwise provided in a valid license issued to you 
//              by Xilinx, and to the maximum extent permitted by applicable law: 
//              (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND WITH ALL FAULTS, 
//              AND XILINX HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, 
//              INCLUDING BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-INFRINGEMENT, OR 
//              FITNESS FOR ANY PARTICULAR PURPOSE; and (2) Xilinx shall not be liable (whether in contract 
//              or tort, including negligence, or under any other theory of liability) for any loss or damage 
//              of any kind or nature related to, arising under or in connection with these materials, 
//              including for any direct, or any indirect, special, incidental, or consequential loss 
//              or damage (including loss of data, profits, goodwill, or any type of loss or damage suffered 
//              as a result of any action brought by a third party) even if such damage or loss was 
//              reasonably foreseeable or Xilinx had been advised of the possibility of the same.
//
//  Critical Applications:
//
//		Xilinx products are not designed or intended to be fail-safe, or for use in any application 
//		requiring fail-safe performance, such as life-support or safety devices or systems, 
//		Class III medical devices, nuclear facilities, applications related to the deployment of airbags,
//		or any other applications that could lead to death, personal injury, or severe property or 
//		environmental damage (individually and collectively, "Critical Applications"). Customer assumes 
//		the sole risk and liability of any use of Xilinx products in Critical Applications, subject only 
//		to applicable laws and regulations governing limitations on product liability.
//
//  THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS PART OF THIS FILE AT ALL TIMES.
//
//////////////////////////////////////////////////////////////////////////////

`timescale 1ps/1ps

module n_x_serdes_1_to_7_mmcm_idelay_sdr (clkin_p, clkin_n, datain_p, datain_n, enable_phase_detector, enable_monitor, rxclk, idelay_rdy, reset, rxclk_div, 
                                          rx_mmcm_lckdps, rx_mmcm_lckd, rx_mmcm_lckdpsbs, mmcm_locked, clk_data, rx_data, status, debug, bit_rate_value, bit_time_value, eye_info, m_delay_1hot) ;

parameter integer 	N = 8 ;				// Set the number of channels
parameter integer 	D = 6 ;   			// Parameter to set the number of data lines per channel
parameter integer      	MMCM_MODE = 1 ;   		// Parameter to set multiplier for MMCM to get VCO in correct operating range. 1 multiplies input clock by 7, 2 multiplies clock by 14, etc
parameter real 	  	CLKIN_PERIOD = 6.000 ;		// clock period (ns) of input clock on clkin_p
parameter 		HIGH_PERFORMANCE_MODE = "FALSE";// Parameter to set HIGH_PERFORMANCE_MODE of input delays to reduce jitter
parameter         	DIFF_TERM = "FALSE" ; 		// Parameter to enable internal differential termination
parameter         	SAMPL_CLOCK = "BUFIO" ;   	// Parameter to set sampling clock buffer type, BUFIO, BUF_H, BUF_G
parameter         	PIXEL_CLOCK = "BUF_R" ;       	// Parameter to set pixel clock buffer type, BUF_R, BUF_H, BUF_G
parameter         	USE_PLL = "FALSE" ;          	// Parameter to enable PLL use rather than MMCM use, overides SAMPL_CLOCK and INTER_CLOCK to be both BUFH
parameter         	DATA_FORMAT = "PER_CLOCK" ;     // Parameter Used to determine method for mapping input parallel word to output serial words
parameter  real  REF_FREQ = 200 ; 

                      
input 	[N-1:0]		clkin_p ;			// Input from LVDS clock receiver pin
input 	[N-1:0]		clkin_n ;			// Input from LVDS clock receiver pin
input 	[N*D-1:0]	datain_p ;			// Input from LVDS clock data pins
input 	[N*D-1:0]	datain_n ;			// Input from LVDS clock data pins
input 			enable_phase_detector ;		// Enables the phase detector logic when high
input			enable_monitor ;		// Enables the monitor logic when high, note time-shared with phase detector function
input 			reset ;				// Reset line
input			idelay_rdy ;			// input delays are ready
output 			rxclk ;				// Global/BUFIO rx clock network
output 			rxclk_div ;			// Global/Regional clock output
output 			rx_mmcm_lckd ; 			// MMCM locked, synchronous to rxclk_d4
output 			rx_mmcm_lckdps ; 		// MMCM locked and phase shifting finished, synchronous to rxclk_d4
output 	[N-1:0]		rx_mmcm_lckdpsbs ; 		// MMCM locked and phase shifting finished and bitslipping finished, synchronous to rxclk_div
output 	[N*7-1:0]	clk_data ;	 		// Clock Data
output 	[N*D*7-1:0]	rx_data ;	 		// Received Data
output 	[(10*D+6)*N-1:0]debug ;	 			// debug info
output 	[6:0]		status ;	 		// clock status
input 	[15:0]		bit_rate_value ;	 	// Bit rate in Mbps, for example 16'h0585
output	[4:0]		bit_time_value ;		// Calculated bit time value for slave devices
output	[32*D*N-1:0]	eye_info ;			// Eye info
output	[32*D*N-1:0]	m_delay_1hot ;			// Master delay control value as a one-hot vector
output  mmcm_locked ;



wire			rxclk_d4 ;
wire			pd ;

serdes_1_to_7_mmcm_idelay_sdr #(
	.SAMPL_CLOCK		(SAMPL_CLOCK),
	.PIXEL_CLOCK		(PIXEL_CLOCK),
	.USE_PLL		(USE_PLL),
	.HIGH_PERFORMANCE_MODE	(HIGH_PERFORMANCE_MODE),
      	.D			(D),				// Number of data lines
      	.CLKIN_PERIOD		(CLKIN_PERIOD),			// Set input clock period
      	.MMCM_MODE		(MMCM_MODE),			// Set mmcm vco, either 1 or 2
	.DIFF_TERM		(DIFF_TERM),
	.DATA_FORMAT		(DATA_FORMAT),
    .REF_FREQ   (REF_FREQ)
    
    )
rx0 (
	.clkin_p   		(clkin_p[0]),
	.clkin_n   		(clkin_n[0]),
	.datain_p     		(datain_p[D-1:0]),
	.datain_n     		(datain_n[D-1:0]),
	.enable_phase_detector	(enable_phase_detector),
	.enable_monitor		(enable_monitor),
	.rxclk    		(rxclk),
	.idelay_rdy		(idelay_rdy),
	.rxclk_div		(rxclk_div),
	.reset     		(reset),
    .mmcm_locked    (mmcm_locked) ,
	.rx_mmcm_lckd		(rx_mmcm_lckd),
	.rx_mmcm_lckdps		(rx_mmcm_lckdps),
	.rx_mmcm_lckdpsbs	(rx_mmcm_lckdpsbs[0]),
	.clk_data  		(clk_data[6:0]),
	.rx_data		(rx_data[7*D-1:0]),
	.bit_rate_value		(bit_rate_value),
	.bit_time_value		(bit_time_value),
	.status			(status),
	.eye_info		(eye_info[32*D-1:0]),
	.rst_iserdes		(rst_iserdes),
	.m_delay_1hot		(m_delay_1hot[32*D-1:0]),
	.debug			(debug[10*D+5:0]));

genvar i ;
genvar j ;

generate
if (N > 1) begin
for (i = 1 ; i <= (N-1) ; i = i+1)
begin : loop0

serdes_1_to_7_slave_idelay_sdr #(
      	.D			(D),				// Number of data lines
	.HIGH_PERFORMANCE_MODE	(HIGH_PERFORMANCE_MODE),
	.DIFF_TERM		(DIFF_TERM),
	.DATA_FORMAT		(DATA_FORMAT))
rxn (
	.clkin_p   		(clkin_p[i]),
	.clkin_n   		(clkin_n[i]),
	.datain_p     		(datain_p[D*(i+1)-1:D*i]),
	.datain_n     		(datain_n[D*(i+1)-1:D*i]),
	.enable_phase_detector	(enable_phase_detector),
	.enable_monitor		(enable_monitor),
	.rxclk    		(rxclk),
	.idelay_rdy		(idelay_rdy),
	.rxclk_div		(rxclk_div),
	.reset     		(~rx_mmcm_lckdps),
	.bitslip_finished	(rx_mmcm_lckdpsbs[i]),
	.clk_data  		(clk_data[7*i+6:7*i]),
	.rx_data		(rx_data[(D*(i+1)*7)-1:D*i*7]),
	.bit_time_value		(bit_time_value),
	.eye_info		(eye_info[32*D*(i+1)-1:32*D*i]),
	.m_delay_1hot		(m_delay_1hot[(32*D)*(i+1)-1:(32*D)*i]),
	.rst_iserdes		(rst_iserdes),
	.debug			(debug[(10*D+6)*(i+1)-1:(10*D+6)*i]));

end
end
endgenerate
endmodule




//////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2012-2015 Xilinx, Inc.
// This design is confidential and proprietary of Xilinx, All Rights Reserved.
//////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /   Vendor: Xilinx
// \   \   \/    Version: 1.2
//  \   \        Filename: n_x_serdes_7_to_1_diff_sdr.v
//  /   /        Date Last Modified:  21JAN2015
// /___/   /\    Date Created: 2SEP2011
// \   \  /  \
//  \___\/\___\
// 
//Device: 	7-Series
//Purpose:  	N channel wrapper for multiple 7:1 SDR serdes channels
//
//Reference:	XAPP585
//    
//Revision History:
//    Rev 1.0 - First created (nicks)
//    Rev 1.2 - Updated format (brandond)
//////////////////////////////////////////////////////////////////////////////
//
//  Disclaimer: 
//
//		This disclaimer is not a license and does not grant any rights to the materials 
//              distributed herewith. Except as otherwise provided in a valid license issued to you 
//              by Xilinx, and to the maximum extent permitted by applicable law: 
//              (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND WITH ALL FAULTS, 
//              AND XILINX HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, 
//              INCLUDING BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-INFRINGEMENT, OR 
//              FITNESS FOR ANY PARTICULAR PURPOSE; and (2) Xilinx shall not be liable (whether in contract 
//              or tort, including negligence, or under any other theory of liability) for any loss or damage 
//              of any kind or nature related to, arising under or in connection with these materials, 
//              including for any direct, or any indirect, special, incidental, or consequential loss 
//              or damage (including loss of data, profits, goodwill, or any type of loss or damage suffered 
//              as a result of any action brought by a third party) even if such damage or loss was 
//              reasonably foreseeable or Xilinx had been advised of the possibility of the same.
//
//  Critical Applications:
//
//		Xilinx products are not designed or intended to be fail-safe, or for use in any application 
//		requiring fail-safe performance, such as life-support or safety devices or systems, 
//		Class III medical devices, nuclear facilities, applications related to the deployment of airbags,
//		or any other applications that could lead to death, personal injury, or severe property or 
//		environmental damage (individually and collectively, "Critical Applications"). Customer assumes 
//		the sole risk and liability of any use of Xilinx products in Critical Applications, subject only 
//		to applicable laws and regulations governing limitations on product liability.
//
//  THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS PART OF THIS FILE AT ALL TIMES.
//
//////////////////////////////////////////////////////////////////////////////

`timescale 1ps/1ps

module n_x_serdes_7_to_1_diff_sdr (txclk, reset, pixel_clk, datain, clk_pattern, dataout_p, dataout_n, clkout_p, clkout_n) ;

parameter integer 	N = 8 ;				// Set the number of channels
parameter integer 	D = 6 ;				// Set the number of outputs per channel
parameter         	DATA_FORMAT = "PER_CLOCK" ;     // Parameter Used to determine method for mapping input parallel word to output serial words
                                       	
input 			txclk ;				// Tx Clock network
input 			reset ;				// Reset
input 			pixel_clk ;			// Clock at pixel rate
input 	[(D*N*7)-1:0]	datain ;  			// Data for output
input 	[6:0]		clk_pattern ;  			// clock pattern for output
output 	[D*N-1:0]	dataout_p ;			// output data
output 	[D*N-1:0]	dataout_n ;			// output data
output 	[N-1:0]		clkout_p ;			// output clock
output 	[N-1:0]		clkout_n ;			// output clock

genvar i ;
genvar j ;

generate
for (i = 0 ; i <= (N-1) ; i = i+1)
begin : loop0

serdes_7_to_1_diff_sdr #(
      	.D			(D),
      	.DATA_FORMAT		(DATA_FORMAT))
dataout (
	.dataout_p  		(dataout_p[D*(i+1)-1:D*i]),
	.dataout_n  		(dataout_n[D*(i+1)-1:D*i]),
	.clkout_p  		(clkout_p[i]),
	.clkout_n  		(clkout_n[i]),
	.txclk    		(txclk),
	.pixel_clk    		(pixel_clk),
	.reset   		(reset),
	.clk_pattern  		(clk_pattern),
	.datain  		(datain[(D*(i+1)*7)-1:D*i*7]));		
end
endgenerate		
endmodule



//////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2012-2015 Xilinx, Inc.
// This design is confidential and proprietary of Xilinx, All Rights Reserved.
//////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /   Vendor: Xilinx
// \   \   \/    Version: 1.2
//  \   \        Filename: serdes_1_to_7_mmcm_idelay_sdr.v
//  /   /        Date Last Modified:  21JAN2015
// /___/   /\    Date Created: 5MAR2010
// \   \  /  \
//  \___\/\___\
//
//Device: 	7 Series
//Purpose:  	1 to 7 SDR receiver clock and data receiver using an MMCM for clock multiplication
//		Data formatting is set by the DATA_FORMAT parameter.
//		PER_CLOCK (default) format receives bits for 0, 1, 2 .. on the same sample edge
//		PER_CHANL format receives bits for 0, 7, 14 ..  on the same sample edge
//
//Reference:	XAPP585
//
//Revision History:
//    Rev 1.0 - First created (nicks)
//    Rev 1.1 - PER_CLOCK and PER_CHANL descriptions swapped
//    Rev 1.2 - Eye monitoring added, updated format
//
//////////////////////////////////////////////////////////////////////////////
//
//  Disclaimer:
//
//		This disclaimer is not a license and does not grant any rights to the materials
//              distributed herewith. Except as otherwise provided in a valid license issued to you
//              by Xilinx, and to the maximum extent permitted by applicable law:
//              (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND WITH ALL FAULTS,
//              AND XILINX HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY,
//              INCLUDING BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-INFRINGEMENT, OR
//              FITNESS FOR ANY PARTICULAR PURPOSE; and (2) Xilinx shall not be liable (whether in contract
//              or tort, including negligence, or under any other theory of liability) for any loss or damage
//              of any kind or nature related to, arising under or in connection with these materials,
//              including for any direct, or any indirect, special, incidental, or consequential loss
//              or damage (including loss of data, profits, goodwill, or any type of loss or damage suffered
//              as a result of any action brought by a third party) even if such damage or loss was
//              reasonably foreseeable or Xilinx had been advised of the possibility of the same.
//
//  Critical Applications:
//
//		Xilinx products are not designed or intended to be fail-safe, or for use in any application
//		requiring fail-safe performance, such as life-support or safety devices or systems,
//		Class III medical devices, nuclear facilities, applications related to the deployment of airbags,
//		or any other applications that could lead to death, personal injury, or severe property or
//		environmental damage (individually and collectively, "Critical Applications"). Customer assumes
//		the sole risk and liability of any use of Xilinx products in Critical Applications, subject only
//		to applicable laws and regulations governing limitations on product liability.
//
//  THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS PART OF THIS FILE AT ALL TIMES.
//
//////////////////////////////////////////////////////////////////////////////

`timescale 1ps/1ps

module serdes_1_to_7_mmcm_idelay_sdr (clkin_p, clkin_n, datain_p, datain_n, enable_phase_detector, enable_monitor, rxclk, idelay_rdy, reset, rxclk_div,
                                      rx_mmcm_lckdps, rx_mmcm_lckd, rx_mmcm_lckdpsbs, mmcm_locked , clk_data, rx_data, status, debug, bit_rate_value, bit_time_value, m_delay_1hot, rst_iserdes, eye_info) ;

parameter integer 	D = 8 ;   			// Parameter to set the number of data lines
parameter integer      	MMCM_MODE = 1 ;   		// Parameter to set multiplier for MMCM to get VCO in correct operating range. 1 multiplies input clock by 7, 2 multiplies clock by 14, etc
parameter 		HIGH_PERFORMANCE_MODE = "FALSE";// Parameter to set HIGH_PERFORMANCE_MODE of input delays to reduce jitter
parameter real 	  	CLKIN_PERIOD = 6.000 ;		// clock period (ns) of input clock on clkin_p
parameter         	DIFF_TERM = "FALSE" ; 		// Parameter to enable internal differential termination
parameter         	SAMPL_CLOCK = "BUFIO" ;   	// Parameter to set sampling clock buffer type, BUFIO, BUF_H, BUF_G
parameter         	PIXEL_CLOCK = "BUF_R" ;       	// Parameter to set final pixel buffer type, BUF_R, BUF_H, BUF_G
parameter         	USE_PLL = "FALSE" ;          	// Parameter to enable PLL use rather than MMCM use, note, PLL does not support BUFIO and BUFR
parameter         	DATA_FORMAT = "PER_CLOCK" ;     // Parameter Used to determine method for mapping input parallel word to output serial words
parameter real REF_FREQ = 200 ;



input 			clkin_p ;			// Input from LVDS clock receiver pin
input 			clkin_n ;			// Input from LVDS clock receiver pin
input 	[D-1:0]		datain_p ;			// Input from LVDS clock data pins
input 	[D-1:0]		datain_n ;			// Input from LVDS clock data pins
input 			enable_phase_detector ;		// Enables the phase detector logic when high
input			enable_monitor ;		// Enables the monitor logic when high, note time-shared with phase detector function
input 			reset ;				// Reset line
input			idelay_rdy ;			// input delays are ready
output 			rxclk ;				// Global/BUFIO rx clock network
output 			rxclk_div ;			// Global/Regional clock output
output 			rx_mmcm_lckd ; 			// MMCM locked, synchronous to rxclk_div
output 			rx_mmcm_lckdps ; 		// MMCM locked and phase shifting finished, synchronous to rxclk_div
output 			rx_mmcm_lckdpsbs ; 		// MMCM locked and phase shifting finished and bitslipping finished, synchronous to rxclk_div
output 	[6:0]		clk_data ;	 		// Clock Data
output 	[D*7-1:0]	rx_data ;	 		// Received Data
output 	[10*D+5:0]	debug ;	 			// debug info
output 	[6:0]		status ;	 		// clock status info
input 	[15:0]		bit_rate_value ;	 	// Bit rate in Mbps, eg 16'h0585
output	[4:0]		bit_time_value ;		// Calculated bit time value for slave devices
output	reg		rst_iserdes ;			// serdes reset signal
output	[32*D-1:0]	eye_info ;			// Eye info
output	[32*D-1:0]	m_delay_1hot ;			// Master delay control value as a one-hot vector
output  mmcm_locked ;



wire	[D*5-1:0]	m_delay_val_in ;
wire	[D*5-1:0]	s_delay_val_in ;
reg	[1:0]		bsstate ;
reg 			bslip ;
reg	[3:0]		bcount ;
wire 	[6:0] 		clk_iserdes_data ;
reg 	[6:0] 		clk_iserdes_data_d ;
reg 			enable ;
reg 			flag1 ;
reg 			flag2 ;
reg 	[2:0] 		state2 ;
reg 	[4:0] 		state2_count ;
reg 	[5:0] 		scount ;
reg 			locked_out ;
reg			chfound ;
reg			chfoundc ;
reg			not_rx_mmcm_lckd_int ;
reg	[4:0]		c_delay_in ;
reg	[4:0]		c_delay_in_target ;
reg			c_delay_in_ud ;
wire 	[D-1:0]		rx_data_in_p ;
wire 	[D-1:0]		rx_data_in_n ;
wire 	[D-1:0]		rx_data_in_m ;
wire 	[D-1:0]		rx_data_in_s ;
wire 	[D-1:0]		rx_data_in_md ;
wire 	[D-1:0]		rx_data_in_sd ;
wire	[(7*D)-1:0] 	mdataout ;
wire	[(7*D)-1:0] 	mdataoutd ;
wire	[(7*D)-1:0] 	sdataout ;
reg			data_different ;
reg			bs_finished ;
reg			not_bs_finished ;
reg	[4:0]		bt_val ;
wire			mmcm_locked ;
wire			rx_mmcmout_x1 ;
wire			rx_mmcmout_xs ;
reg			rstcserdes ;
reg	[1:0]		c_loop_cnt ;

parameter [D-1:0] 	RX_SWAP_MASK = 16'h0000 ;	// pinswap mask for input data bits (0 = no swap (default), 1 = swap). Allows inputs to be connected the wrong way round to ease PCB routing.

assign clk_data = clk_iserdes_data ;
assign debug = {s_delay_val_in, m_delay_val_in, bslip, c_delay_in} ;
assign rx_mmcm_lckdpsbs = bs_finished & mmcm_locked ;
assign rx_mmcm_lckd = ~not_rx_mmcm_lckd_int & mmcm_locked ;
assign rx_mmcm_lckdps = ~not_rx_mmcm_lckd_int & locked_out & mmcm_locked ;
assign bit_time_value = bt_val ;

always @ (bit_rate_value) begin			// Generate tap number to be used for input bit rate
	if      (bit_rate_value > 16'h1068) begin bt_val <= 5'h0C ; end
	else if (bit_rate_value > 16'h0986) begin bt_val <= 5'h0D ; end
	else if (bit_rate_value > 16'h0916) begin bt_val <= 5'h0E ; end
	else if (bit_rate_value > 16'h0855) begin bt_val <= 5'h0F ; end
	else if (bit_rate_value > 16'h0801) begin bt_val <= 5'h10 ; end
	else if (bit_rate_value > 16'h0754) begin bt_val <= 5'h11 ; end
	else if (bit_rate_value > 16'h0712) begin bt_val <= 5'h12 ; end
	else if (bit_rate_value > 16'h0675) begin bt_val <= 5'h13 ; end
	else if (bit_rate_value > 16'h0641) begin bt_val <= 5'h14 ; end
	else if (bit_rate_value > 16'h0611) begin bt_val <= 5'h15 ; end
	else if (bit_rate_value > 16'h0583) begin bt_val <= 5'h16 ; end
	else if (bit_rate_value > 16'h0557) begin bt_val <= 5'h17 ; end
	else if (bit_rate_value > 16'h0534) begin bt_val <= 5'h18 ; end
	else if (bit_rate_value > 16'h0513) begin bt_val <= 5'h19 ; end
	else if (bit_rate_value > 16'h0493) begin bt_val <= 5'h1A ; end
	else if (bit_rate_value > 16'h0475) begin bt_val <= 5'h1B ; end
	else if (bit_rate_value > 16'h0458) begin bt_val <= 5'h1C ; end
	else if (bit_rate_value > 16'h0442) begin bt_val <= 5'h1D ; end
	else if (bit_rate_value > 16'h0427) begin bt_val <= 5'h1E ; end
	else                                begin bt_val <= 5'h1F ; end
end

// Bitslip state machine

always @ (posedge rxclk_div)
begin
if (locked_out == 1'b0) begin
	bslip <= 1'b0 ;
	bsstate <= 1 ;
	enable <= 1'b0 ;
	bcount <= 4'h0 ;
	bs_finished <= 1'b0 ;
	not_bs_finished <= 1'b1 ;
end
else begin
	enable <= 1'b1 ;
   	if (enable == 1'b1) begin
   		if (clk_iserdes_data != 7'b1100001) begin flag1 <= 1'b1 ; end else begin flag1 <= 1'b0 ; end
   		if (clk_iserdes_data != 7'b1100011) begin flag2 <= 1'b1 ; end else begin flag2 <= 1'b0 ; end
     		if (bsstate == 0) begin
   			if (flag1 == 1'b1 && flag2 == 1'b1) begin
     		   		bslip <= 1'b1 ;						// bitslip needed
     		   		bsstate <= 1 ;
     		   	end
     		   	else begin
     		   		bs_finished <= 1'b1 ;					// bitslip done
     		   		not_bs_finished <= 1'b0 ;				// bitslip done
     		   	end
		end
   		else if (bsstate == 1) begin
     		   	bslip <= 1'b0 ;
     		   	bcount <= bcount + 4'h1 ;
   			if (bcount == 4'hF) begin
     		   		bsstate <= 0 ;
     		   	end
   		end
   	end
end
end

// Clock input

IBUFGDS_DIFF_OUT #(
	.DIFF_TERM 		(DIFF_TERM),
	.IBUF_LOW_PWR		("FALSE"))
iob_clk_in (
	.I    			(clkin_p),
	.IB       		(clkin_n),
	.O         		(rx_clk_in_p),
	.OB         		(rx_clk_in_n));

genvar i ;
genvar j ;

IDELAYE2 #(
.REFCLK_FREQUENCY      (REF_FREQ),
	.HIGH_PERFORMANCE_MODE 	(HIGH_PERFORMANCE_MODE),
      	.IDELAY_VALUE		(1),
      	.DELAY_SRC		("IDATAIN"),
      	.IDELAY_TYPE		("VAR_LOAD"))
idelay_cm(
	.DATAOUT		(rx_clkin_p_d),
	.C			(rxclk_div),
	.CE			(1'b0),
	.INC			(1'b0),
	.DATAIN			(1'b0),
	.IDATAIN		(rx_clk_in_p),
	.LD			(1'b1),
	.LDPIPEEN		(1'b0),
	.REGRST			(1'b0),
	.CINVCTRL		(1'b0),
	.CNTVALUEIN		(c_delay_in),
   // .CNTVALUEIN		(0 ),
    
	.CNTVALUEOUT		());

IDELAYE2 #(
.REFCLK_FREQUENCY      (REF_FREQ),
	.HIGH_PERFORMANCE_MODE 	(HIGH_PERFORMANCE_MODE),
      	.IDELAY_VALUE		(1),
      	.DELAY_SRC		("IDATAIN"),
      	.IDELAY_TYPE		("VAR_LOAD"))
idelay_cs(
	.DATAOUT		(rx_clk_in_n_d),
	.C			(rxclk_div),
	.CE			(1'b0),
	.INC			(1'b0),
	.DATAIN			(1'b0),
	.IDATAIN		(~rx_clk_in_n),
	.LD			(1'b1),
	.LDPIPEEN		(1'b0),
	.REGRST			(1'b0),
	.CINVCTRL		(1'b0),
	.CNTVALUEIN		({1'b0, bt_val[4:1]}),
	.CNTVALUEOUT		());

ISERDESE2 #(
	.DATA_WIDTH     	(7),
	.DATA_RATE      	("SDR"),
//	.SERDES_MODE    	("MASTER"),
	.IOBDELAY	    	("IFD"),
	.INTERFACE_TYPE 	("NETWORKING"))
iserdes_cm (
	.D       		(1'b0),
	.DDLY     		(rx_clk_in_n_d),
	.CE1     		(1'b1),
	.CE2     		(1'b1),
	.CLK    		(rxclk),
	.CLKB    		(~rxclk),
	.RST     		(rstcserdes),
	.CLKDIV  		(rxclk_div),
	.CLKDIVP  		(1'b0),
	.OCLK    		(1'b0),
	.OCLKB    		(1'b0),
	.DYNCLKSEL    		(1'b0),
	.DYNCLKDIVSEL  		(1'b0),
	.SHIFTIN1 		(1'b0),
	.SHIFTIN2 		(1'b0),
	.BITSLIP 		(bslip),
	.O	 		(),
	.Q8 			(),
	.Q7 			(clk_iserdes_data[0]),
	.Q6 			(clk_iserdes_data[1]),
	.Q5 			(clk_iserdes_data[2]),
	.Q4 			(clk_iserdes_data[3]),
	.Q3 			(clk_iserdes_data[4]),
	.Q2 			(clk_iserdes_data[5]),
	.Q1 			(clk_iserdes_data[6]),
	.OFB 			(),
	.SHIFTOUT1 		(),
	.SHIFTOUT2 		());

generate
if (USE_PLL == "FALSE") begin : loop8					// use an MMCM
assign status[6] = 1'b1 ;
(*KEEP_HIERARCHY  = "TRUE"*)    
MMCME2_ADV #(
      	.BANDWIDTH		("OPTIMIZED"),  		
      	.CLKFBOUT_MULT_F	(7*MMCM_MODE),
      	.CLKFBOUT_PHASE		(0.0),
      	.CLKIN1_PERIOD		(CLKIN_PERIOD),
      	.CLKIN2_PERIOD		(CLKIN_PERIOD),
      	.CLKOUT0_DIVIDE_F	(1*MMCM_MODE),
       // .CLKOUT0_DIVIDE_F	(2*MMCM_MODE),
        
      	.CLKOUT0_DUTY_CYCLE	(0.5),
      	.CLKOUT0_PHASE		(0.0),
	    .CLKOUT0_USE_FINE_PS	("FALSE"),
      	.CLKOUT1_DIVIDE		(6*MMCM_MODE),
      	.CLKOUT1_DUTY_CYCLE	(0.5),
      	.CLKOUT1_PHASE		(22.5),
	    .CLKOUT1_USE_FINE_PS	("FALSE"),
      	.CLKOUT2_DIVIDE		(7*MMCM_MODE),
      	.CLKOUT2_DUTY_CYCLE	(0.5),
      	.CLKOUT2_PHASE		(0.0),
	    .CLKOUT2_USE_FINE_PS	("FALSE"),
      	.CLKOUT3_DIVIDE		(7),
      	.CLKOUT3_DUTY_CYCLE	(0.5),
      	.CLKOUT3_PHASE		(0.0),
      	.CLKOUT4_DIVIDE		(7),
      	.CLKOUT4_DUTY_CYCLE	(0.5),
      	.CLKOUT4_PHASE		(0.0),
      	.CLKOUT5_DIVIDE		(7),
      	.CLKOUT5_DUTY_CYCLE	(0.5),
      	.CLKOUT5_PHASE		(0.0),
      	.COMPENSATION		("ZHOLD"),
      	.DIVCLK_DIVIDE		(1),
      	.REF_JITTER1		(0.100))
rx_mmcm_adv_inst (
      	.CLKFBOUT		(rx_mmcmout_x1),
      	.CLKFBOUTB		(),
      	.CLKFBSTOPPED		(),
      	.CLKINSTOPPED		(),
      	.CLKOUT0		(rx_mmcmout_xs),
      	.CLKOUT0B		(),
      	.CLKOUT1		(),
      	.CLKOUT1B		(),
      	.CLKOUT2		(),
      	.CLKOUT2B		(),
      	.CLKOUT3		(),
      	.CLKOUT3B		(),
      	.CLKOUT4		(),
      	.CLKOUT5		(),
      	.CLKOUT6		(),
      	.DO			(),
      	.DRDY			(),
      	.PSDONE			(),
      	.PSCLK			(1'b0),
      	.PSEN			(1'b0),
      	.PSINCDEC		(1'b0),
      	.PWRDWN			(1'b0),
      	.LOCKED			(mmcm_locked),
      	.CLKFBIN		(rxclk_div),
      	.CLKIN1			(rx_clkin_p_d),
      	.CLKIN2			(rx_clkin_p_d),
      	.CLKINSEL		(1'b1),
      	.DADDR			(7'h00),
      	.DCLK			(1'b0),
      	.DEN			(1'b0),
      	.DI			(16'h0000),
      	.DWE			(1'b0),
      	.RST			(reset)) ;

   assign status[3:2] = 2'b00 ;

   if (PIXEL_CLOCK == "BUF_G") begin 						// Final clock selection
      BUFG	bufg_mmcm_x1 (.I(rx_mmcmout_x1), .O(rxclk_div)) ;
      assign status[1:0] = 2'b00 ;
   end
   else if (PIXEL_CLOCK == "BUF_R") begin
      BUFR #(.BUFR_DIVIDE("1"),.SIM_DEVICE("7SERIES"))bufr_mmcm_x1 (.I(rx_mmcmout_x1),.CE(1'b1),.O(rxclk_div),.CLR(1'b0)) ;
      assign status[1:0] = 2'b01 ;
   end
   else begin
      BUFH	bufh_mmcm_x1 (.I(rx_mmcmout_x1), .O(rxclk_div)) ;
      assign status[1:0] = 2'b10 ;
   end

   if (SAMPL_CLOCK == "BUF_G") begin						// Sample clock selection
      BUFG	bufg_mmcm_xn (.I(rx_mmcmout_xs), .O(rxclk)) ;
      assign status[5:4] = 2'b00 ;
   end
   else if (SAMPL_CLOCK == "BUFIO") begin
      BUFIO  	bufio_mmcm_xn (.I (rx_mmcmout_xs), .O(rxclk)) ;
      assign status[5:4] = 2'b11 ;
   end
   else begin
      BUFH	bufh_mmcm_xn (.I(rx_mmcmout_xs), .O(rxclk)) ;
      assign status[5:4] = 2'b10 ;
   end

end
else begin
assign status[6] = 1'b0 ;
(*KEEP_HIERARCHY  = "TRUE"*)    
PLLE2_ADV #(
      	.BANDWIDTH	    	("OPTIMIZED"),
      	.CLKFBOUT_MULT		(7*MMCM_MODE),
      	.CLKFBOUT_PHASE		(0.0),
      	.CLKIN1_PERIOD		(CLKIN_PERIOD),
      	.CLKIN2_PERIOD		(CLKIN_PERIOD),
      	.CLKOUT0_DIVIDE		(1*MMCM_MODE),
       // .CLKOUT0_DIVIDE		(2*MMCM_MODE),
        
      	.CLKOUT0_DUTY_CYCLE	(0.5),
      	.CLKOUT0_PHASE		(0.0),
      	.CLKOUT1_DIVIDE		(4*MMCM_MODE),
      	.CLKOUT1_DUTY_CYCLE	(0.5),
      	.CLKOUT1_PHASE		(22.5),
      	.CLKOUT2_DIVIDE		(7*MMCM_MODE),
      	.CLKOUT2_DUTY_CYCLE	(0.5),
      	.CLKOUT2_PHASE		(0.0),
      	.CLKOUT3_DIVIDE		(7),
      	.CLKOUT3_DUTY_CYCLE	(0.5),
      	.CLKOUT3_PHASE		(0.0),
      	.CLKOUT4_DIVIDE		(7),
      	.CLKOUT4_DUTY_CYCLE	(0.5),
      	.CLKOUT4_PHASE		(0.0),
      	.CLKOUT5_DIVIDE		(7),
      	.CLKOUT5_DUTY_CYCLE	(0.5),
      	.CLKOUT5_PHASE		(0.0),
      	.COMPENSATION		("ZHOLD"),
      	.DIVCLK_DIVIDE		(1),
      	.REF_JITTER1		(0.100))
rx_plle2_adv_inst (
      	.CLKFBOUT		(rx_mmcmout_x1),
      	.CLKOUT0		(rx_mmcmout_xs),
      	.CLKOUT1		(),
      	.CLKOUT2		(),
      	.CLKOUT3		(),
      	.CLKOUT4		(),
      	.CLKOUT5		(),
      	.DO			(),
      	.DRDY			(),
      	.PWRDWN			(1'b0),
      	.LOCKED			(mmcm_locked),
      	.CLKFBIN		(rxclk_div),
      	.CLKIN1			(rx_clkin_p_d),
      	.CLKIN2			(rx_clkin_p_d),
      	.CLKINSEL		(1'b1),
      	.DADDR			(7'h00),
      	.DCLK			(1'b0),
      	.DEN			(1'b0),
      	.DI			(16'h0000),
      	.DWE			(1'b0),
      	.RST			(reset)) ;

   assign status[3:2] = 2'b00 ;

   if (PIXEL_CLOCK == "BUF_G") begin 						// Final clock selection
      BUFG	bufg_pll_x1 (.I(rx_mmcmout_x1), .O(rxclk_div)) ;
      assign status[1:0] = 2'b00 ;
   end
   else if (PIXEL_CLOCK == "BUF_R") begin
      BUFR #(.BUFR_DIVIDE("1"),.SIM_DEVICE("7SERIES"))bufr_pll_x1 (.I(rx_mmcmout_x1),.CE(1'b1),.O(rxclk_div),.CLR(1'b0)) ;
      assign status[1:0] = 2'b01 ;
   end
   else begin
      BUFH	bufh_pll_x1 (.I(rx_mmcmout_x1), .O(rxclk_div)) ;
      assign status[1:0] = 2'b10 ;
   end

   if (SAMPL_CLOCK == "BUF_G") begin						// Sample clock selection
      BUFG	bufg_pll_xn (.I(rx_mmcmout_xs), .O(rxclk)) ;
      assign status[5:4] = 2'b00 ;
   end
   else if (SAMPL_CLOCK == "BUFIO") begin
      BUFIO  	bufio_pll_xn (.I (rx_mmcmout_xs), .O(rxclk)) ;
      assign status[5:4] = 2'b11 ;
   end
   else begin
      BUFH	bufh_pll_xn (.I(rx_mmcmout_xs), .O(rxclk)) ;
      assign status[5:4] = 2'b10 ;
   end

end
endgenerate

always @ (posedge rxclk_div) begin				//
	clk_iserdes_data_d <= clk_iserdes_data ;
	if ((clk_iserdes_data != clk_iserdes_data_d) && (clk_iserdes_data != 7'h00) && (clk_iserdes_data != 7'h7F)) begin
		data_different <= 1'b1 ;
	end
	else begin
		data_different <= 1'b0 ;
	end
end

always @ (posedge rxclk_div) begin						// clock delay shift state machine
	not_rx_mmcm_lckd_int <= ~(mmcm_locked & idelay_rdy) ;
	rstcserdes <= not_rx_mmcm_lckd_int | rst_iserdes ;
	if (not_rx_mmcm_lckd_int == 1'b1) begin
		scount <= 6'h00 ;
		state2 <= 0 ;
		state2_count <= 5'h00 ;
		locked_out <= 1'b0 ;
		chfoundc <= 1'b1 ;
		c_delay_in <= bt_val ;							// Start the delay line at the current bit period
		rst_iserdes <= 1'b0 ;
		c_loop_cnt <= 2'b00 ;
	end
	else begin
		if (scount[5] == 1'b0) begin
			scount <= scount + 6'h01 ;
		end
		state2_count <= state2_count + 5'h01 ;
		if (chfoundc == 1'b1) begin
			chfound <= 1'b0 ;
		end
		else if (chfound == 1'b0 && data_different == 1'b1) begin
			chfound <= 1'b1 ;
		end
		if ((state2_count == 5'h1F && scount[5] == 1'b1)) begin
			case(state2)
			0	: begin							// decrement delay and look for a change
				  if (chfound == 1'b1 || (c_loop_cnt == 2'b11 && c_delay_in == 5'h00)) begin  // quit loop if we've been around a few times
					chfoundc <= 1'b1 ;
					state2 <= 1 ;
				  end
				  else begin
					chfoundc <= 1'b0 ;
					if (c_delay_in != 5'h00) begin			// check for underflow
						c_delay_in <= c_delay_in - 5'h01 ;
					end
					else begin
						c_delay_in <= bt_val ;
						c_loop_cnt <= c_loop_cnt + 2'b01 ;
					end
				  end
				  end
			1	: begin							// add half a bit period using input information
				  state2 <= 2 ;
				  if (c_delay_in < {1'b0, bt_val[4:1]}) begin		// choose the lowest delay value to minimise jitter
				   	c_delay_in_target <= c_delay_in + {1'b0, bt_val[4:1]} ;
				  end
				  else begin
				   	c_delay_in_target <= c_delay_in - {1'b0, bt_val[4:1]} ;
				  end
				  end
			2 	: begin
				  if (c_delay_in == c_delay_in_target) begin
				   	state2 <= 3 ;
				  end
				  else begin
				   	if (c_delay_in_ud == 1'b1) begin		// move gently to end position to stop MMCM unlocking
						c_delay_in <= c_delay_in + 5'h01 ;
				   		c_delay_in_ud <= 1'b1 ;
				   	end
				   	else begin
						c_delay_in <= c_delay_in - 5'h01 ;
				   		c_delay_in_ud <= 1'b0 ;
				   	end
				  end
				  end
			3 	: begin rst_iserdes <= 1'b1 ; state2 <= 4 ; end		// remove serdes reset
			default	: begin							// issue locked out signal
				  rst_iserdes <= 1'b0 ;  locked_out <= 1'b1 ;
			 	  end
			endcase
		end
	end
end

generate
for (i = 0 ; i <= D-1 ; i = i+1)
begin : loop3

delay_controller_wrap # (
	.S 			(7))
dc_inst (
	.m_datain		(mdataout[7*i+6:7*i]),
	.s_datain		(sdataout[7*i+6:7*i]),
	.enable_phase_detector	(enable_phase_detector),
	.enable_monitor		(enable_monitor),
	.reset			(not_bs_finished),
	.clk			(rxclk_div),
	.c_delay_in		({1'b0, bt_val[4:1]}),
	.m_delay_out		(m_delay_val_in[5*i+4:5*i]),
	.s_delay_out		(s_delay_val_in[5*i+4:5*i]),
	.data_out		(mdataoutd[7*i+6:7*i]),
	.bt_val			(bt_val),
	.del_mech		(1'b0),
	.m_delay_1hot		(m_delay_1hot[32*i+31:32*i]),
	.results		(eye_info[32*i+31:32*i])) ;

// Data bit Receivers

IBUFDS_DIFF_OUT #(
	.DIFF_TERM 		(DIFF_TERM))
data_in (
	.I    			(datain_p[i]),
	.IB       		(datain_n[i]),
	.O         		(rx_data_in_p[i]),
	.OB         		(rx_data_in_n[i]));

assign rx_data_in_m[i] = rx_data_in_p[i]  ^ RX_SWAP_MASK[i] ;
assign rx_data_in_s[i] = ~rx_data_in_n[i] ^ RX_SWAP_MASK[i] ;

IDELAYE2 #(
.REFCLK_FREQUENCY      (REF_FREQ),
	.HIGH_PERFORMANCE_MODE	(HIGH_PERFORMANCE_MODE),
      	.IDELAY_VALUE		(0),
      	.DELAY_SRC		("IDATAIN"),
      	.IDELAY_TYPE		("VAR_LOAD"))
idelay_m(
	.DATAOUT		(rx_data_in_md[i]),
	.C			(rxclk_div),
	.CE			(1'b0),
	.INC			(1'b0),
	.DATAIN			(1'b0),
	.IDATAIN		(rx_data_in_m[i]),
	.LD			(1'b1),
	.LDPIPEEN		(1'b0),
	.REGRST			(1'b0),
	.CINVCTRL		(1'b0),
	.CNTVALUEIN		(m_delay_val_in[5*i+4:5*i]),
	.CNTVALUEOUT		());

ISERDESE2 #(
	.DATA_WIDTH     	(7),
	.DATA_RATE      	("SDR"),
	.SERDES_MODE    	("MASTER"),
	.IOBDELAY	    	("IFD"),
	.INTERFACE_TYPE 	("NETWORKING"))
iserdes_m (
	.D       		(1'b0),
	.DDLY     		(rx_data_in_md[i]),
	.CE1     		(1'b1),
	.CE2     		(1'b1),
	.CLK	   		(rxclk),
	.CLKB    		(~rxclk),
	.RST     		(rst_iserdes),
	.CLKDIV  		(rxclk_div),
	.CLKDIVP  		(1'b0),
	.OCLK    		(1'b0),
	.OCLKB    		(1'b0),
	.DYNCLKSEL    		(1'b0),
	.DYNCLKDIVSEL  		(1'b0),
	.SHIFTIN1 		(1'b0),
	.SHIFTIN2 		(1'b0),
	.BITSLIP 		(bslip),
	.O	 		(),
	.Q8  			(),
	.Q7  			(mdataout[7*i+0]),
	.Q6  			(mdataout[7*i+1]),
	.Q5  			(mdataout[7*i+2]),
	.Q4  			(mdataout[7*i+3]),
	.Q3  			(mdataout[7*i+4]),
	.Q2  			(mdataout[7*i+5]),
	.Q1  			(mdataout[7*i+6]),
	.OFB 			(),
	.SHIFTOUT1		(),
	.SHIFTOUT2 		());

IDELAYE2 #(
.REFCLK_FREQUENCY      (REF_FREQ),
	.HIGH_PERFORMANCE_MODE	(HIGH_PERFORMANCE_MODE),
      	.IDELAY_VALUE		(0),
      	.DELAY_SRC		("IDATAIN"),
      	.IDELAY_TYPE		("VAR_LOAD"))
idelay_s(
	.DATAOUT		(rx_data_in_sd[i]),
	.C			(rxclk_div),
	.CE			(1'b0),
	.INC			(1'b0),
	.DATAIN			(1'b0),
	.IDATAIN		(rx_data_in_s[i]),
	.LD			(1'b1),
	.LDPIPEEN		(1'b0),
	.REGRST			(1'b0),
	.CINVCTRL		(1'b0),
	.CNTVALUEIN		(s_delay_val_in[5*i+4:5*i]),
	.CNTVALUEOUT		());

ISERDESE2 #(
	.DATA_WIDTH     	(7),
	.DATA_RATE      	("SDR"),
//	.SERDES_MODE    	("SLAVE"),
	.IOBDELAY	    	("IFD"),
	.INTERFACE_TYPE 	("NETWORKING"))
iserdes_s (
	.D       		(1'b0),
	.DDLY     		(rx_data_in_sd[i]),
	.CE1     		(1'b1),
	.CE2     		(1'b1),
	.CLK	   		(rxclk),
	.CLKB    		(~rxclk),
	.RST     		(rst_iserdes),
	.CLKDIV  		(rxclk_div),
	.CLKDIVP  		(1'b0),
	.OCLK    		(1'b0),
	.OCLKB    		(1'b0),
	.DYNCLKSEL    		(1'b0),
	.DYNCLKDIVSEL  		(1'b0),
	.SHIFTIN1 		(1'b0),
	.SHIFTIN2 		(1'b0),
	.BITSLIP 		(bslip),
	.O	 		(),
	.Q8  			(),
	.Q7  			(sdataout[7*i+0]),
	.Q6  			(sdataout[7*i+1]),
	.Q5  			(sdataout[7*i+2]),
	.Q4  			(sdataout[7*i+3]),
	.Q3  			(sdataout[7*i+4]),
	.Q2  			(sdataout[7*i+5]),
	.Q1  			(sdataout[7*i+6]),
	.OFB 			(),
	.SHIFTOUT1		(),
	.SHIFTOUT2 		());

for (j = 0 ; j <= 6 ; j = j+1) begin : loop1			// Assign data bits to correct serdes according to required format
	if (DATA_FORMAT == "PER_CLOCK") begin
		assign rx_data[D*j+i] = mdataoutd[7*i+j] ;
	end
	else begin
		assign rx_data[7*i+j] = mdataoutd[7*i+j] ;
	end
end
end
endgenerate
endmodule



//////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2012-2015 Xilinx, Inc.
// This design is confidential and proprietary of Xilinx, All Rights Reserved.
//////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /   Vendor: Xilinx
// \   \   \/    Version: 1.2
//  \   \        Filename: serdes_1_to_7_slave_idelay_sdr.v
//  /   /        Date Last Modified:  21JAN2015
// /___/   /\    Date Created: 5MAR2010
// \   \  /  \
//  \___\/\___\
// 
//Device:   7 Series
//Purpose:    1 to 7 SDR receiver slave data receiver
//    Data formatting is set by the DATA_FORMAT parameter. 
//    PER_CLOCK (default) format receives bits for 0, 1, 2 .. on the same sample edge
//    PER_CHANL format receives bits for 0, 7, 14 ..  on the same sample edge
//
//Reference:  XAPP585
//    
//Revision History:
//    Rev 1.0 - First created (nicks)
//    Rev 1.1 - PER_CLOCK and PER_CHANL descriptions swapped
//    Rev 1.2 - Eye monitoring added, updated format
//
//////////////////////////////////////////////////////////////////////////////
//
//  Disclaimer: 
//
//    This disclaimer is not a license and does not grant any rights to the materials 
//              distributed herewith. Except as otherwise provided in a valid license issued to you 
//              by Xilinx, and to the maximum extent permitted by applicable law: 
//              (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND WITH ALL FAULTS, 
//              AND XILINX HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, 
//              INCLUDING BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-INFRINGEMENT, OR 
//              FITNESS FOR ANY PARTICULAR PURPOSE; and (2) Xilinx shall not be liable (whether in contract 
//              or tort, including negligence, or under any other theory of liability) for any loss or damage 
//              of any kind or nature related to, arising under or in connection with these materials, 
//              including for any direct, or any indirect, special, incidental, or consequential loss 
//              or damage (including loss of data, profits, goodwill, or any type of loss or damage suffered 
//              as a result of any action brought by a third party) even if such damage or loss was 
//              reasonably foreseeable or Xilinx had been advised of the possibility of the same.
//
//  Critical Applications:
//
//    Xilinx products are not designed or intended to be fail-safe, or for use in any application 
//    requiring fail-safe performance, such as life-support or safety devices or systems, 
//    Class III medical devices, nuclear facilities, applications related to the deployment of airbags,
//    or any other applications that could lead to death, personal injury, or severe property or 
//    environmental damage (individually and collectively, "Critical Applications"). Customer assumes 
//    the sole risk and liability of any use of Xilinx products in Critical Applications, subject only 
//    to applicable laws and regulations governing limitations on product liability.
//
//  THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS PART OF THIS FILE AT ALL TIMES.
//
//////////////////////////////////////////////////////////////////////////////

`timescale 1ps/1ps

module serdes_1_to_7_slave_idelay_sdr (clkin_p, clkin_n, datain_p, datain_n, enable_phase_detector, enable_monitor, idelay_rdy, rxclk, reset, rxclk_div, 
                                       bitslip_finished, clk_data, rx_data, debug, bit_time_value, m_delay_1hot, rst_iserdes, eye_info);

parameter integer   D = 8;         // Parameter to set the number of data lines
parameter           HIGH_PERFORMANCE_MODE = "FALSE";// Parameter to set HIGH_PERFORMANCE_MODE of input delays to reduce jitter
parameter           DIFF_TERM = "FALSE";           // Parameter to enable internal differential termination
parameter           DATA_FORMAT = "PER_CLOCK";     // Parameter Used to determine method for mapping input parallel word to output serial words
parameter   real REF_FREQ = 200 ;                 


                      
input              clkin_p;                  // Input from LVDS clock receiver pin
input              clkin_n;                  // Input from LVDS clock receiver pin
input   [D-1:0]    datain_p;                 // Input from LVDS clock data pins
input   [D-1:0]    datain_n;                 // Input from LVDS clock data pins
input              enable_phase_detector;    // Enables the phase detector logic when high
input              enable_monitor;           // Enables the monitor logic when high, note time-shared with phase detector function
input              idelay_rdy;               // input delays are ready
input              reset;                    // Reset line
input              rxclk;                    // Global/BUFIO rx clock network
input              rxclk_div;                // Global/Regional clock input
output             bitslip_finished;         // bitslipping finished
output  [6:0]      clk_data;                 // Clock Data
output  [D*7-1:0]  rx_data;                  // Received Data
output  [10*D+5:0] debug;                    // debug info
input   [4:0]      bit_time_value;           // Calculated bit time value from 'master'
input              rst_iserdes;              // reset serdes input
output  [32*D-1:0] eye_info;                 // Eye info
output  [32*D-1:0] m_delay_1hot;             // Master delay control value as a one-hot vector

wire  [D*5-1:0]  m_delay_val_in;
wire  [D*5-1:0]  s_delay_val_in;
wire             rx_clk_in;      
reg   [1:0]      bsstate;                   
reg              bslip;                   
reg              bslipreq;                   
reg              bslipr;                   
reg   [3:0]      bcount;                   
wire  [6:0]      clk_iserdes_data;        
reg   [6:0]      clk_iserdes_data_d;      
reg              enable;                  
reg              flag1;                   
reg              flag2;                   
reg   [2:0]      state2;      
reg   [3:0]      state2_count;      
reg   [5:0]      scount;      
reg              locked_out;  
reg              locked_out_rt;  
reg              chfound;  
reg              chfoundc;
reg   [4:0]      c_delay_in;
reg   [4:0]      old_c_delay_in;
reg              local_reset;
wire  [D-1:0]    rx_data_in_p;      
wire  [D-1:0]    rx_data_in_n;      
wire  [D-1:0]    rx_data_in_m;      
wire  [D-1:0]    rx_data_in_s;    
wire  [D-1:0]    rx_data_in_md;      
wire  [D-1:0]    rx_data_in_sd;  
wire  [(7*D)-1:0]   mdataout;            
wire  [(7*D)-1:0]   mdataoutd;      
wire  [(7*D)-1:0]   sdataout;            
reg                 bslip_ackr;    
reg                 bslip_ack;    
reg   [1:0]         bstate;
reg                 data_different;    
reg                 bs_finished;
reg                 not_bs_finished;
wire  [4:0]         bt_val;
reg   [D*4-1:0]     s_state;                       
reg                 retry;
reg                 no_clock;
reg   [1:0]         c_loop_cnt;  

parameter [D-1:0]   RX_SWAP_MASK = 16'h0000;  // pinswap mask for input data bits (0 = no swap (default), 1 = swap). Allows inputs to be connected the wrong way round to ease PCB routing.

assign clk_data = clk_iserdes_data;
assign debug = {s_delay_val_in, m_delay_val_in, bslip, c_delay_in};
assign bitslip_finished = bs_finished & ~reset;
assign bt_val = bit_time_value;

always @ (posedge rxclk_div or posedge reset) begin  // generate local sync (rxclk_div) reset
if (reset == 1'b1 || retry == 1'b1) begin
  local_reset <= 1'b1;
end
else begin
  if (idelay_rdy == 1'b0) begin
    local_reset <= 1'b1;
  end
  else begin
    local_reset <= 1'b0;
  end
end
end

// Bitslip state machine

always @ (posedge rxclk_div)
begin
if (locked_out == 1'b0) begin
  bslip <= 1'b0;
  bsstate <= 1;
  enable <= 1'b0;
  bcount <= 4'h0;
  bs_finished <= 1'b0;
  not_bs_finished <= 1'b1;
  retry <= 1'b0;
end
else begin
  enable <= 1'b1;
     if (enable == 1'b1) begin
       if (clk_iserdes_data != 7'b1100001) begin flag1 <= 1'b1; end else begin flag1 <= 1'b0; end
       if (clk_iserdes_data != 7'b1100011) begin flag2 <= 1'b1; end else begin flag2 <= 1'b0; end
         if (bsstate == 0) begin
         if (flag1 == 1'b1 && flag2 == 1'b1) begin
                bslip <= 1'b1;            // bitslip needed
                bsstate <= 1;
              end
              else begin
                bs_finished <= 1'b1;          // bitslip done
                not_bs_finished <= 1'b0;        // bitslip done
              end
    end
       else if (bsstate == 1) begin        
              bslip <= 1'b0; 
              bcount <= bcount + 4'h1;
         if (bcount == 4'hF) begin
                bsstate <= 0;
              end
       end
     end
end
end

// Clock input 

IBUFGDS #(
  .DIFF_TERM (DIFF_TERM)) 
iob_clk_in (
  .I   (clkin_p),
  .IB  (clkin_n),
  .O   (rx_clk_in));

genvar i;
genvar j;

IDELAYE2 #(
.REFCLK_FREQUENCY      (REF_FREQ),
  .HIGH_PERFORMANCE_MODE  (HIGH_PERFORMANCE_MODE),
        .IDELAY_VALUE    (1),
        .DELAY_SRC       ("IDATAIN"),
        .IDELAY_TYPE     ("VAR_LOAD"))
idelay_cm(                 
  .DATAOUT    (rx_clk_in_d),
  .C      (rxclk_div),
  .CE      (1'b0),
  .INC      (1'b0),
  .DATAIN      (1'b0),
  .IDATAIN    (rx_clk_in),
  .LD      (1'b1),
  .LDPIPEEN    (1'b0),
  .REGRST      (1'b0),
  .CINVCTRL    (1'b0),
  .CNTVALUEIN    (c_delay_in),
  .CNTVALUEOUT    ());
  
ISERDESE2 #(
  .DATA_WIDTH       (7),         
  .DATA_RATE        ("SDR"),       
  .SERDES_MODE      ("MASTER"),       
  .IOBDELAY        ("IFD"),       
  .INTERFACE_TYPE   ("NETWORKING"))     
iserdes_cm (
  .D           (1'b0),
  .DDLY         (rx_clk_in_d),
  .CE1         (1'b1),
  .CE2         (1'b1),
  .CLK        (rxclk),
  .CLKB        (~rxclk),
  .RST         (local_reset),
  .CLKDIV      (rxclk_div),
  .CLKDIVP      (1'b0),
  .OCLK        (1'b0),
  .OCLKB        (1'b0),
  .DYNCLKSEL        (1'b0),
  .DYNCLKDIVSEL      (1'b0),
  .SHIFTIN1     (1'b0),
  .SHIFTIN2     (1'b0),
  .BITSLIP     (bslip),
  .O       (),
  .Q8       (),
  .Q7       (clk_iserdes_data[0]),
  .Q6       (clk_iserdes_data[1]),
  .Q5       (clk_iserdes_data[2]),
  .Q4       (clk_iserdes_data[3]),
  .Q3       (clk_iserdes_data[4]),
  .Q2       (clk_iserdes_data[5]),
  .Q1       (clk_iserdes_data[6]),
  .OFB       (),
  .SHIFTOUT1     (),
  .SHIFTOUT2     ());  

always @ (posedge rxclk_div) begin        // 
  clk_iserdes_data_d <= clk_iserdes_data;
  if ((clk_iserdes_data != clk_iserdes_data_d) && (clk_iserdes_data != 7'h00) && (clk_iserdes_data != 7'h7F)) begin
    data_different <= 1'b1;
  end
  else begin
    data_different <= 1'b0;
  end
  if ((clk_iserdes_data == 7'h00) || (clk_iserdes_data == 7'h7F)) begin
    no_clock <= 1'b1;
  end
  else begin
    no_clock <= 1'b0;
  end
end
  
always @ (posedge rxclk_div) begin          // clock delay shift state machine
  if (local_reset == 1'b1) begin
    scount <= 6'h00;
    state2 <= 0;
    state2_count <= 4'h0;
    locked_out <= 1'b0;
    chfoundc <= 1'b1;
    chfound <= 1'b0;
    c_delay_in <= bt_val;            // Start the delay line at the current bit period
    c_loop_cnt <= 2'b00;  
  end
  else begin
    if (scount[5] == 1'b0) begin
      if (no_clock == 1'b0) begin
        scount <= scount + 6'h01;
      end
      else begin
        scount <= 6'h00;
      end
    end
    state2_count <= state2_count + 4'h1;
    if (chfoundc == 1'b1) begin
      chfound <= 1'b0;
    end
    else if (chfound == 1'b0 && data_different == 1'b1) begin
      chfound <= 1'b1;
    end
    if ((state2_count == 4'hF && scount[5] == 1'b1)) begin
      case(state2)           
      0  : begin              // decrement delay and look for a change
          if (chfound == 1'b1 || (c_loop_cnt == 2'b11 && c_delay_in == 5'h00)) begin  // quit loop if we've been around a few times
          chfoundc <= 1'b1;        // change found
          state2 <= 1;
          c_delay_in <= old_c_delay_in;
          end
          else begin
          chfoundc <= 1'b0;
          old_c_delay_in <= c_delay_in;
          if (c_delay_in != 5'h00) begin      // check for underflow
            c_delay_in <= c_delay_in - 5'h01;
          end
          else begin
            c_delay_in <= bt_val;
            c_loop_cnt <= c_loop_cnt + 2'b01;
          end
          end
          end
      1  : begin              // add half a bit period using input information
          state2 <= 2;
          if (c_delay_in < {1'b0, bt_val[4:1]}) begin    // choose the lowest delay value to minimise jitter
             c_delay_in <= c_delay_in + {1'b0, bt_val[4:1]};
          end
          else begin
             c_delay_in <= c_delay_in - {1'b0, bt_val[4:1]};
          end
          end
      default  : begin              // issue locked out signal
          locked_out <= 1'b1;
           end
      endcase
    end
  end
end
      
generate
for (i = 0; i <= D-1; i = i+1)
begin : loop3

delay_controller_wrap # (
  .S       (7))
dc_inst (                       
  .m_datain    (mdataout[7*i+6:7*i]),
  .s_datain    (sdataout[7*i+6:7*i]),
  .enable_phase_detector  (enable_phase_detector),
  .enable_monitor    (enable_monitor),
  .reset      (not_bs_finished),
  .clk      (rxclk_div),
  .c_delay_in    (c_delay_in),
  .m_delay_out    (m_delay_val_in[5*i+4:5*i]),
  .s_delay_out    (s_delay_val_in[5*i+4:5*i]),
  .data_out    (mdataoutd[7*i+6:7*i]),
  .bt_val      (bt_val),
  .del_mech    (1'b0),
  .m_delay_1hot    (m_delay_1hot[32*i+31:32*i]),
  .results    (eye_info[32*i+31:32*i]));

// Data bit Receivers 

IBUFDS_DIFF_OUT #(
  .DIFF_TERM     (DIFF_TERM)) 
data_in (
  .I          (datain_p[i]),
  .IB           (datain_n[i]),
  .O             (rx_data_in_p[i]),
  .OB             (rx_data_in_n[i]));

assign rx_data_in_m[i] = rx_data_in_p[i]  ^ RX_SWAP_MASK[i];
assign rx_data_in_s[i] = ~rx_data_in_n[i] ^ RX_SWAP_MASK[i];

IDELAYE2 #(
.REFCLK_FREQUENCY      (REF_FREQ),
  .HIGH_PERFORMANCE_MODE  (HIGH_PERFORMANCE_MODE),
        .IDELAY_VALUE    (0),
        .DELAY_SRC    ("IDATAIN"),
        .IDELAY_TYPE    ("VAR_LOAD"))
idelay_m(                 
  .DATAOUT    (rx_data_in_md[i]),
  .C      (rxclk_div),
  .CE      (1'b0),
  .INC      (1'b0),
  .DATAIN      (1'b0),
  .IDATAIN    (rx_data_in_m[i]),
  .LD      (1'b1),
  .LDPIPEEN    (1'b0),
  .REGRST      (1'b0),
  .CINVCTRL    (1'b0),
  .CNTVALUEIN    (m_delay_val_in[5*i+4:5*i]),
  .CNTVALUEOUT    ());
    
ISERDESE2 #(
  .DATA_WIDTH       (7),       
  .DATA_RATE        ("SDR"),     
  .SERDES_MODE      ("MASTER"),     
  .IOBDELAY        ("IFD"),     
  .INTERFACE_TYPE   ("NETWORKING"))   
iserdes_m (
  .D           (1'b0),
  .DDLY         (rx_data_in_md[i]),
  .CE1         (1'b1),
  .CE2         (1'b1),
  .CLK         (rxclk),
  .CLKB        (~rxclk),
  .RST         (rst_iserdes),
  .CLKDIV      (rxclk_div),
  .CLKDIVP      (1'b0),
  .OCLK        (1'b0),
  .OCLKB        (1'b0),
  .DYNCLKSEL        (1'b0),
  .DYNCLKDIVSEL      (1'b0),
  .SHIFTIN1     (1'b0),
  .SHIFTIN2     (1'b0),
  .BITSLIP     (bslip),
  .O       (),
  .Q8        (),
  .Q7        (mdataout[7*i+0]),
  .Q6        (mdataout[7*i+1]),
  .Q5        (mdataout[7*i+2]),
  .Q4        (mdataout[7*i+3]),
  .Q3        (mdataout[7*i+4]),
  .Q2        (mdataout[7*i+5]),
  .Q1        (mdataout[7*i+6]),
  .OFB       (),
  .SHIFTOUT1    (),
  .SHIFTOUT2     ());

IDELAYE2 #(
.REFCLK_FREQUENCY      (REF_FREQ),
  .HIGH_PERFORMANCE_MODE  (HIGH_PERFORMANCE_MODE),
        .IDELAY_VALUE    (0),
        .DELAY_SRC    ("IDATAIN"),
        .IDELAY_TYPE    ("VAR_LOAD"))
idelay_s(                 
  .DATAOUT    (rx_data_in_sd[i]),
  .C      (rxclk_div),
  .CE      (1'b0),
  .INC      (1'b0),
  .DATAIN      (1'b0),
  .IDATAIN    (rx_data_in_s[i]),
  .LD      (1'b1),
  .LDPIPEEN    (1'b0),
  .REGRST      (1'b0),
  .CINVCTRL    (1'b0),
  .CNTVALUEIN    (s_delay_val_in[5*i+4:5*i]),
  .CNTVALUEOUT    ());
  
ISERDESE2 #(
  .DATA_WIDTH       (7),       
  .DATA_RATE        ("SDR"),     
//  .SERDES_MODE      ("SLAVE"),     
  .IOBDELAY        ("IFD"),     
  .INTERFACE_TYPE   ("NETWORKING"))   
iserdes_s (
  .D           (1'b0),
  .DDLY         (rx_data_in_sd[i]),
  .CE1         (1'b1),
  .CE2         (1'b1),
  .CLK         (rxclk),
  .CLKB        (~rxclk),
  .RST         (rst_iserdes),
  .CLKDIV      (rxclk_div),
  .CLKDIVP      (1'b0),
  .OCLK        (1'b0),
  .OCLKB        (1'b0),
  .DYNCLKSEL        (1'b0),
  .DYNCLKDIVSEL      (1'b0),
  .SHIFTIN1     (1'b0),
  .SHIFTIN2     (1'b0),
  .BITSLIP     (bslip),
  .O       (),
  .Q8        (),
  .Q7        (sdataout[7*i+0]),
  .Q6        (sdataout[7*i+1]),
  .Q5        (sdataout[7*i+2]),
  .Q4        (sdataout[7*i+3]),
  .Q3        (sdataout[7*i+4]),
  .Q2        (sdataout[7*i+5]),
  .Q1        (sdataout[7*i+6]),
  .OFB       (),
  .SHIFTOUT1    (),
  .SHIFTOUT2     ());

for (j = 0; j <= 6; j = j+1) begin : loop1      // Assign data bits to correct serdes according to required format
  if (DATA_FORMAT == "PER_CLOCK") begin
    assign rx_data[D*j+i] = mdataoutd[7*i+j];
  end 
  else begin
    assign rx_data[7*i+j] = mdataoutd[7*i+j];
  end
end
end
endgenerate
endmodule



//////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2012-2015 Xilinx, Inc.
// This design is confidential and proprietary of Xilinx, All Rights Reserved.
//////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /   Vendor: Xilinx
// \   \   \/    Version: 1.2
//  \   \        Filename: serdes_7_to_1_diff_sdr.v
//  /   /        Date Last Modified:  21JAN2015
// /___/   /\    Date Created: 2SEP2011
// \   \  /  \
//  \___\/\___\
// 
//Device: 	7-Series
//Purpose:  	D-bit generic SDR 7:1 transmitter module via 7:1 serdes mode
// 		Takes in 7*D bits of data and serialises this to D bits
// 		data is transmitted LSB first
//		Data formatting is set by the DATA_FORMAT parameter. 
//		PER_CLOCK (default) format transmits bits for 0, 1, 2 ... on the same transmitter clock edge
//		PER_CHANL format transmits bits for 0, 7, 14 .. on the same transmitter clock edge
//		Data inversion can be accomplished via the TX_SWAP_MASK 
//		parameter if required.
//		Also generates clock output
//
//Reference:	XAPP585.pdf
//    
//Revision History:
//    Rev 1.0 - First created (nicks)
//    Rev 1.1 - PER_CLOCK and PER_CHANL descriptions swapped
//    Rev 1.2 - Updated format (brandond)
//
//////////////////////////////////////////////////////////////////////////////
//
//  Disclaimer: 
//
//		This disclaimer is not a license and does not grant any rights to the materials 
//              distributed herewith. Except as otherwise provided in a valid license issued to you 
//              by Xilinx, and to the maximum extent permitted by applicable law: 
//              (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND WITH ALL FAULTS, 
//              AND XILINX HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, 
//              INCLUDING BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-INFRINGEMENT, OR 
//              FITNESS FOR ANY PARTICULAR PURPOSE; and (2) Xilinx shall not be liable (whether in contract 
//              or tort, including negligence, or under any other theory of liability) for any loss or damage 
//              of any kind or nature related to, arising under or in connection with these materials, 
//              including for any direct, or any indirect, special, incidental, or consequential loss 
//              or damage (including loss of data, profits, goodwill, or any type of loss or damage suffered 
//              as a result of any action brought by a third party) even if such damage or loss was 
//              reasonably foreseeable or Xilinx had been advised of the possibility of the same.
//
//  Critical Applications:
//
//		Xilinx products are not designed or intended to be fail-safe, or for use in any application 
//		requiring fail-safe performance, such as life-support or safety devices or systems, 
//		Class III medical devices, nuclear facilities, applications related to the deployment of airbags,
//		or any other applications that could lead to death, personal injury, or severe property or 
//		environmental damage (individually and collectively, "Critical Applications"). Customer assumes 
//		the sole risk and liability of any use of Xilinx products in Critical Applications, subject only 
//		to applicable laws and regulations governing limitations on product liability.
//
//  THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS PART OF THIS FILE AT ALL TIMES.
//
//////////////////////////////////////////////////////////////////////////////

`timescale 1ps/1ps

module serdes_7_to_1_diff_sdr (txclk, reset, pixel_clk, datain, clk_pattern, dataout_p, dataout_n, clkout_p, clkout_n) ;

parameter integer 	D = 16 ;			// Set the number of outputs
parameter         	DATA_FORMAT = "PER_CLOCK" ;     // Parameter Used to determine method for mapping input parallel word to output serial words
                                        	
input 			txclk ;				// Tx Clock network
input 			reset ;				// Reset
input 			pixel_clk ;			// pixel rate clock
input 	[(D*7)-1:0]	datain ;  			// Data for output
input 	[6:0]		clk_pattern ;  			// clock pattern for output
output 	[D-1:0]		dataout_p ;			// output data
output 	[D-1:0]		dataout_n ;			// output data
output 			clkout_p ;			// output clock
output 			clkout_n ;			// output clock

wire	[D-1:0]		tx_data_out ;
wire	[D*7-1:0]	mdataina ;	
reg			reset_int ;	

parameter [D-1:0] TX_SWAP_MASK = 16'h0000 ;		// pinswap mask for output bits (0 = no swap (default), 1 = swap). Allows outputs to be connected the 'wrong way round' to ease PCB routing.

always @ (posedge pixel_clk or posedge reset) begin
if (reset == 1'b1) begin
	reset_int <= 1'b1 ;
end
else begin
	reset_int <= 1'b0 ;
end
end

genvar i ;
genvar j ;

generate
for (i = 0 ; i <= (D-1) ; i = i+1)
begin : loop0

OBUFDS io_data_out (
	.O    			(dataout_p[i]),
	.OB       		(dataout_n[i]),
	.I         		(tx_data_out[i]));

// re-arrange data bits for transmission and invert lines as given by the mask
// NOTE If pin inversion is required (non-zero SWAP MASK) then inverters will occur in fabric, as there are no inverters in the OSERDESE2
// This can be avoided by doing the inversion (if necessary) in the user logic

for (j = 0 ; j <= 6 ; j = j+1) begin : loop1
	if (DATA_FORMAT == "PER_CLOCK") begin
		assign mdataina[7*i+j] = datain[i+(D*j)] ^ TX_SWAP_MASK[i] ;
	end 
	else begin
		assign mdataina[7*i+j] = datain[7*i+j] ^ TX_SWAP_MASK[i] ;
	end
end

OSERDESE2 #(
	.DATA_WIDTH     	(7), 			// SERDES word width
	.TRISTATE_WIDTH     	(1), 
	.DATA_RATE_OQ      	("SDR"), 		// <SDR>, DDR
	.DATA_RATE_TQ      	("SDR"), 		// <SDR>, DDR
	.SERDES_MODE    	("MASTER"))  		// <DEFAULT>, MASTER, SLAVE
oserdes_m (
	.OQ       		(tx_data_out[i]),
	.OCE     		(1'b1),
	.CLK    		(txclk),
	.RST     		(reset_int),
	.CLKDIV  		(pixel_clk),
	.D8  			(1'b0),
	.D7  			(mdataina[(7*i)+6]),
	.D6  			(mdataina[(7*i)+5]),
	.D5  			(mdataina[(7*i)+4]),
	.D4  			(mdataina[(7*i)+3]),
	.D3  			(mdataina[(7*i)+2]),
	.D2  			(mdataina[(7*i)+1]),
	.D1  			(mdataina[(7*i)+0]),
	.TQ  			(),
	.T1 			(1'b0),
	.T2 			(1'b0),
	.T3 			(1'b0),
	.T4 			(1'b0),
	.TCE	 		(1'b1),
	.TBYTEIN		(1'b0),
	.TBYTEOUT		(),
	.OFB	 		(),
	.TFB	 		(),
	.SHIFTOUT1 		(),			
	.SHIFTOUT2 		(),			
	.SHIFTIN1 		(1'b0),	
	.SHIFTIN2 		(1'b0)) ;				

end
endgenerate

OBUFDS io_clk_out (
	.O    			(clkout_p),
	.OB       		(clkout_n),
	.I         		(tx_clk_out));

OSERDESE2 #(
	.DATA_WIDTH     	(7), 			// SERDES word width
	.TRISTATE_WIDTH     	(1), 
	.DATA_RATE_OQ      	("SDR"), 		// <SDR>, DDR
	.DATA_RATE_TQ      	("SDR"), 		// <SDR>, DDR
	.SERDES_MODE    	("MASTER"))  		// <DEFAULT>, MASTER, SLAVE
oserdes_cm (
	.OQ       		(tx_clk_out),
	.OCE     		(1'b1),
	.CLK    		(txclk),
	.RST     		(reset_int),
	.CLKDIV  		(pixel_clk),
	.D8  			(1'b0),
	.D7  			(clk_pattern[6]),
	.D6  			(clk_pattern[5]),
	.D5  			(clk_pattern[4]),
	.D4  			(clk_pattern[3]),
	.D3  			(clk_pattern[2]),
	.D2  			(clk_pattern[1]),
	.D1  			(clk_pattern[0]),
	.TQ  			(),
	.T1 			(1'b0),
	.T2 			(1'b0),
	.T3 			(1'b0),
	.T4 			(1'b0),
	.TCE	 		(1'b1),
	.TBYTEIN		(1'b0),
	.TBYTEOUT		(),
	.OFB	 		(),
	.TFB	 		(),
	.SHIFTOUT1 		(),			
	.SHIFTOUT2 		(),			
	.SHIFTIN1 		(1'b0),	
	.SHIFTIN2 		(1'b0)) ;	
	
endmodule



///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2012-2015 Xilinx, Inc.
// This design is confidential and proprietary of Xilinx, All Rights Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /   Vendor: Xilinx
// \   \   \/    Version: 1.2
//  \   \        Filename: clock_generator_pll_7_to_1_diff_sdr.v
//  /   /        Date Last Modified:  20JAN2015
// /___/   /\    Date Created: 5JAN2010
// \   \  /  \
//  \___\/\___\
// 
//Device: 	7 Series
//Purpose:  	SDR PLL or MMCM Based clock generator. Takes in a differential clock and multiplies it
//	    	appropriately 
//Reference:	XAPP585
//    
//Revision History:
//    Rev 1.0 - First created (nicks)
//    Rev 1.1 - Some net names changed to make more sense in Vivado
//    Rev 1.2 - Updated format (brandond)
//
///////////////////////////////////////////////////////////////////////////////
//
//  Disclaimer: 
//
//		This disclaimer is not a license and does not grant any rights to the materials 
//              distributed herewith. Except as otherwise provided in a valid license issued to you 
//              by Xilinx, and to the maximum extent permitted by applicable law: 
//              (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND WITH ALL FAULTS, 
//              AND XILINX HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, 
//              INCLUDING BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-INFRINGEMENT, OR 
//              FITNESS FOR ANY PARTICULAR PURPOSE; and (2) Xilinx shall not be liable (whether in contract 
//              or tort, including negligence, or under any other theory of liability) for any loss or damage 
//              of any kind or nature related to, arising under or in connection with these materials, 
//              including for any direct, or any indirect, special, incidental, or consequential loss 
//              or damage (including loss of data, profits, goodwill, or any type of loss or damage suffered 
//              as a result of any action brought by a third party) even if such damage or loss was 
//              reasonably foreseeable or Xilinx had been advised of the possibility of the same.
//
//  Critical Applications:
//
//		Xilinx products are not designed or intended to be fail-safe, or for use in any application 
//		requiring fail-safe performance, such as life-support or safety devices or systems, 
//		Class III medical devices, nuclear facilities, applications related to the deployment of airbags,
//		or any other applications that could lead to death, personal injury, or severe property or 
//		environmental damage (individually and collectively, "Critical Applications"). Customer assumes 
//		the sole risk and liability of any use of Xilinx products in Critical Applications, subject only 
//		to applicable laws and regulations governing limitations on product liability.
//
//  THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS PART OF THIS FILE AT ALL TIMES.
//
//////////////////////////////////////////////////////////////////////////////

`timescale 1ps/1ps

module clock_generator_pll_7_to_1_diff_sdr (clkin_p, clkin_n, txclk, reset, pixel_clk, mmcm_lckd, status) ;

parameter real 	  	CLKIN_PERIOD = 6.000 ;		// clock period (ns) of input clock on clkin_p
parameter         	DIFF_TERM = "FALSE" ; 		// Parameter to enable internal differential termination
parameter integer      	MMCM_MODE = 1 ;   		// Parameter to set multiplier for MMCM to get VCO in correct operating range. 1 multiplies input clock by 7, 2 multiplies clock by 14, etc
parameter         	TX_CLOCK = "BUFIO" ;   		// Parameter to set transmission clock buffer type, BUFIO, BUF_H, BUF_G
parameter         	PIXEL_CLOCK = "BUF_G" ;       	// Parameter to set final clock buffer type, BUF_R, BUF_H, BUF_G
parameter         	USE_PLL = "FALSE" ;          	// Parameter to enable PLL use rather than MMCM use, note, PLL does not support BUFIO and BUFR

input			reset ;				// reset (active high)
input			clkin_p, clkin_n ;		// differential clock inputs
output			txclk ;				// CLK for serdes
output			pixel_clk ;			// Pixel clock output
output			mmcm_lckd ;			// Locked output from BUFPLL
output 	[6:0]		status ;	 		// clock status
                	
wire 			clkint ;			// clock input from pin
wire    		txpllmmcm_x1 ;      		// pll generated x1 clock
wire    		txpllmmcm_xn ;      		// pll generated xn clock

IBUFGDS #(
	.DIFF_TERM 		(DIFF_TERM)) 
clk_iob_in (
	.I    			(clkin_p),
	.IB       		(clkin_n),
	.O         		(clkint));

generate
if (USE_PLL == "FALSE") begin : loop8			// use an MMCM
assign status[6] = 1'b1 ; 
assign status[3:2] = 2'b00 ;
     
MMCME2_ADV #(
      .BANDWIDTH		("OPTIMIZED"),  		
      .CLKFBOUT_MULT_F		(7*MMCM_MODE),       		
      .CLKFBOUT_PHASE		(0.0),     			
      .CLKIN1_PERIOD		(CLKIN_PERIOD),  		
      .CLKIN2_PERIOD		(CLKIN_PERIOD),  		
      .CLKOUT0_DIVIDE_F		(MMCM_MODE),       		
      .CLKOUT0_DUTY_CYCLE	(0.5), 				
      .CLKOUT0_PHASE		(0.0), 				
      .CLKOUT1_DIVIDE		(8),   				
      .CLKOUT1_DUTY_CYCLE	(0.5), 				
      .CLKOUT1_PHASE		(0.0), 				
      .CLKOUT2_DIVIDE		(7*MMCM_MODE),   		
      .CLKOUT2_DUTY_CYCLE	(0.5), 				
      .CLKOUT2_PHASE		(0.0), 				
      .CLKOUT3_DIVIDE		(8),   				
      .CLKOUT3_DUTY_CYCLE	(0.5), 				
      .CLKOUT3_PHASE		(0.0), 				
      .CLKOUT4_DIVIDE		(8),   				
      .CLKOUT4_DUTY_CYCLE	(0.5), 				
      .CLKOUT4_PHASE		(0.0),      			
      .CLKOUT5_DIVIDE		(8),       			
      .CLKOUT5_DUTY_CYCLE	(0.5), 				
      .CLKOUT5_PHASE		(0.0),      			
      .COMPENSATION		("ZHOLD"), 			
      .DIVCLK_DIVIDE		(1),        			
      .REF_JITTER1		(0.100))       			
tx_mmcme2_adv_inst (
      .CLKFBOUT			(txpllmmcm_x1),           	
      .CLKFBOUTB		(),              		
      .CLKFBSTOPPED		(),              		
      .CLKINSTOPPED		(),              		
      .CLKOUT0			(txpllmmcm_xn),      		
      .CLKOUT0B			(),      			
      .CLKOUT1			(),     	 		
      .CLKOUT1B			(),      			
      .CLKOUT2			(), 				
      .CLKOUT2B			(),      			
      .CLKOUT3			(),              		
      .CLKOUT3B			(),      			
      .CLKOUT4			(),              		
      .CLKOUT5			(),              		
      .CLKOUT6			(),              		
      .DO			(),                    		
      .DRDY			(),                  		
      .PSDONE			(),  
      .PSCLK			(1'b0),  
      .PSEN			(1'b0),  
      .PSINCDEC			(1'b0),  
      .PWRDWN			(1'b0),  
      .LOCKED			(mmcm_lckd),        		
      .CLKFBIN			(pixel_clk),			
      .CLKIN1			(clkint),     			
      .CLKIN2			(1'b0),		     		
      .CLKINSEL			(1'b1),             		
      .DADDR			(7'h00),            		
      .DCLK			(1'b0),               		
      .DEN			(1'b0),                		
      .DI			(16'h0000),        		
      .DWE			(1'b0),                		
      .RST			(reset)) ;               	

   if (PIXEL_CLOCK == "BUF_G") begin 				// Final clock selection
      BUFG	bufg_mmcm_x1 (.I(txpllmmcm_x1), .O(pixel_clk)) ;
      assign status[1:0] = 2'b00 ;
   end
   else if (PIXEL_CLOCK == "BUF_R") begin
      BUFR #(.BUFR_DIVIDE("1"),.SIM_DEVICE("7SERIES"))bufr_mmcm_x1 (.I(txpllmmcm_x1),.CE(1'b1),.O(pixel_clk),.CLR(1'b0)) ;
      assign status[1:0] = 2'b01 ;
   end
   else begin 
      BUFH	bufh_mmcm_x1 (.I(txpllmmcm_x1), .O(pixel_clk)) ;
      assign status[1:0] = 2'b10 ;
   end
      
   if (TX_CLOCK == "BUF_G") begin				// Sample clock selection
      BUFG	bufg_mmcm_xn (.I(txpllmmcm_xn), .O(txclk)) ;
      assign status[5:4] = 2'b00 ;
   end
   else if (TX_CLOCK == "BUFIO") begin
      BUFIO  	bufio_mmcm_xn (.I (txpllmmcm_xn), .O(txclk)) ;
      assign status[5:4] = 2'b11 ;
   end
   else begin 
      BUFH	bufh_mmcm_xn (.I(txpllmmcm_xn), .O(txclk)) ;
      assign status[5:4] = 2'b10 ;
   end
   
end 
else begin							// Use a PLL
assign status[6] = 1'b0 ; 
assign status[3:2] = 2'b00 ;

PLLE2_ADV #(
      .BANDWIDTH		("OPTIMIZED"),  		
      .CLKFBOUT_MULT		(7*MMCM_MODE),       		
      .CLKFBOUT_PHASE		(0.0),     			
      .CLKIN1_PERIOD		(CLKIN_PERIOD),  		
      .CLKIN2_PERIOD		(CLKIN_PERIOD),  		
      .CLKOUT0_DIVIDE		(MMCM_MODE),       		
      .CLKOUT0_DUTY_CYCLE	(0.5), 				
      .CLKOUT0_PHASE		(0.0), 				
      .CLKOUT1_DIVIDE		(14*MMCM_MODE),   		
      .CLKOUT1_DUTY_CYCLE	(0.5), 				
      .CLKOUT1_PHASE		(0.0), 				
      .CLKOUT2_DIVIDE		(7*MMCM_MODE),   		
      .CLKOUT2_DUTY_CYCLE	(0.5), 				
      .CLKOUT2_PHASE		(0.0), 				
      .CLKOUT3_DIVIDE		(8),   				
      .CLKOUT3_DUTY_CYCLE	(0.5), 				
      .CLKOUT3_PHASE		(0.0), 				
      .CLKOUT4_DIVIDE		(8),   				
      .CLKOUT4_DUTY_CYCLE	(0.5), 				
      .CLKOUT4_PHASE		(0.0),      			
      .CLKOUT5_DIVIDE		(8),       			
      .CLKOUT5_DUTY_CYCLE	(0.5), 				
      .CLKOUT5_PHASE		(0.0),      			
      .COMPENSATION		("ZHOLD"), 			
      .DIVCLK_DIVIDE		(1),        			
      .REF_JITTER1		(0.100))       			
tx_mmcme2_adv_inst (
      .CLKFBOUT			(txpllmmcm_x1),              	
      .CLKOUT0			(txpllmmcm_xn),      		
      .CLKOUT1			(),      			
      .CLKOUT2			(), 				
      .CLKOUT3			(),              		
      .CLKOUT4			(),              		
      .CLKOUT5			(),              		
      .DO			(),                    		
      .DRDY			(),                  		
      .PWRDWN			(1'b0),  
      .LOCKED			(mmcm_lckd),        		
      .CLKFBIN			(pixel_clk),			
      .CLKIN1			(clkint),     			
      .CLKIN2			(1'b0),		     		
      .CLKINSEL			(1'b1),             		
      .DADDR			(7'h00),            		
      .DCLK			(1'b0),               		
      .DEN			(1'b0),                		
      .DI			(16'h0000),        		
      .DWE			(1'b0),                		
      .RST			(reset)) ;               	

   if (PIXEL_CLOCK == "BUF_G") begin 				// Final clock selection
      BUFG	bufg_mmcm_x1 (.I(txpllmmcm_x1), .O(pixel_clk)) ;
      assign status[1:0] = 2'b00 ;
   end
   else if (PIXEL_CLOCK == "BUF_R") begin
      BUFR #(.BUFR_DIVIDE("1"),.SIM_DEVICE("7SERIES"))bufr_mmcm_x1 (.I(txpllmmcm_x1),.CE(1'b1),.O(pixel_clk),.CLR(1'b0)) ;
      assign status[1:0] = 2'b01 ;
   end
   else begin 
      BUFH	bufh_mmcm_x1 (.I(txpllmmcm_x1), .O(pixel_clk)) ;
      assign status[1:0] = 2'b10 ;
   end
      
   if (TX_CLOCK == "BUF_G") begin				// Sample clock selection
      BUFG	bufg_mmcm_xn (.I(txpllmmcm_xn), .O(txclk)) ;
      assign status[5:4] = 2'b01 ;
   end
   else if (TX_CLOCK == "BUFIO") begin
      BUFIO  	bufio_mmcm_xn (.I (txpllmmcm_xn), .O(txclk)) ;
      assign status[5:4] = 2'b11 ;
   end
   else begin 
      BUFH	bufh_mmcm_xn (.I(txpllmmcm_xn), .O(txclk)) ;
      assign status[5:4] = 2'b10 ;
   end
   
end 
endgenerate
endmodule

