`define CDC_MULTI_BIT_SIGNAL_OUTGEN_2016(aclk,adata_in,bclk,bdata_out,DATA_WIDTH,DEST_FF)                    generate begin xpm_cdc_array_single #(.DEST_SYNC_FF(DEST_FF),.SIM_ASSERT_CHK(0),.SRC_INPUT_REG(1),.WIDTH(DATA_WIDTH)) cdc_u(.src_clk(aclk),.src_in(adata_in),.dest_clk(bclk),.dest_out(bdata_out));    end  endgenerate  
`define CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN_2016(adata_in,bclk,bdata_out,DATA_WIDTH,DEST_FF)                    generate begin xpm_cdc_array_single #(.DEST_SYNC_FF(DEST_FF),.SIM_ASSERT_CHK(0),.SRC_INPUT_REG(0),.WIDTH(DATA_WIDTH)) cdc_u(.src_clk( ),.src_in(adata_in),.dest_clk(bclk),.dest_out(bdata_out));    end  endgenerate  
`define CDC_SINGLE_BIT_PULSE_OUTGEN_2016(aclk,arst,apulse_in,bclk,brst,bpulse_out,SIM,DEST_FF)               generate if(SIM==0)begin  xpm_cdc_pulse #(.DEST_SYNC_FF(DEST_FF), .REG_OUTPUT(0),.RST_USED(1),.SIM_ASSERT_CHK (0)) cdc_u (.src_clk(aclk),.src_rst(arst),.src_pulse(apulse_in),.dest_clk(bclk),.dest_rst(brst),.dest_pulse(bpulse_out));   end else begin   reg [5:0] name1 = 0;wire name2;always@(posedge aclk)if(arst)name1[0] <=0;else name1[0] <= apulse_in;assign name2 = apulse_in & ~name1[0]; always@(posedge aclk)if(arst)name1[1] <= 0;else name1[1] <= name2 ? ~name1[1]:name1[1];always@(posedge bclk)if(brst)name1[5:2]<=0;else begin name1[2]<=name1[1];name1[3]<=name1[2];name1[4]<=name1[3];name1[5]<=name1[4];end  assign bpulse_out=name1[4]^name1[5];  end  endgenerate
`define POS_MONITOR_OUTGEN(clk,rst,in,out)                                                              generate  begin  reg buf_name1 = 0; always@(posedge clk)begin if(rst)buf_name1 <= 0; else  buf_name1 <= in; end assign out = (~buf_name1)&(in);  end  endgenerate
`define NEG_MONITOR_OUTGEN(clk,rst,in,out)                                                              generate  begin  reg buf_name1 = 0; always@(posedge clk)begin if(rst)buf_name1 <= 0; else  buf_name1 <= in; end assign out = (buf_name1)&(~in);  end  endgenerate
`define XOR_MONITOR_OUTGEN(clk,rst,in,out)                                                              generate  begin  reg buf_name1 = 0; always@(posedge clk)begin if(rst)buf_name1 <= 0; else  buf_name1 <= in; end assign out = buf_name1^in;  end  endgenerate
`define POS_STRETCH_OUTGEN(clk,rst,pulse_in,pulse_out,DELAY_NUM)                                        generate  begin    reg [DELAY_NUM-2:0] temp_name = 0; always@(posedge clk)begin  if(rst)temp_name <= {(DELAY_NUM-1){1'b0}}; else temp_name <= pulse_in ? {(DELAY_NUM-1){1'b1} }: temp_name<<1 ; end  assign  pulse_out = temp_name[DELAY_NUM-2]|pulse_in;  end  endgenerate
`define NEG_STRETCH_OUTGEN(clk,rst,pulsen_in,pulsen_out,DELAY_NUM)                                      generate  begin    reg [DELAY_NUM-2:0] temp_name = 0; always@(posedge clk)begin  if(rst)temp_name <= {(DELAY_NUM-1){1'b0}}; else temp_name <= ~pulsen_in ? {(DELAY_NUM-1){1'b1} }: temp_name<<1 ; end  assign  pulsen_out = ~( temp_name[DELAY_NUM-2] | ~pulsen_in ) ;  end  endgenerate
`define HANDSHAKE_OUTGEN_2016(aclk,arst,apulse_in,adata_in,bclk,brst,bpulse_out,bdata_out,DATA_WIDTH,SIM)    generate  if(SIM==0) begin  handshake_2016  #(.C_DATA_WIDTH(DATA_WIDTH))  handshake_u (.SRC_CLK_I(aclk),.SRC_RST_I(arst),.SRC_DATA_I( adata_in),.SRC_SYNC_PULSE_I ( apulse_in), .DST_CLK_I ( bclk),.DST_DATA_O (bdata_out),.DST_SYNC_FINISH_O(bpulse_out) ,.SRC_SYNC_FINISH_O() ); end  else  begin  handshake2 #(.C_DATA_WIDTH(DATA_WIDTH))  handshake_u (.SRC_CLK_I(aclk),.SRC_RST_I(arst),.SRC_DATA_I( adata_in),.SRC_SYNC_PULSE_I ( apulse_in), .DST_CLK_I (bclk),.DST_DATA_O (bdata_out ),.DST_SYNC_FINISH_O(bpulse_out) ); end  endgenerate   
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

`define CDC_MULTI_BIT_SIGNAL_INGEN_2016(aclk,adata_in,bclk,bdata_out,DATA_WIDTH,DEST_FF)                     begin xpm_cdc_array_single #(.DEST_SYNC_FF(DEST_FF),.SIM_ASSERT_CHK(0),.SRC_INPUT_REG(1),.WIDTH(DATA_WIDTH)) cdc_u(.src_clk(aclk),.src_in(adata_in),.dest_clk(bclk),.dest_out(bdata_out));    end    
`define CDC_MULTI_BIT_SIGNAL_INGEN_NOIN_2016(adata_in,bclk,bdata_out,DATA_WIDTH,DEST_FF)                     begin xpm_cdc_array_single #(.DEST_SYNC_FF(DEST_FF),.SIM_ASSERT_CHK(0),.SRC_INPUT_REG(0),.WIDTH(DATA_WIDTH)) cdc_u(.src_clk( ),.src_in(adata_in),.dest_clk(bclk),.dest_out(bdata_out));    end    
`define CDC_SINGLE_BIT_PULSE_INGEN_2016(aclk,arst,apulse_in,bclk,brst,bpulse_out,SIM,DEST_FF)                if(SIM==0)begin  xpm_cdc_pulse #(.DEST_SYNC_FF(DEST_FF),.REG_OUTPUT(0),.RST_USED(1),.SIM_ASSERT_CHK (0)) cdc_u (.src_clk(aclk),.src_rst(arst),.src_pulse(apulse_in),.dest_clk(bclk),.dest_rst(brst),.dest_pulse(bpulse_out));   end else begin   reg [5:0] name1 = 0;wire name2;always@(posedge aclk)if(arst)name1[0] <=0;else name1[0] <= apulse_in;assign name2 = apulse_in & ~name1[0]; always@(posedge aclk)if(arst)name1[1] <= 0;else name1[1] <= name2 ? ~name1[1]:name1[1];always@(posedge bclk)if(brst)name1[5:2]<=0;else begin name1[2]<=name1[1];name1[3]<=name1[2];name1[4]<=name1[3];name1[5]<=name1[4];end  assign bpulse_out=name1[4]^name1[5];  end  
`define POS_MONITOR_INGEN(clk,rst,in,out)                                                               begin  reg buf_name1 = 0; always@(posedge clk)begin if(rst)buf_name1 <= 0; else  buf_name1 <= in; end assign out = (~buf_name1)&(in);  end  
`define NEG_MONITOR_INGEN(clk,rst,in,out)                                                               begin  reg buf_name1 = 0; always@(posedge clk)begin if(rst)buf_name1 <= 0; else  buf_name1 <= in; end assign out = (buf_name1)&(~in);  end  
`define XOR_MONITOR_INGEN(clk,rst,in,out)                                                               begin  reg buf_name1 = 0; always@(posedge clk)begin if(rst)buf_name1 <= 0; else  buf_name1 <= in; end assign out = buf_name1^in;  end  
`define POS_STRETCH_INGEN(clk,rst,pulse_in,pulse_out,DELAY_NUM)                                         begin    reg [DELAY_NUM-2:0] temp_name = 0; always@(posedge clk)begin  if(rst)temp_name <= {(DELAY_NUM-1){1'b0}}; else temp_name <= pulse_in ? {(DELAY_NUM-1){1'b1} }: temp_name<<1 ; end  assign  pulse_out = temp_name[DELAY_NUM-2]|pulse_in;  end  
`define NEG_STRETCH_INGEN(clk,rst,pulsen_in,pulsen_out,DELAY_NUM)                                       begin    reg [DELAY_NUM-2:0] temp_name = 0; always@(posedge clk)begin  if(rst)temp_name <= {(DELAY_NUM-1){1'b0}}; else temp_name <= ~pulsen_in ? {(DELAY_NUM-1){1'b1} }: temp_name<<1 ; end  assign  pulsen_out = ~( temp_name[DELAY_NUM-2] | ~pulsen_in ) ;  end  
`define HANDSHAKE_INGEN_2016(aclk,arst,apulse_in,adata_in,bclk,brst,bpulse_out,bdata_out,DATA_WIDTH,SIM)     if(SIM==0) begin  handshake_2016  #(.C_DATA_WIDTH(DATA_WIDTH))  handshake_u (.SRC_CLK_I(aclk),.SRC_RST_I(arst),.SRC_DATA_I( adata_in),.SRC_SYNC_PULSE_I ( apulse_in), .DST_CLK_I ( bclk),.DST_DATA_O (bdata_out),.DST_SYNC_FINISH_O(bpulse_out) ,.SRC_SYNC_FINISH_O()); end  else  begin  handshake2 #(.C_DATA_WIDTH(DATA_WIDTH))  handshake_u (.SRC_CLK_I(aclk),.SRC_RST_I(arst),.SRC_DATA_I( adata_in),.SRC_SYNC_PULSE_I ( apulse_in), .DST_CLK_I (bclk),.DST_DATA_O (bdata_out ),.DST_SYNC_FINISH_O(bpulse_out) ); end     
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

