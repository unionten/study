`timescale 1 ns / 1 ps

`define SINGLE_TO_BI_Nm1To0(a,b,in,out)        for(i=1;i<=b;i=i+1)begin assign out[b-i] = in[a*b-1-(a-1)*(i-1)-(i-1):a*b-1-(a-1)*(i)-(i-1)];end 
`define BI_TO_SINGLE_Nm1To0(a,b,in,out)        for(i=1;i<=b;i=i+1)begin assign out[a*b-1-(a-1)*(i-1)-(i-1):a*b-1-(a-1)*(i)-(i-1)] = in[b-i];end 

//系列1：必须放在generate外
`define CDC_MULTI_BIT_SIGNAL(aclk_in,adata_in,bclk_in,bdata_out,DATA_WIDTH)                   generate begin xpm_cdc_array_single #(.DEST_SYNC_FF(4),.INIT_SYNC_FF(0),.SIM_ASSERT_CHK(0),.SRC_INPUT_REG(1),.WIDTH(DATA_WIDTH)) cdc_u(.src_clk(aclk_in),.src_in(adata_in),.dest_clk(bclk_in),.dest_out(bdata_out));    end  endgenerate  
`define CDC_SINGLE_BIT_PULSE(aclk_in,arst_in,apulse_in,bclk_in,brst_in,bpulse_out,SIM)          generate if(SIM==0)begin  xpm_cdc_pulse #(.DEST_SYNC_FF(4), .INIT_SYNC_FF(0),.REG_OUTPUT(0),.RST_USED(1),.SIM_ASSERT_CHK (0)) cdc_u (.src_clk(aclk_in),.src_rst(arst_in),.src_pulse(apulse_in),.dest_clk(bclk_in),.dest_rst(brst_in),.dest_pulse(bpulse_out));   end else begin   reg [5:0] name1 = 0;wire name2;always@(posedge aclk_in)if(arst_in)name1[0] <=0;else name1[0] <= apulse_in;assign name2 = apulse_in & ~name1[0]; always@(posedge aclk_in)if(arst_in)name1[1] <= 0;else name1[1] <= name2 ? ~name1[1]:name1[1];always@(posedge bclk_in)if(brst_in)name1[5:2]<=0;else begin name1[2]<=name1[1];name1[3]<=name1[2];name1[4]<=name1[3];name1[5]<=name1[4];end  assign bpulse_out=name1[4]^name1[5];  end  endgenerate
`define NEG_MONITOR(clk_in,rst_in,in,out)          generate  begin  reg buf_name1 = 0; always@(posedge clk_in)begin if(rst_in)buf_name1 <= 0; else  buf_name1 <= in; end assign out = (buf_name1)&(~in);  end  endgenerate
`define POS_MONITOR(clk_in,rst_in,in,out)          generate  begin  reg buf_name1 = 0; always@(posedge clk_in)begin if(rst_in)buf_name1 <= 0; else  buf_name1 <= in; end assign out = (~buf_name1)&(in);  end  endgenerate
`define POS_STRETCH(clk_in,rst_in,pulse_in,pulse_out,C_DELAY_NUM)          generate  begin    reg [C_DELAY_NUM-2:0] temp_name = 0; always@(posedge clk_in)begin  if(rst_in)temp_name <= {(C_DELAY_NUM-1){1'b0}}; else temp_name <= pulse_in ? {(C_DELAY_NUM-1){1'b1} }: temp_name<<1 ; end  assign  pulse_out = temp_name[C_DELAY_NUM-2]|pulse_in;  end  endgenerate
`define NEG_STRETCH(clk_in,rst_in,pulsen_in,pulsen_out,C_DELAY_NUM)          generate  begin    reg [C_DELAY_NUM-2:0] temp_name = 0; always@(posedge clk_in)begin  if(rst_in)temp_name <= {(C_DELAY_NUM-1){1'b0}}; else temp_name <= ~pulsen_in ? {(C_DELAY_NUM-1){1'b1} }: temp_name<<1 ; end  assign  pulsen_out = ~( temp_name[C_DELAY_NUM-2] | ~pulsen_in ) ;  end  endgenerate
`define HANDSHAKE(aclk_in,arst_in,apulse_in,adata_in,bclk_in,brst_in,bpulse_out,bdata_out,DATA_WIDTH,SIM)         generate  if(SIM==0) begin  handshake  #(.DATA_WIDTH(DATA_WIDTH))  handshake_u (.SRC_CLK_I(aclk_in),.SRC_RST_I(arst_in),.SRC_DATA_I( adata_in),.SRC_SYNC_PULSE_I ( apulse_in), .DST_CLK_I ( bclk_in),.DST_DATA_O (bdata_out),.DST_SYNC_FINISH_O(bpulse_out) ); end  else  begin  handshake2 #(.DATA_WIDTH(DATA_WIDTH))  handshake_u (.SRC_CLK_I(aclk_in),.SRC_RST_I(arst_in),.SRC_DATA_I( adata_in),.SRC_SYNC_PULSE_I ( apulse_in), .DST_CLK_I (bclk_in),.DST_DATA_O (bdata_out ),.DST_SYNC_FINISH_O(bpulse_out) ); end  endgenerate   


//系列2：必须放在generate中
`define CDC_MULTI_BIT_SIGNAL_InGen(aclk_in,adata_in,bclk_in,bdata_out,DATA_WIDTH)                    begin xpm_cdc_array_single #(.DEST_SYNC_FF(4),.INIT_SYNC_FF(0),.SIM_ASSERT_CHK(0),.SRC_INPUT_REG(1),.WIDTH(DATA_WIDTH)) cdc_u(.src_clk(aclk_in),.src_in(adata_in),.dest_clk(bclk_in),.dest_out(bdata_out));    end    
`define CDC_SINGLE_BIT_PULSE_InGen(aclk_in,arst_in,apulse_in,bclk_in,brst_in,bpulse_out,SIM)           if(SIM==0)begin  xpm_cdc_pulse #(.DEST_SYNC_FF(4), .INIT_SYNC_FF(0),.REG_OUTPUT(0),.RST_USED(1),.SIM_ASSERT_CHK (0)) cdc_u (.src_clk(aclk_in),.src_rst(arst_in),.src_pulse(apulse_in),.dest_clk(bclk_in),.dest_rst(brst_in),.dest_pulse(bpulse_out));   end else begin   reg [5:0] name1 = 0;wire name2;always@(posedge aclk_in)if(arst_in)name1[0] <=0;else name1[0] <= apulse_in;assign name2 = apulse_in & ~name1[0]; always@(posedge aclk_in)if(arst_in)name1[1] <= 0;else name1[1] <= name2 ? ~name1[1]:name1[1];always@(posedge bclk_in)if(brst_in)name1[5:2]<=0;else begin name1[2]<=name1[1];name1[3]<=name1[2];name1[4]<=name1[3];name1[5]<=name1[4];end  assign bpulse_out=name1[4]^name1[5];  end  
`define NEG_MONITOR_InGen(clk_in,rst_in,in,out)            begin  reg buf_name1 = 0; always@(posedge clk_in)begin if(rst_in)buf_name1 <= 0; else  buf_name1 <= in; end assign out = (buf_name1)&(~in);  end  
`define POS_MONITOR_InGen(clk_in,rst_in,in,out)            begin  reg buf_name1 = 0; always@(posedge clk_in)begin if(rst_in)buf_name1 <= 0; else  buf_name1 <= in; end assign out = (~buf_name1)&(in);  end  
`define POS_STRETCH_InGen(clk_in,rst_in,pulse_in,pulse_out,C_DELAY_NUM)            begin    reg [C_DELAY_NUM-2:0] temp_name = 0; always@(posedge clk_in)begin  if(rst_in)temp_name <= {(C_DELAY_NUM-1){1'b0}}; else temp_name <= pulse_in ? {(C_DELAY_NUM-1){1'b1} }: temp_name<<1 ; end  assign  pulse_out = temp_name[C_DELAY_NUM-2]|pulse_in;  end  
`define HANDSHAKE_InGen(aclk_in,arst_in,apulse_in,adata_in,bclk_in,brst_in,bpulse_out,bdata_out,DATA_WIDTH,SIM)           if(SIM==0) begin  handshake  #(.DATA_WIDTH(DATA_WIDTH))  handshake_u (.SRC_CLK_I(aclk_in),.SRC_RST_I(arst_in),.SRC_DATA_I( adata_in),.SRC_SYNC_PULSE_I ( apulse_in), .DST_CLK_I ( bclk_in),.DST_DATA_O (bdata_out),.DST_SYNC_FINISH_O(bpulse_out) ); end  else  begin  handshake2 #(.DATA_WIDTH(DATA_WIDTH))  handshake_u (.SRC_CLK_I(aclk_in),.SRC_RST_I(arst_in),.SRC_DATA_I( adata_in),.SRC_SYNC_PULSE_I ( apulse_in), .DST_CLK_I (bclk_in),.DST_DATA_O (bdata_out ),.DST_SYNC_FINISH_O(bpulse_out) ); end     

//目的：在失锁或者vs过程中，如果遇到有数据传输，则以假数据退出
//1 拔出（失锁）-->强行退出
//思路： 外部VS和失锁信号让master强行退出， 同时外部的vs延迟后再触发master, 这样可保证每一个vs都能生效

