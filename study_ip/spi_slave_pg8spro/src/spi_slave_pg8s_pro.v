`timescale 1ns / 1ps

`define CDC_MULTI_BIT_SIGNAL_OUTGEN(aclk,adata_in,bclk,bdata_out,DATA_WIDTH,DEST_FF)                    generate begin xpm_cdc_array_single #(.DEST_SYNC_FF(DEST_FF),.INIT_SYNC_FF(0),.SIM_ASSERT_CHK(0),.SRC_INPUT_REG(1),.WIDTH(DATA_WIDTH)) cdc_u(.src_clk(aclk),.src_in(adata_in),.dest_clk(bclk),.dest_out(bdata_out));    end  endgenerate  
`define CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(adata_in,bclk,bdata_out,DATA_WIDTH,DEST_FF)                    generate begin xpm_cdc_array_single #(.DEST_SYNC_FF(DEST_FF),.INIT_SYNC_FF(0),.SIM_ASSERT_CHK(0),.SRC_INPUT_REG(0),.WIDTH(DATA_WIDTH)) cdc_u(.src_clk( ),.src_in(adata_in),.dest_clk(bclk),.dest_out(bdata_out));    end  endgenerate  
`define CDC_SINGLE_BIT_PULSE_OUTGEN(aclk,arst,apulse_in,bclk,brst,bpulse_out,SIM,DEST_FF)               generate if(SIM==0)begin  xpm_cdc_pulse #(.DEST_SYNC_FF(DEST_FF), .INIT_SYNC_FF(0),.REG_OUTPUT(0),.RST_USED(1),.SIM_ASSERT_CHK (0)) cdc_u (.src_clk(aclk),.src_rst(arst),.src_pulse(apulse_in),.dest_clk(bclk),.dest_rst(brst),.dest_pulse(bpulse_out));   end else begin   reg [5:0] name1 = 0;wire name2;always@(posedge aclk)if(arst)name1[0] <=0;else name1[0] <= apulse_in;assign name2 = apulse_in & ~name1[0]; always@(posedge aclk)if(arst)name1[1] <= 0;else name1[1] <= name2 ? ~name1[1]:name1[1];always@(posedge bclk)if(brst)name1[5:2]<=0;else begin name1[2]<=name1[1];name1[3]<=name1[2];name1[4]<=name1[3];name1[5]<=name1[4];end  assign bpulse_out=name1[4]^name1[5];  end  endgenerate
`define POS_MONITOR_OUTGEN(clk,rst,in,out)                                                              generate  begin  reg buf_name1 = 0; always@(posedge clk)begin if(rst)buf_name1 <= 0; else  buf_name1 <= in; end assign out = (~buf_name1)&(in);  end  endgenerate
`define NEG_MONITOR_OUTGEN(clk,rst,in,out)                                                              generate  begin  reg buf_name1 = 0; always@(posedge clk)begin if(rst)buf_name1 <= 0; else  buf_name1 <= in; end assign out = (buf_name1)&(~in);  end  endgenerate
`define XOR_MONITOR_OUTGEN(clk,rst,in,out)                                                              generate  begin  reg buf_name1 = 0; always@(posedge clk)begin if(rst)buf_name1 <= 0; else  buf_name1 <= in; end assign out = buf_name1^in;  end  endgenerate
`define POS_STRETCH_OUTGEN(clk,rst,pulse_in,pulse_out,DELAY_NUM)                                        generate  begin    reg [DELAY_NUM-2:0] temp_name = 0; always@(posedge clk)begin  if(rst)temp_name <= {(DELAY_NUM-1){1'b0}}; else temp_name <= pulse_in ? {(DELAY_NUM-1){1'b1} }: temp_name<<1 ; end  assign  pulse_out = temp_name[DELAY_NUM-2]|pulse_in;  end  endgenerate
`define NEG_STRETCH_OUTGEN(clk,rst,pulsen_in,pulsen_out,DELAY_NUM)                                      generate  begin    reg [DELAY_NUM-2:0] temp_name = 0; always@(posedge clk)begin  if(rst)temp_name <= {(DELAY_NUM-1){1'b0}}; else temp_name <= ~pulsen_in ? {(DELAY_NUM-1){1'b1} }: temp_name<<1 ; end  assign  pulsen_out = ~( temp_name[DELAY_NUM-2] | ~pulsen_in ) ;  end  endgenerate
`define HANDSHAKE_OUTGEN(aclk,arst,apulse_in,adata_in,bclk,brst,bpulse_out,bdata_out,DATA_WIDTH,SIM)    generate  if(SIM==0) begin  handshake  #(.C_DATA_WIDTH(DATA_WIDTH))  handshake_u (.SRC_CLK_I(aclk),.SRC_RST_I(arst),.SRC_DATA_I( adata_in),.SRC_SYNC_PULSE_I ( apulse_in), .DST_CLK_I ( bclk),.DST_DATA_O (bdata_out),.DST_SYNC_FINISH_O(bpulse_out) ); end  else  begin  handshake2 #(.C_DATA_WIDTH(DATA_WIDTH))  handshake_u (.SRC_CLK_I(aclk),.SRC_RST_I(arst),.SRC_DATA_I( adata_in),.SRC_SYNC_PULSE_I ( apulse_in), .DST_CLK_I (bclk),.DST_DATA_O (bdata_out ),.DST_SYNC_FINISH_O(bpulse_out) ); end  endgenerate   
`define DELAY_OUTGEN(clk,rst,data_in,data_out,DATA_WIDTH,DLY)                                           generate if(DLY==0)begin  assign data_out = data_in; end  else if(DLY==1)begin  reg [DATA_WIDTH-1:0] a_temp = 0; always@(posedge clk) a_temp <= data_in; assign data_out = a_temp ; end  else begin  reg [DATA_WIDTH-1:0] a_temp [DLY-1:0] ;always@(posedge clk) begin  if(rst)a_temp[DLY-1] <= 0; else   a_temp[DLY-1] <= data_in; end  for(i=0;i<=DLY-2;i=i+1)begin  always@(posedge clk)begin  if(rst)begin  a_temp[i] <= 0; end  else begin  a_temp[i] <= a_temp[i+1]; end  end  end  assign data_out = a_temp[0]; end  endgenerate



`define   ADDR_SPI_RESET             16'h0000
`define   ADDR_SPI_MODE              16'h0004
`define   ADDR_SPI_IRPT_EN           16'h0008
`define   ADDR_SPI_IRPT_STS          16'h000c
`define   ADDR_SPI_STS               16'h0010
`define   ADDR_SPI_RX_SIZE           16'h0014
`define   ADDR_SPI_RX_OFFSET         16'h0018
`define   ADDR_SPI_TX_OFFSET         16'h001c
`define   ADDR_SPI_RX_FIFO_COUNT     16'h0020
`define   ADDR_SPI_TX_FIFO_COUNT     16'h0024
`define   ADDR_IRPT_DUPLICATE        16'h0028


`define   CMD_SNAPSHOT     16'h0000
`define   CMD_REQ_IRPT     16'h0100  


`define   READ   8'h01 
`define   WRITE  8'h00


//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: yzhu
// 
// Create Date: 2024/11/13 20:19:41
// Design Name: yzhu
// Module Name: spi_slave_pg8s_pro
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//////////////////////////////////////////////////////////////////////////////////


module spi_slave_pg8s_pro(
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



input  [C_S_AXI_ADDR_WIDTH-1:0]    LB_WADDR   ,
input  [C_S_AXI_DATA_WIDTH-1:0]    LB_WDATA   ,
input                              LB_WREQ    ,
input   [C_S_AXI_DATA_WIDTH/8-1:0] LB_WSTRB , 
input  [C_S_AXI_ADDR_WIDTH-1:0]    LB_RADDR   ,
input                              LB_RREQ    ,
output [C_S_AXI_DATA_WIDTH-1:0]    LB_RDATA   ,
output                             LB_RFINISH ,


input  SPI_SCK_I ,
input  SPI_CS_I  ,
input  SPI_SDO_I ,
output SPI_SDI_O ,

output reg INTERRUPT_O  = 0 ,

output  spi_clk_dbg 



    );


parameter C_RD_NORM_DATA_SOURCE = 0; 
parameter [0:0] C_ILA_SPIIF_ACLK_ENABLE = 0 ;
parameter [0:0] C_ILA_SCLK_ENABLE       = 0 ;
parameter [0:0] C_ILA_ACLK_ENABLE       = 0 ;
parameter [0:0] C_ILA_MCLK_ENABLE       = 0 ;


parameter [0:0] C_LB_ENABLE = 1;
parameter C_S_AXI_ADDR_WIDTH = 16 ;
parameter C_S_AXI_DATA_WIDTH = 32 ;
parameter C_AXI4_DATA_WIDTH = 512 ;//后来改成了32，zb反应有字节对齐问题
parameter C_AXI4_ADDR_WIDTH = 32 ;
parameter C_DDR_BURST_LEN = 32 ;

parameter [0:0] C_SNAP_ENABLE = 1 ;
parameter [0:0] C_TX_FIFO_TYPE = "NORMAL"  ; //  "NORMAL"  "STRB"
 


genvar i,j,k;


//调试用
reg [15:0] spi_rx_num_aclk = 0;
//reg [15:0] spi_ins_rx_num_aclk = 0 ;

always@(posedge  S_AXI_ACLK  )begin
    if(~S_AXI_ARESETN)begin
        spi_rx_num_aclk <= 0;
    end
    else begin
        spi_rx_num_aclk <= SPI_CS_I_aclk_sss_pos ? spi_rx_num_aclk + 1 : spi_rx_num_aclk;
    end
end





//寄存器
(*keep="true"*)reg [2:0] R_SPI_RESET           = 0;
reg [31:0] R_SPI_MODE            = 0;
reg [31:0] R_SPI_IRPT_EN         = 0;
reg [31:0] R_SPI_IRPT_STS        = 0;
wire [31:0] R_SPI_STS             ;
reg [15:0] R_SPI_RX_SIZE         = 0;
reg [15:0] R_SPI_RX_OFFSET       = 0;
reg [15:0] R_SPI_TX_OFFSET       = 0;
wire [15:0] R_SPI_RX_FIFO_COUNT    ;
wire [15:0] R_SPI_TX_FIFO_COUNT_sclk   ;
wire [15:0] R_SPI_TX_FIFO_COUNT   ;
reg [31:0] R_IRPT_DUPLICATE      =  32'hAAFF0011;

wire [0:0] R_TX_FIFO_WR_FULL_SIG ;
wire [0:0] R_TX_FIFO_RD_EMPTY_SIG ;
wire [0:0] R_RX_FIFO_WR_FULL_SIG ;
wire [0:0] R_RX_FIFO_RD_EMPTY_SIG ;
wire [0:0] R_SPI_BUSY_SIG ;



//寄存器跨时钟
wire [31:0] R_IRPT_DUPLICATE_sclk_stap ;
wire  [31:0] R_IRPT_DUPLICATE_sclk ;

wire spi_cs_aclk;




