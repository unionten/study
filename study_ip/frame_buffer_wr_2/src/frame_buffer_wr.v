`timescale 1ns / 1ps
`define CDC_MULTI_BIT_SIGNAL(aclk_in,adata_in,bclk_in,bdata_out,DATA_WIDTH)                   generate begin xpm_cdc_array_single #(.DEST_SYNC_FF(4),.INIT_SYNC_FF(0),.SIM_ASSERT_CHK(0),.SRC_INPUT_REG(1),.WIDTH(DATA_WIDTH)) cdc_u(.src_clk(aclk_in),.src_in(adata_in),.dest_clk(bclk_in),.dest_out(bdata_out));    end  endgenerate  
`define CDC_SINGLE_BIT_PULSE(aclk_in,arst_in,apulse_in,bclk_in,brst_in,bpulse_out,SIM)          generate if(SIM==0)begin  xpm_cdc_pulse #(.DEST_SYNC_FF(4), .INIT_SYNC_FF(0),.REG_OUTPUT(0),.RST_USED(1),.SIM_ASSERT_CHK (0)) cdc_u (.src_clk(aclk_in),.src_rst(arst_in),.src_pulse(apulse_in),.dest_clk(bclk_in),.dest_rst(brst_in),.dest_pulse(bpulse_out));   end else begin   reg [5:0] name1 = 0;wire name2;always@(posedge aclk_in)if(arst_in)name1[0] <=0;else name1[0] <= apulse_in;assign name2 = apulse_in & ~name1[0]; always@(posedge aclk_in)if(arst_in)name1[1] <= 0;else name1[1] <= name2 ? ~name1[1]:name1[1];always@(posedge bclk_in)if(brst_in)name1[5:2]<=0;else begin name1[2]<=name1[1];name1[3]<=name1[2];name1[4]<=name1[3];name1[5]<=name1[4];end  assign bpulse_out=name1[4]^name1[5];  end  endgenerate
`define NEG_MONITOR(clk_in,rst_in,in,out)          generate  begin  reg buf_name1 = 0; always@(posedge clk_in)begin if(rst_in)buf_name1 <= 0; else  buf_name1 <= in; end assign out = (buf_name1)&(~in);  end  endgenerate
`define POS_MONITOR(clk_in,rst_in,in,out)          generate  begin  reg buf_name1 = 0; always@(posedge clk_in)begin if(rst_in)buf_name1 <= 0; else  buf_name1 <= in; end assign out = (~buf_name1)&(in);  end  endgenerate
`define POS_STRETCH(clk_in,rst_in,pulse_in,pulse_out,C_DELAY_NUM)          generate  begin    reg [C_DELAY_NUM-2:0] temp_name = 0; always@(posedge clk_in)begin  if(rst_in)temp_name <= {(C_DELAY_NUM-1){1'b0}}; else temp_name <= pulse_in ? {(C_DELAY_NUM-1){1'b1} }: temp_name<<1 ; end  assign  pulse_out = temp_name[C_DELAY_NUM-2]|pulse_in;  end  endgenerate
`define NEG_STRETCH(clk_in,rst_in,pulsen_in,pulsen_out,C_DELAY_NUM)          generate  begin    reg [C_DELAY_NUM-2:0] temp_name = 0; always@(posedge clk_in)begin  if(rst_in)temp_name <= {(C_DELAY_NUM-1){1'b0}}; else temp_name <= ~pulsen_in ? {(C_DELAY_NUM-1){1'b1} }: temp_name<<1 ; end  assign  pulsen_out = ~( temp_name[C_DELAY_NUM-2] | ~pulsen_in ) ;  end  endgenerate
`define HANDSHAKE(aclk_in,arst_in,apulse_in,adata_in,bclk_in,brst_in,bpulse_out,bdata_out,DATA_WIDTH,SIM)         generate  if(SIM==0) begin  handshake  #(.DATA_WIDTH(DATA_WIDTH))  handshake_u (.SRC_CLK_I(aclk_in),.SRC_RST_I(arst_in),.SRC_DATA_I( adata_in),.SRC_SYNC_PULSE_I ( apulse_in), .DST_CLK_I ( bclk_in),.DST_DATA_O (bdata_out),.DST_SYNC_FINISH_O(bpulse_out) ); end  else  begin  handshake2 #(.DATA_WIDTH(DATA_WIDTH))  handshake_u (.SRC_CLK_I(aclk_in),.SRC_RST_I(arst_in),.SRC_DATA_I( adata_in),.SRC_SYNC_PULSE_I ( apulse_in), .DST_CLK_I (bclk_in),.DST_DATA_O (bdata_out ),.DST_SYNC_FINISH_O(bpulse_out) ); end  endgenerate   


/////////////////////////////////REG TABLE///////////////////////////////////////
`define  ADDR_COLOR_DEPTH     16'h0024 //new
`define  ADDR_COLOR_SPACE     16'h0028 //new
`define  ADDR_MEM_BYTES       16'h002c //new
`define  ADDR_STRIP_SET       16'h000c //old 
`define  ADDR_HACTIVE         16'h0010 //old
`define  ADDR_VACTIVE         16'h0014 //old
`define  ADDR_ENABLE          16'h0018 //old contain port_num([15:12]) and enable(0:0)
`define  ADDR_VS_REVERSE_EN   16'h001c 
`define  ADDR_HS_REVERSE_EN   16'h001c 
`define  ADDR_DE_REVERSE_EN   16'h001c 


