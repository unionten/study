`timescale 1ns / 1ps

`define CDC_MULTI_BIT_SIGNAL_OUTGEN(aclk,adata_in,bclk,bdata_out,DATA_WIDTH,DEST_FF)                    generate begin xpm_cdc_array_single #(.DEST_SYNC_FF(DEST_FF),.INIT_SYNC_FF(0),.SIM_ASSERT_CHK(0),.SRC_INPUT_REG(1),.WIDTH(DATA_WIDTH)) cdc_u(.src_clk(aclk),.src_in(adata_in),.dest_clk(bclk),.dest_out(bdata_out));    end  endgenerate  
`define CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(adata_in,bclk,bdata_out,DATA_WIDTH,DEST_FF)                    generate begin xpm_cdc_array_single #(.DEST_SYNC_FF(DEST_FF),.INIT_SYNC_FF(0),.SIM_ASSERT_CHK(0),.SRC_INPUT_REG(0),.WIDTH(DATA_WIDTH)) cdc_u(.src_clk( ),.src_in(adata_in),.dest_clk(bclk),.dest_out(bdata_out));    end  endgenerate  
`define CDC_SINGLE_BIT_PULSE_OUTGEN(aclk,arst,apulse_in,bclk,brst,bpulse_out,SIM,DEST_FF)               generate if(SIM==0)begin  xpm_cdc_pulse #(.DEST_SYNC_FF(DEST_FF), .INIT_SYNC_FF(0),.REG_OUTPUT(0),.RST_USED(1),.SIM_ASSERT_CHK (0)) cdc_u (.src_clk(aclk),.src_rst(arst),.src_pulse(apulse_in),.dest_clk(bclk),.dest_rst(brst),.dest_pulse(bpulse_out));   end else begin   reg [5:0] name1 = 0;wire name2;always@(posedge aclk)if(arst)name1[0] <=0;else name1[0] <= apulse_in;assign name2 = apulse_in & ~name1[0]; always@(posedge aclk)if(arst)name1[1] <= 0;else name1[1] <= name2 ? ~name1[1]:name1[1];always@(posedge bclk)if(brst)name1[5:2]<=0;else begin name1[2]<=name1[1];name1[3]<=name1[2];name1[4]<=name1[3];name1[5]<=name1[4];end  assign bpulse_out=name1[4]^name1[5];  end  endgenerate
`define POS_MONITOR_OUTGEN(clk,rst,in,out)                                                              generate  begin  reg buf_name1 = 0; always@(posedge clk)begin if(rst)buf_name1 <= 0; else  buf_name1 <= in; end assign out = (~buf_name1)&(in);  end  endgenerate
`define NEG_MONITOR_OUTGEN(clk,rst,in,out)                                                              generate  begin  reg buf_name1 = 0; always@(posedge clk)begin if(rst)buf_name1 <= 0; else  buf_name1 <= in; end assign out = (buf_name1)&(~in);  end  endgenerate
`define POS_STRETCH_OUTGEN(clk,rst,pulse_in,pulse_out,DELAY_NUM)                                        generate  begin    reg [DELAY_NUM-2:0] temp_name = 0; always@(posedge clk)begin  if(rst)temp_name <= {(DELAY_NUM-1){1'b0}}; else temp_name <= pulse_in ? {(DELAY_NUM-1){1'b1} }: temp_name<<1 ; end  assign  pulse_out = temp_name[DELAY_NUM-2]|pulse_in;  end  endgenerate
`define NEG_STRETCH_OUTGEN(clk,rst,pulsen_in,pulsen_out,DELAY_NUM)                                      generate  begin    reg [DELAY_NUM-2:0] temp_name = 0; always@(posedge clk)begin  if(rst)temp_name <= {(DELAY_NUM-1){1'b0}}; else temp_name <= ~pulsen_in ? {(DELAY_NUM-1){1'b1} }: temp_name<<1 ; end  assign  pulsen_out = ~( temp_name[DELAY_NUM-2] | ~pulsen_in ) ;  end  endgenerate
`define HANDSHAKE_OUTGEN(aclk,arst,apulse_in,adata_in,bclk,brst,bpulse_out,bdata_out,DATA_WIDTH,SIM)    generate  if(SIM==0) begin  handshake  #(.C_DATA_WIDTH(DATA_WIDTH))  handshake_u (.SRC_CLK_I(aclk),.SRC_RST_I(arst),.SRC_DATA_I( adata_in),.SRC_SYNC_PULSE_I ( apulse_in), .DST_CLK_I ( bclk),.DST_DATA_O (bdata_out),.DST_SYNC_FINISH_O(bpulse_out) ); end  else  begin  handshake2 #(.C_DATA_WIDTH(DATA_WIDTH))  handshake_u (.SRC_CLK_I(aclk),.SRC_RST_I(arst),.SRC_DATA_I( adata_in),.SRC_SYNC_PULSE_I ( apulse_in), .DST_CLK_I (bclk),.DST_DATA_O (bdata_out ),.DST_SYNC_FINISH_O(bpulse_out) ); end  endgenerate   
`define DELAY_OUTGEN(clk,rst,data_in,data_out,DATA_WIDTH,DLY)                                           generate if(DLY==0)begin  assign data_out = data_in; end  else if(DLY==1)begin  reg [DATA_WIDTH-1:0] a_temp = 0; always@(posedge clk) a_temp <= data_in; assign data_out = a_temp ; end  else begin  reg [DATA_WIDTH-1:0] a_temp [DLY-1:0] ;always@(posedge clk) begin  if(rst)a_temp[DLY-1] <= 0; else   a_temp[DLY-1] <= data_in; end  for(i=0;i<=DLY-2;i=i+1)begin  always@(posedge clk)begin  if(rst)begin  a_temp[i] <= 0; end  else begin  a_temp[i] <= a_temp[i+1]; end  end  end  assign data_out = a_temp[0]; end  endgenerate