(*keep="true"*)wire R_SOFT_RESET ;
(*keep="true"*)wire R_TX_FIFO_RESET ;
(*keep="true"*)wire R_RX_FIFO_RESET ;
(*keep="true"*)wire R_SOFT_RESET_sclk    ;//note: spi 时钟并不是始终存在，所以 1 对fifo的复位存在问题，2 跨时钟无法同步过去
(*keep="true"*)wire R_TX_FIFO_RESET_sclk ;
(*keep="true"*)wire R_RX_FIFO_RESET_sclk ;
wire R_SOFT_RESET_mclk    ;
wire R_TX_FIFO_RESET_mclk ;
wire R_RX_FIFO_RESET_mclk ;


wire  SPI_CS_I_aclk_toclkmux ;
wire  SPI_CS_I_mclk ;
wire  SPI_CS_I_mclk_pos ;
wire  SPI_CS_I_mclk_pos_ss;


//SPI 状态机
reg [7:0]  state_sclk = 0;
wire cpu_fifo_rx_rd_aclk ;
wire [7:0] spi_byte_ascii ;
wire       spi_byte_en ;
wire [3:0] spi_hbyte_hex ;
reg [15:0] cnt ;
wire  snap_fifo_rd_sclk;
wire [7:0] snap_fifo_rd_data_sclk ;



wire flag_spi_dma_trig_sclk_0 ;
wire fifo_rd_ignore_0 ;
wire [15:0] snap_fifo_rd_data_sclk_0 ;
wire snap_fifo_rd_empty_sclk_0 ;
wire snap_fifo_rd_rst_busy_sclk_0 ;





 
reg flag_spi_wr_succ  = 0;
reg flag_spi_wr_fail  = 0;
wire stm32_rd_irpt_aclk;



//spi 信息
reg [7:0]  device_addr_buf_sclk    = 0;
reg [15:0] cmd_id_buf_sclk         = 0;
reg [7:0]  wnr_buf_sclk            = 0;
reg [15:0] length_buf_sclk_dym         = 0; //动态
reg [15:0] length_buf_sclk_dym_m2  = 0 ;// 乘以2 ，针对上位机下发的ddr地址内容
reg [15:0] length_buf_sclk   = 0; //锁存
reg [63:0] snap_ddr_addr_buf_sclk  = 0;
reg [15:0] spi_byte_num_rx_sclk = 0;
reg        flag_fifo_rx_wr_en_sclk     = 1;
wire [1:0]  flag_fifo_rx_src_sclk         ;


wire [7:0]  device_addr_buf_aclk  ;
wire [15:0] cmd_id_buf_aclk       ;
wire [7:0]  wnr_buf_aclk           ;
wire [15:0] length_buf_aclk        ;
wire [15:0] spi_byte_num_rx_aclk   ;
wire [63:0] snap_ddr_addr_buf_aclk ;
wire        flag_fifo_rx_wr_en_aclk  ;
wire [1:0]  flag_fifo_rx_src_aclk ; 




wire [7:0]  device_addr_buf_mclk   ;
wire [15:0] cmd_id_buf_mclk        ;
wire [7:0]  wnr_buf_mclk           ;
wire [15:0] length_buf_mclk        ;
wire [15:0] spi_byte_num_rx_mclk   ;
wire [63:0] snap_ddr_addr_buf_mclk ;
wire        flag_fifo_rx_wr_en_mclk  ;
wire [1:0]  flag_fifo_rx_src_mclk ;




wire [7:0] cpu_fifo_rx_rd_data_aclk ;
wire  flag_spi_tx_fifo_trig_sclk ;
wire  flag_spi_irpt_reg_trig_sclk ;

reg [7:0] state_irpt1 = 0;
reg [31:0] snap_dma_rd_addr = 0;
reg [31:0] snap_dma_rd_bytes = 0;
reg        snap_dma_rd_trig  = 0;
reg        snap_dma_rd_stop  = 0;
wire       snap_dma_rd_busy  = 0;

reg [7:0] state_mclk = 0;
reg snap_fifo_wr_rst = 0;
wire [C_S_AXI_DATA_WIDTH-1:0] tx_fifo_wr_data_aclk;
wire tx_fifo_wr_aclk;
wire [(32/8)-1 :0] tx_fifo_wr_strb_ll ;

wire tx_fifo_rd_rst_busy_sclk ;
wire rx_fifo_rd_rst_busy_aclk ;


//AXI 总线
wire        write_req_cpu_to_axi  ;
wire [C_S_AXI_ADDR_WIDTH-1:0] write_addr_cpu_to_axi ;
wire [C_S_AXI_DATA_WIDTH-1:0] write_data_cpu_to_axi ;
wire        read_req_cpu_to_axi   ;
wire [C_S_AXI_ADDR_WIDTH-1:0] read_addr_cpu_to_axi  ;
wire [C_S_AXI_DATA_WIDTH-1:0] read_data_axi_to_cpu  ;
wire         read_finish_axi_to_cpu;
wire [(C_S_AXI_DATA_WIDTH/8)-1 :0] write_strb_cpu_to_axi ;

wire                       write_req_cpu_to_axi_ll   ;
wire [C_S_AXI_ADDR_WIDTH-1:0]  write_addr_cpu_to_axi_ll  ;
wire [C_S_AXI_DATA_WIDTH-1:0]  write_data_cpu_to_axi_ll  ;
wire                       read_req_cpu_to_axi_ll    ;
wire  [C_S_AXI_ADDR_WIDTH-1:0] read_addr_cpu_to_axi_ll   ;
reg  [C_S_AXI_DATA_WIDTH-1:0]  read_data_axi_to_cpu_ll    = 0;  
reg                        read_finish_axi_to_cpu_ll  = 0;
wire [(C_S_AXI_DATA_WIDTH/8)-1 :0] write_strb_cpu_to_axi_ll ;



 

wire [7:0] spi_ack_data ;//总数据
wire [7:0] spi_dma_fifo_data ;//分数据
reg [31:0] spi_irpt_reg_data ;
wire [7:0] tx_fifo_rd_data_sclk ;
 
wire [3:0] tx_fifo_wr_strb_aclk ;
wire spi_ack_trig ;

wire tx_fifo_wr_rst_busy_aclk ;
wire tx_fifo_wr_full_aclk;
wire tx_fifo_rd_empty_sclk ;

 
 
wire rx_fifo_wr_rst_busy_sclk ;
wire rx_fifo_wr_full_sclk ;
wire rx_fifo_rd_empty_aclk ;


wire snap_fifo_wr_full_0 ;
wire snap_fifo_wr_rst_busy_0 ;

(*keep="true"*)wire spi_clk_mux; //mux from spi_clk and aclk

wire rx_fifo_wr_en ; //最终的有效 rx_fifo 实际有效写信号


wire [15:0] snap_fifo_rd_data_count_sclk ; 


assign  rx_fifo_wr_en  =   spi_byte_en & flag_fifo_rx_wr_en_sclk      ; 

assign spi_clk_dbg = spi_clk_mux ;




//SPI_CS_I                       #——————|_________|————————                ori spi
//SPI_CS_I_aclk_toclkmux         #————————|_________|————————              aclk       选择时钟    同步后
//SPI_CS_I_aclk_s4_tospislave    #————————————|_________|————————          aclk       实际给spi模块的cs【实际给spi slave】, 同时也作为给spi_mux_clk模块的复位（同步？）
//SPI_CS_I_aclk_slong            #————————————————————|_________|————————  aclk       实际给spi模块的cs延长
//S_AXI_ACLK
//spi_clk_mux  
wire SPI_CS_I_aclk_s4_tospislave ;
wire SPI_CS_I_aclk_slong ;
wire SPI_CS_I_aclk_sss_pos ;
wire SPI_CS_I_muxclk_neg ;
wire S_AXI_ARESETN_sclk ;


`CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(S_AXI_ARESETN , spi_clk_mux ,S_AXI_ARESETN_sclk,1,3) 
`CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(SPI_CS_I,S_AXI_ACLK,SPI_CS_I_aclk_toclkmux,1,3)  
`DELAY_OUTGEN(S_AXI_ACLK,0,SPI_CS_I_aclk_toclkmux,SPI_CS_I_aclk_s4_tospislave,1,4) 
`DELAY_OUTGEN(S_AXI_ACLK,0,SPI_CS_I_aclk_s4_tospislave,SPI_CS_I_aclk_slong,1,30)   //特意延长，让数据从sclk同步到aclk能稳定
`POS_MONITOR_OUTGEN(S_AXI_ACLK,0,SPI_CS_I_aclk_slong,SPI_CS_I_aclk_sss_pos) 
`NEG_MONITOR_OUTGEN(spi_clk_mux,0,SPI_CS_I,SPI_CS_I_muxclk_neg) 

BUFGMUX #( .CLK_SEL_TYPE("ASYNC") ) 
    BUFGMUX_inst (
   .O (spi_clk_mux      ),   
   .I0(SPI_SCK_I        ), 
   .I1(S_AXI_ACLK       ), 
   .S (SPI_CS_I_aclk_toclkmux    )  //提前关闭aclk  
    );
   
assign spi_cs_aclk = SPI_CS_I_aclk_s4_tospislave ;




assign write_req_cpu_to_axi_ll  =  C_LB_ENABLE ? LB_WREQ  : write_req_cpu_to_axi  ;
assign write_addr_cpu_to_axi_ll =  C_LB_ENABLE ? LB_WADDR : write_addr_cpu_to_axi ;
assign write_data_cpu_to_axi_ll =  C_LB_ENABLE ? LB_WDATA : write_data_cpu_to_axi ;
assign write_strb_cpu_to_axi_ll =  C_LB_ENABLE ? LB_WSTRB : write_strb_cpu_to_axi ;
assign read_req_cpu_to_axi_ll   =  C_LB_ENABLE ? LB_RREQ  : read_req_cpu_to_axi ;
assign read_addr_cpu_to_axi_ll  =  C_LB_ENABLE ? LB_RADDR : read_addr_cpu_to_axi ;
assign read_data_axi_to_cpu     =  C_LB_ENABLE ? 0 : read_data_axi_to_cpu_ll   ;
assign read_finish_axi_to_cpu   =  C_LB_ENABLE ? 0 : read_finish_axi_to_cpu_ll ;
assign LB_RDATA                 =  C_LB_ENABLE ? read_data_axi_to_cpu_ll   : 0 ;
assign LB_RFINISH               =  C_LB_ENABLE ? read_finish_axi_to_cpu_ll : 0 ;


//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////spi transmission finish token///////////////////////// 


`CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(spi_cs_aclk, M_AXI_ACLK ,SPI_CS_I_mclk, 1, 3)
`POS_MONITOR_OUTGEN(M_AXI_ACLK, (~M_AXI_ARESETN) ,SPI_CS_I_mclk, SPI_CS_I_mclk_pos)  
`DELAY_OUTGEN(M_AXI_ACLK,(~M_AXI_ARESETN),SPI_CS_I_mclk_pos,SPI_CS_I_mclk_pos_ss,1,20)
 

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////spi interface////////////////////////////////////// 

spi_slave_core  
    spi_slave_u(                    
   .SPI_SCK_I    (spi_clk_mux       ) ,  
   .SPI_CS_I     (spi_cs_aclk       ) ,
   .SPI_DO_I     (SPI_SDO_I         ) ,
   .SPI_DI_O     (SPI_SDI_O         ) ,
   .SPI_BYTE_O   (spi_byte_ascii    ) , //8-bit ASCII  ~ posedge of spi_ack_trig
   .SPI_BYTE_EN_O(spi_byte_en       ) ,
   .SPI_ACK_TRIG (spi_ack_trig      ) , //~ posedge of spi_ack_trig // 应该和en信号完全一致
   .SPI_ACK_DATA (spi_ack_data      )
   );

ascii2hex  ascii2hex_u( 
    .ascii  (spi_byte_ascii )  ,      //   8-bit ASCII input 
    .hex    (spi_hbyte_hex  )    );   //   4-bit output hex (0-F)  



//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////AXI-Lite interface///////////////////////////////////// 
//axi_lite_slave2 #(
axi_lite_slave #(
    .C_S_AXI_DATA_WIDTH          (C_S_AXI_DATA_WIDTH),
    .C_S_AXI_ADDR_WIDTH         (C_S_AXI_ADDR_WIDTH)
)axi_lite_slave_u
(
    ////////////////////////////////////////////////////
    // AXI4 Lite Slave interface
    .S_AXI_ACLK                                (S_AXI_ACLK                ),
    .S_AXI_ARESETN                        (S_AXI_ARESETN        ),
    .S_AXI_AWREADY                        (S_AXI_AWREADY        ),
    .S_AXI_AWADDR                        (S_AXI_AWADDR        ),
    .S_AXI_AWVALID                        (S_AXI_AWVALID        ),
    .S_AXI_AWPROT                        (S_AXI_AWPROT        ),
    .S_AXI_WREADY                        (S_AXI_WREADY        ),
    .S_AXI_WDATA                        (S_AXI_WDATA        ),
    .S_AXI_WSTRB                        (S_AXI_WSTRB        ),
    .S_AXI_WVALID                        (S_AXI_WVALID        ),
    .S_AXI_BRESP                        (S_AXI_BRESP        ),
    .S_AXI_BVALID                        (S_AXI_BVALID        ),
    .S_AXI_BREADY                        (S_AXI_BREADY        ),
    .S_AXI_ARREADY                        (S_AXI_ARREADY        ),
    .S_AXI_ARADDR                        (S_AXI_ARADDR        ),
    .S_AXI_ARVALID                        (S_AXI_ARVALID        ),
    .S_AXI_ARPROT                        (S_AXI_ARPROT        ),
    .S_AXI_RRESP                        (S_AXI_RRESP        ),
    .S_AXI_RVALID                        (S_AXI_RVALID        ),
    .S_AXI_RDATA                        (S_AXI_RDATA        ),
    .S_AXI_RREADY                        (S_AXI_RREADY        ),
    
    .write_req_cpu_to_axi  (write_req_cpu_to_axi       ),    //wire                              
    .write_addr_cpu_to_axi (write_addr_cpu_to_axi      ),   //wire [C_S_AXI_ADDR_WIDTH-1:0]     
    .write_data_cpu_to_axi (write_data_cpu_to_axi      ),   //wire [C_S_AXI_DATA_WIDTH-1:0]     
    .read_req_cpu_to_axi   (read_req_cpu_to_axi        ),     //wire                              
    .read_addr_cpu_to_axi  (read_addr_cpu_to_axi       ),    //wire [C_S_AXI_ADDR_WIDTH-1:0]     
    .read_data_axi_to_cpu  (read_data_axi_to_cpu       ),    //wire [C_S_AXI_DATA_WIDTH-1:0]     
    .read_finish_axi_to_cpu(read_finish_axi_to_cpu     )   //wire                              
      
    
    
    //.o_rx_dval                                (write_req_cpu_to_axi                ),
    //.o_rx_addr                                (write_addr_cpu_to_axi                ),
    //.o_rx_data                                (write_data_cpu_to_axi                ),
    //.o_tx_req                                 (read_req_cpu_to_axi                 ),
    //.o_tx_addr                                (read_addr_cpu_to_axi                ),
    //.i_tx_data                                (read_data_axi_to_cpu                ),
    //.i_tx_dval                                (read_finish_axi_to_cpu                )
);




//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////tx fifo/////////////////////////////////////////

assign tx_fifo_wr_data_aclk    = write_data_cpu_to_axi_ll ;
assign tx_fifo_wr_aclk         = write_req_cpu_to_axi_ll & write_addr_cpu_to_axi_ll ==`ADDR_SPI_TX_OFFSET ;
assign tx_fifo_wr_strb_aclk   = write_strb_cpu_to_axi_ll ;

generate if(C_TX_FIFO_TYPE=="NORMAL")begin
tx_fifo_4to1 
    tx_fifo_u_cpu( 
    .FIFO_WR_CLK_I         (S_AXI_ACLK                  ),
    .FIFO_WR_RSTN_I        ( S_AXI_ARESETN & (~R_TX_FIFO_RESET)    ),
    .FIFO_WR_I             (tx_fifo_wr_aclk                  ),
    .FIFO_WR_DATA_I        (tx_fifo_wr_data_aclk                ),
    .FIFO_WR_STRB_I        (tx_fifo_wr_strb_aclk             ),                     
    .FIFO_RD_CLK_I         (spi_clk_mux                  ),
    .FIFO_RD_EN_I          (flag_spi_tx_fifo_trig_sclk  ), //~posedge of SPI_SCK_I
    .FIFO_RD_DATA_O        (tx_fifo_rd_data_sclk            ),
    .FIFO_RD_EMPTY_O       (                            ),  
    .FIFO_RD_DATA_COUNT_O  (R_SPI_TX_FIFO_COUNT_sclk    ), 
    .RD_RST_BUSY_O         ( tx_fifo_rd_rst_busy_sclk   )

    );
end
else begin
   fifo_async_xpm   
    #( .C_RD_MODE           ("fwft" ),
   .C_WR_WIDTH              (32),
   .C_RD_WIDTH              (8),
   .C_WR_DEPTH              (256),
   .C_WR_COUNT_WIDTH        (16),
   .C_RD_COUNT_WIDTH        (16),
   .C_RD_PROG_EMPTY_THRESH  (10),  
   .C_WR_PROG_FULL_THRESH   (220 ), 
   .C_DBG_COUNT_WIDTH       (16 ) )
   tx_fifo_u(
    .WR_RST_I                   (~S_AXI_ARESETN | R_TX_FIFO_RESET   ) , 
    .WR_CLK_I                   (S_AXI_ACLK                      ) ,
    .WR_EN_I                    (tx_fifo_wr_aclk                 ) , 
    .WR_DATA_I                  (tx_fifo_wr_data_aclk            ) ,
    .WR_FULL_O                  (tx_fifo_wr_full_aclk       ) , 
    .WR_DATA_COUNT_O            (                           ) , 
    .WR_PROG_FULL_O             (                           ) , 
    .WR_RST_BUSY_O              (tx_fifo_wr_rst_busy_aclk   ) , 
    .WR_ERR_O                   (                           ) ,
    
    .RD_CLK_I                   (spi_clk_mux                     )  ,
    .RD_EN_I                    (flag_spi_tx_fifo_trig_sclk  )  ,
    .RD_DATA_O                  (tx_fifo_rd_data_sclk        )  ,
    .RD_EMPTY_O                 ( tx_fifo_rd_empty_sclk      )  ,
    .RD_DATA_COUNT_O            ( R_SPI_TX_FIFO_COUNT_sclk   )  , 
    .RD_PROG_EMPTY_O            (                            )  , 
    .RD_RST_BUSY_O              ( tx_fifo_rd_rst_busy_sclk   )  , 
    .RD_ERR_O                   (                            ) 
    
    );

end
endgenerate



//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////R_SPI_STS//////////////////////////////////////
///////////////////////////////////TX FIFO COUNT//////////////////////////////////////
///////////////////////////////////RX FIFO COUNT//////////////////////////////////////
assign  R_TX_FIFO_WR_FULL_SIG = tx_fifo_wr_rst_busy_aclk ? 1 : tx_fifo_wr_full_aclk ;
`CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN((tx_fifo_rd_rst_busy_sclk ? 1 :tx_fifo_rd_empty_sclk ) ,S_AXI_ACLK ,R_TX_FIFO_RD_EMPTY_SIG,1,3)
`CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN( (rx_fifo_wr_rst_busy_sclk ? 1 : rx_fifo_wr_full_sclk ) , S_AXI_ACLK , R_RX_FIFO_WR_FULL_SIG,1,3)
assign R_RX_FIFO_RD_EMPTY_SIG = rx_fifo_rd_rst_busy_aclk ? 1 : rx_fifo_rd_empty_aclk ;
`CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(spi_cs_aclk,S_AXI_ACLK,R_SPI_BUSY_SIG,1,3)
assign R_SPI_STS =  { 0 ,R_RX_FIFO_RD_EMPTY_SIG  , R_RX_FIFO_WR_FULL_SIG , R_TX_FIFO_RD_EMPTY_SIG , R_TX_FIFO_WR_FULL_SIG , R_SPI_BUSY_SIG } ;

`CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN( (tx_fifo_rd_rst_busy_sclk ? 0 : R_SPI_TX_FIFO_COUNT_sclk) ,S_AXI_ACLK, R_SPI_TX_FIFO_COUNT,16,3) 
//R_SPI_RX_FIFO_COUNT 直连即可


//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////cpu wrtite//////////////////////////////////////
always@(posedge S_AXI_ACLK)begin
    if(~S_AXI_ARESETN)begin
        R_SPI_RESET          <=  0;
        R_SPI_MODE           <=  0; //no use
        R_SPI_IRPT_EN        <=  0; //no use
    end
    else if(write_req_cpu_to_axi_ll)begin
        case(write_addr_cpu_to_axi_ll)
            `ADDR_SPI_RESET   : R_SPI_RESET   <=  {0,write_data_cpu_to_axi_ll} ;
            `ADDR_SPI_IRPT_EN : R_SPI_IRPT_EN <=  write_data_cpu_to_axi_ll ; //no use
            `ADDR_SPI_MODE    : R_SPI_MODE    <=  write_data_cpu_to_axi_ll ; //no use
            default:;
        endcase
    end
    else begin
        R_SPI_RESET <= 0;
    end
end


//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////RESET signal///////////////////////////////////////

assign R_SOFT_RESET    = R_SPI_RESET[0];
assign R_TX_FIFO_RESET = R_SPI_RESET[1];
assign R_RX_FIFO_RESET = R_SPI_RESET[2];

`CDC_SINGLE_BIT_PULSE_OUTGEN(S_AXI_ACLK,0,R_SOFT_RESET    ,spi_clk_mux,0,R_SOFT_RESET_sclk   ,0,3) 
`CDC_SINGLE_BIT_PULSE_OUTGEN(S_AXI_ACLK,0,R_TX_FIFO_RESET ,spi_clk_mux,0,R_TX_FIFO_RESET_sclk,0,3) 
`CDC_SINGLE_BIT_PULSE_OUTGEN(S_AXI_ACLK,0,R_RX_FIFO_RESET ,spi_clk_mux,0,R_RX_FIFO_RESET_sclk,0,3) 