//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:  yzhu
// 
// Create Date: 2023/06/07 17:59:09
// Design Name: 
// Module Name: frame_buffer_wr  
//////////////////////////////////////////////////////////////////////////////////
//define WR_STRIP_SET_OFFSET		0x000C
//define WR_H_ACTIVE_OFFSET		    0x0010
//define WR_V_ACTIVE_OFFSET		    0x0014
//define WR_VDMA_DVAL_OFFSET		0x0018
//1674  1943
//840 1895
module frame_buffer_wr_2(
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


input                                    VID_CLK_I        ,
input                                    VID_RSTN_I       ,
input                                    VID_LOCKED_I     ,
input  [C_MAX_PORT_NUM-1:0]              VS_I             ,
input  [C_MAX_PORT_NUM-1:0]              HS_I             ,
input  [C_MAX_PORT_NUM-1:0]              DE_I             ,
input  [C_MAX_PORT_NUM*C_MAX_BPC-1:0]    R_I              ,
input  [C_MAX_PORT_NUM*C_MAX_BPC-1:0]    G_I              ,
input  [C_MAX_PORT_NUM*C_MAX_BPC-1:0]    B_I              ,
                                     



input                                 M_AXI_ACLK      , 
input                                 M_AXI_ARESETN   , 
output    [4-1 : 0]                   M_AXI_AWID      , 
output    [C_AXI4_ADDR_WIDTH-1 : 0]   M_AXI_AWADDR    , 
output    [7 : 0]                     M_AXI_AWLEN     , 
output    [2 : 0]                     M_AXI_AWSIZE    , 
output    [1 : 0]                     M_AXI_AWBURST   , 
output                                M_AXI_AWLOCK    , 
output    [3 : 0]                     M_AXI_AWCACHE   , 
output    [2 : 0]                     M_AXI_AWPROT    , 
output    [3 : 0]                     M_AXI_AWQOS     , 
output    [1-1 : 0]                   M_AXI_AWUSER    , 
output                                M_AXI_AWVALID   , 
input                                 M_AXI_AWREADY   , 
output    [C_AXI4_DATA_WIDTH-1 : 0]   M_AXI_WDATA     , 
output    [C_AXI4_DATA_WIDTH/8-1 : 0] M_AXI_WSTRB     , 
output                                M_AXI_WLAST     , 
output    [1-1 : 0]                   M_AXI_WUSER     , 
output                                M_AXI_WVALID    , 
input                                 M_AXI_WREADY    , 
input    [4-1 : 0]                    M_AXI_BID       , 
input    [1 : 0]                      M_AXI_BRESP     , 
input    [1-1 : 0]                    M_AXI_BUSER     , 
input                                 M_AXI_BVALID    , 
output                                M_AXI_BREADY    , 
output    [4-1 : 0]                   M_AXI_ARID      , 
output    [C_AXI4_ADDR_WIDTH-1 : 0]   M_AXI_ARADDR    , 
output   [7 : 0]                      M_AXI_ARLEN     , 
output    [2 : 0]                     M_AXI_ARSIZE    , 
output    [1 : 0]                     M_AXI_ARBURST   , 
output                                M_AXI_ARLOCK    , 
output    [3 : 0]                     M_AXI_ARCACHE   , 
output    [2 : 0]                     M_AXI_ARPROT    , 
output    [3 : 0]                     M_AXI_ARQOS     , 
output    [1-1 : 0]                   M_AXI_ARUSER    , 
output                                M_AXI_ARVALID   , 
input                                 M_AXI_ARREADY   , 
input    [4-1 : 0]                    M_AXI_RID       , 
input    [C_AXI4_DATA_WIDTH-1 : 0]    M_AXI_RDATA     , 
input    [1 : 0]                      M_AXI_RRESP     , 
input                                 M_AXI_RLAST     , 
input    [1-1 : 0]                    M_AXI_RUSER     , 
input                                 M_AXI_RVALID    , 
output                                M_AXI_RREADY    ,


output                                VID_OVERFLOW_O       ,   //用于表征数据写入满，总线带宽不足 
input                                 AXI4_ROUND_PULSE_I   ,    //~axi4  下一帧从0地址开始写, 写到最大帧数后，即停止    
input                                 AXI4_NORMAL_PULSE_I  ,
output                                VID_CRC_FIFO_RESET_O , //vid


input  [C_AXI_LITE_ADDR_WIDTH-1:0]  LB_WADDR   ,
input  [C_AXI_LITE_DATA_WIDTH-1:0]  LB_WDATA   ,
input                               LB_WREQ    ,
input  [C_AXI_LITE_ADDR_WIDTH-1:0]  LB_RADDR   ,
input                               LB_RREQ     ,
output [C_AXI_LITE_DATA_WIDTH-1:0]  LB_RDATA   ,
output                              LB_RFINISH



    );
    
///////////////////////////////////////////////////////////////////////////////////////////////
parameter [0:0] C_FIXED_MAX_PARA               =  0;


//base para
parameter C_AXI_LITE_ADDR_WIDTH                 = 16 ;
parameter C_AXI_LITE_DATA_WIDTH                 = 32 ;
parameter C_AXI4_ADDR_WIDTH                     = 32 ;
parameter C_AXI4_DATA_WIDTH                     = 256 ;
parameter C_MAX_PORT_NUM                        = 2  ; //default : 4
parameter C_MAX_BPC                             = 8  ; //default : 8
parameter C_DDR_BASE_ADDR                       = 32'h80000000; //default : 32'h80000000
parameter C_FRAME_OFFSET_ADDR                   = 32'h00000000; // will be added to C_DDR_BASE_ADDR
parameter C_FRAME_BYTE_NUM                      = 32'h08000000 ;// be same to second frame start ddr addr
parameter C_FRAME_BUF_NUM                       = 2 ; //must >= 1
parameter C_MAX_MEM_BYTES                       = 2; //exp :  RGBX, sometimes RGB
parameter [0:0]  C_CSC_RGB2YUV_ENABLE           = 1; // for YUV series
parameter [0:0]  C_CSC_FIFO_ENABLE              = 1; // for YUV420
parameter [0:0] C_PCLK_ILA_ENABLE               = 0 ;
parameter [0:0] C_AXI_LITE_ILA_ENABLE           = 0 ;
parameter [0:0] C_AXI4_ILA_ENABLE               = 0 ;

///////////////////////////////////////////////////////////////////////////////////////////////
//default para
parameter [0:0] C_ENABLE_DEFAULT          =  1;
parameter [3:0] C_PORT_NUM_DEFAULT        =  2;
parameter [3:0] C_COLOR_DEPTH_DEFAULT     =  8;
parameter [3:0] C_COLOR_SPACE_DEFAULT     =  2;
parameter [3:0] C_MEM_BYTES_DEFAULT       =  2;
parameter [2:0] C_STRIP_NUM_DEFAULT       =  1;
parameter [2:0] C_STRIP_ID_DEFAULT        =  0;
parameter [15:0] C_HACTIVE_DEFAULT        =  1920;
parameter [15:0] C_VACTIVE_DEFAULT        =  1080;


///////////////////////////////////////////////////////////////////////////////////////////////
//default : vs hs de default
//parameter [0:0] C_VS_REVERSE_EN_DEFAULT =  0 ;
//parameter [0:0] C_HS_REVERSE_EN_DEFAULT =  0 ;
//parameter [0:0] C_DE_REVERSE_EN_DEFAULT =  0 ;


///////////////////////////////////////////////////////////////////////////////////////////////            
//ddr para
parameter [0:0] C_DDR_WR_SIM_ENABLE       = 1;        
parameter       C_DDR_BURST_LEN           = 16; //1, 2, 4, 8, 16, 32, 64, 128, 256



/////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////parameter calc///////////////////////////////////////////
localparam [15:0] C_DATA_IN_WIDTH        =  C_MAX_MEM_BYTES*8 * C_MAX_PORT_NUM;
localparam [15:0] C_FIFO_IN_WIDTH        =  f_upper(C_DATA_IN_WIDTH) ; //向上找最近的典型值
localparam        C_FIFO_DEPTH           =  2048; //satify at least one row of 4K


parameter [0:0] C_LB_ENABLE = 0 ;
parameter [0:0] C_RD_LINE_BY_LINE_EN = 0;

/////////////////////////////////////////////////////////////////////////////////////////////////////
genvar i,j,k;