//////////////////////////////////////////////////////////////////////////////////
// Create Date: 2022/09/20 15:22:07
// Company    : phiyo
// Engineer   : yzhu
// Module Name: axi4_master
// 改写的模块
//////////////////////////////////////////////////////////////////////////////////
/*
axi4_master 
   #(.C_M_AXI_BURST_LEN             (C_BURST_LEN    ) , //1, 2, 4, 8, 16, 32, 64, 128, 256
     .C_M_AXI_ADDR_WIDTH            () , // 32 64
     .C_M_AXI_DATA_WIDTH            () , //32 64 128 256
     .C_RD_BLOCK_ENABLE             () , //= 1,
     .C_WR_BLOCK_ENABLE             () , //= 1,
     .C_RD_SIM_ENABLE               () , //= 0,
     .C_WR_SIM_ENABLE               () , //= 0,
     .C_RD_SIM_PATTERN_TYPE         () , //= 0,
     .C_RD_SIM_PATTERN_UNIT_BYTE_NUM() , //= 4,
     .C_RD_NORM_DATA_SOURCE         () , //= 0,
     .C_RD_NORM_DATA_UNIT_BYTE_NUM  () , //= 4,
     .C_RD_ALIGN_ENABLE             () , //= 0,
     .C_RD_BLOCK_ALIGN_BYTE_NUM     () , //= 4096,
     .C_OP_DELAY_CLK_NUM            ()   //= 0  
    )


axi4_master 
   #(.C_M_AXI_BURST_LEN  (16), //1, 2, 4, 8, 16, 32, 64, 128, 256
    .C_M_AXI_ADDR_WIDTH (C_M_AXI4_ADDR_WIDTH), // 32 64
    .C_M_AXI_DATA_WIDTH (C_M_AXI4_DATA_WIDTH), //32 64 128 256
    .C_SIM_ENABLE(C_SIM_ENABLE))
    axi4_master_u(
   .M_AXI_ACLK    (M_AXI_ACLK          ),  
   .M_AXI_ARESETN (M_AXI_ARESETN   ),  
   
   .M_AXI_AWID    (M_AXI_AWID        ), 
   .M_AXI_AWADDR  (M_AXI_AWADDR      ), 
   .M_AXI_AWLEN   (M_AXI_AWLEN       ), 
   .M_AXI_AWSIZE  (M_AXI_AWSIZE      ), 
   .M_AXI_AWBURST (M_AXI_AWBURST     ), 
   .M_AXI_AWLOCK  (M_AXI_AWLOCK      ), 
   .M_AXI_AWCACHE (M_AXI_AWCACHE     ), 
   .M_AXI_AWPROT  (M_AXI_AWPROT      ), 
   .M_AXI_AWQOS   (M_AXI_AWQOS       ), 
   .M_AXI_AWUSER  (M_AXI_AWUSER      ), 
   .M_AXI_AWVALID (M_AXI_AWVALID     ), 
   .M_AXI_AWREADY (M_AXI_AWREADY     ), 
   .M_AXI_WDATA   (M_AXI_WDATA       ), 
   .M_AXI_WSTRB   (M_AXI_WSTRB       ), 
   .M_AXI_WLAST   (M_AXI_WLAST       ), 
   .M_AXI_WUSER   (M_AXI_WUSER       ), 
   .M_AXI_WVALID  (M_AXI_WVALID      ), 
   .M_AXI_WREADY  (M_AXI_WREADY      ), 
   .M_AXI_BID     (M_AXI_BID         ), 
   .M_AXI_BRESP   (M_AXI_BRESP       ), 
   .M_AXI_BUSER   (M_AXI_BUSER       ), 
   .M_AXI_BVALID  (M_AXI_BVALID      ), 
   .M_AXI_BREADY  (M_AXI_BREADY      ), 
   .M_AXI_ARID    (M_AXI_ARID        ), 
   .M_AXI_ARADDR  (M_AXI_ARADDR      ), 
   .M_AXI_ARLEN   (M_AXI_ARLEN       ), 
   .M_AXI_ARSIZE  (M_AXI_ARSIZE      ), 
   .M_AXI_ARBURST (M_AXI_ARBURST     ), 
   .M_AXI_ARLOCK  (M_AXI_ARLOCK      ), 
   .M_AXI_ARCACHE (M_AXI_ARCACHE     ), 
   .M_AXI_ARPROT  (M_AXI_ARPROT      ), 
   .M_AXI_ARQOS   (M_AXI_ARQOS       ), 
   .M_AXI_ARUSER  (M_AXI_ARUSER      ), 
   .M_AXI_ARVALID (M_AXI_ARVALID     ), 
   .M_AXI_ARREADY (M_AXI_ARREADY     ), 
   .M_AXI_RID     (M_AXI_RID         ), 
   .M_AXI_RDATA   (M_AXI_RDATA       ), 
   .M_AXI_RRESP   (M_AXI_RRESP       ), 
   .M_AXI_RLAST   (M_AXI_RLAST       ), 
   .M_AXI_RUSER   (M_AXI_RUSER       ), 
   .M_AXI_RVALID  (M_AXI_RVALID      ), 
   .M_AXI_RREADY  (M_AXI_RREADY      ), 
    
   .W_RST_I       (),
   .W_REQ_I       (wr_trig_axi4_f   ),
   .W_START_ADDR_I(wr_addr_axi4_f    ), 
   .W_BYTE_NUM_I  (wr_size_axi4_f    ), 

   .W_FIFO_RD_DATA_COUNT_I(  ),
   
   .W_FIFO_EMPTY_I(fifo_rd_empty_2  ),
   .W_FIFO_READ_O (fifo_rd_en_2     ),
   .W_FIFO_DATA_I (fifo_rd_data_2   ), 
   .W_DONE_O      (wr_done_axi4    ),
   .W_FINISH_O    (  ),
   .W_BUSY_O      (  ),
   .W_STOP_I      (  ),
   .W_BEATS_O     (  ),
   .W_BURSTS_O    (  ),
   .W_NEW_BYTE_NUM_I(  ),
   .W_NEW_BYTE_NUM_UPDATE_I(  ),
    
   .R_RST_I       (),
   .R_REQ_I       (rd_trig_axi4   ),
   .R_START_ADDR_I(rd_addr_axi4    ), 
   .R_BYTE_NUM_I  (rd_size_axi4    ), 
   .R_SUSPEND_I      (0),
   .R_SUSPEND_I      (0),
  
   .R_FIFO_FULL_I (fifo_wr_full_2   ), 
   .R_FIFO_WRITE_O(fifo_wr_en_2     ), 
   .R_FIFO_DATA_O (fifo_wr_data_2   ), 
   .R_DONE_O      (rd_done_axi4     ), 
   .R_FINISH_O    (  ),
   .R_BUSY_O      (  ),
   .R_STOP_I      (  ),
   .R_BEATS_O     (  ),
    .R_BURSTS_O   (  )
    
    
    
   );



parameter integer C_M_AXI_ADDR_WIDTH    = 32, // 32 64
parameter integer C_M_AXI_DATA_WIDTH    = 32, //32 64 128 256
localparam integer C_M_AXI_ID_WIDTH       = 4,
localparam integer C_M_AXI_AWUSER_WIDTH   = 1,
localparam integer C_M_AXI_ARUSER_WIDTH   = 1,
localparam integer C_M_AXI_WUSER_WIDTH    = 1,
localparam integer C_M_AXI_RUSER_WIDTH    = 1,
localparam integer C_M_AXI_BUSER_WIDTH    = 1,



input                                 M_AXI_ACLK      ,        //    input      M_AXI_ACLK,                                 // Global Clock Signal.    
input                                 M_AXI_ARESETN   ,        //    input     M_AXI_ARESETN,                              // Global Reset Singal. This Signal is Active Low
output    [C_M_AXI_ID_WIDTH-1 : 0]    M_AXI_AWID      ,        //    output    [C_M_AXI_ID_WIDTH-1 : 0]     Master Interface Write Address ID
output    [C_AXI4_ADDR_WIDTH-1 : 0]    M_AXI_AWADDR    ,        //    output    [C_M_AXI_ADDR_WIDTH-1 : 0]   Master Interface Write Address
output    [7 : 0]                     M_AXI_AWLEN     ,        //    output    [7 : 0]                      The burst length gives the exact number of transfers in a burst
output    [2 : 0]                     M_AXI_AWSIZE    ,        //    output    [2 : 0]                      This signal indicates the size of each transfer in the burst
output    [1 : 0]                     M_AXI_AWBURST   ,        //    output    [1 : 0]                      determine how the address for each transfer within the burst is calculated.
output                                M_AXI_AWLOCK    ,        //    output                                 Provides additional information about the atomic characteristics of the transfer.
output    [3 : 0]                     M_AXI_AWCACHE   ,        //    output    [3 : 0]                      This signal indicates how transactions are required to progress through a system.
output    [2 : 0]                     M_AXI_AWPROT    ,        //    output    [2 : 0]                      Protection type. 
output    [3 : 0]                     M_AXI_AWQOS     ,        //    output    [3 : 0]                      Quality of Service, QoS identifier sent for each write transaction.
output    [C_M_AXI_AWUSER_WIDTH-1 : 0]M_AXI_AWUSER    ,        //    output    [C_M_AXI_AWUSER_WIDTH-1 : 0] Optional User-defined signal in the write address channel.
output                                M_AXI_AWVALID   ,        //    output                                 Write address valid. 
input                                 M_AXI_AWREADY   ,        //    input                                  Write address ready.
output    [C_AXI4_DATA_WIDTH-1 : 0]    M_AXI_WDATA     ,        //    output    [C_M_AXI_DATA_WIDTH-1 : 0]   Master Interface Write Data.
output    [C_AXI4_DATA_WIDTH/8-1 : 0]  M_AXI_WSTRB     ,        //    output    [C_M_AXI_DATA_WIDTH/8-1 : 0] Write strobes. 
output                                M_AXI_WLAST     ,        //    output                                 Write last. 
output    [C_M_AXI_WUSER_WIDTH-1 : 0] M_AXI_WUSER     ,        //    output    [C_M_AXI_WUSER_WIDTH-1 : 0]  Optional User-defined signal in the write data channel.
output                                M_AXI_WVALID    ,        //    output                                 Write valid.
input                                 M_AXI_WREADY    ,        //    input                                  Write ready. 
input    [C_M_AXI_ID_WIDTH-1 : 0]     M_AXI_BID       ,        //    input    [C_M_AXI_ID_WIDTH-1 : 0]      Master Interface Write Response.
input    [1 : 0]                      M_AXI_BRESP     ,        //    input    [1 : 0]                       Write response. 
input    [C_M_AXI_BUSER_WIDTH-1 : 0]  M_AXI_BUSER     ,        //    input    [C_M_AXI_BUSER_WIDTH-1 : 0]   Optional User-defined signal in the write response channel
input                                 M_AXI_BVALID    ,        //    input                                  Write response valid. 
output                                M_AXI_BREADY    ,        //    output                                 Response ready. 
output    [C_M_AXI_ID_WIDTH-1 : 0]    M_AXI_ARID      ,        //    output    [C_M_AXI_ID_WIDTH-1 : 0]     Master Interface Read Address.
output    [C_AXI4_ADDR_WIDTH-1 : 0]    M_AXI_ARADDR    ,        //    output    [C_M_AXI_ADDR_WIDTH-1 : 0]   Read address. 
output   [7 : 0]                      M_AXI_ARLEN     ,        //    output   [7 : 0]                       Burst length. 
output    [2 : 0]                     M_AXI_ARSIZE    ,        //    output    [2 : 0]                      Burst size. 
output    [1 : 0]                     M_AXI_ARBURST   ,        //    output    [1 : 0]                      Burst type. 
output                                M_AXI_ARLOCK    ,        //    output                                 Lock type. 
output    [3 : 0]                     M_AXI_ARCACHE   ,        //    output    [3 : 0]                      Memory type. 
output    [2 : 0]                     M_AXI_ARPROT    ,        //    output    [2 : 0]                      Protection type. 
output    [3 : 0]                     M_AXI_ARQOS     ,        //    output    [3 : 0]                      Quality of Service
output    [C_M_AXI_ARUSER_WIDTH-1 : 0]M_AXI_ARUSER    ,        //    output    [C_M_AXI_ARUSER_WIDTH-1 : 0] Optional User-defined signal in the read address channel.
output                                M_AXI_ARVALID   ,        //    output                                 Write address valid. 
input                                 M_AXI_ARREADY   ,        //    input                                  Read address ready. 
input    [C_M_AXI_ID_WIDTH-1 : 0]     M_AXI_RID       ,        //    input    [C_M_AXI_ID_WIDTH-1 : 0]      Read ID tag. 
input    [C_AXI4_DATA_WIDTH-1 : 0]     M_AXI_RDATA     ,        //    input    [C_M_AXI_DATA_WIDTH-1 : 0]    Master Read Data
input    [1 : 0]                      M_AXI_RRESP     ,        //    input    [1 : 0]                       Read response. 
input                                 M_AXI_RLAST     ,        //    input                                  Read last. 
input    [C_M_AXI_RUSER_WIDTH-1 : 0]  M_AXI_RUSER     ,        //    input    [C_M_AXI_RUSER_WIDTH-1 : 0]   Optional User-defined signal in the read address channel.
input                                 M_AXI_RVALID    ,        //    input                                  Read valid. 
output                                M_AXI_RREADY    ,        //    output                                 Read ready.

*/