`define RELATION_DEBUG(clk,rst,sig0_pos_in,sig1_pos_in,relation_clk_prd_num_out,CNT_WIDTH)       generate begin  reg [31:0] cnt_reg =0; reg [31:0] cnt_dym =0; reg flag_count=0;  always@(posedge clk)begin  if(rst)begin  flag_count <= 0; end  else begin  flag_count <=  sig0_pos_in ? 1 : sig1_pos_in ? 0 : flag_count ;  end  end  always@(posedge clk)begin  if(rst)begin  cnt_reg  <= 0; cnt_dym  <= 0; end  else begin  cnt_reg <= sig1_pos_in ? cnt_dym : cnt_reg ;  cnt_dym <= sig1_pos_in ? 0 : flag_count ? cnt_dym+1 : cnt_dym ; end  end  assign relation_clk_prd_num_out =  cnt_reg ;   end  endgenerate
  
 
`define SINGLE_TO_BI_1ToN(a,b,in,out)               generate for(i=1;i<=b;i=i+1)begin assign out[i] = in[a*b-1-(a-1)*(i-1)-(i-1):a*b-1-(a-1)*(i)-(i-1)];end endgenerate
`define BI_TO_SINGLE_1ToN(a,b,in,out)               generate for(i=1;i<=b;i=i+1)begin assign out[a*b-1-(a-1)*(i-1)-(i-1):a*b-1-(a-1)*(i)-(i-1)] = in[i];end endgenerate
`define SINGLE_TO_TRI_1ToN(a,b,c,in,out)            generate for(i=1;i<=b;i=i+1)begin for(j=1;j<=c;j=j+1)begin assign out[i][j] = in[a*b*c-1-(a-1)* ((i-1)*c+(j-1)) - ((i-1)*c+(j-1)) :a*b*c-1-(a-1)* ((i-1)*c+(j-1)+1) - ((i-1)*c+(j-1)) ];end end endgenerate
`define TRI_TO_SINGLE_1ToN(a,b,c,in,out)            generate for(i=1;i<=b;i=i+1)begin for(j=1;j<=c;j=j+1)begin assign out[a*b*c-1-(a-1)* ((i-1)*c+(j-1)) - ((i-1)*c+(j-1)) :a*b*c-1-(a-1)* ((i-1)*c+(j-1)+1) - ((i-1)*c+(j-1)) ] = in[i][j];end end endgenerate
`define SINGLE_TO_FOUR_1ToN(a,b,c,d,in,out)         generate for(i=1;i<=b;i=i+1)begin for(j=1;j<=c;j=j+1)begin for(k=1;k<=d;k=k+1)begin assign out[i][j][k] = in[(b-i)*(c*d*a)-1 +(c-j)*(d*a) +(d-k)*a +(a-1)+1:(b-i)*(c*d*a)-1 +(c-j)*(d*a) +(d-k)*a+1]; end end end endgenerate
`define FOUR_TO_SINGLE_1ToN(a,b,c,d,in,out)         generate for(i=1;i<=b;i=i+1)begin for(j=1;j<=c;j=j+1)begin for(k=1;k<=d;k=k+1)begin assign out[(b-i)*(c*d*a)-1 +(c-j)*(d*a) +(d-k)*a +(a-1)+1:(b-i)*(c*d*a)-1 +(c-j)*(d*a) +(d-k)*a+1] = in[i][j][k]; end end end endgenerate
                                                    
`define SINGLE_TO_BI_Nm1To0(a,b,in,out)             generate for(i=1;i<=b;i=i+1)begin assign out[b-i] = in[a*b-1-(a-1)*(i-1)-(i-1):a*b-1-(a-1)*(i)-(i-1)];end endgenerate
`define BI_TO_SINGLE_Nm1To0(a,b,in,out)             generate for(i=1;i<=b;i=i+1)begin assign out[a*b-1-(a-1)*(i-1)-(i-1):a*b-1-(a-1)*(i)-(i-1)] = in[b-i];end endgenerate
`define SINGLE_TO_TRI_Nm1To0(a,b,c,in,out)          generate for(i=1;i<=b;i=i+1)begin for(j=1;j<=c;j=j+1)begin assign out[b-i][c-j] = in[a*b*c-1-(a-1)* ((i-1)*c+(j-1)) - ((i-1)*c+(j-1)) :a*b*c-1-(a-1)* ((i-1)*c+(j-1)+1) - ((i-1)*c+(j-1)) ];end end endgenerate
`define TRI_TO_SINGLE_Nm1To0(a,b,c,in,out)          generate for(i=1;i<=b;i=i+1)begin for(j=1;j<=c;j=j+1)begin assign out[a*b*c-1-(a-1)* ((i-1)*c+(j-1)) - ((i-1)*c+(j-1)) :a*b*c-1-(a-1)* ((i-1)*c+(j-1)+1) - ((i-1)*c+(j-1)) ] = in[b-i][c-j];end end endgenerate
`define SINGLE_TO_FOUR_Nm1To0(a,b,c,d,in,out)       generate for(i=1;i<=b;i=i+1)begin for(j=1;j<=c;j=j+1)begin for(k=1;k<=d;k=k+1)begin assign out[b-i][c-j][d-k] = in[(b-i)*(c*d*a)-1 +(c-j)*(d*a) +(d-k)*a +(a-1)+1:(b-i)*(c*d*a)-1 +(c-j)*(d*a) +(d-k)*a+1]; end end end endgenerate
`define FOUR_TO_SINGLE_Nm1To0(a,b,c,d,in,out)       generate for(i=1;i<=b;i=i+1)begin for(j=1;j<=c;j=j+1)begin for(k=1;k<=d;k=k+1)begin assign out[(b-i)*(c*d*a)-1 +(c-j)*(d*a) +(d-k)*a +(a-1)+1:(b-i)*(c*d*a)-1 +(c-j)*(d*a) +(d-k)*a+1] = in[b-i][c-j][d-k]; end end end endgenerate


//没有出现rst时的dval_out异常高电平
`define DVAL_GEN_3(clk_in,rst_in,dval_in,dval_rst_in,dval_out)   generate begin reg  dval_in_buf; reg dval_name; always @ (posedge clk_in)begin if(rst_in)begin  dval_in_buf <= 0; dval_name <= 0;end else begin  dval_in_buf <= dval_in; dval_name   <= (dval_rst_in) ? 0 : dval_name ? 1 : (~dval_in_buf & dval_in);end  end  assign dval_out =  dval_name ; end endgenerate