/////////////////////////////////////////////////////////////////////////////////////////////////////
wire  [C_MAX_PORT_NUM-1:0]              VS_I_i  ;
wire  [C_MAX_PORT_NUM-1:0]              HS_I_i  ;
wire  [C_MAX_PORT_NUM-1:0]              DE_I_i  ;

//assign VS_I_i =  R_VS_REVERSE_ENANLE ? ~VS_I : VS_I ;
//assign HS_I_i =  R_HS_REVERSE_ENANLE ? ~HS_I : HS_I ;
//assign DE_I_i =  R_DE_REVERSE_ENANLE ? ~DE_I : DE_I ;

assign VS_I_i =  VS_I ;
assign HS_I_i =  HS_I ;
assign DE_I_i =  DE_I ;




///////////////////////////////////////////////REG SPACE/////////////////////////////////////////////
reg        R_ENABLE = C_ENABLE_DEFAULT;
reg [3:0]  R_PORT_NUM = C_PORT_NUM_DEFAULT ;
reg [3:0]  R_COLOR_DEPTH = C_COLOR_DEPTH_DEFAULT;
reg [3:0]  R_COLOR_SPACE = C_COLOR_SPACE_DEFAULT;
reg [7:0]  R_STRIP = {2'b00,C_STRIP_NUM_DEFAULT,C_STRIP_ID_DEFAULT};
wire [2:0] R_STRIP_NUM;
wire [2:0] R_STRIP_ID;
reg [3:0]  R_MEM_BYTES = C_MEM_BYTES_DEFAULT;
reg [15:0] R_HACTIVE = C_HACTIVE_DEFAULT;
reg [15:0] R_VACTIVE = C_VACTIVE_DEFAULT;

//reg R_VS_REVERSE_ENANLE  = C_VS_REVERSE_EN_DEFAULT ;
//reg R_HS_REVERSE_ENANLE  = C_HS_REVERSE_EN_DEFAULT ;
//reg R_DE_REVERSE_ENANLE  = C_DE_REVERSE_EN_DEFAULT ;

////////////////////////////////////////////////////////////////////////////////////////////////////
wire write_req_cpu_to_axi   ;
wire [C_AXI_LITE_ADDR_WIDTH-1:0] write_addr_cpu_to_axi ;
wire [C_AXI_LITE_DATA_WIDTH-1:0] write_data_cpu_to_axi ; 
wire read_req_cpu_to_axi  ;
wire [C_AXI_LITE_ADDR_WIDTH-1:0] read_addr_cpu_to_axi ;
wire  [C_AXI_LITE_DATA_WIDTH-1:0] read_data_axi_to_cpu ; 
wire read_finish_axi_to_cpu  ;

wire                       write_req_cpu_to_axi_ll   ;
wire [C_AXI_LITE_ADDR_WIDTH-1:0]  write_addr_cpu_to_axi_ll  ;
wire [C_AXI_LITE_DATA_WIDTH-1:0]  write_data_cpu_to_axi_ll  ;
wire                       read_req_cpu_to_axi_ll    ;
wire  [C_AXI_LITE_ADDR_WIDTH-1:0] read_addr_cpu_to_axi_ll   ;
reg  [C_AXI_LITE_DATA_WIDTH-1:0]  read_data_axi_to_cpu_ll    = 0;  
reg                        read_finish_axi_to_cpu_ll  = 0;





wire [3:0] port_num__pclk;
wire [3:0] color_space_pclk;
wire [15:0] hactive_mclk;
wire [15:0] vactive_mclk;
reg  wr_trig_axi4 = 0;   
reg [31:0] wr_addr_axi4 = 0;  
reg [31:0] wr_size_axi4 = 0;  
wire wr_finish_axi4; 
reg [7:0] state = 0;
wire [31:0] frm_pixel_num_mclk;
wire [31:0] frm_byte_num_mclk ;
wire [31:0] row_pixel_num_mclk;
wire [31:0] row_byte_num_mclk;
wire enable_mclk;
wire enable_pclk;
wire VS_I_pclk_pos;
wire VS_I_mclk_pos;
wire fifo_wr_rst;//pclk
wire fifo_rd_rst;//mclk
wire  [C_FIFO_IN_WIDTH-1:0] fifo_wr_data;
wire                        fifo_wr_en;
wire                        fifo_wr_rst_busy;
wire  pixel_vs_0;
wire  pixel_hs_0;
wire  pixel_de_0;
wire  [C_MAX_BPC*3*C_MAX_PORT_NUM-1:0]   pixel_data_0; //key point 0

wire  pixel_vs_1;
wire  pixel_hs_1;
wire  pixel_de_1;
wire  [C_MAX_BPC*3*C_MAX_PORT_NUM-1:0]   pixel_data_1 ;

wire  pixel_vs_2;
wire  pixel_hs_2;
wire  pixel_de_2;
wire  [C_MAX_MEM_BYTES*8*C_MAX_PORT_NUM-1:0]  pixel_data_2;

wire  pixel_vs_3;
wire  pixel_hs_3;
wire  pixel_de_3;
wire [C_MAX_MEM_BYTES*8*C_MAX_PORT_NUM-1:0] pixel_data_3; //key point 3; 

reg [15:0] cnt_v_al = 0; 
wire [15:0] cnt_v_al_vid;
reg [10:0]  frame_buf_id_f0 = 0;
wire [C_AXI4_DATA_WIDTH-1:0] fifo_rd_data;
wire fifo_rd_empty;
wire fifo_rd_rst_busy;
wire fifo_rd_en ;

wire VIDEO_LOCKED_I_mclk;
wire [3:0] R_COLOR_DEPTH_pclk;
wire [3:0] R_MEM_BYTES_pclk;
wire VS_I_mclk_neg;
wire VS_I_mclk;

wire [7:0] w_state;  
wire [7:0] r_state;   
wire w_misstep ;
wire r_misstep ;

wire  pixel_vs_1;
wire  pixel_hs_1;
wire  pixel_de_1;
wire  pixel_vs_2;
wire  pixel_hs_2;
wire  pixel_de_2;


wire fifo_wr_full ;         
wire fifo_wr_prog_full  ;
wire fifo_wr_err ;


assign pixel_vs_1 = reconcat_top_u.vs1;   
assign pixel_hs_1 = reconcat_top_u.hs1;
assign pixel_de_1 = reconcat_top_u.de1;
assign pixel_vs_2 = reconcat_top_u.vs2;   
assign pixel_hs_2 = reconcat_top_u.hs2;
assign pixel_de_2 = reconcat_top_u.de2;

assign pixel_data_1 = reconcat_top_u.pixel_data_tmp1;
assign pixel_data_2 = reconcat_top_u.pixel_data_tmp2;

////////////////////////////////////////////////////////////////////////////////////////////////////

assign R_STRIP_NUM = R_STRIP[5:3];
assign R_STRIP_ID  = R_STRIP[2:0];



`POS_MONITOR(VID_CLK_I,0,VS_I_i[0],VS_I_pclk_pos)
`CDC_SINGLE_BIT_PULSE(VID_CLK_I,0,VS_I_i[0],M_AXI_ACLK,0,VS_I_mclk_pos,0)



`CDC_MULTI_BIT_SIGNAL(VID_CLK_I,VS_I_i[0],M_AXI_ACLK,VS_I_mclk,1)
`NEG_MONITOR(M_AXI_ACLK,0,VS_I_mclk,VS_I_mclk_neg)

`CDC_MULTI_BIT_SIGNAL(S_AXI_ACLK,R_ENABLE,M_AXI_ACLK,enable_mclk,1)
`CDC_MULTI_BIT_SIGNAL(S_AXI_ACLK,R_ENABLE,VID_CLK_I,enable_pclk,1)
`CDC_MULTI_BIT_SIGNAL(S_AXI_ACLK,R_HACTIVE,M_AXI_ACLK,hactive_mclk,16)
`CDC_MULTI_BIT_SIGNAL(S_AXI_ACLK,R_VACTIVE,M_AXI_ACLK,vactive_mclk,16)
`CDC_MULTI_BIT_SIGNAL(S_AXI_ACLK,R_PORT_NUM,VID_CLK_I,port_num__pclk,4)
`CDC_MULTI_BIT_SIGNAL(S_AXI_ACLK,R_COLOR_DEPTH,VID_CLK_I,R_COLOR_DEPTH_pclk,4)
`CDC_MULTI_BIT_SIGNAL(S_AXI_ACLK,R_COLOR_SPACE,VID_CLK_I,color_space_pclk,4)
`CDC_MULTI_BIT_SIGNAL(VID_CLK_I,VID_LOCKED_I,M_AXI_ACLK,VIDEO_LOCKED_I_mclk,1) 
`CDC_MULTI_BIT_SIGNAL(S_AXI_ACLK,R_MEM_BYTES,VID_CLK_I,R_MEM_BYTES_pclk,4) 



assign fifo_wr_rst = ~VID_LOCKED_I | VS_I_pclk_pos | ~VID_RSTN_I ;
assign fifo_rd_rst = ~M_AXI_ARESETN  | VS_I_mclk_pos;


assign  VID_OVERFLOW_O = fifo_wr_err ;

`CDC_MULTI_BIT_SIGNAL(M_AXI_ACLK,cnt_v_al,VID_CLK_I,cnt_v_al_vid,16)



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
//crc和保存的图片进行同步的逻辑
reg round_flag = 0;
reg round_flag_reset = 0;
always@(posedge M_AXI_ACLK)begin
    if(~M_AXI_ARESETN)begin
        round_flag <= 0;
    end
    else begin
        round_flag <= AXI4_ROUND_PULSE_I ? 1 : round_flag_reset ? 0: round_flag ;
    end
end


reg normal_flag = 0;
reg normal_flag_reset = 0;
always@(posedge M_AXI_ACLK)begin
    if(~M_AXI_ARESETN)begin
        normal_flag <= 0;
    end
    else begin
        normal_flag <= AXI4_NORMAL_PULSE_I ? 1 : normal_flag_reset ? 0: normal_flag ;
    end
end




////////////////////////////////////////////////AXI-LITE///////////////////////////////////////////////////////
axi_lite_slave 
   #(.C_S_AXI_DATA_WIDTH (C_AXI_LITE_DATA_WIDTH ),
     .C_S_AXI_ADDR_WIDTH (C_AXI_LITE_ADDR_WIDTH )   
    )
    axi_lite_slave_u(
    .S_AXI_ACLK           (S_AXI_ACLK     ) ,     //input  wire                              
    .S_AXI_ARESETN        (S_AXI_ARESETN  ) ,     //input  wire                              
    .S_AXI_AWREADY        (S_AXI_AWREADY  ) ,     //output wire                              
    .S_AXI_AWADDR         (S_AXI_AWADDR   ) ,     //input  wire [C_S_AXI_ADDR_WIDTH-1:0]     
    .S_AXI_AWVALID        (S_AXI_AWVALID  ) ,     //input  wire                              
    .S_AXI_AWPROT         (S_AXI_AWPROT   ) ,     //input  wire [ 2:0]                       
    .S_AXI_WREADY         (S_AXI_WREADY   ) ,     //output wire                              
    .S_AXI_WDATA          (S_AXI_WDATA    ) ,     //input  wire [C_S_AXI_DATA_WIDTH-1:0]     
    .S_AXI_WSTRB          (S_AXI_WSTRB    ) ,         //input  wire [(C_S_AXI_DATA_WIDTH/8)-1 :0]
    .S_AXI_WVALID         (S_AXI_WVALID   ) ,     //input  wire                              
    .S_AXI_BRESP          (S_AXI_BRESP    ) ,     //output wire [ 1:0]                       
    .S_AXI_BVALID         (S_AXI_BVALID   ) ,     //output wire                              
    .S_AXI_BREADY         (S_AXI_BREADY   ) ,     //input  wire                              
    .S_AXI_ARREADY        (S_AXI_ARREADY  ) ,     //output wire                              
    .S_AXI_ARADDR         (S_AXI_ARADDR   ) ,     //input  wire [C_S_AXI_ADDR_WIDTH-1:0]     
    .S_AXI_ARVALID        (S_AXI_ARVALID  ) ,     //input  wire                              
    .S_AXI_ARPROT         (S_AXI_ARPROT   ) ,     //input  wire [ 2:0]                       
    .S_AXI_RRESP          (S_AXI_RRESP    ) ,     //output wire [ 1:0]                       
    .S_AXI_RVALID         (S_AXI_RVALID   ) ,     //output wire                              
    .S_AXI_RDATA          (S_AXI_RDATA    ) ,     //output wire [C_S_AXI_DATA_WIDTH-1:0]     
    .S_AXI_RREADY         (S_AXI_RREADY   ) ,     //input  wire                              
    
    .write_req_cpu_to_axi   (write_req_cpu_to_axi   ),
    .write_addr_cpu_to_axi  (write_addr_cpu_to_axi  ),
    .write_data_cpu_to_axi  (write_data_cpu_to_axi  ),
    .read_req_cpu_to_axi    (read_req_cpu_to_axi    ),
    .read_addr_cpu_to_axi   (read_addr_cpu_to_axi   ),
    .read_data_axi_to_cpu   (read_data_axi_to_cpu   ),
    .read_finish_axi_to_cpu (read_finish_axi_to_cpu ) 
      
    );