/*resource estimate
  total function : LUT 490 , FF 253
  total sim      : LUT 238 , FF 137
  total shutdown : LUT   0 , FF   0
  only  RD sim   : LUT 120 , FF  82
  only  RD sim   : LUT 116 , FF  55
  only  RD func  : LUT 197 , FF 146
  only  RD func  : LUT 256 , FF 111
  
*/


//vs      _____|————————|____________________________________
//locked ____|——————————————————————————————————|___________
//frm_trig _____________|-|_____________
//效果：无论哪种异常信号来了边沿，burst都会退出，然后必须等下一次触发



module axi4_master #
(    
    parameter C_WR_FIFO_RD_MODE = "fwft"   , // "std" "fwft"
    parameter integer C_M_AXI_BURST_LEN        = 16, //1, 2, 4, 8, 16, 32, 64, 128, 256
    parameter integer C_M_AXI_ADDR_WIDTH       = 32, 
    parameter integer C_M_AXI_DATA_WIDTH       = 256, 
    ////////////////////////////////////////////////////////////////////////
    localparam integer C_M_AXI_ID_WIDTH        = 4,
    localparam integer C_M_AXI_AWUSER_WIDTH    = 1,
    localparam integer C_M_AXI_ARUSER_WIDTH    = 1,
    localparam integer C_M_AXI_WUSER_WIDTH     = 1,
    localparam integer C_M_AXI_RUSER_WIDTH     = 1,
    localparam integer C_M_AXI_BUSER_WIDTH     = 1,
    //////////////////////////////////////////////////////////////////////
    parameter  [0:0] C_RD_BLOCK_ENABLE         = 1,
    parameter  [0:0] C_WR_BLOCK_ENABLE         = 1,
    //////////////////////////////////////////////////////////////////////
    parameter  [0:0] C_RD_SIM_ENABLE           = 0,
    parameter  [0:0] C_WR_SIM_ENABLE           = 0,
    parameter  C_RD_SIM_PATTERN_TYPE           = 0,
    parameter  C_RD_SIM_PATTERN_UNIT_BYTE_NUM  = 4,
    parameter  C_RD_NORM_DATA_SOURCE           = 0,
    parameter  C_RD_NORM_DATA_UNIT_BYTE_NUM    = 4,
    
    parameter  C_WR_NORM_DATA_SOURCE           = 0,
    parameter  C_WR_NORM_DATA_UNIT_BYTE_NUM    = 4,
    
    parameter  [0:0] C_RD_ALIGN_ENABLE         = 0,
    parameter  C_RD_BLOCK_ALIGN_BYTE_NUM       = 4096,
    parameter        C_OP_DELAY_CLK_NUM        = 0  // >= 0
    
)
(
    
input wire  M_AXI_ACLK,                                 // Global Clock Signal.    
input wire  M_AXI_ARESETN,                              // Global Reset Singal. This Signal is Active Low

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
output wire [C_M_AXI_ID_WIDTH-1 : 0]   M_AXI_AWID,      // Master Interface Write Address ID
output reg [C_M_AXI_ADDR_WIDTH-1 : 0] M_AXI_AWADDR,    // Master Interface Write Address
output reg  [7 : 0]                    M_AXI_AWLEN,     // The burst length gives the exact number of transfers in a burst
output wire [2 : 0]                    M_AXI_AWSIZE,    // This signal indicates the size of each transfer in the burst
output wire [1 : 0]                    M_AXI_AWBURST,   // determine how the address for each transfer within the burst is calculated.
output wire  M_AXI_AWLOCK,                              // Provides additional information about the atomic characteristics of the transfer.
output wire [3 : 0] M_AXI_AWCACHE,                      // This signal indicates how transactions are required to progress through a system.
output wire [2 : 0] M_AXI_AWPROT,                       // Protection type. 
output wire [3 : 0] M_AXI_AWQOS,                        // Quality of Service, QoS identifier sent for each write transaction.
output wire [C_M_AXI_AWUSER_WIDTH-1 : 0] M_AXI_AWUSER,  // Optional User-defined signal in the write address channel.
output reg  M_AXI_AWVALID,                             // Write address valid. 
input wire  M_AXI_AWREADY,                              // Write address ready.
output wire [C_M_AXI_DATA_WIDTH-1 : 0] M_AXI_WDATA,     // Master Interface Write Data.
output reg [C_M_AXI_DATA_WIDTH/8-1 : 0] M_AXI_WSTRB,   // Write strobes. 
output wire  M_AXI_WLAST,                               // Write last. 
output wire [C_M_AXI_WUSER_WIDTH-1 : 0] M_AXI_WUSER,    // Optional User-defined signal in the write data channel.
output wire  M_AXI_WVALID,                              // Write valid.
input wire  M_AXI_WREADY,                               // Write ready. 
input wire [C_M_AXI_ID_WIDTH-1 : 0] M_AXI_BID,          // Master Interface Write Response.
input wire [1 : 0] M_AXI_BRESP,                         // Write response. 
input wire [C_M_AXI_BUSER_WIDTH-1 : 0] M_AXI_BUSER,     // Optional User-defined signal in the write response channel
input wire  M_AXI_BVALID,                               // Write response valid. 
output reg  M_AXI_BREADY,                              // Response ready. 

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
output wire [C_M_AXI_ID_WIDTH-1 : 0] M_AXI_ARID,        // Master Interface Read Address.
output reg [C_M_AXI_ADDR_WIDTH-1 : 0] M_AXI_ARADDR,    // Read address. 
output reg [7 : 0] M_AXI_ARLEN,                         // Burst length. 
output wire [2 : 0] M_AXI_ARSIZE,                       // Burst size. 
output wire [1 : 0] M_AXI_ARBURST,                      // Burst type. 
output wire  M_AXI_ARLOCK,                              // Lock type. 
output wire [3 : 0] M_AXI_ARCACHE,                      // Memory type. 
output wire [2 : 0] M_AXI_ARPROT,                       // Protection type. 
output wire [3 : 0] M_AXI_ARQOS,                        // Quality of Service
output wire [C_M_AXI_ARUSER_WIDTH-1 : 0] M_AXI_ARUSER,  // Optional User-defined signal in the read address channel.
output reg   M_AXI_ARVALID,                             // Write address valid. 
input wire  M_AXI_ARREADY,                              // Read address ready. 
input wire [C_M_AXI_ID_WIDTH-1 : 0] M_AXI_RID,          // Read ID tag. 
input wire [C_M_AXI_DATA_WIDTH-1 : 0] M_AXI_RDATA,      // Master Read Data
input wire [1 : 0] M_AXI_RRESP,                         // Read response. 
input wire  M_AXI_RLAST,                                // Read last. 
input wire [C_M_AXI_RUSER_WIDTH-1 : 0] M_AXI_RUSER,     // Optional User-defined signal in the read address channel.
input wire  M_AXI_RVALID,                               // Read valid. 
output wire  M_AXI_RREADY,                              // Read ready.

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////     
//USER WRITE CHANNEL 
input  W_RST_I,
input  W_REQ_I,//signal __|————————————— inner monitor pos
input  [C_M_AXI_ADDR_WIDTH-1:0] W_START_ADDR_I,
input  [31:0] W_BYTE_NUM_I,
input  W_FIFO_EMPTY_I,//need be true FIFO empty signal (must not be prog empty)
input  [31:0] W_FIFO_RD_DATA_COUNT_I ,
output W_FIFO_READ_O,
input  [C_M_AXI_DATA_WIDTH-1:0] W_FIFO_DATA_I,
output  W_DONE_O,  //signal __|————————————— 真实完成 或 STOP_I 触发完成
output  W_FINISH_O,//pulse  __|——|__________
output  W_BUSY_O,  //signal ——|_____________
input   W_STOP_I,  //pulse _|—|_____ 结束本轮burst后即结束(不同于RST,RST是立刻中途结束) //只对normal模式有效
                   //W_STOP_I 只会在第二个burst时阻止, W_REQ_I比W_STOP_I优先级高
				   //注意：之前版本会读剩余数据，但是本版本会给fifo_empty 强制拉为0，因为假定外部数据会中断
//input   W_EXIT_BURST_I,  //__|——————————|__ 以人造数据退出当前burst 	   
output [31:0] W_BEATS_O,//只对normal模式有效
output [31:0] W_BURSTS_O,//只对normal模式有效
input  [31:0] W_NEW_BYTE_NUM_I,
input         W_NEW_BYTE_NUM_UPDATE_I,  //inner check pos ; 都是直接打断原来的操作，不会计算新的strobe


//USER READ CHANNEL
input  R_RST_I,
input  R_REQ_I,
input  [C_M_AXI_ADDR_WIDTH-1:0] R_START_ADDR_I,
input  [31:0] R_BYTE_NUM_I,
// R_FIFO_FULL_I 可能充当了 burst ready信号
input  R_FIFO_FULL_I,//can be true FIFO full signal  OR  prog  full signal(maintain one burst space)
output R_FIFO_WRITE_O,// read burst 退出后，会假定外部fifo失效，于是会强行输出( 2024年1月24日 做了屏蔽 )（代码里的标志位改了）
                      //相当于把 R_FIFO_FULL_I 改了
output [C_M_AXI_DATA_WIDTH-1:0] R_FIFO_DATA_O,
input  [31:0] R_FIFO_WR_DATA_COUNT_I , //对于写入fifo来说，其实不用判断数量
output R_DONE_O, //__|——————————————————
output R_FINISH_O,//__|——|__________
output R_BUSY_O ,
input  R_STOP_I, //只对normal模式有效 , 本轮burst完成后即退出(当然要保证一轮burst的完整)
//注意：如果中途结束，那么读时候的对齐就没有意义了
//读取的中途burst不存在打断，因为ddr中数据是始终存在的
//需要做的是，收到信号后，完成当前burst，然后退出整个trig
output [31:0] R_BEATS_O,//只对normal模式有效
output [31:0] R_BURSTS_O,//只对normal模式有效

input  R_INNER_DATA_RST_I , 

//DEBUG
output [7:0] DEBUG_W_STATE ,
output [7:0] DEBUG_R_STATE ,
output       DEBUG_W_MISSTEP ,
output       DEBUG_R_MISSTEP 


);

