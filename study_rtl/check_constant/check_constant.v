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

//注意：STRETCH都是检测电平 同时|上输入信号

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

 `define XOR_MONITOR_OUTGEN(clk,rst,in,out)                                                              generate  begin  reg buf_name1 = 0; always@(posedge clk)begin if(rst)buf_name1 <= 0; else  buf_name1 <= in; end assign out = buf_name1^in;  end  endgenerate
`define XOR_MONITOR_INGEN(clk,rst,in,out)                                                               begin  reg buf_name1 = 0; always@(posedge clk)begin if(rst)buf_name1 <= 0; else  buf_name1 <= in; end assign out = buf_name1^in;  end  

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/11/28 17:28:54
// Design Name: 
// Module Name: check_constant
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//////////////////////////////////////////////////////////////////////////////////


module check_constant(
input  CLK_I,
input  RST_I,
input  [WIDTH-1:0] D_I,
output [WIDTH-1:0] IS_ALWAYS_1_O,
output [WIDTH-1:0] IS_ALWAYS_0_O
    );
parameter  [0:0] CHECK_STABLE_HIGH_EN = 1 ;
parameter  [0:0] CHECK_STABLE_LOW_EN  = 1 ;
parameter  WIDTH     = 1 ;
parameter  THRESHOLD = 1024; //valid value : only 2 power !!!
  
genvar i,j,k;
  
reg [$clog2(THRESHOLD):0] cnt [WIDTH-1:0];

wire [WIDTH-1:0] D_I_ss;
wire [WIDTH-1:0] D_I_ss2;
`DELAY_OUTGEN(CLK_I,0,D_I,D_I_ss,WIDTH,2)
`DELAY_OUTGEN(CLK_I,0,D_I_ss,D_I_ss2,WIDTH,1)

//judge  cnt Highest bit
wire [WIDTH-1:0] highest_bit;

reg [WIDTH-1:0] high_flag;//用于暂记是高还是低

wire [WIDTH-1:0]  D_I_ss_pos;
wire [WIDTH-1:0]  D_I_ss_neg;
wire [WIDTH-1:0]  D_I_ss_xor;



generate for(i=0;i<=(WIDTH-1);i=i+1)begin
assign  highest_bit[i] = cnt[i][$clog2(THRESHOLD)]; 

`XOR_MONITOR_INGEN(CLK_I,0,D_I_ss[i],D_I_ss_xor[i])


always@(posedge  CLK_I)begin
    if(RST_I)begin
        cnt[i] <= 0;
    end
    else begin
        cnt[i] <= D_I_ss_xor[i] ? 0 : highest_bit[i]==1'b1 ? cnt[i] : cnt[i] + 1 ;
    end
end
    
assign  IS_ALWAYS_1_O[i] = CHECK_STABLE_HIGH_EN ? ((highest_bit[i] == 1'b1) & D_I_ss2[i]  ? 1 : 0 ) : 0;
assign  IS_ALWAYS_0_O[i] = CHECK_STABLE_LOW_EN  ? ((highest_bit[i] == 1'b1) & D_I_ss2[i]  ? 1 : 0 ) : 0; 


end
endgenerate

    
endmodule