////////////////////////////////////////////////CPU WRITE////////////////////////////////////////////////////////

always@(posedge S_AXI_ACLK)begin
    if(~S_AXI_ARESETN)begin
        R_ENABLE       <= C_ENABLE_DEFAULT;
        R_COLOR_DEPTH  <= C_COLOR_DEPTH_DEFAULT;
        R_COLOR_SPACE  <= C_COLOR_SPACE_DEFAULT;
        R_PORT_NUM     <= C_PORT_NUM_DEFAULT;
        R_STRIP        <= {2'b00,C_STRIP_NUM_DEFAULT,C_STRIP_ID_DEFAULT};
        R_MEM_BYTES    <= C_MEM_BYTES_DEFAULT;
        R_HACTIVE      <= C_HACTIVE_DEFAULT ;
        R_VACTIVE      <= C_VACTIVE_DEFAULT ; 
        //R_VS_REVERSE_ENANLE <=  C_VS_REVERSE_EN_DEFAULT ;
        //R_HS_REVERSE_ENANLE <=  C_HS_REVERSE_EN_DEFAULT ;
        //R_DE_REVERSE_ENANLE <=  C_DE_REVERSE_EN_DEFAULT ;
        
    end
    else if(write_req_cpu_to_axi_ll)begin
        case(write_addr_cpu_to_axi_ll)
            `ADDR_ENABLE           : {R_PORT_NUM,R_ENABLE } <= {0,write_data_cpu_to_axi_ll[15:12],write_data_cpu_to_axi_ll[0]}   ;
            `ADDR_COLOR_DEPTH      : R_COLOR_DEPTH  <= {0,write_data_cpu_to_axi_ll}   ;
            `ADDR_COLOR_SPACE      : R_COLOR_SPACE  <= {0,write_data_cpu_to_axi_ll}   ;
            `ADDR_MEM_BYTES        : R_MEM_BYTES    <= {0,write_data_cpu_to_axi_ll}   ;
            `ADDR_STRIP_SET        : R_STRIP        <= {0,write_data_cpu_to_axi_ll}   ;
            `ADDR_HACTIVE          : R_HACTIVE      <= {0,write_data_cpu_to_axi_ll}   ;
            `ADDR_VACTIVE          : R_VACTIVE      <= {0,write_data_cpu_to_axi_ll}   ;
            //`ADDR_VS_REVERSE_EN    : R_VS_REVERSE_ENANLE <= {0,write_data_cpu_to_axi_ll}   ;
            //`ADDR_HS_REVERSE_EN    : R_HS_REVERSE_ENANLE <= {0,write_data_cpu_to_axi_ll}   ;
            //`ADDR_DE_REVERSE_EN    : R_DE_REVERSE_ENANLE <= {0,write_data_cpu_to_axi_ll}   ;
            default:;
        endcase
    end
end


////////////////////////////////////////////////CPU READ////////////////////////////////////////////////////////

always@(posedge S_AXI_ACLK)begin
    if(~S_AXI_ARESETN)begin
		read_data_axi_to_cpu_ll <= 0;
		read_finish_axi_to_cpu_ll <= 0;
	end	
	else if(read_req_cpu_to_axi_ll)begin
        read_finish_axi_to_cpu_ll <= 1;
		case(read_addr_cpu_to_axi_ll)
            `ADDR_ENABLE           : read_data_axi_to_cpu_ll <=  {0,R_PORT_NUM,4'b0,4'b0,3'b0,R_ENABLE }  ;//yzhu
            `ADDR_COLOR_DEPTH      : read_data_axi_to_cpu_ll <=  {0,R_COLOR_DEPTH}  ;
            `ADDR_COLOR_SPACE      : read_data_axi_to_cpu_ll <=  {0,R_COLOR_SPACE}  ;
            `ADDR_MEM_BYTES        : read_data_axi_to_cpu_ll <=  {0,R_MEM_BYTES  }  ;
            `ADDR_STRIP_SET        : read_data_axi_to_cpu_ll <=  {0,R_STRIP      }  ;
            `ADDR_HACTIVE          : read_data_axi_to_cpu_ll <=  {0,R_HACTIVE    }  ;
            `ADDR_VACTIVE          : read_data_axi_to_cpu_ll <=  {0,R_VACTIVE    }  ;  
            //`ADDR_VS_REVERSE_EN    : read_data_axi_to_cpu_ll <=  {0,R_VS_REVERSE_ENANLE    }  ;  
            //`ADDR_HS_REVERSE_EN    : read_data_axi_to_cpu_ll <=  {0,R_HS_REVERSE_ENANLE    }  ;  
            //`ADDR_DE_REVERSE_EN    : read_data_axi_to_cpu_ll <=  {0,R_DE_REVERSE_ENANLE    }  ;  
           
            default:;
		endcase
	end
	else begin
        read_finish_axi_to_cpu_ll <= 0;
    end
end



/////////////////////////////////////////////////DATA IN/////////////////////////////////////////////////////////

csc  //operates as the max scale
    #(.C_PORT_NUM(C_MAX_PORT_NUM   ),
      .C_BPC     (C_MAX_BPC        ),
      .C_RGB2YUV_EN (C_CSC_RGB2YUV_ENABLE  ), //control if there is rgb2yuv Module for YUV series
      .C_FIFO_EN (C_CSC_FIFO_ENABLE), //control if there is fifo Module for YUV420
      .C_DLY_SRL (3 ) )  // must >= 3
    csc_u  (
    .CLK_I        (VID_CLK_I           ),
    .RST_I        (~VID_LOCKED_I | ~VID_RSTN_I ),
    .OSPACE_I     ({0,color_space_pclk} ), //output color space :  0:RGB , 1:YUV444 , 2:YUV422 , 3:YUV420 
    .VS_I         (VS_I_i[0]          ), 
    .HS_I         (HS_I_i[0]          ),
    .DE_I         (DE_I_i[0]          ),
    .R_I          (R_I              ), //exp: RRRR
    .G_I          (G_I              ), //exp: GGGG
    .B_I          (B_I              ), //exp: BBBB
    .PIXEL_VS_O   (pixel_vs_0         ), 
    .PIXEL_HS_O   (pixel_hs_0         ), 
    .PIXEL_DE_O   (pixel_de_0         ), 
    .PIXEL_DATA_O (pixel_data_0     ),  //exp: {BGR}{BGR}{BGR}{BGR} ; {VUY}{VUY}{VUY}{VUY} ; {0VY}{0UY}{0VY}{0UY} ; {VYY}{UYY}{VYY}{UYY}        
    .ACTUAL_PORT_NUM_I ( C_FIXED_MAX_PARA ? C_MAX_PORT_NUM  :   port_num__pclk)    
    );