localparam integer C_TRANSACTIONS_NUM = clogb2(C_M_AXI_BURST_LEN-1);
localparam integer C_MASTER_LENGTH    = 12;
localparam integer C_NO_BURSTS_REQ = C_MASTER_LENGTH-clogb2((C_M_AXI_BURST_LEN*C_M_AXI_DATA_WIDTH/8)-1);


assign M_AXI_AWID      = 0;
assign M_AXI_AWSIZE    = clogb2((C_M_AXI_DATA_WIDTH/8)-1); //note: checked
assign M_AXI_AWBURST   = 2'b01;
assign M_AXI_AWLOCK    = 0;
assign M_AXI_AWCACHE   = 4'b0010;
assign M_AXI_AWPROT    = 3'h0;
assign M_AXI_AWQOS     = 4'h0;
assign M_AXI_AWUSER    = 1;
assign M_AXI_WUSER     = 0;
assign M_AXI_ARID      = 0;
assign M_AXI_ARSIZE    = clogb2((C_M_AXI_DATA_WIDTH/8)-1); //note: checked
assign M_AXI_ARBURST   = 2'b01;
assign M_AXI_ARLOCK    = 0;
assign M_AXI_ARCACHE   = 4'b0010;
assign M_AXI_ARPROT    = 3'h0;
assign M_AXI_ARQOS     = 4'h0;
assign M_AXI_ARUSER    = 1  ;


genvar i,j,k;


function integer clogb2 (input integer bit_depth);              
    begin                                                           
        for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                   
            bit_depth = bit_depth >> 1;                                 
    end                                                           
endfunction 



wire W_REQ_I_pos;
wire R_REQ_I_pos;
reg [7:0]  r_state = 0;
reg [7:0]  w_state = 0;
reg [7:0] w_byte_num_last_transfer = 0;
wire w_req_valid;
wire r_req_valid;



assign DEBUG_W_STATE   = w_state;
assign DEBUG_R_STATE   = r_state;
assign DEBUG_W_MISSTEP = W_REQ_I_pos & (w_state!=0) ;
assign DEBUG_R_MISSTEP = R_REQ_I_pos & (w_state!=0) ;
assign w_req_valid = W_REQ_I_pos & (W_BYTE_NUM_I >0);
assign r_req_valid = R_REQ_I_pos & (R_BYTE_NUM_I >0);

`POS_MONITOR(M_AXI_ACLK,0,W_REQ_I,W_REQ_I_pos) 
`POS_MONITOR(M_AXI_ACLK,0,R_REQ_I,R_REQ_I_pos) 



generate if(C_WR_SIM_ENABLE==0) begin : wr_normal  ///////////////////////////////////////////////////// wr normal //////////////////////////////////////////////////////////////
// W_REQ_I  ___|—|______
// burst    _____|—|_________________|—|_
// 赋全局   _____\\________
// ...
// 握手valid       |——
// 对端ready          |———
// rvalidb ________|————————————|____
// notempty _________|———————————————
// WVALID  __________|——————————|____
// WREADY  ____________|—————————————
// fifo_rd ____________|————————|____
// LAST    ___________________|—|____
// 调整    _____________________\\___
// 地址握手 和 数据握手 独立

reg [7:0] ii;
wire W_FIFO_READ_O;
reg  W_DONE_O_r = 0;
reg  W_FINISH_O = 0;
reg  W_BUSY_O_r = 0;
wire w_stop_pos;
reg  w_stop_rst = 0;
reg [31:0] w_target_beat_num;
wire w_byte_num_update_pos;
reg  w_stop_reg = 0;
reg        w_start_burst = 0;
reg [31:0] w_cnt_per_burst = 0;
reg [31:0] w_cnt_beat_left__all = 0;
wire       w_transmiter ;
reg [15:0] w_cnt_op_delay = 0;
reg M_AXI_WVALID_b1 = 0;
reg [31:0] w_beat_num_al = 0;
reg [31:0] w_burst_num_al = 0;
wire [C_M_AXI_DATA_WIDTH/8-1 : 0] wr_last_strb;  


always@(posedge M_AXI_ACLK)begin 
    if( ~M_AXI_ARESETN | ~C_WR_BLOCK_ENABLE | W_RST_I  |  W_STOP_I )begin
        for(ii=0;ii<=C_SLICE_NUM-1;ii=ii+1)begin 
            w_fifo_data_m[ii] <= ii;
            
        end
    end
    else if(W_FIFO_READ_O)begin
        for(ii=0;ii<=C_SLICE_NUM-1;ii=ii+1)begin
            w_fifo_data_m[ii] <= w_fifo_data_m[ii] + C_SLICE_NUM;
        end
    end
end


//assign M_AXI_WDATA = W_FIFO_DATA_I;
localparam C_SLICE_NUM = C_M_AXI_DATA_WIDTH/8/C_WR_NORM_DATA_UNIT_BYTE_NUM;
reg  [C_WR_NORM_DATA_UNIT_BYTE_NUM*8-1:0] w_fifo_data_m [C_SLICE_NUM-1:0];
wire [C_M_AXI_DATA_WIDTH-1:0] w_fifo_data_o;
`BI_TO_SINGLE_Nm1To0((C_WR_NORM_DATA_UNIT_BYTE_NUM*8),C_SLICE_NUM,w_fifo_data_m,w_fifo_data_o)
if(C_WR_NORM_DATA_SOURCE==0)      assign M_AXI_WDATA =  W_FIFO_DATA_I ;
else if(C_WR_NORM_DATA_SOURCE==1) assign M_AXI_WDATA =  w_fifo_data_o ;
else if(C_WR_NORM_DATA_SOURCE==2) assign M_AXI_WDATA =  {512{1'b1}}   ;
else if(C_WR_NORM_DATA_SOURCE==3) assign M_AXI_WDATA =  {64{8'haa}}   ;
else assign M_AXI_WDATA = W_FIFO_DATA_I ;



for(i=0;i<=(C_M_AXI_DATA_WIDTH/8-1);i=i+1)begin
    assign wr_last_strb[i] = w_byte_num_last_transfer==0 ? 1'b1 : ( i+1 > w_byte_num_last_transfer ) ? 1'b0 : 1'b1 ;
end


`POS_MONITOR_InGen(M_AXI_ACLK,(~M_AXI_ARESETN),W_NEW_BYTE_NUM_UPDATE_I,w_byte_num_update_pos)

always@(posedge M_AXI_ACLK)begin
    if(~M_AXI_ARESETN | ~C_WR_BLOCK_ENABLE )begin
        w_target_beat_num  <= 0;
    end
    else if( (w_state==0 & w_req_valid ) )begin
        w_target_beat_num <= W_BYTE_NUM_I/(C_M_AXI_DATA_WIDTH/8) + (( W_BYTE_NUM_I & {0,{(C_M_AXI_DATA_WIDTH/8)-1}} ) != 0) ;
    end
    else if(w_byte_num_update_pos)begin
        w_target_beat_num <= W_NEW_BYTE_NUM_I/(C_M_AXI_DATA_WIDTH/8)  +  (( W_NEW_BYTE_NUM_I & {0,{(C_M_AXI_DATA_WIDTH/8)-1}} ) != 0) ;
    end
end


