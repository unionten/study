`timescale 1ns / 1ps
///////////////////////////////////////////////////宏////////////////////////////////////////////////////
//C_PULSE_WIDTH must > 0
`define TIMER(clk_in,rst_in,C_CLK_PRD_NS,cname,sname,bname,C_PULSE_WIDTH,sec_pulse_out,breath_out)    reg [31:0] cname=0;reg sname=0;reg bname=0;always@(posedge clk_in) if(rst_in)begin cname<= 0;sname<=0;bname<=0; end else if(cname==(1000000000/C_CLK_PRD_NS-1))begin cname<=0;sname<=1;bname<=~bname;end else begin cname<= cname+1; bname<=(cname==(500000000/C_CLK_PRD_NS-1))?~bname:bname; sname<=(cname==((C_PULSE_WIDTH)-1))?0:sname;end  assign sec_pulse_out = sname;assign breath_out = bname;
`define POS_MONITOR_OUTGEN(clk,rst,in,out)                                                              generate  begin  reg buf_name1 = 0; always@(posedge clk)begin if(rst)buf_name1 <= 0; else  buf_name1 <= in; end assign out = (~buf_name1)&(in);  end  endgenerate

//纯异步信号打拍
`define CDC2(local_clk,local_rst,async_signal,buf1_name,buf2_name,init_value)                 reg buf1_name=0;reg buf2_name=0;always@(posedge local_clk)begin if(local_rst)begin buf1_name <= init_value; buf2_name <= init_value;end  else begin buf1_name <= async_signal;buf2_name <= buf1_name;end  end
`define CDC3(local_clk,local_rst,async_signal,buf1_name,buf2_name,buf3_name,init_value)       reg buf1_name=0;reg buf2_name=0;reg buf3_name=0; always@(posedge local_clk)begin if(local_rst)begin buf1_name <= init_value; buf2_name <= init_value;buf3_name <= init_value; end  else begin buf1_name <= async_signal;buf2_name <= buf1_name; buf3_name <= buf2_name; end  end
//电平信号同步（常用）
`define SYN_MULTI_BIT_SINGLE(u_name,aclk_in,adata_in,bclk_in,bdata_out,data_width)               xpm_cdc_array_single #(.DEST_SYNC_FF(3),.INIT_SYNC_FF(0),.SIM_ASSERT_CHK(0),.SRC_INPUT_REG(1),.WIDTH(data_width)) u_name(.src_clk(aclk_in),.src_in(adata_in),.dest_clk(bclk_in),.dest_out(bdata_out));       
//脉冲同步  , arst_in brst_in 可以为常0
`define SYN_SINGLE_BIT_PULSE(u_name,aclk_in,arst_in,apulse_in,bclk_in,brst_in,bpulse_out)         xpm_cdc_pulse #(.DEST_SYNC_FF(4), .INIT_SYNC_FF(0),.REG_OUTPUT(0),.RST_USED(1),.SIM_ASSERT_CHK (0)) u_name (.src_clk(aclk_in),.src_rst(arst_in),.src_pulse(apulse_in),.dest_clk(bclk_in),.dest_rst(brst_in),.dest_pulse(bpulse_out));            

`define CDC_MULTI_BIT_SIGNAL_OUTGEN(aclk,adata_in,bclk,bdata_out,DATA_WIDTH)                            generate begin xpm_cdc_array_single #(.DEST_SYNC_FF(3),.INIT_SYNC_FF(0),.SIM_ASSERT_CHK(0),.SRC_INPUT_REG(1),.WIDTH(DATA_WIDTH)) cdc_u(.src_clk(aclk),.src_in(adata_in),.dest_clk(bclk),.dest_out(bdata_out));    end  endgenerate  
`define CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(adata_in,bclk,bdata_out,DATA_WIDTH)                            generate begin xpm_cdc_array_single #(.DEST_SYNC_FF(3),.INIT_SYNC_FF(0),.SIM_ASSERT_CHK(0),.SRC_INPUT_REG(0),.WIDTH(DATA_WIDTH)) cdc_u(.src_clk( ),.src_in(adata_in),.dest_clk(bclk),.dest_out(bdata_out));    end  endgenerate  

`define CDC_SINGLE_BIT_PULSE_OUTGEN(aclk,arst,apulse_in,bclk,brst,bpulse_out,SIM,DEST_FF)               generate if(SIM==0)begin  xpm_cdc_pulse #(.DEST_SYNC_FF(DEST_FF), .INIT_SYNC_FF(0),.REG_OUTPUT(0),.RST_USED(1),.SIM_ASSERT_CHK (0)) cdc_u (.src_clk(aclk),.src_rst(arst),.src_pulse(apulse_in),.dest_clk(bclk),.dest_rst(brst),.dest_pulse(bpulse_out));   end else begin   reg [5:0] name1 = 0;wire name2;always@(posedge aclk)if(arst)name1[0] <=0;else name1[0] <= apulse_in;assign name2 = apulse_in & ~name1[0]; always@(posedge aclk)if(arst)name1[1] <= 0;else name1[1] <= name2 ? ~name1[1]:name1[1];always@(posedge bclk)if(brst)name1[5:2]<=0;else begin name1[2]<=name1[1];name1[3]<=name1[2];name1[4]<=name1[3];name1[5]<=name1[4];end  assign bpulse_out=name1[4]^name1[5];  end  endgenerate
`define NEG_MONITOR_OUTGEN(clk,rst,in,out)                                                              generate  begin  reg buf_name1 = 0; always@(posedge clk)begin if(rst)buf_name1 <= 0; else  buf_name1 <= in; end assign out = (buf_name1)&(~in);  end  endgenerate
`define XOR_MONITOR_OUTGEN(clk,rst,in,out)                                                              generate  begin  reg buf_name1 = 0; always@(posedge clk)begin if(rst)buf_name1 <= 0; else  buf_name1 <= in; end assign out = buf_name1^in;  end  endgenerate
`define POS_STRETCH_OUTGEN(clk,rst,pulse_in,pulse_out,DELAY_NUM)                                        generate  begin    reg [DELAY_NUM-2:0] temp_name = 0; always@(posedge clk)begin  if(rst)temp_name <= {(DELAY_NUM-1){1'b0}}; else temp_name <= pulse_in ? {(DELAY_NUM-1){1'b1} }: temp_name<<1 ; end  assign  pulse_out = temp_name[DELAY_NUM-2]|pulse_in;  end  endgenerate
`define NEG_STRETCH_OUTGEN(clk,rst,pulsen_in,pulsen_out,DELAY_NUM)                                      generate  begin    reg [DELAY_NUM-2:0] temp_name = 0; always@(posedge clk)begin  if(rst)temp_name <= {(DELAY_NUM-1){1'b0}}; else temp_name <= ~pulsen_in ? {(DELAY_NUM-1){1'b1} }: temp_name<<1 ; end  assign  pulsen_out = ~( temp_name[DELAY_NUM-2] | ~pulsen_in ) ;  end  endgenerate
`define HANDSHAKE_OUTGEN(aclk,arst,apulse_in,adata_in,bclk,brst,bpulse_out,bdata_out,DATA_WIDTH,SIM)    generate  if(SIM==0) begin  handshake  #(.C_DATA_WIDTH(DATA_WIDTH))  handshake_u (.SRC_CLK_I(aclk),.SRC_RST_I(arst),.SRC_DATA_I( adata_in),.SRC_SYNC_PULSE_I ( apulse_in), .DST_CLK_I ( bclk),.DST_DATA_O (bdata_out),.DST_SYNC_FINISH_O(bpulse_out) ); end  else  begin  handshake2 #(.C_DATA_WIDTH(DATA_WIDTH))  handshake_u (.SRC_CLK_I(aclk),.SRC_RST_I(arst),.SRC_DATA_I( adata_in),.SRC_SYNC_PULSE_I ( apulse_in), .DST_CLK_I (bclk),.DST_DATA_O (bdata_out ),.DST_SYNC_FINISH_O(bpulse_out) ); end  endgenerate   
`define DELAY_OUTGEN(clk,rst,data_in,data_out,DATA_WIDTH,DLY)                                           generate if(DLY==0)begin  assign data_out = data_in; end  else if(DLY==1)begin  reg [DATA_WIDTH-1:0] a_temp = 0; always@(posedge clk) a_temp <= data_in; assign data_out = a_temp ; end  else begin  reg [DATA_WIDTH-1:0] a_temp [DLY-1:0] ;always@(posedge clk) begin  if(rst)a_temp[DLY-1] <= 0; else   a_temp[DLY-1] <= data_in; end  for(i=0;i<=DLY-2;i=i+1)begin  always@(posedge clk)begin  if(rst)begin  a_temp[i] <= 0; end  else begin  a_temp[i] <= a_temp[i+1]; end  end  end  assign data_out = a_temp[0]; end  endgenerate