reconcat_top
    #(.C_MAX_PORT_NUM           (C_MAX_PORT_NUM      ) ,
      .C_MAX_BPC                (C_MAX_BPC           ) ,
      .C_DDR_PIXEL_MAX_BYTE_NUM (C_MAX_MEM_BYTES     ) 
     )
    reconcat_top_u(
    .TARGET_DDR_BYTE_NUM_I  (C_FIXED_MAX_PARA ? C_MAX_MEM_BYTES   :  {0,R_MEM_BYTES_pclk}),
    .TARGET_BPC_I           (C_FIXED_MAX_PARA ? C_MAX_BPC  :  {0,R_COLOR_DEPTH_pclk}),
    .RST_I                  (~VID_LOCKED_I | ~VID_RSTN_I  ),       
    .CLK_I                  (VID_CLK_I    ),       
    .PIXEL_VS_I             (pixel_vs_0   ),  
    .PIXEL_HS_I             (pixel_hs_0   ),   
    .PIXEL_DE_I             (pixel_de_0   ),  
    .PIXEL_DATA_I           (pixel_data_0 ), 
    .PIXEL_VS_O             (pixel_vs_3   ),          
    .PIXEL_HS_O             (pixel_hs_3   ), // no use      
    .PIXEL_DE_O             (pixel_de_3   ),         
    .PIXEL_DATA_O           (pixel_data_3 )  //allign tightly according TARGET_DDR_BYTE_NUM_I and TARGET_BPC_I
    );
    