`POS_MONITOR_InGen(M_AXI_ACLK,(~M_AXI_ARESETN),W_STOP_I,w_stop_pos)

always@(posedge M_AXI_ACLK)begin
    if(~M_AXI_ARESETN| ~C_WR_BLOCK_ENABLE | W_RST_I )begin
        w_stop_reg <= 0;
    end
    else begin
        w_stop_reg <= w_stop_pos ? 1 : w_stop_rst ? 0 : w_stop_reg;
    end
end



always@(posedge M_AXI_ACLK)begin 
    if (~M_AXI_ARESETN | ~C_WR_BLOCK_ENABLE | W_RST_I ) begin 
        M_AXI_AWVALID <= 0; 
    end 
    else if (~M_AXI_AWVALID && w_start_burst) begin 
        M_AXI_AWVALID <= 1; 
    end 
    else if (M_AXI_AWREADY && M_AXI_AWVALID) begin 
        M_AXI_AWVALID <= 0; 
    end 
end
 

always @(posedge M_AXI_ACLK)begin                                                                             
    if (~M_AXI_ARESETN | ~C_WR_BLOCK_ENABLE | W_RST_I )begin                                                                         
        M_AXI_WVALID_b1 <= 0;                                                         
    end                                                                            
    else if(M_AXI_AWREADY && M_AXI_AWVALID)begin 
        M_AXI_WVALID_b1 <= 1;  //execute data handshake after addr handshake
    end
    else if (M_AXI_WLAST & M_AXI_WREADY) begin                                       
        M_AXI_WVALID_b1 <= 0;   
    end
end       


always @(posedge M_AXI_ACLK) begin                                                                 
    if ( ~M_AXI_ARESETN  | ~C_WR_BLOCK_ENABLE | W_RST_I ) begin                                                         
        M_AXI_BREADY <= 0;                                             
    end                                                                                    
    else if (M_AXI_BVALID && ~M_AXI_BREADY) begin                                                             
        M_AXI_BREADY <= 1;                                             
    end                                                               
    else if (M_AXI_BREADY)begin                                                             
        M_AXI_BREADY <= 0;                                             
    end                                 
end  


assign M_AXI_WLAST =  M_AXI_WVALID & ( w_cnt_per_burst == M_AXI_AWLEN );

//assign M_AXI_WVALID = ( M_AXI_WVALID_b1 & ~W_FIFO_EMPTY_I ) ; 

assign M_AXI_WVALID = ( M_AXI_WVALID_b1 & (~W_FIFO_EMPTY_I | w_stop_reg  ) ) ; //yzhu


assign W_FIFO_READ_O =  C_WR_FIFO_RD_MODE=="fwft" ? (M_AXI_WVALID & M_AXI_WREADY) :  
                         ( w_start_burst | w_transmiter) & (w_cnt_transmiter != M_AXI_AWLEN) 
                        ; //如果为std模式，则需要先读一次，并【取消】最后一次读


assign w_transmiter =   M_AXI_WVALID & M_AXI_WREADY;

reg [8:0] w_cnt_transmiter ;
always @(posedge M_AXI_ACLK)begin
    if( (~M_AXI_ARESETN) | w_start_burst ) begin
        w_cnt_transmiter <= 0;
    end
    else begin
        w_cnt_transmiter <= w_transmiter ? w_cnt_transmiter + 1 :w_cnt_transmiter;    
    end
end



always@(posedge M_AXI_ACLK)begin
    if( ~C_WR_BLOCK_ENABLE | ~M_AXI_ARESETN | W_RST_I )begin
        w_state        <= 0;
        w_start_burst  <= 0;
        w_cnt_beat_left__all <= 0;
        M_AXI_AWADDR <= 0;
        M_AXI_AWLEN  <= C_M_AXI_BURST_LEN - 1;
        w_cnt_per_burst <= 0;
        W_DONE_O_r <= 0;
        W_BUSY_O_r <= 0;
        W_FINISH_O <= 0;
        M_AXI_WSTRB   <= {(C_M_AXI_DATA_WIDTH/8){1'b1}};
        w_byte_num_last_transfer <= 0;
        w_stop_rst <= 0;
        w_beat_num_al <= 0;
        w_burst_num_al <= 0;
        w_cnt_op_delay <= C_OP_DELAY_CLK_NUM;
    end
    else begin
        case(w_state)
            0:begin
                w_cnt_op_delay <= C_OP_DELAY_CLK_NUM;
                W_FINISH_O   <= 0;
                W_DONE_O_r   <= w_req_valid ? 0 : W_DONE_O_r;
                W_BUSY_O_r   <= w_req_valid ? 1 : 0;
                w_stop_rst   <= 1;
                if( w_req_valid )begin
                  w_cnt_beat_left__all <=  W_BYTE_NUM_I/(C_M_AXI_DATA_WIDTH/8)  +  (( W_BYTE_NUM_I & {0,{(C_M_AXI_DATA_WIDTH/8)-1}} ) != 0); 
                  w_byte_num_last_transfer <=  ( W_BYTE_NUM_I & {0,{(C_M_AXI_DATA_WIDTH/8)-1}} ) ;// align when w_byte_num_last_transfer == 0
                  M_AXI_AWADDR <= W_START_ADDR_I;
                  w_state <= 10;
                  w_beat_num_al <= 0;
                  w_burst_num_al <= 0;
                end
            end
            //op delay
            10:begin
                w_state        <= w_cnt_op_delay==0 ? 11 : w_state;
                w_cnt_op_delay    <= w_cnt_op_delay>0  ? w_cnt_op_delay - 1 : 0;
            end
            11:begin // judge fifo rd data count
                if(w_stop_reg)begin
                    w_cnt_beat_left__all <= 0;
                    w_start_burst <= 0;
                    w_cnt_per_burst <= 0;
                    w_state <= 0; 
                    W_DONE_O_r <= 1; 
                    W_FINISH_O <= 1;
                    W_BUSY_O_r <= 0; 
                end
                else if(w_cnt_beat_left__all <= C_M_AXI_BURST_LEN)begin
                    w_start_burst <= W_FIFO_RD_DATA_COUNT_I >= w_cnt_beat_left__all ? 1: 0; //就算数据空了，还是可以拉数据
                    w_state       <= W_FIFO_RD_DATA_COUNT_I >= w_cnt_beat_left__all ? 1: w_state;
                end
                else begin
                    w_start_burst <= W_FIFO_RD_DATA_COUNT_I>=C_M_AXI_BURST_LEN ? 1 : 0;
                    w_state       <= W_FIFO_RD_DATA_COUNT_I >= C_M_AXI_BURST_LEN ? 1: w_state;
                end
            end
            1:begin
                    w_stop_rst <= 0;
                    w_start_burst <= 0;
					
                    if(w_cnt_beat_left__all <= C_M_AXI_BURST_LEN)begin//结算后
                        M_AXI_AWLEN <= w_cnt_beat_left__all - 1;
                    end
                    else begin
                        M_AXI_AWLEN <= C_M_AXI_BURST_LEN - 1;
                    end
					
					
                    if(M_AXI_AWVALID & M_AXI_AWREADY)begin
                        w_state <= 2;
                    end
					
					
                    if(w_cnt_beat_left__all==1 )begin
                        M_AXI_WSTRB <=  wr_last_strb;
                    end
                    else begin
                        M_AXI_WSTRB <= {(C_M_AXI_DATA_WIDTH/8){1'b1}};
                    end
					
            end
            2:begin//一次 burst 传输
                if(w_transmiter)begin 
                    if((w_cnt_per_burst == M_AXI_AWLEN-1) & (w_cnt_beat_left__all<=C_M_AXI_BURST_LEN) )begin //last beat of last burst 
                        M_AXI_WSTRB <=  wr_last_strb;
                    end
                    else begin
                        M_AXI_WSTRB <= {(C_M_AXI_DATA_WIDTH/8){1'b1}};
                    end
                end
            
                if(w_transmiter)begin // support one  transfer ; control transfer num
                    if(w_cnt_per_burst == M_AXI_AWLEN )begin
                        w_state <= 3;
                        w_cnt_per_burst <= 0;
                        w_burst_num_al <= w_burst_num_al + 1;
                    end
                    else begin
                        w_cnt_per_burst <= w_cnt_per_burst + 1;
                    end
                end
                
                if(w_transmiter)begin //count beat num
                    w_beat_num_al <= w_beat_num_al + 1;
                end
            end
            3:begin//结算
                M_AXI_AWADDR <= M_AXI_AWADDR + C_M_AXI_BURST_LEN * (C_M_AXI_DATA_WIDTH/8);
                if(w_cnt_beat_left__all <= C_M_AXI_BURST_LEN)begin// OVER
                    w_cnt_beat_left__all <= 0;
                    w_cnt_per_burst <= 0;
                    W_DONE_O_r <= 1;
                    W_FINISH_O <= 1;
                    W_BUSY_O_r <= 0; 
                    w_state <= 0;
                end
                else if(~w_stop_reg & w_target_beat_num>w_beat_num_al )begin //not stop
                    w_cnt_beat_left__all <= w_cnt_beat_left__all - C_M_AXI_BURST_LEN;
                    w_cnt_per_burst <= 0;
                    w_state <= 11; 
                end
                else begin //if stop ,return to idle
                    w_cnt_beat_left__all <= 0;
                    w_start_burst <= 0;
                    w_cnt_per_burst <= 0;
                    w_state <= 0; 
                    W_DONE_O_r <= 1; 
                    W_FINISH_O <= 1;
                    W_BUSY_O_r <= 0; 
                end
            end
            default:begin
                w_state        <= 0;
                w_start_burst       <= 0;
                w_cnt_beat_left__all <= 0;
                M_AXI_AWADDR <= 0;
                M_AXI_AWLEN <= C_M_AXI_BURST_LEN - 1;
                w_cnt_per_burst <= 0;
                W_DONE_O_r <= 0;
                W_BUSY_O_r <= 0;
                W_FINISH_O <= 0;
                M_AXI_WSTRB   <= {(C_M_AXI_DATA_WIDTH/8){1'b1}};
                w_byte_num_last_transfer <= 0;
                w_stop_rst <= 0;
                w_beat_num_al <= 0;
                w_burst_num_al <= 0;
                w_cnt_op_delay <= C_OP_DELAY_CLK_NUM;
            end
        endcase
    end
end

                                                                 
                                                                      
end

else begin : wr_sim            ////////////////////////////////////////////////////////////// wr sim //////////////////////////////////////////////////////////////
reg [31:0] w_target_beat_num;
wire w_byte_num_update_pos;
wire w_stop_pos;
reg  w_stop_rst = 0;
reg [31:0] w_beat_num_al;
reg [31:0] w_burst_num_al;
reg W_FIFO_READ_O = 0;
reg W_DONE_O_r = 0;
reg W_BUSY_O_r = 0;
reg W_FINISH_O = 0;
reg [15:0] w_aux_idf1= 0 ;
reg [15:0] w_cnt_first_delay = 0;
reg [31:0] w_cnt_beat_left_all = 0;
reg [31:0] w_cnt_per_burst;
reg  w_stop_reg = 0;


`POS_MONITOR_InGen(M_AXI_ACLK,(~M_AXI_ARESETN),W_NEW_BYTE_NUM_UPDATE_I,w_byte_num_update_pos)