/////////////////////////////////////////////寄存器空间///////////////////////////////////////////////////
//read only from RGB ananlyze
`define   ADDR_LOCKED                  16'h0000 
`define   ADDR_HSYNC                   16'h0004   //assume one port
`define   ADDR_HBP                     16'h0008   //assume one port
`define   ADDR_HACTIVE                 16'h000c   //assume one port
`define   ADDR_HFP                     16'h0010   //assume one port
`define   ADDR_VSYNC                   16'h0014   //assume one port
`define   ADDR_VBP                     16'h0018   //assume one port
`define   ADDR_VACTIVE                 16'h001c   //assume one port
`define   ADDR_VFP                     16'h0020   //assume one port
`define   ADDR_FPS_C1                  16'h0024   //class 1
`define   ADDR_FPS_C1_M1               16'h0028
`define   ADDR_FPS_C1_M2               16'h002C
`define   ADDR_FPS_C1_M3               16'h0030
`define   ADDR_FPS_C1_M4               16'h0034
`define   ADDR_FPS_C1_M5               16'h0038
`define   ADDR_FPS_C1_M6               16'h003c
`define   ADDR_FPS_C1_M7               16'h0040
`define   ADDR_FPS_C1_M8               16'h0044
`define   ADDR_FPS_C1_M9               16'h0048
`define   ADDR_FPS_C1_M10              16'h004c
`define   ADDR_FPS_C2                  16'h0050
`define   ADDR_FPS_C2_M1               16'h0054
`define   ADDR_FPS_C2_M2               16'h0058
`define   ADDR_FPS_C2_M3               16'h005c
`define   ADDR_FPS_C2_M4               16'h0060
`define   ADDR_FPS_C2_M5               16'h0064
`define   ADDR_FPS_C2_M6               16'h0068
`define   ADDR_FPS_C2_M7               16'h006c
`define   ADDR_FPS_C2_M8               16'h0070
`define   ADDR_FPS_C2_M9               16'h0074
`define   ADDR_FPS_C2_M10              16'h0078
`define   ADDR_PARA_VALID              16'h007c
`define   ADDR_RED_VALID               16'h0080
`define   ADDR_GREEN_VALID             16'h0084
`define   ADDR_BLUE_VALID              16'h0088
`define   ADDR_WHITE_VALID             16'h008c
`define   ADDR_BLACK_VALID             16'h0090
                                       
                                       
//read from fifo                       
`define   ADDR_CRC_NUM                 16'h2000 
`define   ADDR_CRC_OFFSET              16'h2004
`define   ADDR_CRC_FIFO_RESET          16'h2008
                                      