/////////////////////////////////////////////////DATA CONCAT/////////////////////////////////////////////////////
wire [$clog2( C_FIFO_IN_WIDTH/8):0] fifo_wr_byte_num;
assign  fifo_wr_byte_num = C_FIXED_MAX_PARA ?  C_MAX_PORT_NUM *C_MAX_MEM_BYTES  :   port_num__pclk*R_MEM_BYTES_pclk;//注意，不能写成{0,{port_num__pclk*R_MEM_BYTES_pclk}}的形式，因为工具会对后面的{} 限制位宽

strobe_station_unify 
    #(.C_BYTE_NUM( C_FIFO_IN_WIDTH/8 )) //note: C_FIFO_IN_WIDTH is upper of pixel_data_3  width
    strobe_station_u(
    .RST_I       (fifo_wr_rst                         ),  //vs pos has been taken into account
    .CLK_I       (VID_CLK_I                           ),
    .DATA_EN_I   (   pixel_de_3                       ),  //note： BYTE_NUM_I = 0, represents C_BYTE_NUM
    .DATA_I      ({0,pixel_data_3}                    ),  // C_FIFO_IN_WIDTH
    .BYTE_NUM_I  ({0,fifo_wr_byte_num}                ),  //natual num ; for example  1  2  3  4(the same as 0) when C_BYTE_NUM is 4 
    .DATA_O      (fifo_wr_data                        ), 
    .DATA_EN_O   (fifo_wr_en                          )   // C_FIFO_IN_WIDTH
    );
    
    
//////////////////////////////////////////////////FIFO //////////////////////////////////////////////////////////
wire  [15:0]  rd_data_count;
wire [31:0] WR_EN_ACCUS;
wire [31:0] RD_EN_ACCUS;

fifo_async_xpm  
    #(.C_WR_WIDTH             (C_FIFO_IN_WIDTH    ),// ratio must be 1:1, 1:2, 1:4, 1:8,
      .C_WR_DEPTH             (C_FIFO_DEPTH       ),// must>=16 ; actual depth = C_WR_DEPTH - 1;  must be power of 2
      .C_RD_WIDTH             (C_AXI4_DATA_WIDTH  ),
      .C_WR_COUNT_WIDTH       (16                 ),
      .C_RD_COUNT_WIDTH       (16                 ),
      .C_RD_PROG_EMPTY_THRESH (32                 ),
      .C_WR_PROG_FULL_THRESH  (C_FIFO_DEPTH-64    ),
      .C_RD_MODE              ("fwft"             ) //"std" "fwft"  
     )
    fifo_async_xpm_u(
    .WR_RST_I         (fifo_wr_rst |  (~enable_pclk)         ),
    .WR_CLK_I         (VID_CLK_I               ),
    .WR_EN_I          (fifo_wr_en           ),
    .WR_EN_VALID_O    ( ),
    .WR_EN_NAMES_O    ( ),
    .WR_EN_ACCUS_O    (WR_EN_ACCUS          ),
    .WR_DATA_I        (fifo_wr_data         ),
    .WR_FULL_O        (fifo_wr_full         ),
    .WR_DATA_COUNT_O  (                     ),
    .WR_PROG_FULL_O   (fifo_wr_prog_full    ),
    .WR_RST_BUSY_O    (                     ),
    .WR_ERR_O         (fifo_wr_err          ),
                                           
    .RD_RST_I         (fifo_rd_rst          ), 
    .RD_CLK_I         (M_AXI_ACLK           ),
    .RD_EN_I          (fifo_rd_en           ),
    .RD_EN_NAMES_O    ( ),
    .RD_EN_ACCUS_O    (RD_EN_ACCUS          ),
    .RD_DATA_VALID_O  ( ), 
    .RD_DATA_O        (fifo_rd_data         ),
    .RD_EMPTY_O       (fifo_rd_empty        ),
    .RD_DATA_COUNT_O  (rd_data_count        ),
    .RD_PROG_EMPTY_O  (                     ),
    .RD_RST_BUSY_O    (fifo_rd_rst_busy     )
    
    );
    