//向上找最近的2的幂次方
function [15:0] f_upper_power;
input  [15:0] in;
begin
         if(in>0 && in<=2)     f_upper_power = 2 ;
    else if(in>2 && in<=4)     f_upper_power = 4 ;
    else if(in>4 && in<=8)     f_upper_power = 8 ;
    else if(in>8 && in<=16)    f_upper_power = 16;
    else if(in>16 && in<=32)   f_upper_power = 32;
    else if(in>32 && in<=64)   f_upper_power = 64;
    else if(in>64 && in<=128)  f_upper_power = 128;
    else if(in>128 && in<=256) f_upper_power = 256;
    else if(in>256 && in<=512) f_upper_power = 512;
    else                       f_upper_power = 512;
end
endfunction


//向下找最近的2的幂次方
function [15:0] f_lower_power;
input  [15:0] in;
begin
         if(in>=0 && in<2)     f_lower_power = 0 ;
    else if(in>=2 && in<4)     f_lower_power = 2 ;
    else if(in>=4 && in<8)     f_lower_power = 4 ;
    else if(in>=8 && in<16)    f_lower_power = 8;
    else if(in>=16 && in<32)   f_lower_power = 16;
    else if(in>=32 && in<64)   f_lower_power = 32;
    else if(in>=64 && in<128)  f_lower_power = 64;
    else if(in>=128 && in<256) f_lower_power = 128;
    else if(in>=256 && in<512) f_lower_power = 256;
    else                       f_lower_power = 512;