//write only                           
`define   ADDR_PORT_NUM                16'h1000
`define   ADDR_BPC                     16'h1004
`define   ADDR_RED_HIGH                16'h1008
`define   ADDR_RED_LOW                 16'h100c
`define   ADDR_GREEN_HIGH              16'h1010
`define   ADDR_GREEN_LOW               16'h1014
`define   ADDR_BLUE_HIGH               16'h1018
`define   ADDR_BLUE_LOW                16'h101c
`define   ADDR_PURE_EXCLUDE_PT_NUM     16'h1020   //数值含义：排除点数
`define   ADDR_VS_REVERSE_EN           16'h1024
`define   ADDR_HS_REVERSE_EN           16'h1028
`define   ADDR_DE_REVERSE_EN           16'h102c  
`define   ADDR_CRC_EXCLUSIVE_X         16'h1030  
`define   ADDR_CRC_EXCLUSIVE_Y         16'h1034  
`define   ADDR_CRC_EXCLUSIVE_H         16'h1038   
`define   ADDR_CRC_EXCLUSIVE_V         16'h103c  
`define   ADDR_CRC_VALUE_ACLK          16'h1040  //读取crc值，从pclk(每帧更新一次) 跨时钟到aclk 

//配置pure exclude prescale 
//点数可以精确计算   

//对外寄存器：   是否纯红，是否纯绿，是否纯蓝 。。。。（全部已经考虑百分比）
//用户自定义纯色pattern
//是否用户自定义纯色
//



// 总点数 0000110100110110011001
// 非纯点 0000000000010010101110
// 


//////////////////////////////
//8*Port_num   * 3
//
//8*3          * Port_num
// 
// 1 无论 Port_num 为多少，理论crc占用资源并不会增加
// 2 关键是考虑不同BPC时 ，需要的crc种类
// 3 需要准备 MAX_PORT_NUM*MAX_BPC vs MAX_BPC*3 
//   明显前者宽度更大，考虑到宽度更大会引起时序困难，采用后者（只需要准备4种 硬CRC）
// 4 如果不使用 flag方式判断纯色，（可以判断组合纯色），则必须使用cnt模式

// 5 纯色过滤模式可以硬选择为FLAG模式或者 CNT模式，FLAG模式下资源消耗较少，但是不能应对osd的情况
//  

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: yzhu
// 
// Create Date: 2022/11/22 18:51:24 
// Design Name: 
// Module Name: rgb_analyze_top
// 
//////////////////////////////////////////////////////////////////////////////////
//4 port no crc no pure check: 500 LUT 1200 FF
//4 port has crc has pure check: 2100  LUT  3000 FF
//4 port has crc no pure check:  1156  LUT  1800  FF
//4 port no  crc has pure check(mode 1):  1488  LUT  2500  FF
//4 port no  crc has pure check(mode 0):  806  LUT  1900  FF
//4 port no  crc has pure check(mode 0) fixed MAX_PORT_NUM :  700  LUT  1850  FF
module rgb_analyze_axi(  
input  wire                                 S_AXI_ACLK      ,
input  wire                                 S_AXI_ARESETN   ,
output wire                                 S_AXI_AWREADY   ,
input  wire [C_S_AXI_ADDR_WIDTH-1:0]        S_AXI_AWADDR    ,
input  wire                                 S_AXI_AWVALID   ,
input  wire [ 2:0]                          S_AXI_AWPROT    ,
output wire                                 S_AXI_WREADY    ,
input  wire [C_S_AXI_DATA_WIDTH-1:0]        S_AXI_WDATA     ,
input  wire [(C_S_AXI_DATA_WIDTH/8)-1 :0]   S_AXI_WSTRB     ,
input  wire                                 S_AXI_WVALID    ,
output wire [ 1:0]                          S_AXI_BRESP     ,
output wire                                 S_AXI_BVALID    ,
input  wire                                 S_AXI_BREADY    ,
output wire                                 S_AXI_ARREADY   ,
input  wire [C_S_AXI_ADDR_WIDTH-1:0]        S_AXI_ARADDR    ,
input  wire                                 S_AXI_ARVALID   ,
input  wire [ 2:0]                          S_AXI_ARPROT    ,
output wire [ 1:0]                          S_AXI_RRESP     ,
output wire                                 S_AXI_RVALID    ,
output wire [C_S_AXI_DATA_WIDTH-1:0]        S_AXI_RDATA     ,
input  wire                                 S_AXI_RREADY    ,

input  PIXEL_CLK_I                 ,
input  PIXEL_CLK_LOCKED_I          ,
input  DE_I                        ,
input  HS_I                        ,
input  VS_I                        ,
input  [C_MAX_PORT_NUM*C_MAX_BPC-1:0] R_I  ,
input  [C_MAX_PORT_NUM*C_MAX_BPC-1:0] G_I  ,
input  [C_MAX_PORT_NUM*C_MAX_BPC-1:0] B_I  ,

output VID_PARA_VALID_O    ,
output VID_SIGNAL_RED_O    ,
output VID_SIGNAL_GREEN_O  ,
output VID_SIGNAL_BLUE_O   ,
output VID_SIGNAL_WHITE_O  ,
output VID_SIGNAL_BLACK_O  ,

input  [C_S_AXI_ADDR_WIDTH-1:0]  LB_WADDR   ,
input  [C_S_AXI_DATA_WIDTH-1:0]  LB_WDATA   ,
input                        LB_WREQ    ,
input  [C_S_AXI_ADDR_WIDTH-1:0]  LB_RADDR   ,
input                        LB_RREQ    ,
output [C_S_AXI_DATA_WIDTH-1:0]  LB_RDATA   ,
output                       LB_RFINISH


);

parameter  [0:0] C_FIXED_MAX_PARA  =  0;

parameter  C_INPUT_REG_NUM = 0; //rgb_analyze NATIVE input FF num


parameter   C_S_AXI_ADDR_WIDTH       = 16;//only support 16
parameter   C_S_AXI_DATA_WIDTH       = 32;//only support 32
parameter [3:0]  C_MAX_PORT_NUM      = 4;
parameter [3:0]  C_MAX_BPC           = 8;
parameter   C_AXI_CLK_PERIOD_NS      = 10;//for second count
/////////////////////////////////////////////////////////////////////////////////////////////////////
parameter  [0:0] C_CRC_BLOCK_EN      = 0;
parameter  C_CRC_FIFO_DEPTH          = 256 ;

parameter  [0:0] C_PURE_CHECK_BLOCK_EN = 1;
parameter  C_PURE_CHECK_MODE = 0; //0 1(exclude point num) 2(exclude percentage)
parameter  C_PURE_CHECK_EXCLUDE_PT_NUM_DEFAULT = 1000000; //test: one time uh8s outpout 4k，osd has 680000 point

//////////////////////////////////////////////////////////////////////////////////////////////////////
parameter [3:0] PORT_NUM_DEFAULT  = 4;    
parameter [3:0] BPC_DEFAULT  = 8; 
parameter [C_MAX_BPC-1:0] RED_HIGH_DEFAULT = 220;    
parameter [C_MAX_BPC-1:0] RED_LOW_DEFAULT  = 20;     
parameter [C_MAX_BPC-1:0] GREEN_HIGH_DEFAULT = 220;  
parameter [C_MAX_BPC-1:0] GREEN_LOW_DEFAULT = 20;   
parameter [C_MAX_BPC-1:0] BLUE_HIGH_DEFAULT = 220;   
parameter [C_MAX_BPC-1:0] BLUE_LOW_DEFAULT = 20;   
//////////////////////////////////////////////////////////////////////////////////////////////////////
parameter  [0:0] C_DEBUG_ENABLE_PCLK = 0;
parameter  [0:0] C_DEBUG_ENABLE_ACLK = 0;


parameter [0:0] C_VS_REVERSE_EN_DEFAULT =  0 ;
parameter [0:0] C_HS_REVERSE_EN_DEFAULT =  0 ;
parameter [0:0] C_DE_REVERSE_EN_DEFAULT =  0 ;

parameter C_CRC_EXCLUVE_X_DEFAULT = 0;
parameter C_CRC_EXCLUVE_Y_DEFAULT = 0;
parameter C_CRC_EXCLUVE_H_DEFAULT = 0;
parameter C_CRC_EXCLUVE_V_DEFAULT = 0;


parameter [0:0] C_ILA_RGB_PARA_PARSE_ACLK = 0;  //aclk 时钟域抓 解析参数，避免在pclk下引入ila导致大量时序问题
parameter [0:0] C_ILA_HSVSDERGB_PCLK      = 0 ; //专门抓输入的实际数据，附带有位置定位

parameter [0:0] C_LB_ENABLE = 0;
//////////////////////////////////////////////////////////////////////////////////////////////////////
genvar i,j,k;

//////////////////////////////////////////////////////////////////////////////////////////////////////

reg        R_LOCKED    ;
reg [15:0] R_HSYNC     ;
reg [15:0] R_HBP       ;
reg [15:0] R_HACTIVE   ;
reg [15:0] R_HFP       ;
reg [15:0] R_VSYNC     ;
reg [15:0] R_VBP       ;
reg [15:0] R_VACTIVE   ;
reg [15:0] R_VFP       ;
reg [7:0]  R_FPS       ;
reg [7:0]  R_FPS_SERIES;
reg [7:0]  R_FPS_RED   ;
reg [7:0]  R_FPS_GREEN ;
reg [7:0]  R_FPS_BLUE  ;
reg [7:0]  R_FPS_BLACK ;
reg [7:0]  R_FPS_WHITE ;

reg [3:0]            R_PORT_NUM    = PORT_NUM_DEFAULT ;//  16'h1000
reg [3:0]            R_BPC         = BPC_DEFAULT ;//  16'h1004
reg [C_MAX_BPC-1:0]  R_RED_HIGH    = RED_HIGH_DEFAULT ;//  16'h1008
reg [C_MAX_BPC-1:0]  R_RED_LOW     = RED_LOW_DEFAULT ;//  16'h100c
reg [C_MAX_BPC-1:0]  R_GREEN_HIGH  = GREEN_HIGH_DEFAULT ;//  16'h1010
reg [C_MAX_BPC-1:0]  R_GREEN_LOW   = GREEN_LOW_DEFAULT ;//  16'h1014
reg [C_MAX_BPC-1:0]  R_BLUE_HIGH   = BLUE_HIGH_DEFAULT ;//  16'h1018
reg [C_MAX_BPC-1:0]  R_BLUE_LOW    = BLUE_LOW_DEFAULT ;//  16'h101c


reg  R_VS_REVERSE_EN  = C_VS_REVERSE_EN_DEFAULT; 
reg  R_HS_REVERSE_EN  = C_HS_REVERSE_EN_DEFAULT; 
reg  R_DE_REVERSE_EN  = C_DE_REVERSE_EN_DEFAULT;   



//////////////////////////////////////////////////////////////////////////////////////////////////////
reg        de_buf  = 0;
reg        hs_buf  = 0;
reg        vs_buf  = 0;
reg [C_MAX_PORT_NUM*C_MAX_BPC-1:0] r_buf   = 0;
reg [C_MAX_PORT_NUM*C_MAX_BPC-1:0] g_buf   = 0;
reg [C_MAX_PORT_NUM*C_MAX_BPC-1:0] b_buf   = 0;

always@(posedge PIXEL_CLK_I)begin
    if(~PIXEL_CLK_LOCKED_I)begin
        de_buf <= 0;
        hs_buf <= 0;
        vs_buf <= 0;
        r_buf  <= 0;
        g_buf  <= 0;
        b_buf  <= 0;
    end
    else begin
        de_buf <= DE_I;
        hs_buf <= HS_I;
        vs_buf <= VS_I;
        r_buf  <= R_I ;
        g_buf  <= G_I ;
        b_buf  <= B_I ;
    end
end


//////////////////////////////////////////////////////////////////////////////////////////////////////
wire sec_pulse_axi;
wire sec_pulse_pclk;
wire        ram_wr_en ;
wire [15:0] ram_wr_addr;
wire [31:0] ram_wr_data;
(*keep="true"*)wire        ram_rd_en;
(*keep="true"*)wire [15:0] ram_rd_addr;
wire [31:0] ram_rd_data;
wire [31:0] fifo_crc;
wire        fifo_wr ; 
wire breath_out;
reg [31:0] cnt_sim = 0;


wire        write_req_cpu_to_axi  ;
wire [C_S_AXI_ADDR_WIDTH-1:0] write_addr_cpu_to_axi ;
wire [C_S_AXI_DATA_WIDTH-1:0] write_data_cpu_to_axi ;
wire        read_req_cpu_to_axi   ;
wire [C_S_AXI_ADDR_WIDTH-1:0] read_addr_cpu_to_axi  ;
wire [C_S_AXI_DATA_WIDTH-1:0] read_data_axi_to_cpu  ;
wire         read_finish_axi_to_cpu;


wire                       write_req_cpu_to_axi_ll   ;
wire [C_S_AXI_ADDR_WIDTH-1:0]  write_addr_cpu_to_axi_ll  ;
wire [C_S_AXI_DATA_WIDTH-1:0]  write_data_cpu_to_axi_ll  ;
wire                       read_req_cpu_to_axi_ll    ;
wire  [C_S_AXI_ADDR_WIDTH-1:0] read_addr_cpu_to_axi_ll   ;
reg  [C_S_AXI_DATA_WIDTH-1:0]  read_data_axi_to_cpu_ll    = 0;  
reg                        read_finish_axi_to_cpu_ll  = 0;


wire        fifo_wr_en;
wire [31:0] fifo_wr_data;
wire        fifo_rd_en;
wire [31:0] fifo_rd_data;   
wire [9:0]  fifo_rd_data_count;
wire [9:0]  fifo_rd_data_count2;
reg [7:0]   state = 0;
wire wr_rst_busy;
wire rd_rst_busy;
wire PIXEL_CLK_LOCKED_I_aclk;
reg [3:0]            R_PORT_NUM    = PORT_NUM_DEFAULT   ;//  16'h1000
reg [3:0]            R_BPC         = BPC_DEFAULT        ;//  16'h1004
reg [C_MAX_BPC-1:0]  R_RED_HIGH    = RED_HIGH_DEFAULT   ;//  16'h1008
reg [C_MAX_BPC-1:0]  R_RED_LOW     = RED_LOW_DEFAULT    ;//  16'h100c
reg [C_MAX_BPC-1:0]  R_GREEN_HIGH  = GREEN_HIGH_DEFAULT ;//  16'h1010
reg [C_MAX_BPC-1:0]  R_GREEN_LOW   = GREEN_LOW_DEFAULT  ;//  16'h1014
reg [C_MAX_BPC-1:0]  R_BLUE_HIGH   = BLUE_HIGH_DEFAULT  ;//  16'h1018
reg [C_MAX_BPC-1:0]  R_BLUE_LOW    = BLUE_LOW_DEFAULT   ;//  16'h101c
wire [3:0]            R_PORT_NUM_vid   ;//  16'h1000
wire [3:0]            R_BPC_vid        ;//  16'h1004
wire [C_MAX_BPC-1:0]  R_RED_HIGH_vid   ;//  16'h1008
wire [C_MAX_BPC-1:0]  R_RED_LOW_vid    ;//  16'h100c
wire [C_MAX_BPC-1:0]  R_GREEN_HIGH_vid ;//  16'h1010
wire [C_MAX_BPC-1:0]  R_GREEN_LOW_vid  ;//  16'h1014
wire [C_MAX_BPC-1:0]  R_BLUE_HIGH_vid  ;//  16'h1018
wire [C_MAX_BPC-1:0]  R_BLUE_LOW_vid   ;//  16'h101c
reg [7:0] state = 0;
wire [9:0]  fifo_crc_count;
wire        fifo_rst_busy ;
wire        fifo_rd_en;
wire [31:0] fifo_rd_data;
wire        para_valid;
wire  rsta_busy;
wire  rstb_busy;
reg [23:0] R_PURE_EXCLUDE_PT_NUM = C_PURE_CHECK_EXCLUDE_PT_NUM_DEFAULT;
wire [23:0] R_PURE_EXCLUDE_PT_NUM_vid;
reg  R_CRC_FIFO_RESET = 0;

reg [15:0] R_CRC_EXCLUVE_X = C_CRC_EXCLUVE_X_DEFAULT;
reg [15:0] R_CRC_EXCLUVE_Y = C_CRC_EXCLUVE_Y_DEFAULT;
reg [15:0] R_CRC_EXCLUVE_H = C_CRC_EXCLUVE_H_DEFAULT;
reg [15:0] R_CRC_EXCLUVE_V = C_CRC_EXCLUVE_V_DEFAULT;


wire [15:0] R_CRC_EXCLUVE_X_vid ;
wire [15:0] R_CRC_EXCLUVE_Y_vid ;
wire [15:0] R_CRC_EXCLUVE_H_vid ;
wire [15:0] R_CRC_EXCLUVE_V_vid ;


wire R_DE_REVERSE_EN_pclk  ;
wire R_HS_REVERSE_EN_pclk  ;
wire R_VS_REVERSE_EN_pclk  ;




assign write_req_cpu_to_axi_ll  =  C_LB_ENABLE ? LB_WREQ  : write_req_cpu_to_axi  ;
assign write_addr_cpu_to_axi_ll =  C_LB_ENABLE ? LB_WADDR : write_addr_cpu_to_axi ;
assign write_data_cpu_to_axi_ll =  C_LB_ENABLE ? LB_WDATA : write_data_cpu_to_axi ;
assign read_req_cpu_to_axi_ll   =  C_LB_ENABLE ? LB_RREQ  : read_req_cpu_to_axi ;
assign read_addr_cpu_to_axi_ll  =  C_LB_ENABLE ? LB_RADDR : read_addr_cpu_to_axi ;

assign read_data_axi_to_cpu     =  C_LB_ENABLE ? 0 : read_data_axi_to_cpu_ll   ;
assign read_finish_axi_to_cpu   =  C_LB_ENABLE ? 0 : read_finish_axi_to_cpu_ll ;
assign LB_RDATA                 =  C_LB_ENABLE ? read_data_axi_to_cpu_ll   : 0 ;
assign LB_RFINISH               =  C_LB_ENABLE ? read_finish_axi_to_cpu_ll : 0 ;



`CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(R_PORT_NUM   ,PIXEL_CLK_I ,R_PORT_NUM_vid   ,4)
`CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(R_BPC        ,PIXEL_CLK_I ,R_BPC_vid        ,4)
`CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(R_RED_HIGH   ,PIXEL_CLK_I ,R_RED_HIGH_vid   ,C_MAX_BPC)
`CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(R_RED_LOW    ,PIXEL_CLK_I ,R_RED_LOW_vid    ,C_MAX_BPC)
`CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(R_GREEN_HIGH ,PIXEL_CLK_I ,R_GREEN_HIGH_vid ,C_MAX_BPC)
`CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(R_GREEN_LOW  ,PIXEL_CLK_I ,R_GREEN_LOW_vid  ,C_MAX_BPC)
`CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(R_BLUE_HIGH  ,PIXEL_CLK_I ,R_BLUE_HIGH_vid  ,C_MAX_BPC)
`CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(R_BLUE_LOW   ,PIXEL_CLK_I ,R_BLUE_LOW_vid   ,C_MAX_BPC)
`CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(R_PURE_EXCLUDE_PT_NUM   ,PIXEL_CLK_I ,R_PURE_EXCLUDE_PT_NUM_vid   ,24)

`CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(R_CRC_EXCLUVE_X   ,PIXEL_CLK_I ,R_CRC_EXCLUVE_X_vid   ,16)
`CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(R_CRC_EXCLUVE_Y   ,PIXEL_CLK_I ,R_CRC_EXCLUVE_Y_vid   ,16)
`CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(R_CRC_EXCLUVE_H   ,PIXEL_CLK_I ,R_CRC_EXCLUVE_H_vid   ,16)
`CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(R_CRC_EXCLUVE_V   ,PIXEL_CLK_I ,R_CRC_EXCLUVE_V_vid   ,16)


`CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(PIXEL_CLK_LOCKED_I,S_AXI_ACLK,PIXEL_CLK_LOCKED_I_aclk,1)  

`CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(R_DE_REVERSE_EN,PIXEL_CLK_I,R_DE_REVERSE_EN_pclk,1)  
`CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(R_HS_REVERSE_EN,PIXEL_CLK_I,R_HS_REVERSE_EN_pclk,1)  
`CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(R_VS_REVERSE_EN,PIXEL_CLK_I,R_VS_REVERSE_EN_pclk,1)  
 



`TIMER(S_AXI_ACLK,0,C_AXI_CLK_PERIOD_NS,cname,sname,bname,20,sec_pulse_axi,breath_out)
`SYN_SINGLE_BIT_PULSE(cdc_u0,S_AXI_ACLK,0,sec_pulse_axi,PIXEL_CLK_I,0,sec_pulse_pclk) 