////////////////////////////////////////////////AXI4 MASTER/////////////////////////////////////////////////////
wire [31:0] beats;
wire [31:0] bursts;
wire w_master_busy;
axi4_master 
   #(.C_M_AXI_BURST_LEN             (C_DDR_BURST_LEN      ), //1, 2, 4, 8, 16, 32, 64, 128, 256
     .C_M_AXI_ADDR_WIDTH            (C_AXI4_ADDR_WIDTH    ), // 32 64
     .C_M_AXI_DATA_WIDTH            (C_AXI4_DATA_WIDTH    ), //32 64 128 256
     .C_RD_BLOCK_ENABLE             (0                    ),
     .C_WR_BLOCK_ENABLE             (1                    ),
     .C_RD_SIM_ENABLE               (0                    ),
     .C_WR_SIM_ENABLE               (C_DDR_WR_SIM_ENABLE  ),
     .C_RD_SIM_PATTERN_TYPE         (0                    ),
     .C_RD_SIM_PATTERN_UNIT_BYTE_NUM(4                    ),
     .C_RD_NORM_DATA_SOURCE         (0                    ),
     .C_RD_NORM_DATA_UNIT_BYTE_NUM  (4                    ),
     .C_RD_ALIGN_ENABLE             (0                    ),
     .C_RD_BLOCK_ALIGN_BYTE_NUM     (4096                 ),
     .C_IMMEDIATE_TRIG_ENABLE       (0                    ),//note: must be 0
     .C_OP_DELAY_CLK_NUM            (10                   )
    )
    axi4_master_u(
   .M_AXI_ACLK    (M_AXI_ACLK         ),  
   .M_AXI_ARESETN (M_AXI_ARESETN      ),  
   .M_AXI_AWID    (M_AXI_AWID         ), 
   .M_AXI_AWADDR  (M_AXI_AWADDR       ), 
   .M_AXI_AWLEN   (M_AXI_AWLEN        ), 
   .M_AXI_AWSIZE  (M_AXI_AWSIZE       ), 
   .M_AXI_AWBURST (M_AXI_AWBURST      ), 
   .M_AXI_AWLOCK  (M_AXI_AWLOCK       ), 
   .M_AXI_AWCACHE (M_AXI_AWCACHE      ), 
   .M_AXI_AWPROT  (M_AXI_AWPROT       ), 
   .M_AXI_AWQOS   (M_AXI_AWQOS        ), 
   .M_AXI_AWUSER  (M_AXI_AWUSER       ), 
   .M_AXI_AWVALID (M_AXI_AWVALID      ), 
   .M_AXI_AWREADY (M_AXI_AWREADY      ), 
   .M_AXI_WDATA   (M_AXI_WDATA        ), 
   .M_AXI_WSTRB   (M_AXI_WSTRB        ), 
   .M_AXI_WLAST   (M_AXI_WLAST        ), 
   .M_AXI_WUSER   (M_AXI_WUSER        ), 
   .M_AXI_WVALID  (M_AXI_WVALID       ), 
   .M_AXI_WREADY  (M_AXI_WREADY       ), 
   .M_AXI_BID     (M_AXI_BID          ), 
   .M_AXI_BRESP   (M_AXI_BRESP        ), 
   .M_AXI_BUSER   (M_AXI_BUSER        ), 
   .M_AXI_BVALID  (M_AXI_BVALID       ), 
   .M_AXI_BREADY  (M_AXI_BREADY       ), 
   .M_AXI_ARID    (M_AXI_ARID         ), 
   .M_AXI_ARADDR  (M_AXI_ARADDR       ), 
   .M_AXI_ARLEN   (M_AXI_ARLEN        ), 
   .M_AXI_ARSIZE  (M_AXI_ARSIZE       ), 
   .M_AXI_ARBURST (M_AXI_ARBURST      ), 
   .M_AXI_ARLOCK  (M_AXI_ARLOCK       ), 
   .M_AXI_ARCACHE (M_AXI_ARCACHE      ), 
   .M_AXI_ARPROT  (M_AXI_ARPROT       ), 
   .M_AXI_ARQOS   (M_AXI_ARQOS        ), 
   .M_AXI_ARUSER  (M_AXI_ARUSER       ), 
   .M_AXI_ARVALID (M_AXI_ARVALID      ), 
   .M_AXI_ARREADY (M_AXI_ARREADY      ), 
   .M_AXI_RID     (M_AXI_RID          ), 
   .M_AXI_RDATA   (M_AXI_RDATA        ), 
   .M_AXI_RRESP   (M_AXI_RRESP        ), 
   .M_AXI_RLAST   (M_AXI_RLAST        ), 
   .M_AXI_RUSER   (M_AXI_RUSER        ), 
   .M_AXI_RVALID  (M_AXI_RVALID       ), 
   .M_AXI_RREADY  (M_AXI_RREADY       ), 
    
   .W_STOP_I      (~VIDEO_LOCKED_I_mclk | VS_I_mclk ),//注意：首先退出本次burst，同时也退出了本次trig(发出finish---state于是认为本行或一帧写入完成)
   .W_RST_I       (0                  ),
   .W_REQ_I       (wr_trig_axi4       ),
   .W_START_ADDR_I(wr_addr_axi4       ), 
   .W_BYTE_NUM_I  (wr_size_axi4       ), 
   .W_FIFO_RD_DATA_COUNT_I({0,rd_data_count}),
   .W_FIFO_EMPTY_I(fifo_rd_empty | fifo_rd_rst_busy ),
   .W_FIFO_READ_O (fifo_rd_en        ),
   .W_FIFO_DATA_I (fifo_rd_data      ), 
   .W_DONE_O      (                  ),
   .W_FINISH_O    (wr_finish_axi4    ),
   .W_BEATS_O                (beats),
   .W_BURSTS_O               (bursts),
   .W_NEW_BYTE_NUM_I         (0),
   .W_NEW_BYTE_NUM_UPDATE_I  (0),
   .W_BUSY_O                 (w_master_busy),
   
   
   .R_RST_I       (0  ),
   .R_REQ_I       (0  ),
   .R_START_ADDR_I(0  ), 
   .R_BYTE_NUM_I  (0  ), 
   .R_FIFO_FULL_I (0  ), 
   .R_FIFO_WRITE_O(   ), 
   .R_FIFO_DATA_O (   ), 
   .R_DONE_O      (   ), 
   .R_FINISH_O    (   ),
   .R_STOP_I       (0),
   
   
    .DEBUG_W_STATE   (w_state   ),
    .DEBUG_R_STATE   (r_state   ),
	.DEBUG_W_MISSTEP (w_misstep ),
	.DEBUG_R_MISSTEP (r_misstep )

   
    
   );


assign frm_pixel_num_mclk = hactive_mclk * vactive_mclk;
assign frm_byte_num_mclk =  frm_pixel_num_mclk *  C_MAX_MEM_BYTES ;
assign row_pixel_num_mclk = hactive_mclk;
assign row_byte_num_mclk = row_pixel_num_mclk *  C_MAX_MEM_BYTES ;

/////////////////////////////////////////////////////////////////////
//vs上沿触发退出burst，等待退出完成后，生成启动操作的信号
reg  master_trig = 0;
reg [7:0] state_mt;
always@(posedge M_AXI_ACLK)begin
    if(~M_AXI_ARESETN)begin
        master_trig <= 0;
        state_mt <= 0;
    end
    else begin
        case(state_mt)
            0:begin
                master_trig <= 0;
                state_mt <=  VS_I_mclk_pos ? 1 : state_mt ;
            end
            1:begin
                master_trig <= w_master_busy==0 ? 1 : 0 ;
                state_mt    <= w_master_busy==0 ? 0 : state_mt  ;
            end
            default:;
        endcase
    end
end