`CDC_SINGLE_BIT_PULSE_OUTGEN(S_AXI_ACLK,0,R_SOFT_RESET    ,M_AXI_ACLK,0,R_SOFT_RESET_mclk    ,0,3)
`CDC_SINGLE_BIT_PULSE_OUTGEN(S_AXI_ACLK,0,R_TX_FIFO_RESET ,M_AXI_ACLK,0,R_TX_FIFO_RESET_mclk ,0,3)
`CDC_SINGLE_BIT_PULSE_OUTGEN(S_AXI_ACLK,0,R_RX_FIFO_RESET ,M_AXI_ACLK,0,R_RX_FIFO_RESET_mclk ,0,3)


 
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////cpu read////////////////////////////////////////

assign cpu_fifo_rx_rd_aclk = read_req_cpu_to_axi_ll & read_addr_cpu_to_axi_ll ==`ADDR_SPI_RX_OFFSET ;

always@(posedge S_AXI_ACLK)begin
    if(~S_AXI_ARESETN)begin
        read_data_axi_to_cpu_ll  <=  0;
        read_finish_axi_to_cpu_ll <=  0;
    end
    else if(read_req_cpu_to_axi_ll)begin
        read_finish_axi_to_cpu_ll <= 1 ;
        case(read_addr_cpu_to_axi_ll)
            `ADDR_SPI_MODE            : read_data_axi_to_cpu_ll  <=  R_SPI_MODE      ;//no use
            `ADDR_SPI_IRPT_EN         : read_data_axi_to_cpu_ll  <=  R_SPI_IRPT_EN   ;//no use
            `ADDR_SPI_IRPT_STS        : read_data_axi_to_cpu_ll  <=  R_SPI_IRPT_STS  ;//no use
            `ADDR_SPI_STS             : read_data_axi_to_cpu_ll  <=  R_SPI_STS       ;
            `ADDR_SPI_RX_SIZE         : read_data_axi_to_cpu_ll  <=  R_SPI_RX_SIZE   ;
            `ADDR_SPI_RX_OFFSET       : read_data_axi_to_cpu_ll  <=  cpu_fifo_rx_rd_data_aclk   ;
            `ADDR_SPI_RX_FIFO_COUNT   : read_data_axi_to_cpu_ll  <=  rx_fifo_rd_rst_busy_aclk ? 0 : R_SPI_RX_FIFO_COUNT ;// ok
            `ADDR_SPI_TX_FIFO_COUNT   : read_data_axi_to_cpu_ll  <=  R_SPI_TX_FIFO_COUNT ;
            `ADDR_IRPT_DUPLICATE      : read_data_axi_to_cpu_ll  <=  R_IRPT_DUPLICATE ;
            default:;
        endcase
    end
    else begin
        read_finish_axi_to_cpu_ll <= 0;
    end
end

 



//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////IRPT Duplicate//////////////////////////////////////
always@(posedge S_AXI_ACLK)begin
    if(~S_AXI_ARESETN )begin
        R_IRPT_DUPLICATE     <=  32'hAAFF0011; 
    end
    else if(write_req_cpu_to_axi_ll)begin
        case(write_addr_cpu_to_axi_ll)
            `ADDR_IRPT_DUPLICATE : R_IRPT_DUPLICATE <= write_data_cpu_to_axi_ll ;
            default:;
        endcase
    end
    else begin
       R_IRPT_DUPLICATE <=  clear_irpt_sts_aclk ? 0 : R_IRPT_DUPLICATE ;
    end
end





// snap_fifo_rd_sclk                                                                                           /* 暂时无用 */
//assign  spi_ack_data  =  flag_fifo_rx_src_sclk==2'b00 ?  tx_fifo_rd_data_sclk : flag_fifo_rx_src_sclk==2'b01 ?   spi_dma_fifo_data  : spi_irpt_reg_data ;
assign  spi_ack_data  =  flag_fifo_rx_src_sclk==2'b00 ?  tx_fifo_rd_data_sclk : flag_fifo_rx_src_sclk==2'b01 ?   snap_fifo_rd_data_sclk  : spi_irpt_reg_data ;


assign spi_ack_trig = flag_spi_tx_fifo_trig_sclk | flag_spi_irpt_reg_trig_sclk |  flag_spi_dma_trig_sclk;



`CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(device_addr_buf_sclk    ,S_AXI_ACLK,device_addr_buf_aclk    ,8,3)  
`CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(cmd_id_buf_sclk     ,S_AXI_ACLK,cmd_id_buf_aclk     ,16,3)  
`CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(wnr_buf_sclk     ,S_AXI_ACLK,wnr_buf_aclk     ,8,3)  
`CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(length_buf_sclk  ,S_AXI_ACLK,length_buf_aclk  ,16,3)  
`CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(spi_byte_num_rx_sclk,S_AXI_ACLK,spi_byte_num_rx_aclk,16,3)
`CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(flag_fifo_rx_src_sclk     ,S_AXI_ACLK,flag_fifo_rx_src_aclk     ,2,3)  
`CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(snap_ddr_addr_buf_sclk     ,S_AXI_ACLK,snap_ddr_addr_buf_aclk     ,64,3)  

 

`CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(device_addr_buf_sclk    ,M_AXI_ACLK,device_addr_buf_mclk    ,8,3)  
`CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(cmd_id_buf_sclk     ,M_AXI_ACLK,cmd_id_buf_mclk     ,16,3)  
`CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(wnr_buf_sclk     ,M_AXI_ACLK,wnr_buf_mclk     ,8,3)  
`CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(length_buf_sclk  ,M_AXI_ACLK,length_buf_mclk  ,16,3)  
`CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(spi_byte_num_rx_sclk ,M_AXI_ACLK,spi_byte_num_rx_mclk ,16,3)  
`CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(flag_fifo_rx_src_sclk,M_AXI_ACLK,flag_fifo_rx_src_mclk,2,3)  
`CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(f_inv_8byte(snap_ddr_addr_buf_sclk)     ,M_AXI_ACLK,snap_ddr_addr_buf_mclk     ,64,3)  


`CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(R_IRPT_DUPLICATE    ,spi_clk_mux  ,R_IRPT_DUPLICATE_sclk     ,32,3)  


 
 always@(posedge  spi_clk_mux )begin
    // if(SPI_CS_I_muxclk_neg)begin
     //    spi_byte_num_rx_sclk <= 0;     
    // end
     //else begin

       //  spi_byte_num_rx_sclk <= spi_byte_en ? spi_byte_num_rx_sclk + 1 : spi_byte_num_rx_sclk ;
          spi_byte_num_rx_sclk <=  (state_sclk==0 && spi_byte_en && spi_byte_ascii==8'h23 ) ? 1 :  state_sclk>0 & spi_byte_en ? spi_byte_num_rx_sclk + 1 : spi_byte_num_rx_sclk;
   //  end
 end



reg [63:0] ddr_target_addr_sclk = 0 ;
wire [31:0] ddr_target_addr_aclk ;
`CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(ddr_target_addr_sclk,M_AXI_ACLK,ddr_target_addr_aclk,32,3)  
//reg [31:0] ddr_byte_num_sclk ;

//HANDSHAKE_OUTGEN(aclk,arst,apulse_in,adata_in,bclk,brst,bpulse_out,bdata_out,DATA_WIDTH,SIM)  


//wire [31:0] ddr_target_addr_mclk ;
//`CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(ddr_target_addr_sclk,M_AXI_ACLK,ddr_target_addr_mclk,32,3)  