always@(posedge M_AXI_ACLK)begin
    if(~M_AXI_ARESETN | ~C_WR_BLOCK_ENABLE )begin
        w_target_beat_num  <= 0;
    end
    else if( (w_state==0 & w_req_valid ) )begin
        w_target_beat_num <= W_BYTE_NUM_I/(C_M_AXI_DATA_WIDTH/8)  +  (( W_BYTE_NUM_I & {0,{(C_M_AXI_DATA_WIDTH/8)-1}} ) != 0) ;
    end
    else if(w_byte_num_update_pos)begin
        w_target_beat_num <= W_NEW_BYTE_NUM_I/(C_M_AXI_DATA_WIDTH/8)  +  (( W_NEW_BYTE_NUM_I & {0,{(C_M_AXI_DATA_WIDTH/8)-1}} ) != 0) ;
    end
end


`POS_MONITOR_InGen(M_AXI_ACLK,(~M_AXI_ARESETN),W_STOP_I,w_stop_pos)

always@(posedge M_AXI_ACLK)begin
    if(~M_AXI_ARESETN| ~C_WR_BLOCK_ENABLE | W_RST_I )begin
        w_stop_reg <= 0;
    end
    else begin
        w_stop_reg <= w_stop_pos ? 1 : w_stop_rst ? 0 : w_stop_reg;
    end
end


always@(posedge M_AXI_ACLK)begin
    if(~M_AXI_ARESETN | ~C_WR_BLOCK_ENABLE | W_RST_I )begin
        w_state <= 0;
        W_FIFO_READ_O <= 0;
        w_cnt_first_delay <= 0;
        w_cnt_beat_left_all <= 0;  
        W_DONE_O_r <= 0;
        W_BUSY_O_r <= 0;
        W_FINISH_O <= 0;
        w_aux_idf1 <= 0;
        w_cnt_per_burst <= 0;
        w_stop_rst <= 0;
        w_beat_num_al <= 0;
        w_burst_num_al <=0;;   
    end
    else begin
        case(w_state)
            0:begin
                w_stop_rst         <= 1;
                W_FINISH_O         <= 0;
                W_DONE_O_r         <= w_req_valid  ? 0 : W_DONE_O_r;
                w_state            <= w_req_valid  ? 1:0; 
                w_cnt_first_delay  <= 10; // >= 0
                
                w_cnt_beat_left_all   <=  W_BYTE_NUM_I/(C_M_AXI_DATA_WIDTH/8)  +  (( W_BYTE_NUM_I & {0,{(C_M_AXI_DATA_WIDTH/8)-1}} ) != 0); //yzhu
                W_BUSY_O_r     <= w_req_valid ? 1 : 0;
                w_burst_num_al <= w_req_valid ? 0 : w_burst_num_al;
                w_beat_num_al  <= w_req_valid ? 0 : w_beat_num_al;
           end
            1:begin//first delay
                w_stop_rst <= 0;
                if(w_cnt_first_delay == 0)begin
                    w_state <= 2;
                end
                else begin
                    w_cnt_first_delay <= w_cnt_first_delay - 1;
                end
            end
            2:begin //判断终止 
                if(w_stop_reg | (w_beat_num_al >= w_target_beat_num) )begin
                    W_DONE_O_r   <= 1;
                    W_BUSY_O_r   <= 0;  
                    W_FINISH_O   <= 1;
                    w_aux_idf1   <= 0;
                    w_state      <= 0;
                end
                else if(w_cnt_beat_left_all==0)begin
                    W_DONE_O_r   <= 1;
                    W_BUSY_O_r   <= 0;  
                    W_FINISH_O   <= 1;
                    w_aux_idf1   <= 0;
                    w_state      <= 0;
                end
                else if(w_cnt_beat_left_all <= C_M_AXI_BURST_LEN)begin
                    w_cnt_per_burst <= w_cnt_beat_left_all;   
                    w_cnt_beat_left_all <= 0;
                    w_state <= 3;
                end
                else begin
                    w_cnt_per_burst <= C_M_AXI_BURST_LEN;
                    w_cnt_beat_left_all <= w_cnt_beat_left_all - C_M_AXI_BURST_LEN;
                    w_state <= 3;
                end
                
            end
            3:begin 
                W_FIFO_READ_O   <= ~W_FIFO_EMPTY_I ;
                w_aux_idf1      <= ~W_FIFO_EMPTY_I ? w_aux_idf1 + 1 : w_aux_idf1;
                w_state         <= ~W_FIFO_EMPTY_I  ? 4 : w_state; 
            end
            4:begin
                W_FIFO_READ_O     <= 0;
                w_cnt_per_burst <= w_cnt_per_burst - 1;
                w_beat_num_al    <= w_beat_num_al + 1;
                w_state <= 5;
            end
            5:begin
                w_state <= w_cnt_per_burst >0  ? 3 : 2;
                w_burst_num_al <= w_cnt_per_burst==0 ? w_burst_num_al + 1 : w_burst_num_al;
            end
            default:begin
                w_state <= 0;
                W_FIFO_READ_O <= 0;
                w_cnt_first_delay <= 0;
                w_cnt_beat_left_all <= 0;  
                W_DONE_O_r <= 0; 
                W_BUSY_O_r <= 0;                
                W_FINISH_O <= 0;
            end   
        endcase
    end
end

end

endgenerate





generate if(C_RD_SIM_ENABLE==0)begin : rd_normal    ////////////////////////////////////////////////////////////// rd normal //////////////////////////////////////////////////////////////
reg [7:0] ii;
wire [C_M_AXI_DATA_WIDTH-1:0] R_FIFO_DATA_O;
reg  R_DONE_O_r = 0;
reg  R_BUSY_O_r = 0;
wire R_FIFO_WRITE_O;
wire fifo_write_extra ;
reg  R_FINISH_O = 0;
wire r_num_self_extra_beats_s0;
wire [15:0] r_num_extra_beats_for_block_align;
wire  [31:0] r_num_self_ori_beats_s0 ;
reg [31:0] r_num_self_total_beats_s1= 0;
reg [31:0] r_cnt_self_total_beats_left = 0;
reg [15:0] r_num_block_align_extra_beats_s2= 0;
reg [15:0] r_cnt_block_align_extra_beats_left= 0;   
reg        r_start_burst;
wire       r_transmiter ;
//wire R_REQ_I_pos;
//reg  R_REQ_I_ff1;
reg [15:0] r_cnt_delay = 0;
wire r_stop_pos;
reg  r_stop_rst = 0;
reg  r_stop_reg = 0;
reg [31:0] r_beat_num_al = 0;
reg [31:0] r_burst_num_al= 0;


`POS_MONITOR_InGen(M_AXI_ACLK,(~M_AXI_ARESETN),R_STOP_I,r_stop_pos)

always@(posedge M_AXI_ACLK)begin
    if(~M_AXI_ARESETN  )begin
        r_stop_reg <= 0;
    end
    else begin
        r_stop_reg <= r_stop_pos ? 1 : r_stop_rst ? 0 : r_stop_reg;
    end
end


assign r_num_self_ori_beats_s0 = R_BYTE_NUM_I/(C_M_AXI_DATA_WIDTH/8);
assign r_num_self_extra_beats_s0 = (( R_BYTE_NUM_I & {0,{(C_M_AXI_DATA_WIDTH/8)-1}} ) != 0) ;

always@(posedge M_AXI_ACLK)begin
    if(~M_AXI_ARESETN | ~C_RD_BLOCK_ENABLE | R_RST_I  )begin
        r_num_self_total_beats_s1 <= 0;
    end
    else begin
        r_num_self_total_beats_s1 <= r_num_self_ori_beats_s0 + r_num_self_extra_beats_s0;
    end
end

always@(posedge M_AXI_ACLK)begin
    if(~M_AXI_ARESETN | ~C_RD_BLOCK_ENABLE | R_RST_I  )begin
        r_num_block_align_extra_beats_s2 <= 0;
    end
    else begin
        r_num_block_align_extra_beats_s2 <= C_RD_BLOCK_ALIGN_BYTE_NUM/(C_M_AXI_DATA_WIDTH/8) - (r_num_self_total_beats_s1) & {0,{C_RD_BLOCK_ALIGN_BYTE_NUM/(C_M_AXI_DATA_WIDTH/8)-1}} ;
    end
end


always@(posedge M_AXI_ACLK)begin 
if((~M_AXI_ARESETN)  | ~C_RD_BLOCK_ENABLE | R_RST_I | R_INNER_DATA_RST_I |  R_STOP_I )begin
        for(ii=0;ii<=C_SLICE_NUM-1;ii=ii+1)begin 
            r_fifo_data_m[ii] <= ii;
        end
    end
    else if(R_FIFO_WRITE_O)begin
        for(ii=0;ii<=C_SLICE_NUM-1;ii=ii+1)begin
            r_fifo_data_m[ii] <= r_fifo_data_m[ii] + C_SLICE_NUM;
        end
    end
end