end
endfunction



   

//向上找最近的2的幂次方
function [31:0] f_upper_power;
input  [31:0] in;
begin
         if(in==0)                f_upper_power = 0;
    else if(in>2**0 && in<=2**1)  f_upper_power = 2**1;
    else if(in>2**1 && in<=2**2)  f_upper_power = 2**2;
    else if(in>2**2 && in<=2**3)  f_upper_power = 2**3;
    else if(in>2**3 && in<=2**4)  f_upper_power = 2**4;
    else if(in>2**4 && in<=2**5)  f_upper_power = 2**5;
    else if(in>2**5 && in<=2**6)  f_upper_power = 2**6;
    else if(in>2**6 && in<=2**7)  f_upper_power = 2**7;
    else if(in>2**7 && in<=2**8)  f_upper_power = 2**8;
    else if(in>2**8  && in<=2**9)  f_upper_power = 2**9;
    else if(in>2**9  && in<=2**10)  f_upper_power = 2**10;
    else if(in>2**10 && in<=2**11)  f_upper_power = 2**11;
    else if(in>2**11 && in<=2**12)  f_upper_power = 2**12;
    else if(in>2**12 && in<=2**13)  f_upper_power = 2**13;
    else if(in>2**13 && in<=2**14)  f_upper_power = 2**14;
    else if(in>2**14 && in<=2**15)  f_upper_power = 2**15;
    else if(in>2**15 && in<=2**16)  f_upper_power = 2**16;
    else                            f_upper_power = 2**15;
end
endfunction


//向下找最近的2的幂次方
function [31:0] f_lower_power;
input  [31:0] in;
begin       
         if(in==0)                f_lower_power = 0;
    else if(in>2**0 && in<=2**1)  f_lower_power = 2**0;
    else if(in>2**1 && in<=2**2)  f_lower_power = 2**1;
    else if(in>2**2 && in<=2**3)  f_lower_power = 2**2;
    else if(in>2**3 && in<=2**4)  f_lower_power = 2**3;
    else if(in>2**4 && in<=2**5)  f_lower_power = 2**4;
    else if(in>2**5 && in<=2**6)  f_lower_power = 2**5;
    else if(in>2**6 && in<=2**7)  f_lower_power = 2**6;
    else if(in>2**7 && in<=2**8)  f_lower_power = 2**7;
    else if(in>2**8  && in<=2**9)  f_lower_power = 2**8;
    else if(in>2**9  && in<=2**10)  f_lower_power = 2**9;
    else if(in>2**10 && in<=2**11)  f_lower_power = 2**10;
    else if(in>2**11 && in<=2**12)  f_lower_power = 2**11;
    else if(in>2**12 && in<=2**13)  f_lower_power = 2**12;
    else if(in>2**13 && in<=2**14)  f_lower_power = 2**13;
    else if(in>2**14 && in<=2**15)  f_lower_power = 2**14;
    else if(in>2**15 && in<=2**16)  f_lower_power = 2**15;
    else                            f_lower_power = 2**15;