//PULSE_WIDTH 为时钟周期数，>= 1
`define TIMER_OUTGEN(clk,rst,sec_pulse_out,breath_out,CLK_PRD_NS,PULSE_WIDTH)                           generate  begin reg [31:0] cname = 0;reg sname = 0;reg bname = 0;always@(posedge clk) if(rst)begin cname<= 0;sname<=0;bname<=0; end else if(cname==(1000000000/CLK_PRD_NS-1))begin cname<=0;sname<=1;bname<=~bname;end else begin cname<= cname+1; bname<=(cname==(500000000/CLK_PRD_NS-1))?~bname:bname; sname<=(cname==((PULSE_WIDTH)-1))?0:sname;end  assign sec_pulse_out = sname;assign breath_out = bname; end endgenerate
`define CLK_DIV_OUTGEN(clk,rst,clk_out,DIV)                                                             generate begin  reg clk_div_name = 0;reg [7:0] cnt_name = 0;always@(posedge clk)begin if(rst)begin clk_div_name <= 0;cnt_name <= 0;end else begin if(cnt_name<(DIV/2))begin cnt_name <= cnt_name + 1;clk_div_name <= 0;end else if(cnt_name<DIV-1) begin cnt_name <= cnt_name + 1;clk_div_name <= 1;end  else begin cnt_name <= 0;clk_div_name <= 1;end  end  end  assign clk_out = clk_div_name; end endgenerate
`define POS_STRETCH_CNT_OUTGEN(pulse_p_in,clk,pulse_p_out,TOTAL_PRD)                                    generate begin  reg [31:0] cnt_name = 0;always@(posedge clk)begin if(pulse_p_in )begin cnt_name <= TOTAL_PRD-1; end  else begin  cnt_name <= (cnt_name == 0) ? 0 : (cnt_name - 1);end end  assign pulse_p_out = pulse_p_in|((cnt_name != 0)? 1:0); end  endgenerate
`define NEG_STRETCH_CNT_OUTGEN(pulse_n_in,clk,pulse_n_out,TOTAL_PRD)                                    generate begin  reg [31:0] cnt_name = 0;always@(posedge clk)begin if(~pulse_n_in )begin cnt_name <= TOTAL_PRD-1; end  else begin  cnt_name <= (cnt_name == 0) ? 0 : (cnt_name - 1);end end  assign pulse_n_out = pulse_n_in&((cnt_name != 0)? 0:1); end  endgenerate
`define POS_MONITOR_FF2_OUTGEN(clk,rst,in,out)                                                          generate begin reg buf_name1 = 0; reg buf_name2 = 0; always@(posedge clk)begin if(rst)begin buf_name1 <= 0; buf_name2 <= 0;  end else begin buf_name1 <= in; buf_name2 <= buf_name1; end end assign out = (~buf_name2)&(buf_name1); end  endgenerate 
`define NEG_MONITOR_FF2_OUTGEN(clk,rst,in,out)                                                          generate begin reg buf_name1 = 0; reg buf_name2 = 0; always@(posedge clk)begin if(rst)begin buf_name1 <= 0; buf_name2 <= 0;  end else begin buf_name1 <= in; buf_name2 <= buf_name1; end end assign out = (buf_name2)&(~buf_name1); end  endgenerate 
`define POS_MONITOR_FF3_OUTGEN(clk,rst,in,out)                                                          generate begin reg buf_name1 = 0;  reg buf_name2 = 0;  reg buf_name3 = 0; always@(posedge clk)begin if(rst)begin buf_name1 <= 0; buf_name2 <= 0; buf_name3 <= 0; end else begin buf_name1 <= in; buf_name2 <= buf_name1; buf_name3 <= buf_name2; end end assign out = (~buf_name3)&(buf_name2); end  endgenerate 
`define NEG_MONITOR_FF3_OUTGEN(clk,rst,in,out)                                                          generate begin reg buf_name1 = 0;  reg buf_name2 = 0;  reg buf_name3 = 0; always@(posedge clk)begin if(rst)begin buf_name1 <= 0; buf_name2 <= 0; buf_name3 <= 0; end else begin buf_name1 <= in; buf_name2 <= buf_name1; buf_name3 <= buf_name2; end end assign out = (buf_name3)&(~buf_name2); end  endgenerate 
`define ASYNC_BEAT1_OUTGEN(sync_clk,sync_rst,async_in,signal_s1_out)                                    generate begin  reg buf1_name=0;always@(posedge sync_clk)begin if(sync_rst)begin buf1_name <= 0;end  else begin buf1_name <= async_in;end  end  assign signal_s1_out = buf1_name;  end  endgenerate 
`define ASYNC_BEAT2_OUTGEN(sync_clk,sync_rst,async_in,signal_s2_out)                                    generate begin  reg buf1_name=0;reg buf2_name=0; always@(posedge sync_clk)begin if(sync_rst)begin buf1_name <= 0; buf2_name <= 0; end  else begin buf1_name <= async_in; buf2_name <= buf1_name; end  end  assign signal_s2_out = buf2_name;  end  endgenerate    
`define ASYNC_BEAT3_OUTGEN(sync_clk,sync_rst,async_in,signal_s3_out)                                    generate begin  reg buf1_name=0;reg buf2_name=0;reg buf3_name=0; always@(posedge sync_clk)begin if(sync_rst)begin buf1_name <= 0; buf2_name <= 0;buf3_name <= 0; end  else begin buf1_name <= async_in;buf2_name <= buf1_name; buf3_name <= buf2_name; end  end  assign signal_s3_out =  buf3_name;    end  endgenerate 
`define REVERSE_OUTGEN(data_in,data_out,BYTE_NUM,BITS_PER_BYTE)                                         generate for(i=0;i<BYTE_NUM;i=i+1)begin assign data_out[i*BITS_PER_BYTE+:BITS_PER_BYTE] = data_in[(BYTE_NUM-1-i)*BITS_PER_BYTE+:BITS_PER_BYTE]; end  endgenerate