if(C_RD_NORM_DATA_SOURCE==0)      assign R_FIFO_DATA_O =  M_AXI_RDATA   ;
else if(C_RD_NORM_DATA_SOURCE==1) assign R_FIFO_DATA_O =  r_fifo_data_o ;
else if(C_RD_NORM_DATA_SOURCE==2) assign R_FIFO_DATA_O =  {512{1'b1}}   ;
else if(C_RD_NORM_DATA_SOURCE==3) assign R_FIFO_DATA_O =  {64{8'haa}}   ;
else assign R_FIFO_DATA_O =  {512{1'b1}}  ;
localparam C_SLICE_NUM = C_M_AXI_DATA_WIDTH/8/C_RD_NORM_DATA_UNIT_BYTE_NUM;
reg  [C_RD_NORM_DATA_UNIT_BYTE_NUM*8-1:0] r_fifo_data_m [C_SLICE_NUM-1:0];
wire [C_M_AXI_DATA_WIDTH-1:0] r_fifo_data_o;
`BI_TO_SINGLE_Nm1To0((C_RD_NORM_DATA_UNIT_BYTE_NUM*8),C_SLICE_NUM,r_fifo_data_m,r_fifo_data_o)


    
//always@(posedge M_AXI_ACLK)begin
 //   if(~M_AXI_ARESETN | ~C_RD_BLOCK_ENABLE | R_RST_I  )begin
 //       R_REQ_I_ff1 <= 0;
 //   end
 //   else begin
////        R_REQ_I_ff1 <= R_REQ_I;
//    end
///end
//assign R_REQ_I_pos = R_REQ_I & ~R_REQ_I_ff1;



always@(posedge M_AXI_ACLK)begin
    if(~M_AXI_ARESETN | ~C_RD_BLOCK_ENABLE | R_RST_I)begin
        M_AXI_ARADDR <= 0;
        M_AXI_ARLEN <= C_M_AXI_BURST_LEN - 1;
        r_state <= 0; 
        r_start_burst <= 0;
        r_cnt_self_total_beats_left <= 0;
        R_DONE_O_r <= 0;
        R_BUSY_O_r <= 0;
        R_FINISH_O <= 0;
        r_cnt_block_align_extra_beats_left <= 0;
        r_stop_rst <= 0;
        r_beat_num_al <= 0;
        r_burst_num_al <= 0;
        r_cnt_delay <= C_OP_DELAY_CLK_NUM;
    end
    else begin
        case(r_state)
            0:begin
                r_stop_rst   <= 1;
                R_FINISH_O   <= 0;
                R_DONE_O_r   <= r_req_valid  ? 0 : R_DONE_O_r;
                r_state      <= r_req_valid  ? 5 : 0;
                M_AXI_ARADDR <= R_START_ADDR_I;
                R_BUSY_O_r   <= r_req_valid ? 1 : 0;
                if(r_req_valid)begin
                    r_beat_num_al <= 0;
                    r_burst_num_al <= 0;
                
                end
            end
            5:begin
                r_stop_rst   <= 0;
                r_cnt_self_total_beats_left <= r_num_self_total_beats_s1;
                r_state <= r_num_self_total_beats_s1>0 ? 6 : 0;
            end
            6:begin//note to maintain ff relationship 
                r_cnt_block_align_extra_beats_left <= C_RD_ALIGN_ENABLE ?  r_num_block_align_extra_beats_s2 : 0;
                r_state <= 10;
                r_cnt_delay <= C_OP_DELAY_CLK_NUM;
            end
            //delay
            10:begin
                r_state <= r_cnt_delay==0 ? 1 : 10;
                r_cnt_delay <= r_cnt_delay - 1;
               // r_start_burst <= r_cnt_delay==0 ? 1 : 0; 
            end
            1:begin
                if(r_stop_reg)begin
                    r_cnt_self_total_beats_left <= 0;
                    R_DONE_O_r <= 0; //R_DONE_O_r <= 1;
                    R_FINISH_O <= 0;//R_FINISH_O <= 1;
                    r_state <= 4;// r_state<= 0;
                end
                else begin
            
                    //r_start_burst <= 0;
                    if(r_cnt_self_total_beats_left <= C_M_AXI_BURST_LEN)begin//结算后
                        M_AXI_ARLEN <= r_cnt_self_total_beats_left - 1;
                    end
                    else begin
                        M_AXI_ARLEN <= C_M_AXI_BURST_LEN - 1;
                    end
                    
                    
                    r_start_burst <=  ~R_FIFO_FULL_I ? 1 :  0 ; 
                    r_state       <= ~R_FIFO_FULL_I ? 11 : r_state ;
                    
                    //if(r_cnt_self_total_beats_left <= C_M_AXI_BURST_LEN)begin//结算后
                    //    r_start_burst <=  R_FIFO_WR_DATA_COUNT_I >= r_cnt_self_total_beats_left ;
                    //    r_state <= R_FIFO_WR_DATA_COUNT_I >= r_cnt_self_total_beats_left ? 11 :  r_state ;
                    //end
                    //else begin
                    //    r_start_burst <= R_FIFO_WR_DATA_COUNT_I >= C_M_AXI_BURST_LEN ;
                    //    r_state <= R_FIFO_WR_DATA_COUNT_I >= C_M_AXI_BURST_LEN ? 11 : r_state;
                    //end
                    
                    
                    //if(M_AXI_ARVALID & M_AXI_ARREADY)begin //地址握手完成
                    //    r_state <= 2;
                    //end
                    
                    
                end   
            end
            11:begin //已经启动的传输，[不能强行结束]
                r_start_burst <= 0;
            
                if(M_AXI_ARVALID & M_AXI_ARREADY)begin //地址握手完成
                    r_state <= 2;
                end
                
            end
    
            
            2:begin//传输
                if(r_transmiter & M_AXI_RLAST)begin //note: mig来的last,本模块不可控 , ！注意不是通过计数来判断结束
                    r_burst_num_al <= r_burst_num_al + 1;
                    r_state <= 3;
                end
                
                if(r_transmiter)begin
                    r_beat_num_al <= r_beat_num_al + 1;
                end
                         
            end
            3:begin//结算
                M_AXI_ARADDR <= M_AXI_ARADDR + C_M_AXI_BURST_LEN * (C_M_AXI_DATA_WIDTH/8);
                if(r_stop_reg)begin
                    r_cnt_self_total_beats_left <= 0;
                    R_DONE_O_r <= 0; //R_DONE_O_r <= 1;
                    //R_BUSY_O_r <= 0;   2023年11月23日14:30:29
                    R_FINISH_O <= 0;//R_FINISH_O <= 1;
                    r_state <= 4;// r_state<= 0;
                end
                else if(r_cnt_self_total_beats_left <= C_M_AXI_BURST_LEN)begin//OVER
                    r_cnt_self_total_beats_left <= 0;
                    R_DONE_O_r <= 0; //R_DONE_O_r <= 1;
                    //R_BUSY_O_r <= 0;  //2023年11月23日14:30:33
                    R_FINISH_O <= 0;//R_FINISH_O <= 1;
                    r_state <= 4;// r_state<= 0;
                end
                else begin
                    r_cnt_self_total_beats_left <= r_cnt_self_total_beats_left - C_M_AXI_BURST_LEN;
                    //r_start_burst <= 1;//启动下一个burst
                    r_state <= 1; 
                end
            end
            4:begin//block align
                if(C_RD_ALIGN_ENABLE)begin
                    if(fifo_write_extra)r_cnt_block_align_extra_beats_left <= r_cnt_block_align_extra_beats_left - 1; 
                    r_state  <= r_cnt_block_align_extra_beats_left==0 ? 0: r_state;
                    R_DONE_O_r <= r_cnt_block_align_extra_beats_left==0 ? 1 : 0;
                    R_FINISH_O <= r_cnt_block_align_extra_beats_left==0 ? 1 : 0;
                    R_BUSY_O_r <= r_cnt_block_align_extra_beats_left==0 ? 0 : 1;
                end
                else begin
                    R_DONE_O_r <= 1;
                    R_BUSY_O_r <= 0;
                    R_FINISH_O <= 1;
                    r_state <= 0;
                end
            end
            default:begin
                 M_AXI_ARADDR <= 0;
                 M_AXI_ARLEN <= C_M_AXI_BURST_LEN - 1;
                 r_state <= 0; 
                 r_start_burst <= 0;
                 r_cnt_self_total_beats_left <= 0;
                 R_DONE_O_r <= 0;
                 R_BUSY_O_r <= 0;
                 R_FINISH_O <= 0;
            end
        endcase
    end 
end
                                                                 

//M_AXI_ARVALID
always@(posedge M_AXI_ACLK)begin 
    if (~M_AXI_ARESETN  | ~C_RD_BLOCK_ENABLE | R_RST_I  ) begin 
        M_AXI_ARVALID <= 0; 
    end 
    else if (~M_AXI_ARVALID && r_start_burst) begin 
        M_AXI_ARVALID <= 1; 
    end 
    else if (M_AXI_ARREADY && M_AXI_ARVALID) begin 
        M_AXI_ARVALID <= 0; 
    end 
end


//assign fifo_write_extra = r_state==4 & ~R_FIFO_FULL_I & r_cnt_block_align_extra_beats_left>0; 
assign fifo_write_extra = r_state==4 & (~R_FIFO_FULL_I | r_stop_reg ) & r_cnt_block_align_extra_beats_left>0; 


//RREADY  认为 M_AXI_RREADY 
//assign M_AXI_RREADY = ~R_FIFO_FULL_I & r_state==2 ; 
//assign M_AXI_RREADY = (~R_FIFO_FULL_I | r_stop_reg )  & r_state==2 ;//如果为rd强制退出模式，则将该信号拉高 
assign M_AXI_RREADY =  r_state==2 ;

assign r_transmiter = M_AXI_RREADY & M_AXI_RVALID;

//assign R_FIFO_WRITE_O = r_stop_reg( M_AXI_RREADY & M_AXI_RVALID ) | fifo_write_extra;
assign R_FIFO_WRITE_O = ~r_stop_reg ? (( M_AXI_RREADY & M_AXI_RVALID ) | fifo_write_extra) : 0 ;

     


end
else begin : rd_sim           ////////////////////////////////////////////////////////////// rd sim //////////////////////////////////////////////////////////////
wire r_stop_pos;
reg  r_stop_rst = 0;
reg  r_stop_reg = 0;
reg [31:0] r_cnt_beat_left_all;
reg [31:0] r_cnt_per_burst;
reg [15:0] r_aux_idf1= 0;
reg [15:0] r_cnt_first_delay= 0 ;
wire  [31:0] r_num_self_ori_beats_s0 ;
wire r_num_self_extra_beats_s0;
reg [31:0] r_num_self_total_beats_s1= 0;
reg [31:0] r_cnt_self_total_beats_left= 0 ;
reg [15:0] r_num_block_align_extra_beats_s2= 0;
reg [15:0] r_cnt_block_align_extra_beats_left= 0;
reg R_FIFO_WRITE_O ;
wire [C_M_AXI_DATA_WIDTH-1:0] R_FIFO_DATA_O;
reg  R_DONE_O_r = 0;
reg  R_BUSY_O_r = 0;
reg  R_FINISH_O = 0;
//wire R_REQ_I_pos;
//reg  R_REQ_I_ff1;
reg [31:0] r_beat_num_al;
reg [31:0] r_burst_num_al;


`POS_MONITOR_InGen(M_AXI_ACLK,(~M_AXI_ARESETN),R_STOP_I,r_stop_pos)


    
//always@(posedge M_AXI_ACLK)begin
//    if(~M_AXI_ARESETN | ~C_RD_BLOCK_ENABLE | R_RST_I  )begin
//        R_REQ_I_ff1 <= 0;
//    end
 //   else begin
//        R_REQ_I_ff1 <= R_REQ_I;
//    end
//end
//assign R_REQ_I_pos = R_REQ_I & ~R_REQ_I_ff1;




always@(posedge M_AXI_ACLK)begin
    if(~M_AXI_ARESETN | r_state==0  | ~C_RD_BLOCK_ENABLE | R_RST_I )begin
        r_aux_idf1 <= 0;
    end
    else if(R_FIFO_WRITE_O)begin
        r_aux_idf1 <= r_aux_idf1 + 1;
    end
end


always@(posedge M_AXI_ACLK)begin
    if(~M_AXI_ARESETN  )begin
        r_stop_reg <= 0;
    end
    else begin
        r_stop_reg <= r_stop_pos ? 1 : r_stop_rst ? 0 : r_stop_reg;
    end
end



assign r_num_self_ori_beats_s0   = R_BYTE_NUM_I/(C_M_AXI_DATA_WIDTH/8);
assign r_num_self_extra_beats_s0 = (( R_BYTE_NUM_I & {0,{(C_M_AXI_DATA_WIDTH/8)-1}} ) != 0) ;

always@(posedge M_AXI_ACLK)begin
    if(~M_AXI_ARESETN | ~C_RD_BLOCK_ENABLE | R_RST_I )begin
        r_num_self_total_beats_s1 <= 0;
    end
    else begin
        r_num_self_total_beats_s1 <= r_num_self_ori_beats_s0 + r_num_self_extra_beats_s0;
    end
end


always@(posedge M_AXI_ACLK)begin
    if(~M_AXI_ARESETN | ~C_RD_BLOCK_ENABLE | R_RST_I )begin
        r_num_block_align_extra_beats_s2 <= 0;
    end
    else begin
        r_num_block_align_extra_beats_s2 <= C_RD_BLOCK_ALIGN_BYTE_NUM/(C_M_AXI_DATA_WIDTH/8) - (r_num_self_total_beats_s1) & {0,{C_RD_BLOCK_ALIGN_BYTE_NUM/(C_M_AXI_DATA_WIDTH/8)-1}} ;
    end
end



reg [7:0] ii;
localparam C_SLICE_NUM = C_M_AXI_DATA_WIDTH/8/C_RD_SIM_PATTERN_UNIT_BYTE_NUM;
reg  [C_RD_SIM_PATTERN_UNIT_BYTE_NUM*8-1:0] r_fifo_data_m [C_SLICE_NUM-1:0];
wire [C_M_AXI_DATA_WIDTH-1:0] r_fifo_data_o;
`BI_TO_SINGLE_Nm1To0((C_RD_SIM_PATTERN_UNIT_BYTE_NUM*8),C_SLICE_NUM,r_fifo_data_m,r_fifo_data_o)


if(C_RD_SIM_PATTERN_TYPE==0) assign  R_FIFO_DATA_O =  512'b0 ;
else if(C_RD_SIM_PATTERN_TYPE==1) assign R_FIFO_DATA_O =  r_fifo_data_o ;
else if(C_RD_SIM_PATTERN_TYPE==2) assign R_FIFO_DATA_O =  {512{1'b1}}   ;
else if(C_RD_SIM_PATTERN_TYPE==3) assign R_FIFO_DATA_O =  {64{8'haa}}   ;
else assign R_FIFO_DATA_O =  {512{1'b1}} ;



always@(posedge M_AXI_ACLK)begin 
    if( ~M_AXI_ARESETN | ~C_RD_BLOCK_ENABLE | R_RST_I )begin
        for(ii=0;ii<=C_SLICE_NUM-1;ii=ii+1)begin 
            r_fifo_data_m[ii] <= ii;
        end
    end
    else if(R_FIFO_WRITE_O)begin
        for(ii=0;ii<=C_SLICE_NUM-1;ii=ii+1)begin
            r_fifo_data_m[ii] <= r_fifo_data_m[ii] + C_SLICE_NUM;
        end
    end
end



always@(posedge M_AXI_ACLK)begin
    if(~M_AXI_ARESETN | ~C_RD_BLOCK_ENABLE | R_RST_I)begin
        r_stop_rst <= 0;
        R_FIFO_WRITE_O <= 0;
        r_state <= 0;
        r_cnt_first_delay <= 0;
        r_cnt_self_total_beats_left <= 0;
        R_DONE_O_r <= 0;
        R_BUSY_O_r <= 0;
        R_FINISH_O <= 0;
        r_cnt_block_align_extra_beats_left <= 0;
        r_beat_num_al  <= 0;
        r_burst_num_al <= 0;  
        r_cnt_beat_left_all  <= 0;    
        r_cnt_per_burst <= 0;
    end
    else begin
        case(r_state)
            0:begin//隐含了参数打拍
                R_FINISH_O         <= 0;
                R_DONE_O_r         <= r_req_valid ? 0 : R_DONE_O_r;
                r_state            <= r_req_valid ? 5 : 0;
                R_BUSY_O_r         <= r_req_valid ? 1 : 0;
                r_beat_num_al      <= r_req_valid ? 0 : r_beat_num_al ;
                r_burst_num_al     <= r_req_valid ? 0 : r_burst_num_al;
                r_stop_rst         <= 1;
           end
           5:begin
                r_stop_rst <= 0;
                r_cnt_self_total_beats_left    <=  r_num_self_total_beats_s1;
                r_cnt_first_delay  <= 10;// >= 0
                r_state            <=  r_num_self_total_beats_s1>0 ? 6 : 0;
           end
           6:begin
                r_cnt_beat_left_all <= C_RD_ALIGN_ENABLE ? (r_cnt_self_total_beats_left + r_num_block_align_extra_beats_s2): r_cnt_self_total_beats_left ;
                r_state <= 1;
           end
           1:begin//first delay
                if(r_cnt_first_delay == 0)begin
                    r_state <= 2;
                end
                else begin
                    r_cnt_first_delay <= r_cnt_first_delay - 1;
                end
            end
            2:begin
                if(r_stop_reg)begin
                    R_DONE_O_r   <= 1;
                    R_BUSY_O_r   <= 0;  
                    R_FINISH_O   <= 1;
                    r_state      <= 0;
                end
                else if(r_cnt_beat_left_all==0)begin
                    R_DONE_O_r   <= 1;
                    R_BUSY_O_r   <= 0;  
                    R_FINISH_O   <= 1;
                    r_state      <= 0; 
                end
                else if(r_cnt_beat_left_all <= C_M_AXI_BURST_LEN)begin
                    r_cnt_per_burst <= r_cnt_beat_left_all;
                    r_cnt_beat_left_all <= 0;
                    r_state <= 3;
                end
                else begin
                    r_cnt_per_burst <= C_M_AXI_BURST_LEN;
                    r_cnt_beat_left_all <= r_cnt_beat_left_all - C_M_AXI_BURST_LEN;
                    r_state <= 3;
                end  
            end
            3:begin
                R_FIFO_WRITE_O  <= ~R_FIFO_FULL_I ;
                r_state         <= ~R_FIFO_FULL_I  ? 4 : r_state; 
            end
            4:begin
                R_FIFO_WRITE_O <= 0;
                r_cnt_per_burst <= r_cnt_per_burst - 1;
                r_beat_num_al <= r_beat_num_al + 1;
                r_state <= 7 ;
            end
            7:begin
                r_state <= r_cnt_per_burst>0 ? 3 : 2 ;
                r_burst_num_al <= r_cnt_per_burst==0 ? r_burst_num_al + 1 : r_burst_num_al ;
            end
            default:begin
                 r_stop_rst <= 0;
                 R_FIFO_WRITE_O <= 0;
                 r_state <= 0;
                 r_cnt_first_delay <= 0;
                 r_cnt_self_total_beats_left <= 0;
                 R_DONE_O_r <= 0;
                 R_BUSY_O_r <= 0;
                 R_FINISH_O <= 0;
                 r_cnt_block_align_extra_beats_left <= 0;
                 r_beat_num_al  <= 0;
                 r_burst_num_al <= 0;  
                 r_cnt_beat_left_all  <= 0;    
                 r_cnt_per_burst <= 0;
            end
        endcase
    end
end


end

endgenerate




generate if(C_WR_SIM_ENABLE)
begin
  
assign  W_FIFO_READ_O  =  wr_sim.W_FIFO_READ_O;
assign  W_DONE_O  =  wr_sim.W_DONE_O_r & ~W_REQ_I_pos   ;
assign  W_FINISH_O = wr_sim.W_FINISH_O ;
assign  W_BUSY_O   = wr_sim.W_BUSY_O_r | W_REQ_I_pos  ;   
assign  W_BEATS_O  = wr_sim.w_beat_num_al;
assign  W_BURSTS_O = wr_sim.w_burst_num_al;

end
else begin
assign  W_FIFO_READ_O  =  wr_normal.W_FIFO_READ_O;
assign  W_DONE_O  =  wr_normal.W_DONE_O_r & ~W_REQ_I_pos ;
assign  W_FINISH_O = wr_normal.W_FINISH_O;
assign  W_BUSY_O  =  wr_normal.W_BUSY_O_r | W_REQ_I_pos  ; 
assign  W_BEATS_O =  wr_normal.w_beat_num_al;
assign  W_BURSTS_O = wr_normal.w_burst_num_al; 

end
endgenerate



generate if(C_RD_SIM_ENABLE)
begin
assign  R_FIFO_WRITE_O  =  rd_sim.R_FIFO_WRITE_O ; 
assign  R_FIFO_DATA_O  =  rd_sim.R_FIFO_DATA_O ;
assign  R_DONE_O   =  rd_sim.R_DONE_O_r & ~R_REQ_I_pos ; 
assign  R_FINISH_O = rd_sim.R_FINISH_O ;
assign  R_BUSY_O   = rd_sim.R_BUSY_O_r | R_REQ_I_pos ;

//assign  R_BUSY_O   = 1  ;

assign  R_BEATS_O  = rd_sim.r_beat_num_al;
assign  R_BURSTS_O = rd_sim.r_burst_num_al;

end
else begin
    
assign  R_FIFO_WRITE_O  =  rd_normal.R_FIFO_WRITE_O ; 
assign  R_FIFO_DATA_O  =  rd_normal.R_FIFO_DATA_O ;
assign  R_DONE_O =  rd_normal.R_DONE_O_r & ~R_REQ_I_pos ;
assign  R_FINISH_O = rd_normal.R_FINISH_O ;  
assign  R_BUSY_O  = rd_normal.R_BUSY_O_r | R_REQ_I_pos ;
assign  R_BEATS_O  = rd_normal.r_beat_num_al;
assign  R_BURSTS_O = rd_normal.r_burst_num_al;



end

endgenerate




endmodule