end
endfunction








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



//axi lite 外部拼接代码
inout     [153:0]  S_AXI,


wire S_AXI_ACLK;
wire S_AXI_ARESETN;
wire S_AXI_AWREADY;
wire [31:0] S_AXI_AWADDR;
wire S_AXI_AWVALID;
wire [ 2:0] S_AXI_AWPROT;
wire S_AXI_WREADY;
wire [31:0] S_AXI_WDATA;
wire [ 3:0] S_AXI_WSTRB;
wire S_AXI_WVALID;
wire [ 1:0] S_AXI_BRESP;
wire S_AXI_BVALID;
wire S_AXI_BREADY;
wire S_AXI_ARREADY;
wire [31:0] S_AXI_ARADDR;
wire S_AXI_ARVALID;
wire [ 2:0] S_AXI_ARPROT;
wire [ 1:0] S_AXI_RRESP;
wire S_AXI_RVALID;
wire [31:0] S_AXI_RDATA;
wire S_AXI_RREADY;


assign S_AXI_ACLK = S_AXI[153:153];
assign S_AXI_ARESETN = S_AXI[152:152];
assign S_AXI[151:151] = S_AXI_AWREADY ;
assign S_AXI_AWADDR = S_AXI[150:119];
assign S_AXI_AWVALID = S_AXI[118:118];
assign S_AXI_AWPROT = S_AXI[117:115];
assign S_AXI[114:114] = S_AXI_WREADY;
assign S_AXI_WDATA = S_AXI[113:82];
assign S_AXI_WSTRB = S_AXI[81:78];
assign S_AXI_WVALID = S_AXI[77:77];
assign S_AXI[76:75] = S_AXI_BRESP;
assign S_AXI[74:74] = S_AXI_BVALID;
assign S_AXI_BREADY = S_AXI[73:73];
assign S_AXI[72:72] = S_AXI_ARREADY;
assign S_AXI_ARADDR = S_AXI[71:40];
assign S_AXI_ARVALID = S_AXI[39:39];
assign S_AXI_ARPROT = S_AXI[38:36];
assign S_AXI[35:34] = S_AXI_RRESP;
assign S_AXI[33:33] = S_AXI_RVALID;
assign S_AXI[32: 1] = S_AXI_RDATA;
assign S_AXI_RREADY = S_AXI[ 0: 0];




//axi4 外部拼接代码
    //only support
    //localparam integer C_M_AXI_ID_WIDTH        = 4,
    //localparam integer C_M_AXI_AWUSER_WIDTH    = 1,
    //localparam integer C_M_AXI_ARUSER_WIDTH    = 1,
    //localparam integer C_M_AXI_WUSER_WIDTH     = 1,
    //localparam integer C_M_AXI_RUSER_WIDTH     = 1,
    //localparam integer C_M_AXI_BUSER_WIDTH     = 1




inout  [ 1+1+4+C_M_AXI_ADDR_WIDTH+8+3+2+1+4+3+4+1+1+1+C_M_AXI_DATA_WIDTH+C_M_AXI_DATA_WIDTH/8+1+1+1+1+4+2+1+1+1 +4+C_M_AXI_ADDR_WIDTH+8+3+2+1+4+3+4+1+1+1+4+C_M_AXI_DATA_WIDTH+2+1+1+1+1-1 :0  ] S_AXI4 ;


 //连到master模块接口 
 wire  M_AXI_ACLK;                                 // Global Clock Signal.    
 wire  M_AXI_ARESETN;                              // Global Reset Singal. This Signal is Active Low
 wire [4-1 : 0]   M_AXI_AWID;                    // Master Interface Write Address ID
 wire [C_M_AXI_ADDR_WIDTH-1 : 0]  M_AXI_AWADDR;     // Master Interface Write Address
 wire  [7 : 0]                    M_AXI_AWLEN;      // The burst length gives the exact number of transfers in a burst
 wire [2 : 0]                    M_AXI_AWSIZE;     // This signal indicates the size of each transfer in the burst
 wire [1 : 0]                    M_AXI_AWBURST;    // determine how the address for each transfer within the burst is calculated.
 wire  M_AXI_AWLOCK;                               // Provides additional information about the atomic characteristics of the transfer.
 wire [3 : 0] M_AXI_AWCACHE;                       // This signal indicates how transactions are required to progress through a system.
 wire [2 : 0] M_AXI_AWPROT;                        // Protection type. 
 wire [3 : 0] M_AXI_AWQOS;                         // Quality of Service, QoS identifier sent for each write transaction.
 wire [1-1 : 0] M_AXI_AWUSER;                    // Optional User-defined signal in the write address channel.
 wire  M_AXI_AWVALID;                              // Write address valid. 
 wire  M_AXI_AWREADY;                               // Write address ready.
 wire [C_M_AXI_DATA_WIDTH-1 : 0] M_AXI_WDATA;      // Master Interface Write Data.
 wire [C_M_AXI_DATA_WIDTH/8-1 : 0] M_AXI_WSTRB;    // Write strobes. 
 wire  M_AXI_WLAST;                                // Write last. 
 wire [1-1 : 0] M_AXI_WUSER;     // Optional User-defined signal in the write data channel.
 wire  M_AXI_WVALID;                               // Write valid.