`define CDC_MULTI_BIT_SIGNAL_INGEN(aclk,adata_in,bclk,bdata_out,DATA_WIDTH,DEST_FF)                     begin xpm_cdc_array_single #(.DEST_SYNC_FF(DEST_FF),.INIT_SYNC_FF(0),.SIM_ASSERT_CHK(0),.SRC_INPUT_REG(1),.WIDTH(DATA_WIDTH)) cdc_u(.src_clk(aclk),.src_in(adata_in),.dest_clk(bclk),.dest_out(bdata_out));    end    
`define CDC_MULTI_BIT_SIGNAL_INGEN_NOIN(adata_in,bclk,bdata_out,DATA_WIDTH,DEST_FF)                     begin xpm_cdc_array_single #(.DEST_SYNC_FF(DEST_FF),.INIT_SYNC_FF(0),.SIM_ASSERT_CHK(0),.SRC_INPUT_REG(0),.WIDTH(DATA_WIDTH)) cdc_u(.src_clk( ),.src_in(adata_in),.dest_clk(bclk),.dest_out(bdata_out));    end    
`define CDC_SINGLE_BIT_PULSE_INGEN(aclk,arst,apulse_in,bclk,brst,bpulse_out,SIM,DEST_FF)                if(SIM==0)begin  xpm_cdc_pulse #(.DEST_SYNC_FF(DEST_FF), .INIT_SYNC_FF(0),.REG_OUTPUT(0),.RST_USED(1),.SIM_ASSERT_CHK (0)) cdc_u (.src_clk(aclk),.src_rst(arst),.src_pulse(apulse_in),.dest_clk(bclk),.dest_rst(brst),.dest_pulse(bpulse_out));   end else begin   reg [5:0] name1 = 0;wire name2;always@(posedge aclk)if(arst)name1[0] <=0;else name1[0] <= apulse_in;assign name2 = apulse_in & ~name1[0]; always@(posedge aclk)if(arst)name1[1] <= 0;else name1[1] <= name2 ? ~name1[1]:name1[1];always@(posedge bclk)if(brst)name1[5:2]<=0;else begin name1[2]<=name1[1];name1[3]<=name1[2];name1[4]<=name1[3];name1[5]<=name1[4];end  assign bpulse_out=name1[4]^name1[5];  end  
`define POS_MONITOR_INGEN(clk,rst,in,out)                                                               begin  reg buf_name1 = 0; always@(posedge clk)begin if(rst)buf_name1 <= 0; else  buf_name1 <= in; end assign out = (~buf_name1)&(in);  end  
`define NEG_MONITOR_INGEN(clk,rst,in,out)                                                               begin  reg buf_name1 = 0; always@(posedge clk)begin if(rst)buf_name1 <= 0; else  buf_name1 <= in; end assign out = (buf_name1)&(~in);  end  
`define POS_STRETCH_INGEN(clk,rst,pulse_in,pulse_out,DELAY_NUM)                                         begin    reg [DELAY_NUM-2:0] temp_name = 0; always@(posedge clk)begin  if(rst)temp_name <= {(DELAY_NUM-1){1'b0}}; else temp_name <= pulse_in ? {(DELAY_NUM-1){1'b1} }: temp_name<<1 ; end  assign  pulse_out = temp_name[DELAY_NUM-2]|pulse_in;  end  
`define NEG_STRETCH_INGEN(clk,rst,pulsen_in,pulsen_out,DELAY_NUM)                                       begin    reg [DELAY_NUM-2:0] temp_name = 0; always@(posedge clk)begin  if(rst)temp_name <= {(DELAY_NUM-1){1'b0}}; else temp_name <= ~pulsen_in ? {(DELAY_NUM-1){1'b1} }: temp_name<<1 ; end  assign  pulsen_out = ~( temp_name[DELAY_NUM-2] | ~pulsen_in ) ;  end  
`define HANDSHAKE_INGEN(aclk,arst,apulse_in,adata_in,bclk,brst,bpulse_out,bdata_out,DATA_WIDTH,SIM)     if(SIM==0) begin  handshake  #(.C_DATA_WIDTH(DATA_WIDTH))  handshake_u (.SRC_CLK_I(aclk),.SRC_RST_I(arst),.SRC_DATA_I( adata_in),.SRC_SYNC_PULSE_I ( apulse_in), .DST_CLK_I ( bclk),.DST_DATA_O (bdata_out),.DST_SYNC_FINISH_O(bpulse_out) ); end  else  begin  handshake2 #(.C_DATA_WIDTH(DATA_WIDTH))  handshake_u (.SRC_CLK_I(aclk),.SRC_RST_I(arst),.SRC_DATA_I( adata_in),.SRC_SYNC_PULSE_I ( apulse_in), .DST_CLK_I (bclk),.DST_DATA_O (bdata_out ),.DST_SYNC_FINISH_O(bpulse_out) ); end     
`define DELAY_INGEN(clk,rst,data_in,data_out,DATA_WIDTH,DLY)                                            if(DLY==0)begin  assign data_out = data_in; end  else if(DLY==1)begin  reg [DATA_WIDTH-1:0] a_temp = 0; always@(posedge clk) a_temp <= data_in; assign data_out = a_temp ; end  else begin  reg [DATA_WIDTH-1:0] a_temp [DLY-1:0] ;always@(posedge clk) begin  if(rst)a_temp[DLY-1] <= 0; else   a_temp[DLY-1] <= data_in; end  for(i=0;i<=DLY-2;i=i+1)begin  always@(posedge clk)begin  if(rst)begin  a_temp[i] <= 0; end  else begin  a_temp[i] <= a_temp[i+1]; end  end  end  assign data_out = a_temp[0]; end  
`define TIMER_INGEN(clk,rst,sec_pulse_out,breath_out,CLK_PRD_NS,PULSE_WIDTH)                            begin reg [31:0] cname = 0;reg sname = 0;reg bname = 0;always@(posedge clk) if(rst)begin cname<= 0;sname<=0;bname<=0; end else if(cname==(1000000000/CLK_PRD_NS-1))begin cname<=0;sname<=1;bname<=~bname;end else begin cname<= cname+1; bname<=(cname==(500000000/CLK_PRD_NS-1))?~bname:bname; sname<=(cname==((PULSE_WIDTH)-1))?0:sname;end  assign sec_pulse_out = sname;assign breath_out = bname; end 
`define CLK_DIV_INGEN(clk,rst,clk_out,DIV)                                                              begin  reg clk_div_name = 0;reg [7:0] cnt_name = 0;always@(posedge clk)begin if(rst)begin clk_div_name <= 0;cnt_name <= 0;end else begin if(cnt_name<(DIV/2))begin cnt_name <= cnt_name + 1;clk_div_name <= 0;end else if(cnt_name<DIV-1) begin cnt_name <= cnt_name + 1;clk_div_name <= 1;end  else begin cnt_name <= 0;clk_div_name <= 1;end  end  end  assign clk_out = clk_div_name; end 
`define POS_STRETCH_CNT_INGEN(pulse_p_in,clk,pulse_p_out,TOTAL_PRD)                                     begin  reg [31:0] cnt_name = 0;always@(posedge clk)begin if(pulse_p_in )begin cnt_name <= TOTAL_PRD-1; end  else begin  cnt_name <= (cnt_name == 0) ? 0 : (cnt_name - 1);end end  assign pulse_p_out = pulse_p_in|((cnt_name != 0)? 1:0); end  
`define NEG_STRETCH_CNT_INGEN(pulse_n_in,clk,pulse_n_out,TOTAL_PRD)                                     begin  reg [31:0] cnt_name = 0;always@(posedge clk)begin if(~pulse_n_in )begin cnt_name <= TOTAL_PRD-1; end  else begin  cnt_name <= (cnt_name == 0) ? 0 : (cnt_name - 1);end end  assign pulse_n_out = pulse_n_in&((cnt_name != 0)? 0:1); end  
`define POS_MONITOR_FF2_INGEN(clk,rst,in,out)                                                           begin reg buf_name1 = 0; reg buf_name2 = 0; always@(posedge clk)begin if(rst)begin buf_name1 <= 0; buf_name2 <= 0;  end else begin buf_name1 <= in; buf_name2 <= buf_name1; end end assign out = (~buf_name2)&(buf_name1); end   
`define NEG_MONITOR_FF2_INGEN(clk,rst,in,out)                                                           begin reg buf_name1 = 0; reg buf_name2 = 0; always@(posedge clk)begin if(rst)begin buf_name1 <= 0; buf_name2 <= 0;  end else begin buf_name1 <= in; buf_name2 <= buf_name1; end end assign out = (buf_name2)&(~buf_name1); end   
`define POS_MONITOR_FF3_INGEN(clk,rst,in,out)                                                           begin reg buf_name1 = 0;  reg buf_name2 = 0;  reg buf_name3 = 0; always@(posedge clk)begin if(rst)begin buf_name1 <= 0; buf_name2 <= 0; buf_name3 <= 0; end else begin buf_name1 <= in; buf_name2 <= buf_name1; buf_name3 <= buf_name2; end end assign out = (~buf_name3)&(buf_name2); end   
`define NEG_MONITOR_FF3_INGEN(clk,rst,in,out)                                                           begin reg buf_name1 = 0;  reg buf_name2 = 0;  reg buf_name3 = 0; always@(posedge clk)begin if(rst)begin buf_name1 <= 0; buf_name2 <= 0; buf_name3 <= 0; end else begin buf_name1 <= in; buf_name2 <= buf_name1; buf_name3 <= buf_name2; end end assign out = (buf_name3)&(~buf_name2); end   
`define ASYNC_BEAT1_INGEN(sync_clk,sync_rst,async_in,signal_s1_out)                                     begin  reg buf1_name=0;always@(posedge sync_clk)begin if(sync_rst)begin buf1_name <= 0;end  else begin buf1_name <= async_in;end  end  assign signal_s1_out = buf1_name;  end   
`define ASYNC_BEAT2_INGEN(sync_clk,sync_rst,async_in,signal_s2_out)                                     begin  reg buf1_name=0;reg buf2_name=0; always@(posedge sync_clk)begin if(sync_rst)begin buf1_name <= 0; buf2_name <= 0; end  else begin buf1_name <= async_in; buf2_name <= buf1_name; end  end  assign signal_s2_out = buf2_name;  end      
`define ASYNC_BEAT3_INGEN(sync_clk,sync_rst,async_in,signal_s3_out)                                     begin  reg buf1_name=0;reg buf2_name=0;reg buf3_name=0; always@(posedge sync_clk)begin if(sync_rst)begin buf1_name <= 0; buf2_name <= 0;buf3_name <= 0; end  else begin buf1_name <= async_in;buf2_name <= buf1_name; buf3_name <= buf2_name; end  end  assign signal_s3_out =  buf3_name;    end   
`define REVERSE_INGEN(data_in,data_out,BYTE_NUM,BITS_PER_BYTE)                                          for(i=0;i<BYTE_NUM;i=i+1)begin assign data_out[i*BITS_PER_BYTE+:BITS_PER_BYTE] = data_in[(BYTE_NUM-1-i)*BITS_PER_BYTE+:BITS_PER_BYTE]; end  


//////////////////////////////////////////////////////////////////////////////////
//reg space
`define ADDR_CLK0   16'h0000
`define ADDR_CLK1   16'h0004
`define ADDR_CLK2   16'h0008
`define ADDR_CLK3   16'h000c
`define ADDR_CLK4   16'h0010
`define ADDR_CLK5   16'h0014
`define ADDR_CLK6   16'h0018
`define ADDR_CLK7   16'h001c




//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: yzhu
// 
// Create Date: 2024
// Design Name: 
// Module Name: clk_det 
//////////////////////////////////////////////////////////////////////////////////
 //以 Hz 形式读取，不做截取
module clk_det(  

input  wire                                      S_AXI_ACLK      ,//总线时钟
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


input  [C_CLK_BE_TESTED_NUM-1:0]                 CLK_TO_BE_TESTED_I  


    );
parameter C_CLK_BE_TESTED_NUM             = 8   ; //1~8
parameter C_CLK_BE_TESTED_MHZ_WIDTH       = 32  ;


parameter C_AXI_LITE_DATA_WIDTH           = 32  ; 
parameter C_AXI_LITE_ADDR_WIDTH           = 16  ;
parameter  SYS_PRD_NS                     = 10  ;
parameter [0:0] TEST_REF_PRD_ILA_ENABLE   = 1   ;



genvar i,j,k;

wire                              write_req_cpu_to_axi   ;
wire  [C_AXI_LITE_ADDR_WIDTH-1:0] write_addr_cpu_to_axi  ;
wire [C_AXI_LITE_DATA_WIDTH-1:0]  write_data_cpu_to_axi  ;
wire                              read_req_cpu_to_axi    ;
wire  [C_AXI_LITE_ADDR_WIDTH-1:0] read_addr_cpu_to_axi   ;
reg   [C_AXI_LITE_DATA_WIDTH-1:0] read_data_axi_to_cpu   ;
reg                               read_finish_axi_to_cpu ;



wire [31:0] CLK_BE_TESTED_I_Hz_aclk [C_CLK_BE_TESTED_NUM-1:0] ;


axi_lite_slave #(
    .C_S_AXI_DATA_WIDTH (C_AXI_LITE_DATA_WIDTH ),
    .C_S_AXI_ADDR_WIDTH (C_AXI_LITE_ADDR_WIDTH )   
    )
    axi_lite_slave_u(

    .S_AXI_ACLK            (S_AXI_ACLK      ),     //input  wire                              
    .S_AXI_ARESETN         (S_AXI_ARESETN   ),     //input  wire                              
    .S_AXI_AWREADY         (S_AXI_AWREADY   ),     //output wire                              
    .S_AXI_AWADDR          (S_AXI_AWADDR    ),     //input  wire [C_S_AXI_ADDR_WIDTH-1:0]     
    .S_AXI_AWVALID         (S_AXI_AWVALID   ),     //input  wire                              
    .S_AXI_AWPROT          (S_AXI_AWPROT    ),     //input  wire [ 2:0]                       
    .S_AXI_WREADY          (S_AXI_WREADY    ),     //output wire                              
    .S_AXI_WDATA           (S_AXI_WDATA     ),     //input  wire [C_S_AXI_DATA_WIDTH-1:0]     
    .S_AXI_WSTRB           (S_AXI_WSTRB     ),         //input  wire [(C_S_AXI_DATA_WIDTH/8)-1 :0]
    .S_AXI_WVALID          (S_AXI_WVALID    ),     //input  wire                              
    .S_AXI_BRESP           (S_AXI_BRESP     ),     //output wire [ 1:0]                       
    .S_AXI_BVALID          (S_AXI_BVALID    ),     //output wire                              
    .S_AXI_BREADY          (S_AXI_BREADY    ),     //input  wire                              
    .S_AXI_ARREADY         (S_AXI_ARREADY   ),     //output wire                              
    .S_AXI_ARADDR          (S_AXI_ARADDR    ),     //input  wire [C_S_AXI_ADDR_WIDTH-1:0]     
    .S_AXI_ARVALID         (S_AXI_ARVALID   ),     //input  wire                              
    .S_AXI_ARPROT          (S_AXI_ARPROT    ),     //input  wire [ 2:0]                       
    .S_AXI_RRESP           (S_AXI_RRESP     ),     //output wire [ 1:0]                       
    .S_AXI_RVALID          (S_AXI_RVALID    ),     //output wire                              
    .S_AXI_RDATA           (S_AXI_RDATA     ),     //output wire [C_S_AXI_DATA_WIDTH-1:0]     
    .S_AXI_RREADY          (S_AXI_RREADY    ),     //input  wire                              
    
    .write_req_cpu_to_axi  (write_req_cpu_to_axi   ),    //wire                              
    .write_addr_cpu_to_axi (write_addr_cpu_to_axi  ),   //wire [C_S_AXI_ADDR_WIDTH-1:0]     
    .write_data_cpu_to_axi (write_data_cpu_to_axi  ),   //wire [C_S_AXI_DATA_WIDTH-1:0]     
    .read_req_cpu_to_axi   (read_req_cpu_to_axi    ),     //wire                              
    .read_addr_cpu_to_axi  (read_addr_cpu_to_axi   ),    //wire [C_S_AXI_ADDR_WIDTH-1:0]     
    .read_data_axi_to_cpu  (read_data_axi_to_cpu   ),    //wire [C_S_AXI_DATA_WIDTH-1:0]     
    .read_finish_axi_to_cpu(read_finish_axi_to_cpu )   //wire                              
      
);


always@(posedge S_AXI_ACLK)begin
    if(~S_AXI_ARESETN)begin
        read_data_axi_to_cpu <= 0;
        read_finish_axi_to_cpu <= 0;
    end
    else if(read_req_cpu_to_axi)begin
        read_finish_axi_to_cpu <= 1;
        case(read_addr_cpu_to_axi)
            `ADDR_CLK0  : read_data_axi_to_cpu <= C_CLK_BE_TESTED_NUM>=1 ? CLK_BE_TESTED_I_Hz_aclk[0]  : 0 ;
            `ADDR_CLK1  : read_data_axi_to_cpu <= C_CLK_BE_TESTED_NUM>=2 ? CLK_BE_TESTED_I_Hz_aclk[1]  : 0 ;
            `ADDR_CLK2  : read_data_axi_to_cpu <= C_CLK_BE_TESTED_NUM>=3 ? CLK_BE_TESTED_I_Hz_aclk[2]  : 0 ;
            `ADDR_CLK3  : read_data_axi_to_cpu <= C_CLK_BE_TESTED_NUM>=4 ? CLK_BE_TESTED_I_Hz_aclk[3]  : 0 ;
            `ADDR_CLK4  : read_data_axi_to_cpu <= C_CLK_BE_TESTED_NUM>=5 ? CLK_BE_TESTED_I_Hz_aclk[4]  : 0 ;
            `ADDR_CLK5  : read_data_axi_to_cpu <= C_CLK_BE_TESTED_NUM>=6 ? CLK_BE_TESTED_I_Hz_aclk[5]  : 0 ;
            `ADDR_CLK6  : read_data_axi_to_cpu <= C_CLK_BE_TESTED_NUM>=7 ? CLK_BE_TESTED_I_Hz_aclk[6]  : 0 ;
            `ADDR_CLK7  : read_data_axi_to_cpu <= C_CLK_BE_TESTED_NUM>=8 ? CLK_BE_TESTED_I_Hz_aclk[7]  : 0 ;
           
            default:read_data_axi_to_cpu <= 0;
            
        endcase
    end
    else begin
        read_finish_axi_to_cpu <= 0;
    end
end





generate for(i=0;i<=(C_CLK_BE_TESTED_NUM-1);i=i+1)begin

freq_test_value
    #(.SYS_PRD_NS (SYS_PRD_NS) //以 Hz 形式读取，不做截取
    )
    freq_test_value_u
    (
    .SYS_CLK_I                   (S_AXI_ACLK  ) , //用于生成内部秒脉冲 时钟域1
    .SYS_RSTN_I                  (S_AXI_ARESETN) , //时钟域1
    .CLK_BE_TESTED_I             (CLK_TO_BE_TESTED_I[i]) , //时钟域2
    .CLK_BE_TESTED_HZ_O         () ,  //时钟域2  最多到1000M 偏小
    .CLK_BE_TESTED_HZ_O_SYSCLK  (CLK_BE_TESTED_I_Hz_aclk[i])

    );
end
endgenerate




generate if(TEST_REF_PRD_ILA_ENABLE)begin

ila_0  ila_0_u
(
.clk      (S_AXI_ACLK              ),
.probe0   (C_CLK_BE_TESTED_NUM>=1 ? CLK_BE_TESTED_I_Hz_aclk[0] : 0),
.probe1   (C_CLK_BE_TESTED_NUM>=2 ? CLK_BE_TESTED_I_Hz_aclk[1] : 0),
.probe2   (C_CLK_BE_TESTED_NUM>=3 ? CLK_BE_TESTED_I_Hz_aclk[2] : 0),
.probe3   (C_CLK_BE_TESTED_NUM>=4 ? CLK_BE_TESTED_I_Hz_aclk[3] : 0),
.probe4   (C_CLK_BE_TESTED_NUM>=5 ? CLK_BE_TESTED_I_Hz_aclk[4] : 0),
.probe5   (C_CLK_BE_TESTED_NUM>=6 ? CLK_BE_TESTED_I_Hz_aclk[5] : 0),
.probe6   (C_CLK_BE_TESTED_NUM>=7 ? CLK_BE_TESTED_I_Hz_aclk[6] : 0),
.probe7   (C_CLK_BE_TESTED_NUM>=8 ? CLK_BE_TESTED_I_Hz_aclk[7] : 0)


);
end
endgenerate
    
    
    
    
    
    
endmodule







