`timescale 1ns / 1ps

`define CDC_MULTI_BIT_SIGNAL_OUTGEN(aclk,adata_in,bclk,bdata_out,DATA_WIDTH,DEST_FF)                    generate begin xpm_cdc_array_single #(.DEST_SYNC_FF(DEST_FF),.INIT_SYNC_FF(0),.SIM_ASSERT_CHK(0),.SRC_INPUT_REG(1),.WIDTH(DATA_WIDTH)) cdc_u(.src_clk(aclk),.src_in(adata_in),.dest_clk(bclk),.dest_out(bdata_out));    end  endgenerate  
`define CDC_MULTI_BIT_SIGNAL_OUTGEN_NOIN(adata_in,bclk,bdata_out,DATA_WIDTH,DEST_FF)                    generate begin xpm_cdc_array_single #(.DEST_SYNC_FF(DEST_FF),.INIT_SYNC_FF(0),.SIM_ASSERT_CHK(0),.SRC_INPUT_REG(0),.WIDTH(DATA_WIDTH)) cdc_u(.src_clk( ),.src_in(adata_in),.dest_clk(bclk),.dest_out(bdata_out));    end  endgenerate  
`define CDC_SINGLE_BIT_PULSE_OUTGEN(aclk,arst,apulse_in,bclk,brst,bpulse_out,SIM,DEST_FF)               generate if(SIM==0)begin  xpm_cdc_pulse #(.DEST_SYNC_FF(DEST_FF), .INIT_SYNC_FF(0),.REG_OUTPUT(0),.RST_USED(1),.SIM_ASSERT_CHK (0)) cdc_u (.src_clk(aclk),.src_rst(arst),.src_pulse(apulse_in),.dest_clk(bclk),.dest_rst(brst),.dest_pulse(bpulse_out));   end else begin   reg [5:0] name1 = 0;wire name2;always@(posedge aclk)if(arst)name1[0] <=0;else name1[0] <= apulse_in;assign name2 = apulse_in & ~name1[0]; always@(posedge aclk)if(arst)name1[1] <= 0;else name1[1] <= name2 ? ~name1[1]:name1[1];always@(posedge bclk)if(brst)name1[5:2]<=0;else begin name1[2]<=name1[1];name1[3]<=name1[2];name1[4]<=name1[3];name1[5]<=name1[4];end  assign bpulse_out=name1[4]^name1[5];  end  endgenerate
`define POS_MONITOR_OUTGEN(clk,rst,in,out)                                                              generate  begin  reg buf_name1 = 0; always@(posedge clk)begin if(rst)buf_name1 <= 0; else  buf_name1 <= in; end assign out = (~buf_name1)&(in);  end  endgenerate
`define HANDSHAKE_OUTGEN(aclk,arst,apulse_in,adata_in,bclk,brst,bpulse_out,bdata_out,DATA_WIDTH,SIM)    generate  if(SIM==0) begin  handshake  #(.C_DATA_WIDTH(DATA_WIDTH))  handshake_u (.SRC_CLK_I(aclk),.SRC_RST_I(arst),.SRC_DATA_I( adata_in),.SRC_SYNC_PULSE_I ( apulse_in), .DST_CLK_I ( bclk),.DST_DATA_O (bdata_out),.DST_SYNC_FINISH_O(bpulse_out) ); end  else  begin  handshake2 #(.C_DATA_WIDTH(DATA_WIDTH))  handshake_u (.SRC_CLK_I(aclk),.SRC_RST_I(arst),.SRC_DATA_I( adata_in),.SRC_SYNC_PULSE_I ( apulse_in), .DST_CLK_I (bclk),.DST_DATA_O (bdata_out ),.DST_SYNC_FINISH_O(bpulse_out) ); end  endgenerate   


//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/02/29 09:50:36
// Design Name: 
// Module Name: drp_cconverter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//////////////////////////////////////////////////////////////////////////////////


module drp_cconverter(
input                      S_DRPCLK_I  ,
input                      S_DRPRST_I  ,
input  [C_ADDR_WIDTH-1:0]  S_DRPADDR_I ,
input  [C_DATA_WIDTH-1:0]  S_DRPDI_I   ,
output [C_DATA_WIDTH-1:0]  S_DRPDO_O   ,
input                      S_DRPEN_I   ,
input                      S_DRPWE_I   ,
output                     S_DRPRDY_O  ,

input                      M_DRPCLK_I  ,
input                      M_DRPRST_I  ,
output [C_ADDR_WIDTH-1:0]  M_DRPADDR_O ,
output [C_DATA_WIDTH-1:0]  M_DRPDI_O   ,
input  [C_DATA_WIDTH-1:0]  M_DRPDO_I   ,
output                     M_DRPEN_O   ,
output                     M_DRPWE_O   ,
input                      M_DRPRDY_I  

);

parameter  C_ADDR_WIDTH =  12;
parameter  C_DATA_WIDTH =  16;

//思路：因为在drp信号跨时钟过程中，没有特别双向同时发生的信号
// 所以跨时钟过程就是简单的使用跨时钟 handshake 组件

`HANDSHAKE_OUTGEN(S_DRPCLK_I,S_DRPRST_I,S_DRPEN_I,{S_DRPWE_I,S_DRPDI_I,S_DRPADDR_I},M_DRPCLK_I,M_DRPRST_I,M_DRPEN_O,{M_DRPWE_O,M_DRPDI_O,M_DRPADDR_O},C_ADDR_WIDTH+C_DATA_WIDTH+1,0)

`HANDSHAKE_OUTGEN(M_DRPCLK_I,M_DRPRST_I,M_DRPRDY_I,M_DRPDO_I,S_DRPCLK_I,S_DRPRST_I,S_DRPRDY_O,S_DRPDO_O,C_DATA_WIDTH,0)



endmodule