wire  M_AXI_WREADY;                                // Write ready. 
wire  [4-1 : 0] M_AXI_BID;           // Master Interface Write Response.
wire  [1 : 0] M_AXI_BRESP;                          // Write response. 
wire  [1-1 : 0] M_AXI_BUSER;      // Optional User-defined signal in the write response channel
wire  M_AXI_BVALID;                                // Write response valid. 
 wire  M_AXI_BREADY;                                // Response ready. 
 wire [4-1 : 0] M_AXI_ARID;         // Master Interface Read Address.
 wire [C_M_AXI_ADDR_WIDTH-1 : 0] M_AXI_ARADDR;     // Read address. 
 wire [7 : 0] M_AXI_ARLEN;                          // Burst length. 
 wire [2 : 0] M_AXI_ARSIZE;                        // Burst size. 
 wire [1 : 0] M_AXI_ARBURST;                       // Burst type. 
 wire  M_AXI_ARLOCK;                               // Lock type. 
 wire [3 : 0] M_AXI_ARCACHE;                       // Memory type. 
 wire [2 : 0] M_AXI_ARPROT;                        // Protection type. 
 wire [3 : 0] M_AXI_ARQOS;                         // Quality of Service
 wire [1-1 : 0] M_AXI_ARUSER;   // Optional User-defined signal in the read address channel.
 wire   M_AXI_ARVALID;                              // Write address valid. 
wire  M_AXI_ARREADY;                               // Read address ready. 
wire  [4-1 : 0] M_AXI_RID;           // Read ID tag. 
wire  [C_M_AXI_DATA_WIDTH-1 : 0] M_AXI_RDATA;       // Master Read Data
wire  [1 : 0] M_AXI_RRESP;                          // Read response. 
wire  M_AXI_RLAST;                                 // Read last. 
wire  [1-1 : 0] M_AXI_RUSER;      // Optional User-defined signal in the read address channel.
wire  M_AXI_RVALID;                                // Read valid. 
 wire  M_AXI_RREADY ;                              // Read ready.