//always@(posedge spi_clk_mux or posedge spi_cs_aclk)begin  //2024年12月12日09:46:29 
always@(posedge spi_clk_mux)begin
    if(spi_cs_aclk)begin //异步复位; 除了状态，其他变量都锁住
        state_sclk   <= 0 ;
    end
    else begin
        case(state_sclk)
            0:begin 
                flag_spi_wr_succ <= 0;
                flag_spi_wr_fail <= 0;
                
                flag_fifo_rx_wr_en_sclk <= 1; //默认向fifo写
                state_sclk <= spi_byte_en & spi_byte_ascii==8'h23 ? 1 : state_sclk ;//SOP
                
                //yzhu 2024年12月10日11:17:50 
                
                
            end
            //Device Addr ////////////////////////////////////////////////////////////////////////////////////////
            1:begin
                state_sclk <= spi_byte_en  ? 2 : state_sclk ;
                device_addr_buf_sclk <= spi_byte_en ?  { device_addr_buf_sclk,spi_hbyte_hex } :  device_addr_buf_sclk ;
            end
            2:begin
                cmd_id_buf_sclk <= 0;//命令清零，防止后面判断中间状态时出错 2024年12月6日15:25:44
                state_sclk <= spi_byte_en  ? 3 : state_sclk ;
                device_addr_buf_sclk <= spi_byte_en ?  { device_addr_buf_sclk,spi_hbyte_hex } :  device_addr_buf_sclk ;
            end
            
            
            //cmd ID  ////////////////////////////////////////////////////////////////////////////////////////
            3:begin
                state_sclk <= spi_byte_en  ? 4 : state_sclk ;
                cmd_id_buf_sclk <= spi_byte_en ?  { cmd_id_buf_sclk,spi_hbyte_hex } :  cmd_id_buf_sclk ;
            end
            4:begin
                state_sclk <= spi_byte_en  ? 5 : state_sclk ;
                cmd_id_buf_sclk <= spi_byte_en ?  { cmd_id_buf_sclk,spi_hbyte_hex } :  cmd_id_buf_sclk ;
            end
            5:begin
                state_sclk <= spi_byte_en  ? 6 : state_sclk ;
                cmd_id_buf_sclk <= spi_byte_en ?  { cmd_id_buf_sclk,spi_hbyte_hex } :  cmd_id_buf_sclk ;
            end    
            6:begin
                state_sclk <= spi_byte_en  ? 7 : state_sclk ;
                cmd_id_buf_sclk <= spi_byte_en ?  f_inv_2byte( { cmd_id_buf_sclk,spi_hbyte_hex } ):  cmd_id_buf_sclk ;
                
                                
                //判断 是不是缩略图 以及 读中断寄存器拷贝 -----  颠倒值
                
               // flag_fifo_rx_wr_en_sclk <= { cmd_id_buf_sclk,spi_hbyte_hex } == 16'h0000 | { cmd_id_buf_sclk,spi_hbyte_hex } == 16'h0100  ?  0 : 1 ;
               // flag_spi_wr_succ             <= spi_byte_en ? (   { cmd_id_buf_sclk,spi_hbyte_hex } == 16'h0000 | { cmd_id_buf_sclk,spi_hbyte_hex } == 16'h0100  ?  0 : 1  ) : flag_spi_wr_succ  ;
                //flag_spi_wr_fail             <= spi_byte_en ? (   { cmd_id_buf_sclk,spi_hbyte_hex } == 16'h0000 | { cmd_id_buf_sclk,spi_hbyte_hex } == 16'h0100  ?  1 : 0  ) : flag_spi_wr_fail ;
               
               
               //更换位置
              // flag_spi_wr_succ             <=   { cmd_id_buf_sclk,spi_hbyte_hex } == 16'h0000 | { cmd_id_buf_sclk,spi_hbyte_hex } == 16'h0100  ?  0 : 1    ;
               // flag_spi_wr_fail             <=   { cmd_id_buf_sclk,spi_hbyte_hex } == 16'h0000 | { cmd_id_buf_sclk,spi_hbyte_hex } == 16'h0100  ?  1 : 0    ;
               
 
            end   
            
            
            //rd or wr ////////////////////////////////////////////////////////////////////////////////////////
            7:begin
               // flag_spi_wr_succ <= 0; //之后一直拉高
                
                
                flag_spi_wr_fail <= 0; //用于对不需要写入fifo的内容复位
                

                state_sclk <= spi_byte_en  ? 8 : state_sclk ;
                wnr_buf_sclk <= spi_byte_en ?  { wnr_buf_sclk,spi_hbyte_hex } :  wnr_buf_sclk ;
            end    
            8:begin
                state_sclk   <= spi_byte_en  ? 9 : state_sclk ;
                wnr_buf_sclk <= spi_byte_en ?  { wnr_buf_sclk,spi_hbyte_hex } :  wnr_buf_sclk ;
            end 
            
            
            // length ////////////////////////////////////////////////////////////////////////////////////////
            9:begin

                state_sclk <= spi_byte_en  ? 10 : state_sclk ;
                length_buf_sclk_dym <= spi_byte_en ?  { length_buf_sclk_dym,spi_hbyte_hex } :  length_buf_sclk_dym ;
            end 
            10:begin
                state_sclk <= spi_byte_en  ? 11 : state_sclk ;
                length_buf_sclk_dym <= spi_byte_en ?  { length_buf_sclk_dym,spi_hbyte_hex } :  length_buf_sclk_dym ;
            end 
            11:begin
                state_sclk <= spi_byte_en  ? 12 : state_sclk ;
                length_buf_sclk_dym <= spi_byte_en ?  { length_buf_sclk_dym,spi_hbyte_hex } :  length_buf_sclk_dym ;
            end  
            12:begin
                cnt       <= spi_byte_en ?  16 : 0 ;
                                               //特殊指令                                                                  //如果为正常指令, 读 则生成fail ; 同时控制fifo wr en
                flag_spi_wr_succ             <=   { cmd_id_buf_sclk } == 16'h0000 | { cmd_id_buf_sclk } == 16'h0001  ?  0 :  wnr_buf_sclk==8'hFF  ? 0 : 1   ;
                flag_spi_wr_fail            <=   { cmd_id_buf_sclk } == 16'h0000 | { cmd_id_buf_sclk } == 16'h0001  ?  1 :   wnr_buf_sclk==8'hFF  ? 1 : 0   ;
                flag_fifo_rx_wr_en_sclk <= { cmd_id_buf_sclk } == 16'h0000 | { cmd_id_buf_sclk } == 16'h0001  ?  0 : wnr_buf_sclk==8'hFF  ? 0 : 1   ;
                
                
                
                
                //顺序已经调整
                state_sclk <= spi_byte_en ?  (  
                                                 (  cmd_id_buf_sclk==16'h0000  && wnr_buf_sclk!=8'hff  )  ?  13  :  //读ddr请求指令（下发目标(最终)字节的地址）
                                                 (  cmd_id_buf_sclk==16'h0000  && wnr_buf_sclk==8'hff  )  ?  70  :  //读ddr请求指令 ，从fifo拉数据回传
                                                 //(  cmd_id_buf_sclk==16'h0000  & wnr_buf_sclk ==`READ   )  ?  15  :  //暂不考虑     从dma fifo拉取缩略图
                                                 //(  cmd_id_buf_sclk==16'h0001  & wnr_buf_sclk ==`WRITE  )  ?  20  :  // 协议中并没有这条  ！！！
                                                 (  cmd_id_buf_sclk==16'h0001                           )  ?  30  :  //stm32读取软核的中断状态寄存器
                                                 //其他正常指令
                                                                         wnr_buf_sclk == 8'hFF  ?  40  :    // 正常 读
                                                                                                      50     //正常写  
                                                                       ////  wnr_buf_sclk ==`WRITE  ?  50 : 
                                                                       // 40     //正常指令   全部跳到读，上面发的指令 wr位始终为 0，通过length区分
                                                                       
                                                                         
                                           
                                           ) : state_sclk ;
                                           
                
                //length_buf_sclk_dym <= spi_byte_en ?  { length_buf_sclk_dym,spi_hbyte_hex } :  length_buf_sclk_dym ;
                //高4位和低4位颠倒
                length_buf_sclk_dym <= spi_byte_en ?  f_inv_2byte ({ length_buf_sclk_dym,spi_hbyte_hex }) :  length_buf_sclk_dym ;
                length_buf_sclk_dym_m2 <=    spi_byte_en ? 2* f_inv_2byte ({ length_buf_sclk_dym,spi_hbyte_hex }) :  length_buf_sclk_dym_m2 ;
                length_buf_sclk <= spi_byte_en ?  f_inv_2byte ({ length_buf_sclk_dym,spi_hbyte_hex }) :  length_buf_sclk_dym ;
                
                
                //ack数据时选择的源
                
                //不能打拍，不然对不上
               //flag_fifo_rx_src_sclk  <= spi_byte_en ?  (  
               //                           cmd_id_buf_sclk==16'h0000  & wnr_buf_sclk ==`WRITE  ?  2'b01  :  //暂不考虑   读缩略图请求，随后数据位ddr地址
               //                           cmd_id_buf_sclk==16'h0000  & wnr_buf_sclk ==`READ   ?  2'b01  :  //暂不考虑     从dma fifo拉取缩略图
               //                           cmd_id_buf_sclk==16'h0001  & wnr_buf_sclk ==`WRITE  ?  2'b10  : 
               //                           cmd_id_buf_sclk==16'h0001  & wnr_buf_sclk ==`READ   ?  2'b10 :
               //                                                          wnr_buf_sclk ==`READ  ? 2'b00 : 
               //                                                          wnr_buf_sclk ==`WRITE  ?  2'b00  :
               //                                                          state_sclk
               //                           
               //                           ) : 2'b00  ;
                
                
                
                
                
            end     
             //从ddr拉数据， 请求指令，存储ddr目标地址 ;  (注意：之后跟随的ddr地址长度是length的两倍) 
            13:begin
                length_buf_sclk_dym_m2 <= spi_byte_en ? (  length_buf_sclk_dym_m2 !=0 ? length_buf_sclk_dym_m2 - 1 : 0  )  : length_buf_sclk_dym_m2 ;    
                state_sclk  <=  spi_byte_en &   length_buf_sclk_dym_m2==0 ? 14 : state_sclk;  
                ddr_target_addr_sclk  <= (  spi_byte_en & length_buf_sclk_dym_m2>0 )   ?   { ddr_target_addr_sclk,spi_hbyte_hex } :  ddr_target_addr_sclk ;
            end
            14:begin           
                ddr_target_addr_sclk <=  f_inv_8byte( ddr_target_addr_sclk ) ;
                state_sclk <= 60 ;
            end
            60:begin
                //ddr_byte_num_sclk
                ;
            end
            
            
            
            
            //从 dma fifo 读缩略图
            15:begin
            
                
                
                length_buf_sclk_dym <= spi_byte_en ? (  length_buf_sclk_dym !=0 ? length_buf_sclk_dym - 1 : 0  )  : length_buf_sclk_dym ;    
                state_sclk  <=  spi_byte_en &   length_buf_sclk_dym==0 ? 16 : state_sclk;

                
            end
            16:begin //读满length个数据后，就停止读
                ;
            
            end
            //通知软核 有 中断内容读取请求
            20:begin
               // irpt_req_flag_sclk <= 1 ;  //no use
            end
            
            //返回软核的中断状态寄存器
            30:begin // //此处 length_buf_sclk_dym  可为0 
                length_buf_sclk_dym <= spi_byte_en ? (  length_buf_sclk_dym !=0 ? length_buf_sclk_dym - 1 : 0  )  : length_buf_sclk_dym ;    
                state_sclk  <=  spi_byte_en &   length_buf_sclk_dym==0 ? 41 : state_sclk;  
            end
            31:begin
                ;//读取特定数据后，即停止
            
            end
            
            
            
            //从tx_fifo读取内容
            40:begin  //此处 length_buf_sclk_dym  可为0 
                length_buf_sclk_dym <= spi_byte_en ? (  length_buf_sclk_dym !=0 ? length_buf_sclk_dym - 1 : 0  )  : length_buf_sclk_dym ;    
                state_sclk  <=  spi_byte_en &   length_buf_sclk_dym==0 ? 41 : state_sclk;
            end
            41:begin
                ; //读取特定量数据后，即停止
            
            end
           
           //正常指令 向rx_fifo 写内容
           50:begin  //写则不会发生从tx_fifo读的状态
                ;
           
           end
            
            
            
            //从fifo拉ddr数据
            70:begin
                length_buf_sclk_dym <= spi_byte_en ? (  length_buf_sclk_dym !=0 ? length_buf_sclk_dym - 1 : 0  )  : length_buf_sclk_dym ;    
                state_sclk  <=  spi_byte_en &   length_buf_sclk_dym==0 ? 71 : state_sclk;
            end
            71:begin
                ;
            end
            
            
            default:;
        endcase
    end
end




//////////////////////////////////////////////////SPI ACK数据触发///////////////////////////////////////////////////
wire  flag_spi_dma_trig_sclk ;

//assign  snap_fifo_rd_sclk = (  state_sclk==12 &  spi_byte_en &  cmd_id_buf_sclk==0 &  wnr_buf_sclk==1 ) |  (state_sclk==15 & spi_byte_en & length_buf_sclk_dym>1 )  ;
assign  flag_spi_tx_fifo_trig_sclk   = (state_sclk==12 &  (cmd_id_buf_sclk!=16'h0000 &&  cmd_id_buf_sclk!=16'h0001 )  & spi_byte_en  & length_buf_sclk_dym!=0   &  wnr_buf_sclk==8'hff ) | (state_sclk==40 & spi_byte_en & length_buf_sclk_dym>1  ) ;  ;

//assign  flag_spi_irpt_reg_trig_sclk  = (state_sclk==12 &  cmd_id_buf_sclk==16'h0001 & spi_byte_en & wnr_buf_sclk ==`READ ) | (state_sclk==30 & spi_byte_en & length_buf_sclk_dym>1  ) ;  ;

assign  flag_spi_irpt_reg_trig_sclk  = (state_sclk==12 &  cmd_id_buf_sclk==16'h0001 & spi_byte_en  & length_buf_sclk_dym!=0 ) | (state_sclk==30 & spi_byte_en & length_buf_sclk_dym>1  ) ;  ;

assign  flag_spi_dma_trig_sclk  = //(state_sclk==12 &  cmd_id_buf_sclk==16'h0000 & spi_byte_en  & length_buf_sclk_dym!=0 & wnr_buf_sclk==8'hff  )
                                    
                                  //2025年3月12日14:18:44 遇到问题第二次从ddr拉数据时，延后了一个字节，应该是这里的问题（ 指令不能发 0字节，不然就会多读一个字节）
                                 (state_sclk==12 &  cmd_id_buf_sclk==16'h0000 & spi_byte_en                            & wnr_buf_sclk==8'hff  )

                                 |  (state_sclk==70 & spi_byte_en & length_buf_sclk_dym>1  )    ;
    


//////////////////////////////////////////////////SPI ACK数据源选择//////////////////////////////////////////////////
assign  flag_fifo_rx_src_sclk  = cmd_id_buf_sclk==16'h0000   ?  2'b01  :  // 从缩略图 ddr 取数据
                                 cmd_id_buf_sclk==16'h0001   ?  2'b10  :  // 从irpt sts 寄存器取数据
                                                                2'b00   ;  // tx fifo 取数据
assign  spi_ack_data  =  flag_fifo_rx_src_sclk==2'b00 ?  tx_fifo_rd_data_sclk : flag_fifo_rx_src_sclk==2'b01 ?   snap_fifo_rd_data_sclk  : spi_irpt_reg_data ;

 
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////IRPT STS reg/////////////////////////////////////////
always@(posedge  spi_clk_mux  or posedge spi_cs_aclk)begin
    if(spi_cs_aclk)begin
        ;
    end
    else begin 
        spi_irpt_reg_data <= state_sclk==1 ? R_IRPT_DUPLICATE_sclk : flag_spi_irpt_reg_trig_sclk ?  spi_irpt_reg_data>>8 : spi_irpt_reg_data ;
    end
end


reg [15:0] byte_num_ignore_aclk     =0 ;
reg        fifo_ignore_start_aclk   =0 ;
reg [15:0] fifo_ignore_byte_aclk    =0;

//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////中断 & 控制////////////////////////////////////////////
reg [7:0] cnt_d = 0;
reg [15:0] irpt_out_num = 0;
always@(posedge S_AXI_ACLK)begin
    //if(~S_AXI_ARESETN |  R_SOFT_RESET)begin
    if(~S_AXI_ARESETN )begin
        state_irpt1     <= 0;
        INTERRUPT_O    <= 0;
        cnt_d <= 0;
        irpt_out_num <= 0 ;
        dma_addr_aclk  <= 0;
        dma_start_aclk <=  0;
        
         byte_num_ignore_aclk   <= 0;
         fifo_ignore_start_aclk <= 0;
         fifo_ignore_byte_aclk  <= 0;
       
    end
    else  if(read_req_cpu_to_axi_ll & read_addr_cpu_to_axi_ll==`ADDR_SPI_IRPT_STS )begin
          R_SPI_IRPT_STS  <= 0;
    end
    else begin
        case(state_irpt1)
            0:begin
                //普通指令 下发完成  上传完成 发出 中断
               // if( SPI_CS_I_aclk_sss_pos & cmd_id_buf_aclk != 16'h0001  & cmd_id_buf_aclk != 16'h0000 ) begin
                if( SPI_CS_I_aclk_sss_pos & cmd_id_buf_aclk != 16'h0001  & cmd_id_buf_aclk != 16'h0000 &  wnr_buf_aclk!=8'hff  ) begin
               

                    R_SPI_RX_SIZE  <= spi_byte_num_rx_aclk ;
                    
                    R_SPI_IRPT_STS <= wnr_buf_aclk ? 32'b00000000000000000000000000000010 : 32'b00000000000000000000000000000001 ; 
                    INTERRUPT_O      <= 1;
                    irpt_out_num    <= irpt_out_num + 1  ;
                    state_irpt1      <= 1;
                    cnt_d <= 10;
                end   
                else if(SPI_CS_I_aclk_sss_pos & cmd_id_buf_aclk==0 &  wnr_buf_aclk!=8'hff)begin
                    dma_stop_aclk <= 1 ;
                    state_irpt1   <= 2 ;     
                end
                

                
                //else if(SPI_CS_I_aclk_sss_pos & cmd_id_buf_aclk==0 &  wnr_buf_aclk!=8'hff)begin
                //     //触发dma读操作, 注意要先停止，后启动       
                //    //dma_stop_aclk <= 1 ;
                //    state_irpt1   <= 2 ;
                //    dma_addr_aclk <=  ddr_target_addr_aclk ;
                //    dma_start_aclk <= 1 ; 
                //        
                //end
                
                
                
                
                
            end
            1:begin
                cnt_d <= cnt_d-1 ;
                INTERRUPT_O     <= cnt_d==0 ? 0 : 1 ;
                state_irpt1     <= cnt_d==0 ? 0 : 1 ;
            end
            2:begin
                dma_stop_aclk <= 0 ;
                state_irpt1 <= ~dma_busy_aclk ? 3 : state_irpt1 ;
            
            end
            3:begin
                snap_fifo_wr_rst_aclk <= 1 ;
                state_irpt1 <= 4 ;
            
            end
            4:begin
                snap_fifo_wr_rst_aclk <= 0 ;
                state_irpt1 <= snap_fifo_wr_rst_finish_aclk ? 5 :state_irpt1 ;
            end
            5:begin
                dma_addr_aclk <=  ddr_target_addr_aclk ;
                byte_num_ignore_aclk <=   ddr_target_addr_aclk - f_lower_align(ddr_target_addr_aclk,(C_AXI4_DATA_WIDTH/8));      
                dma_start_aclk <= 1 ; 
                state_irpt1   <= 6;
            end
            6:begin
                dma_start_aclk <= 0 ;
                state_irpt1 <= 7 ;//启动fifo的忽略模块
            end
            7:begin      
                fifo_ignore_start_aclk <= 1;
                fifo_ignore_byte_aclk  <= byte_num_ignore_aclk;
                state_irpt1  <= 8;
            end
            8:begin
                fifo_ignore_start_aclk <= 0;
                state_irpt1 <= 0;
            end
            
            
            
           //2:begin
           //    
           //    //dma_stop_aclk <= 0 ;
           //    //state_irpt1   <= dma_busy  ;
           //    dma_start_aclk <= 0 ; 
           //    state_irpt1 <= 0 ;
           //end
            
            
            
            default:;
        endcase
    end
end

wire snap_fifo_rd_empty_sclk ;
wire  snap_fifo_rd_rst_busy_sclk ;


wire fifo_ignore_start_sclk;
wire [15:0] fifo_ignore_byte_sclk ;

`HANDSHAKE_OUTGEN(S_AXI_ACLK,0,fifo_ignore_start_aclk,fifo_ignore_byte_aclk,spi_clk_mux,0,fifo_ignore_start_sclk,fifo_ignore_byte_sclk,16,0)  

reg fifo_rd_ignore = 0 ;

reg [7:0] state_fifo_ig_sclk = 0;
reg [15:0] cnt_ignore =0  ; 


always@(posedge  spi_clk_mux)begin
    if(~S_AXI_ARESETN_sclk)begin
        state_fifo_ig_sclk <= 0;
        cnt_ignore <= 0 ;
    end
    else if(fifo_ignore_start_sclk)begin
        cnt_ignore <= 0;
        if(fifo_ignore_byte_sclk!=0) state_fifo_ig_sclk <= 1;    //如果需要忽略，才到状态1
        else state_fifo_ig_sclk <= 0;
    end
    else begin
        case(state_fifo_ig_sclk)
            0:begin
                ;
            end
            1:begin
                cnt_ignore         <=  ~snap_fifo_rd_rst_busy_sclk &  ~snap_fifo_rd_empty_sclk ? cnt_ignore + 1 :    cnt_ignore ;
                fifo_rd_ignore     <=  ~snap_fifo_rd_rst_busy_sclk &  ~snap_fifo_rd_empty_sclk ? 1 : 0 ;
                state_fifo_ig_sclk <=  ~snap_fifo_rd_rst_busy_sclk &  ~snap_fifo_rd_empty_sclk ? 2 : 1  ;
            end
            2:begin
                
                fifo_rd_ignore <= 0 ;
                if(cnt_ignore>=fifo_ignore_byte_sclk)begin
                    state_fifo_ig_sclk <= 0;
                end
                else begin
                    state_fifo_ig_sclk <= 1 ;
                end 
            end
            default:;
        endcase
    end
end





reg dma_stop_aclk = 0;
wire dma_busy_aclk ;
reg snap_fifo_wr_rst_aclk = 0;
wire snap_fifo_wr_rst_finish_aclk  ;
wire snap_fifo_wr_rst_mclk ;

dma_utility_0   dma_utility_0_u(
    .S_CLK_I        (S_AXI_ACLK       ),
    .S_RST_I        (~S_AXI_ARESETN   ),
    .S_DMA_STOP_I   (dma_stop_aclk    ),
    .S_DMA_BUSY_O   (dma_busy_aclk   ),
    .M_CLK_I        (M_AXI_ACLK      ),
    .M_RST_I        (~M_AXI_ARESETN   ),
    .M_DMA_STOP_O   (dma_stop_mclk),
    .M_DMA_BUSY_I   (dma_busy_mclk)
);







 fifo_utility_0   fifo_utility_0 (
.S_CLK_I            (S_AXI_ACLK  )  ,
.S_RST_I            (~S_AXI_ARESETN) ,
.S_FIFO_RST_I       (snap_fifo_wr_rst_aclk  )   ,
.S_FIFO_RST_FINISH_O(snap_fifo_wr_rst_finish_aclk)  ,
.M_CLK_I            (M_AXI_ACLK     )   ,
.M_RST_I            (~M_AXI_ARESETN)  ,
.M_FIFO_RST_O       (snap_fifo_wr_rst_mclk)     //只关心rst信号是否发送给了fifo

);
    

wire snap_fifo_wr_rst_sclk ;
reg [7:0] state_sclk_snap_fifo = 0;

`CDC_SINGLE_BIT_PULSE_OUTGEN(S_AXI_ACLK,0,snap_fifo_wr_rst_aclk,spi_clk_mux,0,snap_fifo_wr_rst_sclk,0,3)


reg   dma_start_aclk;
reg   [31:0]  dma_addr_aclk ;
wire   dma_start_mclk ;
wire  [31:0]  dma_addr_mclk ;

`HANDSHAKE_OUTGEN(S_AXI_ACLK,0,dma_start_aclk,dma_addr_aclk,M_AXI_ACLK,0,dma_start_mclk,dma_addr_mclk,32,0) 







reg clear_irpt_sts_aclk = 0;
reg [7:0] state_irpt2 = 0;
always@(posedge S_AXI_ACLK)begin
   // if(~S_AXI_ARESETN |  R_SOFT_RESET)begin
    if(~S_AXI_ARESETN )begin
       clear_irpt_sts_aclk <= 0;
       state_irpt2    <= 0;
    end
    else begin
        case(state_irpt2)
            0:begin
                if( SPI_CS_I_aclk_sss_pos & cmd_id_buf_aclk == 16'h0001  & length_buf_aclk != 0 ) begin //length_buf_aclk 已经为锁存
                    clear_irpt_sts_aclk   <= 1 ;
                    state_irpt2      <= 1;
                end   
            end
            1:begin
                clear_irpt_sts_aclk   <= 0 ;
                state_irpt2      <= 0;
            end
            default:;
        endcase
    end
end







//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
wire [15:0]  FIFO_WR_EN_NAMES_O_sclk  ;//名义写入次数
wire [15:0]  FIFO_WR_EN_ACCUS_O_sclk  ;
wire [15:0]  FIFO_RD_EN_NAMES_O_aclk  ;
wire [15:0]  FIFO_RD_EN_ACCUS_O_aclk  ;  

wire [15:0] FIFO_WR_EN_NAMES_O_aclk ;
wire [15:0] FIFO_WR_EN_ACCUS_O_aclk ;


`CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(FIFO_WR_EN_NAMES_O_sclk,S_AXI_ACLK,FIFO_WR_EN_NAMES_O_aclk,16,3)
`CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(FIFO_WR_EN_ACCUS_O_sclk,S_AXI_ACLK,FIFO_WR_EN_ACCUS_O_aclk,16,3)

//异步return对时钟有要求
 fifo_async_return_wr
    #(.C_FIFO_WRITE_WIDTH      (8  ),
      .C_FIFO_READ_WIDTH       (8  ),
      .C_WR_TMN_RTL_FIFO_DEPTH (512  ),
      .C_RD_TMN_XPM_FIFO_DEPTH (512),
      .C_DATA_COUNT_WIDTH      (16  ),
      .C_DBG_COUNT_WIDTH       (16  ) )
     fifo_rx_cpu_u (
    // .FIFO_WR_RST_I         ( flag_spi_wr_fail  | R_RX_FIFO_RESET_sclk   ),   
     .FIFO_WR_RST_I         (   R_RX_FIFO_RESET_sclk   ),    //取消了接收中途的复位 
    
     .FIFO_WR_CLK_I         (  spi_clk_mux                 ),            
     .FIFO_WR_EN_I          (spi_byte_en & flag_fifo_rx_wr_en_sclk       ), 
     .FIFO_WR_SUCC_I        (flag_spi_wr_succ       ),         
     .FIFO_WR_FAIL_I        (flag_spi_wr_fail       ),  
     .FIFO_WR_DATA_I        (spi_byte_ascii    ),      
     .FIFO_WR_FULL_O         (rx_fifo_wr_full_sclk      ) , 
     .FIFO_WR_RST_BUSY_O     ( rx_fifo_wr_rst_busy_sclk ) , 
     .FIFO_WR_EN_NAMES_O     (   ),
     .FIFO_WR_EN_ACCUS_O     (   ),
     
     
     
     
     
     .FIFO_RD_CLK_I         (S_AXI_ACLK        ),
     .FIFO_RD_EN_I          (cpu_fifo_rx_rd_aclk        ),    
     .FIFO_RD_DATA_O        (cpu_fifo_rx_rd_data_aclk   ),    
     .FIFO_RD_EMPTY_O       (rx_fifo_rd_empty_aclk      ),
     .FIFO_RD_DATA_COUNT_O  (R_SPI_RX_FIFO_COUNT        ),
     .FIFO_RD_RST_BUSY_O    ( rx_fifo_rd_rst_busy_aclk  ) ,
     .FIFO_RD_EN_NAMES_O    (  FIFO_RD_EN_NAMES_O_aclk  ),
     .FIFO_RD_EN_ACCUS_O    ( FIFO_RD_EN_ACCUS_O_aclk )  
     
   
     );


fifo_wr_return_count   
    #(.C_COUNT_WIDTH (16))
    fifo_wr_return_count_u(
    .CLK_I          (spi_clk_mux                            ) ,
    .RST_I          (0                                      ) ,
    .WR_EN_I        (spi_byte_en & flag_fifo_rx_wr_en_sclk  ) ,
    .WR_FULL_I      (rx_fifo_wr_full_sclk                   ) ,
    .WR_RST_BUSY_I  (0                                      ) ,
    .WR_SUCC_I      (flag_spi_wr_succ                       ) ,
    .WR_FAIL_I      (flag_spi_wr_fail                       ) ,
    .WR_NUM_ACCU_O  (FIFO_WR_EN_ACCUS_O_sclk                ) 

    );







   
//
//fifo_async_xpm   
//   #( .C_RD_MODE              ("fwft" ),
//     .C_WR_WIDTH              (8),
//     .C_RD_WIDTH              (8),
//     .C_WR_DEPTH              (256),
//     .C_WR_COUNT_WIDTH        (16),
//     .C_RD_COUNT_WIDTH        (16),
//     .C_RD_PROG_EMPTY_THRESH  (10),  
//     .C_WR_PROG_FULL_THRESH   (256-C_DDR_BURST_LEN*2 ), 
//     .C_DBG_COUNT_WIDTH       (16 ) )
//    rx_fifo_u(
//    //.WR_RST_I                   (  flag_spi_wr_fail  | R_RX_FIFO_RESET_sclk  | R_SOFT_RESET_sclk   ) , 
//    .WR_RST_I                   (  flag_spi_wr_fail  | R_RX_FIFO_RESET_sclk     ) , 
//    .WR_CLK_I                   ( ~spi_clk_mux                 ) , //为了解决spi cs范围内最后一个时钟的问题
//    .WR_EN_I                    (spi_byte_en & flag_fifo_rx_wr_en_sclk            ) , 
//    .WR_DATA_I                  (spi_byte_ascii            ) ,
//    .WR_FULL_O                  (rx_fifo_wr_full_sclk      ) , 
//    .WR_DATA_COUNT_O            (       ) , 
//    .WR_PROG_FULL_O             (       ) , 
//    .WR_RST_BUSY_O              ( rx_fifo_wr_rst_busy_sclk ) , 
//    .WR_ERR_O                   (       ) ,
//    
//    .RD_CLK_I                   (S_AXI_ACLK                 )  ,
//    .RD_EN_I                    (cpu_fifo_rx_rd_aclk        )  ,
//    .RD_DATA_O                  (cpu_fifo_rx_rd_data_aclk   )  ,
//    .RD_EMPTY_O                 ( rx_fifo_rd_empty_aclk      )  ,
//    .RD_DATA_COUNT_O            ( R_SPI_RX_FIFO_COUNT       )  ,
//    .RD_PROG_EMPTY_O            (                           )  , 
//    .RD_RST_BUSY_O              ( rx_fifo_rd_rst_busy_aclk  )  ,
//    .RD_ERR_O                   (                           ) 
//    
//    );








///////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////snap dma control//////////////////////////////////////////////
//always@(posedge M_AXI_ACLK)begin
//    //if(~M_AXI_ARESETN |   R_SOFT_RESET_mclk  )begin
//    if(~M_AXI_ARESETN   )begin
//        state_mclk   <= 0;  
//        snap_dma_rd_addr  <= 0;
//        snap_dma_rd_bytes <= 0;
//        snap_dma_rd_trig  <= 0;
//        snap_dma_rd_stop  <= 0;
//        snap_fifo_wr_rst <= 0;
//    end
//    else begin
//        case(state_mclk)
//            0:begin
//                if(SPI_CS_I_mclk_pos_ss & cmd_id_buf_aclk ==0 ) begin //获取缩略图
//                    snap_dma_rd_stop <= 1 ;
//                    state_mclk <= 1;
//                end
//            end
//            1:begin
//                snap_dma_rd_stop <= 0;
//                if(snap_dma_rd_busy ==0)begin
//                    snap_fifo_wr_rst <= 1;
//                    state_mclk <= 2 ;
//                end
//            end
//            2:begin
//                snap_fifo_wr_rst <= 0;
//                snap_dma_rd_addr  <= snap_ddr_addr_buf_mclk ;
//                snap_dma_rd_bytes <= 614400;//一张缩略图
//                snap_dma_rd_trig  <= 1; 
//                state_mclk <= 3 ;
//            end
//            3:begin
//                snap_dma_rd_trig <= 0;
//            end
//            default:;
//        endcase
//    end
//end
//

wire snap_fifo_wr ;
wire [C_AXI4_DATA_WIDTH-1:0] snap_fifo_wr_data ;

wire dma_stop_mclk ;  
wire dma_busy_mclk   ;
wire snap_fifo_wr_full;
wire snap_fifo_wr_rst_busy ;


wire [7:0] r_dma_state_mclk ;



generate  if(C_SNAP_ENABLE)begin

axi4_master 
    #(.C_M_AXI_BURST_LEN             (C_DDR_BURST_LEN                    ), //1, 2, 4, 8, 16, 32, 64, 128, 256
     .C_M_AXI_ADDR_WIDTH            (C_AXI4_ADDR_WIDTH    ), // 32 64
     .C_M_AXI_DATA_WIDTH            (C_AXI4_DATA_WIDTH    ), //32 64 128 256
     .C_RD_BLOCK_ENABLE             (1                    ),
     .C_WR_BLOCK_ENABLE             (1                    ),
     .C_RD_SIM_ENABLE               (0                    ),
   //  .C_RD_SIM_ENABLE               (1                   ),
     
     
     .C_WR_SIM_ENABLE               (0                    ),
     .C_RD_SIM_PATTERN_TYPE         (1                    ),
     .C_RD_SIM_PATTERN_UNIT_BYTE_NUM(4                    ),
     .C_RD_NORM_DATA_SOURCE         (C_RD_NORM_DATA_SOURCE                    ),
     .C_RD_NORM_DATA_UNIT_BYTE_NUM  (1                    ),
     .C_RD_ALIGN_ENABLE             (0                    ),
     .C_RD_BLOCK_ALIGN_BYTE_NUM     (4096                 ),
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
    
   .W_STOP_I      (0   ),
   .W_RST_I       (0   ),
   .W_REQ_I       (0   ),
   .W_START_ADDR_I(0   ), 
   .W_BYTE_NUM_I  (0   ), 
   .W_FIFO_RD_DATA_COUNT_I( 0 ),
   .W_FIFO_EMPTY_I( 1 ),
   .W_FIFO_READ_O (     ),
   .W_FIFO_DATA_I ( 0 ), 
   .W_DONE_O      (     ),
   .W_FINISH_O    (     ),
   .W_BEATS_O                ( ),
   .W_BURSTS_O               ( ),
   .W_NEW_BYTE_NUM_I         (0),
   .W_NEW_BYTE_NUM_UPDATE_I  (0),
   .W_BUSY_O                 ( ),
   
   
   .R_RST_I       (0                   ),
   .R_REQ_I       (dma_start_mclk        ),
   .R_START_ADDR_I(dma_addr_mclk         ), 
   .R_BYTE_NUM_I  (2147483648   ), 
   .R_FIFO_FULL_I (snap_fifo_wr_full | snap_fifo_wr_rst_busy   ), 
  // .R_FIFO_FULL_I (0  ), 
 
   .R_FIFO_WRITE_O(snap_fifo_wr        ), 
   .R_FIFO_DATA_O (snap_fifo_wr_data   ), 
   .R_DONE_O      (     ), 
   .R_FINISH_O    (   ),
   .R_STOP_I      (dma_stop_mclk        ),
   .R_BUSY_O      (dma_busy_mclk    ),
   
   
    .DEBUG_W_STATE   (   ),
    .DEBUG_R_STATE   (r_dma_state_mclk  ),
	.DEBUG_W_MISSTEP (   ),
	.DEBUG_R_MISSTEP (   )

   );

end
endgenerate



 

generate if(C_SNAP_ENABLE)begin
fifo_async_xpm   
  #( .C_RD_MODE               ("fwft" ),
   .C_WR_WIDTH              (C_AXI4_DATA_WIDTH),    //先以 256bit x 256深度为基准
   .C_RD_WIDTH              (16),
   .C_WR_DEPTH              (256*256/C_AXI4_DATA_WIDTH),
   .C_WR_COUNT_WIDTH        (16),
   .C_RD_COUNT_WIDTH        (16),
   //.C_RD_PROG_EMPTY_THRESH  (10),  
  // .C_WR_PROG_FULL_THRESH   (256*(256/C_AXI4_DATA_WIDTH) - C_DDR_BURST_LEN*2 ), 
   .C_DBG_COUNT_WIDTH       (16 ) )
    fifo_tx_snap_u(
   // .WR_RST_I                   (~M_AXI_ARESETN | snap_fifo_wr_rst | R_SOFT_RESET_mclk  ) , 
    .WR_RST_I                   (~M_AXI_ARESETN | snap_fifo_wr_rst_mclk   ) , //snap_fifo_wr_rst_mclk 每次下发请求时，复位拉取数据的fifo
    .WR_CLK_I                   (M_AXI_ACLK                       ) ,
    .WR_EN_I                    (snap_fifo_wr           ) ,  //从ddr拉数据后写入
    .WR_DATA_I                  (snap_fifo_wr_data      ) ,     
    .WR_FULL_O                  (    ) , 
    .WR_DATA_COUNT_O            (    ) , 
    .WR_PROG_FULL_O             (snap_fifo_wr_full      ) , 
    .WR_RST_BUSY_O              (snap_fifo_wr_rst_busy  ) , 
    .WR_ERR_O                   (    ) ,
    
    .RD_CLK_I                   (spi_clk_mux               )  ,
    .RD_EN_I                    (~snap_fifo_rd_rst_busy_sclk_0 & ~snap_fifo_rd_empty_sclk_0  & ~snap_fifo_wr_rst_busy_0 & ~snap_fifo_wr_full_0  )  ,
    .RD_DATA_O                  (snap_fifo_rd_data_sclk_0       )  ,
    .RD_EMPTY_O                 (snap_fifo_rd_empty_sclk_0       )  ,
    .RD_DATA_COUNT_O            (        )  ,
    .RD_PROG_EMPTY_O            (        )  , 
    .RD_RST_BUSY_O              (snap_fifo_rd_rst_busy_sclk_0    )  ,
    .RD_ERR_O                   (        ) 
    
);



fifo_async_xpm   
  #( .C_RD_MODE               ("fwft" ),
   .C_WR_WIDTH              (16),    //先以 256bit x 256深度为基准
   .C_RD_WIDTH              (8),
   .C_WR_DEPTH              (256*256/16),
   .C_WR_COUNT_WIDTH        (16),
   .C_RD_COUNT_WIDTH        (16),
   //.C_RD_PROG_EMPTY_THRESH  (10),  
  // .C_WR_PROG_FULL_THRESH   (256*(256/C_AXI4_DATA_WIDTH) - C_DDR_BURST_LEN*2 ), 
   .C_DBG_COUNT_WIDTH       (16 ) )
    fifo_tx_snap_u2(
    .WR_RST_I                   (~S_AXI_ARESETN_sclk | snap_fifo_wr_rst_sclk   ) , //snap_fifo_wr_rst_mclk 每次下发请求时，复位拉取数据的fifo
    .WR_CLK_I                   (spi_clk_mux                       ) ,
    .WR_EN_I                    (  ~snap_fifo_rd_rst_busy_sclk_0 & ~snap_fifo_rd_empty_sclk_0  & ~snap_fifo_wr_rst_busy_0 & ~snap_fifo_wr_full_0         ) ,  //从ddr拉数据后写入
    .WR_DATA_I                  (snap_fifo_rd_data_sclk_0      ) ,     
    .WR_FULL_O                  (    ) , 
    .WR_DATA_COUNT_O            (    ) , 
    .WR_PROG_FULL_O             (snap_fifo_wr_full_0      ) , 
    .WR_RST_BUSY_O              (snap_fifo_wr_rst_busy_0  ) , 
    .WR_ERR_O                   (    ) ,
    
    .RD_CLK_I                   (spi_clk_mux               )  ,
    .RD_EN_I                    (flag_spi_dma_trig_sclk | fifo_rd_ignore )  ,
    .RD_DATA_O                  (snap_fifo_rd_data_sclk       )  ,
    .RD_EMPTY_O                 (snap_fifo_rd_empty_sclk       )  ,
    .RD_DATA_COUNT_O            (snap_fifo_rd_data_count_sclk   )  ,
    .RD_PROG_EMPTY_O            (        )  , 
    .RD_RST_BUSY_O              (snap_fifo_rd_rst_busy_sclk    )  ,
    .RD_ERR_O                   (        ) 
    
);




end

endgenerate





//向上对齐

//f_upper_align(x,y);

function [15:0] f_upper_align ;
input  [15:0] in;
input  [15:0] align_unit;//must be power of 2, must >= 1, do not allow to be 0
begin : AA
    reg [15:0] tail;
    tail = in & {0,{align_unit-1}} ; //取尾部
    f_upper_align = (in & ~{0,{align_unit-1}}) + (tail!=0)*align_unit ;
end
endfunction



//向下对齐
//f_lower_align(x,y);

function [15:0] f_lower_align ;
input  [15:0] in;
input  [15:0] align_unit;//must be power of 2, must >= 1, do not allow to be 0
begin : AA
    f_lower_align = in & ~{0,{align_unit-1}} ;
end
endfunction  





function [15:0] f_inv_2byte;
input [15:0] in;
begin
    f_inv_2byte = { in[7:0],in[15:8] } ;
end
endfunction






function [31:0] f_inv_4byte;
input [31:0] in;
begin
    f_inv_4byte = { in[7:0],in[15:8],in[23:16],in[31:24] } ;
end
endfunction





function [63:0] f_inv_8byte;
input [63:0] in;
begin
    f_inv_8byte = { in[7:0],in[15:8],in[23:16],in[31:24], in[39:32],in[47:40],in[55:48],in[63:56]   } ;
end
endfunction













//用aclk抓取接口收到的spi信号,
generate if(C_ILA_SPIIF_ACLK_ENABLE)begin
ila_spi_interface_aclk   
    ila_spi_interface_aclk_u(
    .clk     (S_AXI_ACLK        ),
    .probe0  (SPI_SCK_I         ),
    .probe1  (SPI_CS_I          ),
    .probe2  (SPI_SDO_I         ),
    .probe3  (SPI_SDI_O         ),
    .probe4  (INTERRUPT_O       )
    
    
    
    );
end
endgenerate





generate if(C_ILA_SCLK_ENABLE)begin
    ila_sclk 
    ila_sclk_u(
    .clk     (spi_clk_mux                   ) ,
    .probe0  ({fifo_ignore_start_sclk,state_sclk}                 ) ,
    .probe1  (length_buf_sclk_dym           ) ,
    .probe2  (spi_byte_num_rx_sclk      ) ,
    .probe3  (wnr_buf_sclk              ) ,
    .probe4  (cmd_id_buf_sclk           ) ,
    .probe5  (device_addr_buf_sclk      ) ,
    .probe6  (spi_byte_en               ) ,
    .probe7  (flag_fifo_rx_wr_en_sclk   ) ,
    .probe8  (spi_byte_ascii            ) ,
    .probe9  (spi_hbyte_hex             ) ,//4
    .probe10 (flag_spi_wr_succ                 ) ,
    .probe11 ({fifo_ignore_byte_sclk,flag_spi_wr_fail   }    ) ,
    .probe12 (SPI_CS_I_muxclk_neg          ) ,//每一轮  spi rx num 清零标志
    .probe13 ({flag_spi_dma_trig_sclk,fifo_rd_ignore,snap_fifo_rd_empty_sclk,snap_fifo_rd_rst_busy_sclk  } ) ,
    .probe14 (snap_fifo_rd_data_count_sclk                 ) ,//16
    .probe15 ({state_fifo_ig_sclk,snap_fifo_rd_data_sclk }   ) , // 8 8
    .probe16 (cnt_ignore    )   // 8 8
    

    ) ;
end
endgenerate


 



generate if(C_ILA_ACLK_ENABLE)begin
    ila_aclk 
    ila_aclk_u
    (
    .clk     (S_AXI_ACLK  ) ,
    .probe0  (R_SPI_RX_SIZE) ,
    .probe1  (R_SPI_IRPT_STS) ,
    .probe2  ({INTERRUPT_O,dma_stop_aclk,dma_busy_aclk}) ,
    .probe3  (R_SPI_RX_FIFO_COUNT) ,
    .probe4  (R_SPI_TX_FIFO_COUNT) ,
    .probe5  (R_IRPT_DUPLICATE   ) ,//发出一个中断
    .probe6  ({write_req_cpu_to_axi_ll,read_req_cpu_to_axi_ll}) ,
    .probe7  (write_addr_cpu_to_axi_ll) ,
    .probe8  (write_data_cpu_to_axi_ll) ,
    .probe9  (read_data_axi_to_cpu_ll) ,
    .probe10 ( state_irpt1                     ),
    .probe11 ( SPI_CS_I_aclk_sss_pos   ),//收到一个spi 指令
    .probe12 ( cmd_id_buf_aclk                 ),//16 协议里解析到的
    .probe13 (spi_rx_num_aclk          ), //收到的总的 spi 传输数量
    .probe14 (FIFO_WR_EN_ACCUS_O_aclk  ),
    .probe15 (FIFO_RD_EN_NAMES_O_aclk  ),
    .probe16 (FIFO_RD_EN_ACCUS_O_aclk  ),
    .probe17 (irpt_out_num           ),//16
    .probe18 ( device_addr_buf_aclk   ), //8 协议里解析到的
    .probe19 ( wnr_buf_aclk           ), //8 协议里解析到的
    .probe20 ( length_buf_aclk        ), //16 协议里解析到的
    .probe21 ( spi_byte_num_rx_aclk    )//16   一次传输中收到的spi字节数
    ) ;

end
endgenerate




generate if(C_ILA_MCLK_ENABLE)begin
    ila_mclk (
    .clk     (M_AXI_ACLK  ),
    .probe0  (dma_stop_mclk  ),
    .probe1  (dma_busy_mclk  ),
    .probe2  (dma_start_mclk  ),
    .probe3  (dma_addr_mclk   ),//32
    .probe4  (r_dma_state_mclk) //8

    );


    

end
endgenerate



endmodule









