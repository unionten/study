`timescale 1ns / 1ps
`define HANDSHAKE_OUTGEN(aclk,arst,apulse_in,adata_in,bclk,brst,bpulse_out,bdata_out,DATA_WIDTH,SIM)    generate  if(SIM==0) begin  handshake  #(.C_DATA_WIDTH(DATA_WIDTH))  handshake_u (.SRC_CLK_I(aclk),.SRC_RST_I(arst),.SRC_DATA_I( adata_in),.SRC_SYNC_PULSE_I ( apulse_in), .DST_CLK_I ( bclk),.DST_DATA_O (bdata_out),.DST_SYNC_FINISH_O(bpulse_out) ); end  else  begin  handshake2 #(.C_DATA_WIDTH(DATA_WIDTH))  handshake_u (.SRC_CLK_I(aclk),.SRC_RST_I(arst),.SRC_DATA_I( adata_in),.SRC_SYNC_PULSE_I ( apulse_in), .DST_CLK_I (bclk),.DST_DATA_O (bdata_out ),.DST_SYNC_FINISH_O(bpulse_out) ); end  endgenerate   
`define CDC_MULTI_BIT_SIGNAL_OUTGEN(aclk,adata_in,bclk,bdata_out,DATA_WIDTH,DEST_FF)                    generate begin xpm_cdc_array_single #(.DEST_SYNC_FF(DEST_FF),.INIT_SYNC_FF(0),.SIM_ASSERT_CHK(0),.SRC_INPUT_REG(1),.WIDTH(DATA_WIDTH)) cdc_u(.src_clk(aclk),.src_in(adata_in),.dest_clk(bclk),.dest_out(bdata_out));    end  endgenerate  
`define POS_MONITOR_OUTGEN(clk,rst,in,out)                                                              generate  begin  reg buf_name1 = 0; always@(posedge clk)begin if(rst)buf_name1 <= 0; else  buf_name1 <= in; end assign out = (~buf_name1)&(in);  end  endgenerate
`define NEG_MONITOR_OUTGEN(clk,rst,in,out)                                                              generate  begin  reg buf_name1 = 0; always@(posedge clk)begin if(rst)buf_name1 <= 0; else  buf_name1 <= in; end assign out = (buf_name1)&(~in);  end  endgenerate


//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/04 15:20:27
// Design Name: 
// Module Name: drp_init_read
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//////////////////////////////////////////////////////////////////////////////////
//针对不同默认配置的工程，通过触发读取默认配置参数
//通过触发 读取drp的内容（不需要和串口通信）
module drp_init_read_rtl(
input                             DRPCLK_I     ,
input                             DRPRSTN_I    ,
output reg [C_DRP_ADDR_WIDTH-1:0] M_DRPADDR_O  = 0 ,
output reg [C_DRP_DATA_WIDTH-1:0] M_DRPDI_O    = 0 ,
input  [C_DRP_DATA_WIDTH-1:0]     M_DRPDO_I    ,
output reg                        M_DRPEN_O    = 0 ,
output reg                        M_DRPWE_O    = 0 ,
input                             M_DRPRDY_I   ,
input VIO_TRIG_vio_drp

);
parameter C_DRP_ADDR_WIDTH = 16;
parameter C_DRP_DATA_WIDTH = 16;
parameter [15:0] C_DRP_START_ADDR = 16'h0000;
parameter [15:0] C_DRP_STOP_ADDR  = 16'h028c;
parameter C_SYS_CLK_PRD = 10;
parameter C_BAUD_RATE  = 115200 ;
parameter [0:0] C_ILA_DRP_ENABLE = 1; 

//M_DRPDO_I 
//M_DRPRDY_I
reg [7:0] state_drp = 0;
reg  uart_trig_drp = 0;
wire uart_busy_drp;
wire uart_finish_drp;
reg [15:0] uart_data_drp = 0;
wire uart_busy_drp_neg;
reg [15:0] uart_addr_drp = 0;

wire uart_trig;
wire [15:0] uart_data;
wire [7:0]  uart_data_ascii [3:0] ;
wire [15:0] uart_addr;
wire [7:0]  uart_addr_ascii [3:0] ;
wire uart_busy;
wire uart_finish;

wire VIO_TRIG_vio_drp_pos;

`POS_MONITOR_OUTGEN(DRPCLK_I,0,VIO_TRIG_vio_drp,VIO_TRIG_vio_drp_pos) 
always@(posedge DRPCLK_I)begin
    if(~DRPRSTN_I)begin
        M_DRPADDR_O   <= 0;
        M_DRPEN_O     <= 0;
        state_drp     <= 0;  
        uart_trig_drp <= 0;
        uart_data_drp <= 0;
        uart_addr_drp <= 0;
    end
    else begin
        case(state_drp)
            0:begin
                state_drp   <= VIO_TRIG_vio_drp_pos ? 1 : state_drp ;
                M_DRPADDR_O <= C_DRP_START_ADDR ; 
            end
            1:begin
                M_DRPADDR_O <= M_DRPADDR_O ;
                M_DRPEN_O   <= 1; 
                state_drp   <= 2;
            end
            2:begin //在drp时钟域下等待 rdy
                M_DRPEN_O     <= 0;
                state_drp     <= M_DRPRDY_I ? 3 :state_drp;
                uart_trig_drp <= M_DRPRDY_I ? 1 : 0; 
                uart_data_drp <= M_DRPRDY_I ? M_DRPDO_I : uart_data_drp ; 
                uart_addr_drp <= M_DRPADDR_O ;
            end
            3:begin//等待发送完毕
                uart_trig_drp <= 0;
                state_drp     <=   M_DRPADDR_O==C_DRP_STOP_ADDR ? 0 : 1   ;
                M_DRPADDR_O   <=  M_DRPADDR_O + 1   ;
            end
            default:; 
        endcase
    end
end



    
endmodule