assign M_AXI_ACLK = S_AXI4[(1+4+C_M_AXI_ADDR_WIDTH+8+3+2+1+4+3+4+1+1+1+C_M_AXI_DATA_WIDTH+C_M_AXI_DATA_WIDTH/8+1+1+1+1+4+2+1+1+1 +4+C_M_AXI_ADDR_WIDTH+8+3+2+1+4+3+4+1+1+1+4+C_M_AXI_DATA_WIDTH+2+1+1+1+1-1)+:1]                          ;
assign M_AXI_ARESETN =  S_AXI4[(4+C_M_AXI_ADDR_WIDTH+8+3+2+1+4+3+4+1+1+1+C_M_AXI_DATA_WIDTH+C_M_AXI_DATA_WIDTH/8+1+1+1+1+4+2+1+1+1 +4+C_M_AXI_ADDR_WIDTH+8+3+2+1+4+3+4+1+1+1+4+C_M_AXI_DATA_WIDTH+2+1+1+1+1-1)+:1]  ;
assign  S_AXI4[(C_M_AXI_ADDR_WIDTH+8+3+2+1+4+3+4+1+1+1+C_M_AXI_DATA_WIDTH+C_M_AXI_DATA_WIDTH/8+1+1+1+1+4+2+1+1+1 +4+C_M_AXI_ADDR_WIDTH+8+3+2+1+4+3+4+1+1+1+4+C_M_AXI_DATA_WIDTH+2+1+1+1+1-1)+:4] = M_AXI_AWID                        ;
assign  S_AXI4[(8+3+2+1+4+3+4+1+1+1+C_M_AXI_DATA_WIDTH+C_M_AXI_DATA_WIDTH/8+1+1+1+1+4+2+1+1+1 +4+C_M_AXI_ADDR_WIDTH+8+3+2+1+4+3+4+1+1+1+4+C_M_AXI_DATA_WIDTH+2+1+1+1+1-1)+:C_M_AXI_ADDR_WIDTH]  = M_AXI_AWADDR    ;
assign  S_AXI4[(3+2+1+4+3+4+1+1+1+C_M_AXI_DATA_WIDTH+C_M_AXI_DATA_WIDTH/8+1+1+1+1+4+2+1+1+1 +4+C_M_AXI_ADDR_WIDTH+8+3+2+1+4+3+4+1+1+1+4+C_M_AXI_DATA_WIDTH+2+1+1+1+1-1)+:8]  = M_AXI_AWLEN                     ;
assign  S_AXI4[(2+1+4+3+4+1+1+1+C_M_AXI_DATA_WIDTH+C_M_AXI_DATA_WIDTH/8+1+1+1+1+4+2+1+1+1 +4+C_M_AXI_ADDR_WIDTH+8+3+2+1+4+3+4+1+1+1+4+C_M_AXI_DATA_WIDTH+2+1+1+1+1-1)+:3]=M_AXI_AWSIZE                  ;
assign  S_AXI4[(1+4+3+4+1+1+1+C_M_AXI_DATA_WIDTH+C_M_AXI_DATA_WIDTH/8+1+1+1+1+4+2+1+1+1 +4+C_M_AXI_ADDR_WIDTH+8+3+2+1+4+3+4+1+1+1+4+C_M_AXI_DATA_WIDTH+2+1+1+1+1-1)+:2]  = M_AXI_AWBURST ;
assign  S_AXI4[(4+3+4+1+1+1+C_M_AXI_DATA_WIDTH+C_M_AXI_DATA_WIDTH/8+1+1+1+1+4+2+1+1+1 +4+C_M_AXI_ADDR_WIDTH+8+3+2+1+4+3+4+1+1+1+4+C_M_AXI_DATA_WIDTH+2+1+1+1+1-1)+:1] =M_AXI_AWLOCK                   ;
assign S_AXI4[(3+4+1+1+1+C_M_AXI_DATA_WIDTH+C_M_AXI_DATA_WIDTH/8+1+1+1+1+4+2+1+1+1 +4+C_M_AXI_ADDR_WIDTH+8+3+2+1+4+3+4+1+1+1+4+C_M_AXI_DATA_WIDTH+2+1+1+1+1-1)+:4]  =M_AXI_AWCACHE                   ;
assign  S_AXI4[(4+1+1+1+C_M_AXI_DATA_WIDTH+C_M_AXI_DATA_WIDTH/8+1+1+1+1+4+2+1+1+1 +4+C_M_AXI_ADDR_WIDTH+8+3+2+1+4+3+4+1+1+1+4+C_M_AXI_DATA_WIDTH+2+1+1+1+1-1)+:3] =M_AXI_AWPROT                   ;
assign S_AXI4[(1+1+1+C_M_AXI_DATA_WIDTH+C_M_AXI_DATA_WIDTH/8+1+1+1+1+4+2+1+1+1 +4+C_M_AXI_ADDR_WIDTH+8+3+2+1+4+3+4+1+1+1+4+C_M_AXI_DATA_WIDTH+2+1+1+1+1-1)+:4] =M_AXI_AWQOS                        ;
assign S_AXI4[(1+1+C_M_AXI_DATA_WIDTH+C_M_AXI_DATA_WIDTH/8+1+1+1+1+4+2+1+1+1 +4+C_M_AXI_ADDR_WIDTH+8+3+2+1+4+3+4+1+1+1+4+C_M_AXI_DATA_WIDTH+2+1+1+1+1-1)+:1]= M_AXI_AWUSER                     ;
assign  S_AXI4[(1+C_M_AXI_DATA_WIDTH+C_M_AXI_DATA_WIDTH/8+1+1+1+1+4+2+1+1+1 +4+C_M_AXI_ADDR_WIDTH+8+3+2+1+4+3+4+1+1+1+4+C_M_AXI_DATA_WIDTH+2+1+1+1+1-1)+:1] =M_AXI_AWVALID                   ;
assign M_AXI_AWREADY = S_AXI4[(C_M_AXI_DATA_WIDTH+C_M_AXI_DATA_WIDTH/8+1+1+1+1+4+2+1+1+1 +4+C_M_AXI_ADDR_WIDTH+8+3+2+1+4+3+4+1+1+1+4+C_M_AXI_DATA_WIDTH+2+1+1+1+1-1)+:1]                    ;
assign  S_AXI4[(C_M_AXI_DATA_WIDTH/8+1+1+1+1+4+2+1+1+1 +4+C_M_AXI_ADDR_WIDTH+8+3+2+1+4+3+4+1+1+1+4+C_M_AXI_DATA_WIDTH+2+1+1+1+1-1)+:C_M_AXI_DATA_WIDTH]= M_AXI_WDATA   ;
assign   S_AXI4[(1+1+1+1+4+2+1+1+1 +4+C_M_AXI_ADDR_WIDTH+8+3+2+1+4+3+4+1+1+1+4+C_M_AXI_DATA_WIDTH+2+1+1+1+1-1)+:C_M_AXI_DATA_WIDTH/8]=M_AXI_WSTRB  ;
assign   S_AXI4[(1+1+1+4+2+1+1+1 +4+C_M_AXI_ADDR_WIDTH+8+3+2+1+4+3+4+1+1+1+4+C_M_AXI_DATA_WIDTH+2+1+1+1+1-1)+:1] = M_AXI_WLAST                    ;
assign  S_AXI4[(1+1+4+2+1+1+1 +4+C_M_AXI_ADDR_WIDTH+8+3+2+1+4+3+4+1+1+1+4+C_M_AXI_DATA_WIDTH+2+1+1+1+1-1)+:1]= M_AXI_WUSER                      ;
assign   S_AXI4[(1+4+2+1+1+1 +4+C_M_AXI_ADDR_WIDTH+8+3+2+1+4+3+4+1+1+1+4+C_M_AXI_DATA_WIDTH+2+1+1+1+1-1)+:1] = M_AXI_WVALID                    ;
assign M_AXI_WREADY = S_AXI4[(4+2+1+1+1 +4+C_M_AXI_ADDR_WIDTH+8+3+2+1+4+3+4+1+1+1+4+C_M_AXI_DATA_WIDTH+2+1+1+1+1-1)+:1]                      ;
assign M_AXI_BID = S_AXI4[(2+1+1+1 +4+C_M_AXI_ADDR_WIDTH+8+3+2+1+4+3+4+1+1+1+4+C_M_AXI_DATA_WIDTH+2+1+1+1+1-1)+:4]                          ;
assign M_AXI_BRESP = S_AXI4[(1+1+1 +4+C_M_AXI_ADDR_WIDTH+8+3+2+1+4+3+4+1+1+1+4+C_M_AXI_DATA_WIDTH+2+1+1+1+1-1)+:2]                        ;
assign M_AXI_BUSER= S_AXI4[(1+1 +4+C_M_AXI_ADDR_WIDTH+8+3+2+1+4+3+4+1+1+1+4+C_M_AXI_DATA_WIDTH+2+1+1+1+1-1)+:1]                         ;
assign M_AXI_BVALID= S_AXI4[(1 +4+C_M_AXI_ADDR_WIDTH+8+3+2+1+4+3+4+1+1+1+4+C_M_AXI_DATA_WIDTH+2+1+1+1+1-1)+:1]                        ;
assign   S_AXI4[(4+C_M_AXI_ADDR_WIDTH+8+3+2+1+4+3+4+1+1+1+4+C_M_AXI_DATA_WIDTH+2+1+1+1+1-1)+:1] = M_AXI_BREADY                   ;


    
assign   S_AXI4[(C_M_AXI_ADDR_WIDTH+8+3+2+1+4+3+4+1+1+1+4+C_M_AXI_DATA_WIDTH+2+1+1+1+1-1)+:4] = M_AXI_ARID                  ;
assign  S_AXI4[(8+3+2+1+4+3+4+1+1+1+4+C_M_AXI_DATA_WIDTH+2+1+1+1+1-1)+:C_M_AXI_ADDR_WIDTH] = M_AXI_ARADDR ;
assign  S_AXI4[(3+2+1+4+3+4+1+1+1+4+C_M_AXI_DATA_WIDTH+2+1+1+1+1-1)+:8]  = M_AXI_ARLEN                ;
assign   S_AXI4[(2+1+4+3+4+1+1+1+4+C_M_AXI_DATA_WIDTH+2+1+1+1+1-1)+:3]  = M_AXI_ARSIZE                ;
assign   S_AXI4[(1+4+3+4+1+1+1+4+C_M_AXI_DATA_WIDTH+2+1+1+1+1-1)+:2]  = M_AXI_ARBURST                ;
assign    S_AXI4[(4+3+4+1+1+1+4+C_M_AXI_DATA_WIDTH+2+1+1+1+1-1)+:1] = M_AXI_ARLOCK                  ;
assign    S_AXI4[(3+4+1+1+1+4+C_M_AXI_DATA_WIDTH+2+1+1+1+1-1)+:4] = M_AXI_ARCACHE                 ;
assign  S_AXI4[(4+1+1+1+4+C_M_AXI_DATA_WIDTH+2+1+1+1+1-1)+:3] = M_AXI_ARPROT                 ;
assign    S_AXI4[(1+1+1+4+C_M_AXI_DATA_WIDTH+2+1+1+1+1-1)+:4] =M_AXI_ARQOS                  ;
assign   S_AXI4[(1+1+4+C_M_AXI_DATA_WIDTH+2+1+1+1+1-1)+:1] = M_AXI_ARUSER                 ;
assign   S_AXI4[(1+4+C_M_AXI_DATA_WIDTH+2+1+1+1+1-1)+:1] = M_AXI_ARVALID                 ;
assign  M_AXI_ARREADY = S_AXI4[(4+C_M_AXI_DATA_WIDTH+2+1+1+1+1-1)+:1]                                    ;
assign M_AXI_RID =  S_AXI4[(C_M_AXI_DATA_WIDTH+2+1+1+1+1-1)+:4]                                        ;
assign M_AXI_RDATA =  S_AXI4[(2+1+1+1+1-1)+:C_M_AXI_DATA_WIDTH]                    ;
assign  M_AXI_RRESP = S_AXI4[(1+1+1+1-1)+:2]                                     ;
assign  M_AXI_RLAST = S_AXI4[(1+1+1-1)+:1]                                      ;
assign  M_AXI_RUSER = S_AXI4[(1+1-1)+:1]                                     ;
assign  M_AXI_RVALID = S_AXI4[(1-1)+:1]                     ;               ;
assign    S_AXI4[(0)+:1]  = M_AXI_RREADY                ;





function integer clog2;  //check ok
    input integer value;
    begin
        value = value - 1;
        for (clog2 = 0; value > 0; clog2 = clog2 + 1) begin
            value = value >> 1;
        end
    end
endfunction