axi_lite_slave 
    #(.C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH  ),
      .C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH  ))
    axi_lite_slave_u(
	.S_AXI_ACLK            (S_AXI_ACLK              ),
	.S_AXI_ARESETN         (S_AXI_ARESETN           ),
	.S_AXI_AWADDR          (S_AXI_AWADDR            ), // [C_S_AXI_ADDR_WIDTH-1 : 0]
	.S_AXI_AWPROT          (S_AXI_AWPROT            ), //[2 : 0]
	.S_AXI_AWVALID         (S_AXI_AWVALID           ),
	.S_AXI_AWREADY         (S_AXI_AWREADY           ),
	.S_AXI_WDATA           (S_AXI_WDATA             ), //[C_S_AXI_DATA_WIDTH-1 : 0] 
	.S_AXI_WSTRB           (S_AXI_WSTRB             ), // [(C_S_AXI_DATA_WIDTH/8)-1 : 0]
	.S_AXI_WVALID          (S_AXI_WVALID            ),
	.S_AXI_WREADY          (S_AXI_WREADY            ),
	.S_AXI_BRESP           (S_AXI_BRESP             ), //[1 : 0] 
	.S_AXI_BVALID          (S_AXI_BVALID            ),
	.S_AXI_BREADY          (S_AXI_BREADY            ),
	.S_AXI_ARADDR          (S_AXI_ARADDR            ), //[C_S_AXI_ADDR_WIDTH-1 : 0]
	.S_AXI_ARPROT          (S_AXI_ARPROT            ), //[2 : 0]
	.S_AXI_ARVALID         (S_AXI_ARVALID           ),
	.S_AXI_ARREADY         (S_AXI_ARREADY           ),
	.S_AXI_RDATA           (S_AXI_RDATA             ), //[C_S_AXI_DATA_WIDTH-1 : 0]
	.S_AXI_RRESP           (S_AXI_RRESP             ), //[1 : 0]
	.S_AXI_RVALID          (S_AXI_RVALID            ),
	.S_AXI_RREADY          (S_AXI_RREADY            ),
    .o_rx_dval             (  write_req_cpu_to_axi  ),
    .o_rx_addr             (  write_addr_cpu_to_axi ), //[C_S_AXI_ADDR_WIDTH-1:0]
    .o_rx_data             (  write_data_cpu_to_axi ), //[C_S_AXI_DATA_WIDTH-1:0]
    .o_tx_req              (  read_req_cpu_to_axi   ),
    .o_tx_addr             (  read_addr_cpu_to_axi  ), //[C_S_AXI_ADDR_WIDTH-1:0] 
    .i_tx_data             (  read_data_axi_to_cpu  ), //[C_S_AXI_DATA_WIDTH-1:0]
    .i_tx_dval             (  read_finish_axi_to_cpu));




always@(posedge S_AXI_ACLK)begin
    if(~S_AXI_ARESETN)begin
        R_PORT_NUM    <= PORT_NUM_DEFAULT   ;
        R_BPC         <= BPC_DEFAULT        ;
        R_RED_HIGH    <= RED_HIGH_DEFAULT   ;
        R_RED_LOW     <= RED_LOW_DEFAULT    ;
        R_GREEN_HIGH  <= GREEN_HIGH_DEFAULT ;
        R_GREEN_LOW   <= GREEN_LOW_DEFAULT  ;
        R_BLUE_HIGH   <= BLUE_HIGH_DEFAULT  ;
        R_BLUE_LOW    <= BLUE_LOW_DEFAULT   ;  
        R_PURE_EXCLUDE_PT_NUM <= C_PURE_CHECK_EXCLUDE_PT_NUM_DEFAULT;
        R_VS_REVERSE_EN  <= C_VS_REVERSE_EN_DEFAULT; 
        R_HS_REVERSE_EN  <= C_HS_REVERSE_EN_DEFAULT; 
        R_DE_REVERSE_EN  <= C_DE_REVERSE_EN_DEFAULT;   
        R_CRC_EXCLUVE_X  <= C_CRC_EXCLUVE_X_DEFAULT;
        R_CRC_EXCLUVE_Y  <= C_CRC_EXCLUVE_Y_DEFAULT;
        R_CRC_EXCLUVE_H  <= C_CRC_EXCLUVE_H_DEFAULT;
        R_CRC_EXCLUVE_V  <= C_CRC_EXCLUVE_V_DEFAULT;
        R_CRC_FIFO_RESET <= 0;
    end
    else if(write_req_cpu_to_axi_ll)begin
        case(write_addr_cpu_to_axi_ll)
            `ADDR_PORT_NUM   : R_PORT_NUM    <= write_data_cpu_to_axi_ll ;
            `ADDR_BPC        : R_BPC         <= write_data_cpu_to_axi_ll ;
            `ADDR_RED_HIGH   : R_RED_HIGH    <= write_data_cpu_to_axi_ll ;
            `ADDR_RED_LOW    : R_RED_LOW     <= write_data_cpu_to_axi_ll ;
            `ADDR_GREEN_HIGH : R_GREEN_HIGH  <= write_data_cpu_to_axi_ll ;
            `ADDR_GREEN_LOW  : R_GREEN_LOW   <= write_data_cpu_to_axi_ll ;
            `ADDR_BLUE_HIGH  : R_BLUE_HIGH   <= write_data_cpu_to_axi_ll ;
            `ADDR_BLUE_LOW   : R_BLUE_LOW    <= write_data_cpu_to_axi_ll ;
            `ADDR_PURE_EXCLUDE_PT_NUM : R_PURE_EXCLUDE_PT_NUM <= write_data_cpu_to_axi_ll;
            `ADDR_VS_REVERSE_EN       : R_VS_REVERSE_EN <= write_data_cpu_to_axi_ll ;
            `ADDR_HS_REVERSE_EN       : R_HS_REVERSE_EN <= write_data_cpu_to_axi_ll ;
            `ADDR_DE_REVERSE_EN       : R_DE_REVERSE_EN <= write_data_cpu_to_axi_ll ;
            
            `ADDR_CRC_FIFO_RESET      : R_CRC_FIFO_RESET  <= 1 ;
            
            `ADDR_CRC_EXCLUSIVE_X   : R_CRC_EXCLUVE_X <=  write_data_cpu_to_axi_ll ;
            `ADDR_CRC_EXCLUSIVE_Y   : R_CRC_EXCLUVE_Y <=  write_data_cpu_to_axi_ll   ;
            `ADDR_CRC_EXCLUSIVE_H   : R_CRC_EXCLUVE_H <=  write_data_cpu_to_axi_ll  ;
            `ADDR_CRC_EXCLUSIVE_V   : R_CRC_EXCLUVE_V <=  write_data_cpu_to_axi_ll   ;
            
            default:;
        endcase
    end
    else begin
        R_CRC_FIFO_RESET <= 0;
    end
end


wire crc_fifo_rst_pclk;
`SYN_SINGLE_BIT_PULSE(cdc_u1,S_AXI_ACLK,0,R_CRC_FIFO_RESET,PIXEL_CLK_I,0,crc_fifo_rst_pclk) 


wire [15:0] HSYNC_VID    ;
wire [15:0] HBP_VID      ;
wire [15:0] HACTIVE_VID  ;
wire [15:0] HFP_VID      ;
wire [15:0] VSYNC_VID    ;
wire [15:0] VBP_VID      ;
wire [15:0] VACTIVE_VID  ;
wire [15:0] VFP_VID      ;


wire [15:0] HSYNC_aclk    ;
wire [15:0] HBP_aclk       ;
wire [15:0] HACTIVE_aclk   ;
wire [15:0] HFP_aclk       ;
wire [15:0] VSYNC_aclk     ;
wire [15:0] VBP_aclk       ;
wire [15:0] VACTIVE_aclk  ;
wire [15:0] VFP_aclk       ;