////////////////////////////////////////////////AXI4 STATE/////////////////////////////////////////////////////
reg round_mode_en = 0;
always@(posedge M_AXI_ACLK)begin
    if(~M_AXI_ARESETN)begin
        state <= 0;
        wr_trig_axi4 <= 0;
        wr_addr_axi4 <= 0;
        wr_size_axi4 <= 0;
        cnt_v_al <= 0;
        frame_buf_id_f0 <= 0;
        round_mode_en <= 0;
        round_flag_reset <= 0;
        normal_flag_reset <= 0;
        
    end
	//VS     _____|————|______
	//VS neg __________|—|____
	else if(~VIDEO_LOCKED_I_mclk)begin//如果遇到退出信号，state也要复位
	    state <= 0;
        wr_trig_axi4 <= 0;
        wr_addr_axi4 <= 0;
        wr_size_axi4 <= 0;
        cnt_v_al <= 0;
        frame_buf_id_f0 <= 0; //帧id 归零
	end
    //else if(VS_I_mclk)begin//如果遇到退出信号，state也要复位
    //if(VS_I_mclk_pos)begin
    //      frame_buf_id_f0 <= frame_buf_id_f0 == C_FRAME_BUF_NUM-1 ? 0 : frame_buf_id_f0 + 1;
    //  end
    else if(VS_I_mclk_pos)begin
        round_mode_en    <=  round_flag ?  1 :  normal_flag ? 0 :  round_mode_en;//round_mode_en 且帧在C_FRAME_BUF_NUM以内时，才使能）
        frame_buf_id_f0  <=  round_flag ?  0 : (  frame_buf_id_f0 == C_FRAME_BUF_NUM-1 ? 0 : frame_buf_id_f0 + 1  ) ;
        round_flag_reset <=  round_flag ;
        normal_flag_reset <= round_flag ? 0 : normal_flag ;
	    state <= 0;
        wr_trig_axi4 <= 0;
        wr_addr_axi4 <= 0;
        wr_size_axi4 <= 0;
        cnt_v_al <= 0;
	end
    //else if(VS_I_mclk_neg & VIDEO_LOCKED_I_mclk & enable_mclk)begin//【注意使用了 VS下降沿，保证burst已经退出时，才进行触发操作】
    else if(master_trig & VIDEO_LOCKED_I_mclk & enable_mclk & (round_mode_en ? frame_buf_id_f0<=(C_FRAME_BUF_NUM-1) : 1) )begin
        wr_trig_axi4 <= 1;
        wr_addr_axi4 <= C_DDR_BASE_ADDR + C_FRAME_OFFSET_ADDR + row_byte_num_mclk * R_STRIP_ID + frame_buf_id_f0 * C_FRAME_BYTE_NUM;
        wr_size_axi4 <= C_RD_LINE_BY_LINE_EN ? row_byte_num_mclk : frm_byte_num_mclk ;
        state        <= C_RD_LINE_BY_LINE_EN ? 1 : 3 ;
        cnt_v_al     <= 0;
    end
    else case(state)
        0: begin
            round_flag_reset <= 0;
            normal_flag_reset <= 0;
        end
        1:begin // judege and operation   //如果在本状态中遇到 退出signal，则不会触发wr_trig_axi4
            if(cnt_v_al >= vactive_mclk)begin
                state <= 0;
                //如果wr配置值很大，此处就不会运行到，然后直接被vs触发进入下一帧，导致帧地址不会变化
                //frame_buf_id_f0 <= frame_buf_id_f0 == C_FRAME_BUF_NUM-1 ? 0 : frame_buf_id_f0 + 1;
            end
            else begin
                state        <= 2;
                wr_trig_axi4 <= 1;
                wr_addr_axi4 <= wr_addr_axi4 ;
                wr_size_axi4 <= row_byte_num_mclk;
            end
        end
        2: begin // change addr ; 中途拔出后，burst退出(master退出了，但是逻辑上还会进行下一行所以)，随后进入2，但是此时fifo无数据，所以不会进行下一次握手;   而新的vs（伴随数据）来后，就触发
            wr_trig_axi4 <= 0; //如果在本状态中遇到 退出signal，则因为state被复位，所以退出2后，状态不会到跳到1
            state        <= wr_finish_axi4 ?    1    :   state ;
            cnt_v_al     <= wr_finish_axi4 ? cnt_v_al + 1 : cnt_v_al;
            wr_addr_axi4 <= wr_finish_axi4 ? wr_addr_axi4 +  R_STRIP_NUM * row_byte_num_mclk : wr_addr_axi4;
        end
        3: begin
            wr_trig_axi4 <= 0;
            state        <= wr_finish_axi4 ?    0    :   state ;
        end
        default : ;    
    endcase
end

reg ff = 0;
wire sync_fifo_rst_axi4;
always@(posedge M_AXI_ACLK)begin
    if(~M_AXI_ARESETN)begin
        ff <= 0;
    end
    else begin
        ff <= round_flag_reset ? 1 : VS_I_mclk_neg ? 0 : ff;
    end
end

assign sync_fifo_rst_axi4 = VS_I_mclk_neg & ff;

`CDC_SINGLE_BIT_PULSE(M_AXI_ACLK,0,sync_fifo_rst_axi4,VID_CLK_I,0,VID_CRC_FIFO_RESET_O,0) 




///////////////////////////////////////////////////////////////////////////////////////////////////////////////

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
 


generate if(C_PCLK_ILA_ENABLE)begin
    ila_pclk  ila_pclk_u(
        .clk       (VID_CLK_I),
        .probe0    (VS_I),
        .probe1    (HS_I),
        .probe2    (DE_I),
        .probe3    (R_I),
        .probe4    (G_I),
        .probe5    (B_I),
        .probe6    (VID_LOCKED_I),
        .probe7    (fifo_wr_en),
        .probe8    (fifo_wr_data),
        .probe9    (pixel_de_0      ),
        .probe10   (pixel_data_0    ),
        .probe11   (pixel_de_1      ),
        .probe12   (pixel_data_1    ),
        .probe13   (pixel_de_2      ),
        .probe14   (pixel_data_2    ),
        .probe15   (pixel_de_3      ),
        .probe16   (pixel_data_3    ),
        
        .probe17   (fifo_wr_err     ),
        .probe18   (csc_u.fifo420_wr_data),
        .probe19   (csc_u.fifo420_rd),
        .probe20   (cnt_v_al_vid)

           
    );
end
endgenerate


generate if(C_AXI_LITE_ILA_ENABLE)begin
    ila_axi_lite  ila_axi_lite_u(
        .clk       (S_AXI_ACLK),
        .probe0    (R_ENABLE),
        .probe1    (R_PORT_NUM),
        .probe2    (R_COLOR_DEPTH),
        .probe3    (R_COLOR_SPACE),
        .probe4    (R_MEM_BYTES),
        .probe5    (R_STRIP_NUM),
        .probe6    (R_STRIP_ID),
        .probe7    (R_HACTIVE),
        .probe8    (R_VACTIVE),
        .probe9    (write_req_cpu_to_axi),
        .probe10   (write_addr_cpu_to_axi),
        .probe11   (write_data_cpu_to_axi)
    );


end
endgenerate



generate if(C_AXI4_ILA_ENABLE)begin
    ila_axi4  ila_axi4_u(
        .clk       (M_AXI_ACLK),
        .probe0    (state),
        .probe1    ({VS_I_mclk_pos,VS_I_mclk,VS_I_mclk_neg,w_misstep,axi4_master_u.w_meat_trig_stop,axi4_master_u.w_burst_exit}), //抓了是否遇到burst
        .probe2    (wr_trig_axi4),
        .probe3    (wr_addr_axi4),
        .probe4    (wr_size_axi4),
        .probe5    (wr_finish_axi4),
        .probe6    (frame_buf_id_f0),
        .probe7    (cnt_v_al),
        .probe8    (fifo_rd_en),
        .probe9    (fifo_rd_data),
        .probe10   (rd_data_count ),
        .probe11   (VIDEO_LOCKED_I_mclk),
        .probe12   (fifo_rd_empty      ),
        .probe13   ({w_master_busy,master_trig }  ),
        .probe14   (beats),
        .probe15   (bursts),
        .probe16   (RD_EN_ACCUS),
		.probe17   (w_state)  
		
   
    );


end
endgenerate




endmodule