`SYN_MULTI_BIT_SINGLE(cdc_u10,PIXEL_CLK_I,HSYNC_VID    ,S_AXI_ACLK,HSYNC_aclk    ,16) 
`SYN_MULTI_BIT_SINGLE(cdc_u11,PIXEL_CLK_I,HBP_VID      ,S_AXI_ACLK,HBP_aclk      ,16) 
`SYN_MULTI_BIT_SINGLE(cdc_u12,PIXEL_CLK_I,HACTIVE_VID  ,S_AXI_ACLK,HACTIVE_aclk  ,16) 
`SYN_MULTI_BIT_SINGLE(cdc_u13,PIXEL_CLK_I,HFP_VID      ,S_AXI_ACLK,HFP_aclk      ,16) 
`SYN_MULTI_BIT_SINGLE(cdc_u14,PIXEL_CLK_I,VSYNC_VID    ,S_AXI_ACLK,VSYNC_aclk    ,16) 
`SYN_MULTI_BIT_SINGLE(cdc_u15,PIXEL_CLK_I,VBP_VID      ,S_AXI_ACLK,VBP_aclk      ,16) 
`SYN_MULTI_BIT_SINGLE(cdc_u16,PIXEL_CLK_I,VACTIVE_VID  ,S_AXI_ACLK,VACTIVE_aclk  ,16) 
`SYN_MULTI_BIT_SINGLE(cdc_u17,PIXEL_CLK_I,VFP_VID      ,S_AXI_ACLK,VFP_aclk      ,16) 




reg auto_vs_polarity_pclk = 0;
reg auto_hs_polarity_pclk = 0; 

wire auto_vs_polarity_aclk;
wire auto_hs_polarity_aclk;

`SYN_MULTI_BIT_SINGLE(cdc_u18,PIXEL_CLK_I,auto_vs_polarity_pclk      ,S_AXI_ACLK,auto_vs_polarity_aclk      ,1) 
`SYN_MULTI_BIT_SINGLE(cdc_u19,PIXEL_CLK_I,auto_hs_polarity_pclk      ,S_AXI_ACLK,auto_hs_polarity_aclk      ,1) 


always @ (posedge PIXEL_CLK_I)begin
    auto_vs_polarity_pclk <= de_buf ? vs_buf : auto_vs_polarity_pclk ;
    auto_hs_polarity_pclk <= de_buf ? hs_buf : auto_hs_polarity_pclk;

end



wire [31:0] fifo_crc_aclk ;
`CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(fifo_crc ,S_AXI_ACLK, fifo_crc_aclk ,32)  

   
rgb_analyze  
    #(.MAX_PORT_NUM    (C_MAX_PORT_NUM   ) , 
      .MAX_BPC         (C_MAX_BPC) ,
      .RAM_UPDATE_REG_NUM (50) ,
      .CRC_BLOCK_EN    (C_CRC_BLOCK_EN),
      .PURE_CHECK_BLOCK_EN(C_PURE_CHECK_BLOCK_EN) ,
      .PURE_CHECK_MODE (C_PURE_CHECK_MODE),
      .INPUT_REG_NUM   (C_INPUT_REG_NUM  ),
	  .ADDR_LOCKED    ( `ADDR_LOCKED      ), 
	  .ADDR_HSYNC     ( `ADDR_HSYNC       ), 
	  .ADDR_HBP       ( `ADDR_HBP         ), 
	  .ADDR_HACTIVE   ( `ADDR_HACTIVE     ), 
	  .ADDR_HFP       ( `ADDR_HFP         ), 
	  .ADDR_VSYNC     ( `ADDR_VSYNC       ), 
	  .ADDR_VBP       ( `ADDR_VBP         ), 
	  .ADDR_VACTIVE   ( `ADDR_VACTIVE     ), 
	  .ADDR_VFP       ( `ADDR_VFP         ), 
	  .ADDR_FPS_C1    ( `ADDR_FPS_C1      ), 
	  .ADDR_FPS_C1_M1 ( `ADDR_FPS_C1_M1   ), 
	  .ADDR_FPS_C1_M2 ( `ADDR_FPS_C1_M2   ), 
	  .ADDR_FPS_C1_M3 ( `ADDR_FPS_C1_M3   ), 
	  .ADDR_FPS_C1_M4 ( `ADDR_FPS_C1_M4   ), 
	  .ADDR_FPS_C1_M5 ( `ADDR_FPS_C1_M5   ), 
	  .ADDR_FPS_C1_M6 ( `ADDR_FPS_C1_M6   ), 
	  .ADDR_FPS_C1_M7 ( `ADDR_FPS_C1_M7   ), 
	  .ADDR_FPS_C1_M8 ( `ADDR_FPS_C1_M8   ), 
	  .ADDR_FPS_C1_M9 ( `ADDR_FPS_C1_M9   ), 
	  .ADDR_FPS_C1_M10( `ADDR_FPS_C1_M10  ), 
	  .ADDR_FPS_C2    ( `ADDR_FPS_C2      ), 
	  .ADDR_FPS_C2_M1 ( `ADDR_FPS_C2_M1   ), 
	  .ADDR_FPS_C2_M2 ( `ADDR_FPS_C2_M2   ), 
	  .ADDR_FPS_C2_M3 ( `ADDR_FPS_C2_M3   ), 
	  .ADDR_FPS_C2_M4 ( `ADDR_FPS_C2_M4   ), 
	  .ADDR_FPS_C2_M5 ( `ADDR_FPS_C2_M5   ), 
	  .ADDR_FPS_C2_M6 ( `ADDR_FPS_C2_M6   ), 
	  .ADDR_FPS_C2_M7 ( `ADDR_FPS_C2_M7   ), 
	  .ADDR_FPS_C2_M8 ( `ADDR_FPS_C2_M8   ), 
	  .ADDR_FPS_C2_M9 ( `ADDR_FPS_C2_M9   ), 
	  .ADDR_FPS_C2_M10( `ADDR_FPS_C2_M10  ),
	  .ADDR_PARA_VALID (`ADDR_PARA_VALID ),
	  .ADDR_RED_VALID  (`ADDR_RED_VALID  ),
	  .ADDR_GREEN_VALID(`ADDR_GREEN_VALID),
	  .ADDR_BLUE_VALID (`ADDR_BLUE_VALID ),
	  .ADDR_WHITE_VALID(`ADDR_WHITE_VALID),
	  .ADDR_BLACK_VALID(`ADDR_BLACK_VALID)

      )
    rgb_u(
    .TIMER_I        (sec_pulse_pclk      ), 
    .CLK_I          (PIXEL_CLK_I         ),
    .RST_I          (~PIXEL_CLK_LOCKED_I ),  
    .PORT_NUM_I     ( C_FIXED_MAX_PARA ?  C_MAX_PORT_NUM  :  R_PORT_NUM_vid  ),

    .BPC_I          ( C_FIXED_MAX_PARA ?  C_MAX_BPC :   R_BPC_vid       ),
    
    .RH_I           (R_RED_HIGH_vid  ),
    .RL_I           (R_RED_LOW_vid   ),
    .GH_I           (R_GREEN_HIGH_vid),
    .GL_I           (R_GREEN_LOW_vid ),
    .BH_I           (R_BLUE_HIGH_vid ),
    .BL_I           (R_BLUE_LOW_vid  ), 
   //.DE_I           (R_DE_REVERSE_EN_pclk ? ~de_buf : de_buf  ), 
   // .HS_I           (R_HS_REVERSE_EN_pclk ? ~hs_buf : hs_buf  ), 
   // .VS_I           (R_VS_REVERSE_EN_pclk ? ~vs_buf : vs_buf  ), 
    

    .DE_I           (   de_buf                                 ), 
    .HS_I           (auto_hs_polarity_pclk ? ~hs_buf : hs_buf  ), 
    .VS_I           (auto_vs_polarity_pclk ? ~vs_buf : vs_buf  ), 
    
    
    
    .R_I            (r_buf         ), 
    .G_I            (g_buf         ), 
    .B_I            (b_buf         ), 
    .RAM_DATA_O     (ram_wr_data   ),
    .RAM_ADDR_O     (ram_wr_addr   ),
    .RAM_WR_O       (ram_wr_en     ),
    .FIFO_CRC_O     (fifo_crc      ),
    .FIFO_WR_O      (fifo_wr       ),
	.PARA_VALID_O   (VID_PARA_VALID_O   ),//~timer
	.SIGNAL_RED_O   (VID_SIGNAL_RED_O   ),//~vs
	.SIGNAL_GREEN_O (VID_SIGNAL_GREEN_O ),//~vs
	.SIGNAL_BLUE_O  (VID_SIGNAL_BLUE_O  ),//~vs
	.SIGNAL_WHITE_O (VID_SIGNAL_WHITE_O ),//~vs
	.SIGNAL_BLACK_O (VID_SIGNAL_BLACK_O ),//~vs
    
    .EXCLUDE_PT_NUM_I (R_PURE_EXCLUDE_PT_NUM_vid),
    
  
    .CRC_EXCLUVE_X   (R_CRC_EXCLUVE_X_vid) ,
    .CRC_EXCLUVE_Y   (R_CRC_EXCLUVE_Y_vid) ,
    .CRC_EXCLUVE_H   (R_CRC_EXCLUVE_H_vid) ,
    .CRC_EXCLUVE_V   (R_CRC_EXCLUVE_V_vid) ,
    
    
    .HSYNC_O       (HSYNC_VID    ),
    .HBP_O         (HBP_VID      ),
    .HACTIVE_O     (HACTIVE_VID  ),
    .HFP_O         (HFP_VID      ),
    .VSYNC_O       (VSYNC_VID    ),
    .VBP_O         (VBP_VID      ),
    .VACTIVE_O     (VACTIVE_VID  ),
    .VFP_O         (VFP_VID      )
    
    
    

     );


assign ram_rd_en   = read_req_cpu_to_axi ;
assign ram_rd_addr = read_addr_cpu_to_axi >> 2 ;//如果为非rgb analyze寄存器，也能在其他处被忽略

rgb_analyze_ram   rgb_analyze_ram_u(
    .clka      (PIXEL_CLK_I   ) ,//: IN STD_LOGIC;
    .wea       (ram_wr_en     ) ,//: IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    .addra     (ram_wr_addr   ) ,//: IN STD_LOGIC_VECTOR(4 DOWNTO 0);
    .dina      (ram_wr_data   ) ,//: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    .clkb      (S_AXI_ACLK    ) ,//: IN STD_LOGIC;
    //.rstb      (~PIXEL_CLK_LOCKED_I_aclk | ~S_AXI_ARESETN) ,//因为没有输入端时钟域复位
    .enb       (ram_rd_en     ) ,//: IN STD_LOGIC;
    .addrb     (ram_rd_addr   ) ,//: IN STD_LOGIC_VECTOR(4 DOWNTO 0);
    .doutb     (ram_rd_data   )  //: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    //.rsta_busy (rsta_busy ) ,//: OUT STD_LOGIC;
    //.rstb_busy (rstb_busy )  //: OUT STD_LOGIC
    );
    


assign fifo_rd_en = read_req_cpu_to_axi & (read_addr_cpu_to_axi==`ADDR_CRC_OFFSET) ;




generate if(C_CRC_BLOCK_EN)begin
fifo_xpm_async
   #(.WRITE_DATA_WIDTH   (32      ), //W/R ratio must be 1:1, 1:2, 1:4, 1:8, 8:1, 4:1 , 2:1  
     .READ_DATA_WIDTH    (32      ), //W/R ratio must be 1:1, 1:2, 1:4, 1:8, 8:1, 4:1 , 2:1  
     .WRITE_FIFO_DEPTH   (C_CRC_FIFO_DEPTH     ), //must>=16 ;actual depth = WRITE_FIFO_DEPTH-1; must be power of two
     .WR_DATA_COUNT_WIDTH(10      ), //as you wish ; must >= 1
     .RD_DATA_COUNT_WIDTH(10      ),//as you wish ; must >= 1
     .PROG_EMPTY_THRESH  (16      ),
     .PROG_FULL_THRESH   (110     )) 
   fifo_xpm_async_u(
   .WR_RST_I       (~PIXEL_CLK_LOCKED_I | crc_fifo_rst_pclk),//at least 1 WR_CLK_I period
   .WR_CLK_I       (PIXEL_CLK_I         ),//[0:0]
   .WR_EN_I        (fifo_wr             ),//[0:0]
   .WR_DATA_I      (fifo_crc            ),//[WRITE_DATA_WIDTH-1:0]
   .WR_FULL_O      (                    ),//[0:0]
   .WR_DATA_COUNT_O(                    ),//[WR_DATA_COUNT_WIDTH-1:0]
   .WR_RST_BUSY_O  (                    ),
   .RD_CLK_I       (S_AXI_ACLK          ),//[0:0]
   .RD_EN_I        (fifo_rd_en          ),//[0:0]
   .RD_DATA_O      (fifo_rd_data        ),//[READ_DATA_WIDTH-1:0]
   .RD_EMPTY_O     (                    ),//[0:0]
   .RD_DATA_COUNT_O(fifo_crc_count      ),//[RD_DATA_COUNT_WIDTH-1:0]
   .RD_RST_BUSY_O  (fifo_rst_busy       ) 
   );
end
endgenerate



always@(posedge S_AXI_ACLK) begin
    if(~S_AXI_ARESETN)begin
         read_finish_axi_to_cpu_ll <= 0;
         read_data_axi_to_cpu_ll <= 0;
         state <= 0;
    end
    else begin
        case(state)
            0:begin
                read_finish_axi_to_cpu_ll <= 0;
                if(read_req_cpu_to_axi_ll)begin
                    state <= 1;
                end
            end
            1:begin
                state <= 0;
                read_finish_axi_to_cpu_ll <= 1;
                case(read_addr_cpu_to_axi_ll)
                    `ADDR_LOCKED     : read_data_axi_to_cpu_ll <= PIXEL_CLK_LOCKED_I_aclk ;
                    `ADDR_HSYNC      : read_data_axi_to_cpu_ll <= ram_rd_data ;
                    `ADDR_HBP        : read_data_axi_to_cpu_ll <= ram_rd_data ;
                    `ADDR_HACTIVE    : read_data_axi_to_cpu_ll <= ram_rd_data ;
                    `ADDR_HFP        : read_data_axi_to_cpu_ll <= ram_rd_data ;
                    `ADDR_VSYNC      : read_data_axi_to_cpu_ll <= ram_rd_data ;
                    `ADDR_VBP        : read_data_axi_to_cpu_ll <= ram_rd_data ;
                    `ADDR_VACTIVE    : read_data_axi_to_cpu_ll <= ram_rd_data ;
                    `ADDR_VFP        : read_data_axi_to_cpu_ll <= ram_rd_data ;
                    `ADDR_FPS_C1     : read_data_axi_to_cpu_ll <= ram_rd_data ;
					`ADDR_FPS_C1_M1  : read_data_axi_to_cpu_ll <= ram_rd_data ;
					`ADDR_FPS_C1_M2  : read_data_axi_to_cpu_ll <= ram_rd_data ;
					`ADDR_FPS_C1_M3  : read_data_axi_to_cpu_ll <= ram_rd_data ;
					`ADDR_FPS_C1_M4  : read_data_axi_to_cpu_ll <= ram_rd_data ;
					`ADDR_FPS_C1_M5  : read_data_axi_to_cpu_ll <= ram_rd_data ;
					`ADDR_FPS_C1_M6  : read_data_axi_to_cpu_ll <= ram_rd_data ;
					`ADDR_FPS_C1_M7  : read_data_axi_to_cpu_ll <= ram_rd_data ;
                    `ADDR_FPS_C1_M8  : read_data_axi_to_cpu_ll <= ram_rd_data ;
                    `ADDR_FPS_C1_M9  : read_data_axi_to_cpu_ll <= ram_rd_data ;
                    `ADDR_FPS_C1_M10 : read_data_axi_to_cpu_ll <= ram_rd_data ;
                    `ADDR_FPS_C2     : read_data_axi_to_cpu_ll <= ram_rd_data ;
                    `ADDR_FPS_C2_M1  : read_data_axi_to_cpu_ll <= ram_rd_data ;
                    `ADDR_FPS_C2_M2  : read_data_axi_to_cpu_ll <= ram_rd_data ;
                    `ADDR_FPS_C2_M3  : read_data_axi_to_cpu_ll <= ram_rd_data ;
                    `ADDR_FPS_C2_M4  : read_data_axi_to_cpu_ll <= ram_rd_data ;
                    `ADDR_FPS_C2_M5  : read_data_axi_to_cpu_ll <= ram_rd_data ;
                    `ADDR_FPS_C2_M6  : read_data_axi_to_cpu_ll <= ram_rd_data ;
                    `ADDR_FPS_C2_M7  : read_data_axi_to_cpu_ll <= ram_rd_data ;
                    `ADDR_FPS_C2_M8  : read_data_axi_to_cpu_ll <= ram_rd_data ;
                    `ADDR_FPS_C2_M9  : read_data_axi_to_cpu_ll <= ram_rd_data ;
                    `ADDR_FPS_C2_M10 : read_data_axi_to_cpu_ll <= ram_rd_data ;
					`ADDR_PARA_VALID  :read_data_axi_to_cpu_ll <= ram_rd_data ;
                    `ADDR_RED_VALID   :read_data_axi_to_cpu_ll <= ram_rd_data ;
                    `ADDR_GREEN_VALID :read_data_axi_to_cpu_ll <= ram_rd_data ;
                    `ADDR_BLUE_VALID  :read_data_axi_to_cpu_ll <= ram_rd_data ;
                    `ADDR_WHITE_VALID :read_data_axi_to_cpu_ll <= ram_rd_data ;
                    `ADDR_BLACK_VALID :read_data_axi_to_cpu_ll <= ram_rd_data ;
					
					`ADDR_CRC_NUM    : read_data_axi_to_cpu_ll <= C_CRC_BLOCK_EN ? ( (fifo_rst_busy!=1) ? fifo_crc_count : 0 )  : 0 ;
                    `ADDR_CRC_OFFSET : read_data_axi_to_cpu_ll <= C_CRC_BLOCK_EN ? fifo_rd_data   : 0;
                    
                    
                    `ADDR_PORT_NUM   : read_data_axi_to_cpu_ll <= {0,R_PORT_NUM  } ;
                    `ADDR_BPC        : read_data_axi_to_cpu_ll <= {0,R_BPC       } ;
                    `ADDR_RED_HIGH   : read_data_axi_to_cpu_ll <= {0,R_RED_HIGH  } ;
                    `ADDR_RED_LOW    : read_data_axi_to_cpu_ll <= {0,R_RED_LOW   } ;
                    `ADDR_GREEN_HIGH : read_data_axi_to_cpu_ll <= {0,R_GREEN_HIGH} ;
                    `ADDR_GREEN_LOW  : read_data_axi_to_cpu_ll <= {0,R_GREEN_LOW } ;
                    `ADDR_BLUE_HIGH  : read_data_axi_to_cpu_ll <= {0,R_BLUE_HIGH } ;
                    `ADDR_BLUE_LOW   : read_data_axi_to_cpu_ll <= {0,R_BLUE_LOW  } ;
                    
                    
                    `ADDR_VS_REVERSE_EN   : read_data_axi_to_cpu_ll <= auto_vs_polarity_aclk;   
                    `ADDR_HS_REVERSE_EN   : read_data_axi_to_cpu_ll <= auto_hs_polarity_aclk ;    
                    
                    `ADDR_CRC_VALUE_ACLK  :  read_data_axi_to_cpu_ll <=  fifo_crc_aclk ;  
                    
                    default:;
                endcase
            end
            default:;
        endcase
    end
end
 
                

(*keep="true"*)wire [7:0] r0 ;
(*keep="true"*)wire [7:0] g0 ;
(*keep="true"*)wire [7:0] b0 ;
(*keep="true"*)wire [7:0] r1 ;
(*keep="true"*)wire [7:0] g1 ;
(*keep="true"*)wire [7:0] b1 ;

assign r0 = R_I[7:0] ;
assign g0 = G_I[7:0] ;
assign b0 = B_I[7:0] ;
//assign r1 = R_I[15:8] ;
//assign g1 = G_I[15:8] ;
//assign b1 = B_I[15:8] ;


                
generate if(C_DEBUG_ENABLE_PCLK)begin
    
ila_0  lvds_ila_0_u(
    .clk     (PIXEL_CLK_I   ),
    .probe0  (DE_I          ),
    .probe1  (HS_I          ),
    .probe2  (VS_I          ),
    .probe3  (ram_wr_en     ),
    .probe4  (ram_wr_addr   ),	
    .probe5  (ram_wr_data   ), 	
    .probe6  (r0),
	.probe7  (g0),
    .probe8  (   fifo_wr ),
	.probe9  (   HS_I_d),
    .probe10 (  HS_I_d_neg),  
    .probe11 ( rgb_u.HSYNC_count ) ,
    .probe12 ({PIXEL_CLK_LOCKED_I,crc_fifo_rst_pclk} )
    
   //.probe6  ({VID_PARA_VALID_O ,VID_SIGNAL_RED_O  ,VID_SIGNAL_GREEN_O ,VID_SIGNAL_BLUE_O  ,VID_SIGNAL_WHITE_O ,VID_SIGNAL_BLACK_O } ),
//.probe7 ( {rsta_busy,rstb_busy} ),
   //.probe9 (rgb_u.R_FPS_RED_cntmode),
   //.probe10(rgb_u.R_FPS_RED_count_cntmode),
   //.probe11(rgb_u.cnt_total_total_dym_s2),
   //.probe12(rgb_u.cnt_red_total_dym_s2),
   //.probe13(rgb_u.cnt_red_total_dym_comp_s2),
    

    );


end
endgenerate



generate if(C_DEBUG_ENABLE_ACLK)begin
    
ila_1  lvds_ila_1_u(
    .clk     (S_AXI_ACLK),
    .probe0  (write_req_cpu_to_axi     ),
    .probe1  (write_addr_cpu_to_axi    ),
    .probe2  (write_data_cpu_to_axi    ),
    .probe3  (read_req_cpu_to_axi      ),
    .probe4  (read_addr_cpu_to_axi     ),
    .probe5  (read_data_axi_to_cpu     ),
    .probe6  (read_finish_axi_to_cpu   ),
	
	
	.probe7  (fifo_rst_busy   ),
	.probe8  (ram_rd_addr ),
	//.probe9  (ram_rd_data )
	.probe9 (fifo_crc_count)
	
	
    );


end
endgenerate


generate if(C_ILA_RGB_PARA_PARSE_ACLK) begin
    ila_rgb_parse_aclk  ila_rgb_parse_aclk_u
    (   
        .clk     (S_AXI_ACLK    ),
        .probe0  (HSYNC_aclk    ),      
        .probe1  (HBP_aclk      ), 
        .probe2  (HACTIVE_aclk  ), 
        .probe3  (HFP_aclk      ), 
        .probe4  (VSYNC_aclk    ), 
        .probe5  (VBP_aclk      ), 
        .probe6  (VACTIVE_aclk  ), 
        .probe7  (VFP_aclk      ), 
        .probe8  (rgb_u.h_mult  ) //4 
        
    );

end
endgenerate



reg [15:0] cnt_h;
wire hs_buf_pos;
reg [15:0] cnt_v;
`POS_MONITOR_OUTGEN(PIXEL_CLK_I,0,hs_buf,hs_buf_pos)


always@(posedge PIXEL_CLK_I)begin
    if(vs_buf)begin
        cnt_v <= 0;
        cnt_h <= 0;
    end
    else begin
        cnt_v <= hs_buf_pos ? cnt_v + 1 : cnt_v ;
        cnt_h <= hs_buf_pos ? 0 : de_buf ? cnt_h + 1 : cnt_h ;
    end
end


generate if(C_ILA_HSVSDERGB_PCLK)begin
    ila_2  ila_HSVSDERGB_PCLK  
    ( 
       .clk    (PIXEL_CLK_I ) ,
       .probe0 (cnt_v)  ,
       .probe1 (cnt_h)  ,
       .probe2 (vs_buf) ,
       .probe3 (hs_buf) ,
       .probe4 (de_buf) ,
       .probe5 (r_buf)  ,
       .probe6 (g_buf)  ,
       .probe7 (b_buf) 
    );     

    
end
endgenerate





endmodule



