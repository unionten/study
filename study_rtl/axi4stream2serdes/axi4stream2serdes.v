`timescale 1ns / 1ps
`define CDC_SINGLE_BIT_PULSE_OUTGEN(aclk,arst,apulse_in,bclk,brst,bpulse_out,SIM,DEST_FF)               generate if(SIM==0)begin  xpm_cdc_pulse #(.DEST_SYNC_FF(DEST_FF), .INIT_SYNC_FF(0),.REG_OUTPUT(0),.RST_USED(1),.SIM_ASSERT_CHK (0)) cdc_u (.src_clk(aclk),.src_rst(arst),.src_pulse(apulse_in),.dest_clk(bclk),.dest_rst(brst),.dest_pulse(bpulse_out));   end else begin   reg [5:0] name1 = 0;wire name2;always@(posedge aclk)if(arst)name1[0] <=0;else name1[0] <= apulse_in;assign name2 = apulse_in & ~name1[0]; always@(posedge aclk)if(arst)name1[1] <= 0;else name1[1] <= name2 ? ~name1[1]:name1[1];always@(posedge bclk)if(brst)name1[5:2]<=0;else begin name1[2]<=name1[1];name1[3]<=name1[2];name1[4]<=name1[3];name1[5]<=name1[4];end  assign bpulse_out=name1[4]^name1[5];  end  endgenerate
`define POS_MONITOR_OUTGEN(clk,rst,in,out)                                                              generate  begin  reg buf_name1 = 0; always@(posedge clk)begin if(rst)buf_name1 <= 0; else  buf_name1 <= in; end assign out = (~buf_name1)&(in);  end  endgenerate
`define NEG_MONITOR_OUTGEN(clk,rst,in,out)                                                              generate  begin  reg buf_name1 = 0; always@(posedge clk)begin if(rst)buf_name1 <= 0; else  buf_name1 <= in; end assign out = (buf_name1)&(~in);  end  endgenerate
`define HANDSHAKE_OUTGEN(aclk,arst,apulse_in,adata_in,bclk,brst,bpulse_out,bdata_out,DATA_WIDTH,SIM)    generate  if(SIM==0) begin  handshake  #(.C_DATA_WIDTH(DATA_WIDTH))  handshake_u (.SRC_CLK_I(aclk),.SRC_RST_I(arst),.SRC_DATA_I( adata_in),.SRC_SYNC_PULSE_I ( apulse_in), .DST_CLK_I ( bclk),.DST_DATA_O (bdata_out),.DST_SYNC_FINISH_O(bpulse_out) ); end  else  begin  handshake2 #(.C_DATA_WIDTH(DATA_WIDTH))  handshake_u (.SRC_CLK_I(aclk),.SRC_RST_I(arst),.SRC_DATA_I( adata_in),.SRC_SYNC_PULSE_I ( apulse_in), .DST_CLK_I (bclk),.DST_DATA_O (bdata_out ),.DST_SYNC_FINISH_O(bpulse_out) ); end  endgenerate   

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/11/28 16:02:09
// Design Name: 
// Module Name: axi4stream2serdes
// Project Name: 
// Target Devices: 
//////////////////////////////////////////////////////////////////////////////////


module axi4stream2serdes(
input                     M_CLK_I        ,  
input                     M_RST_I        ,
output   [MDATA_WIDTH-1:0] M_DATA_O       ,//check CRC in this module  serdes端数据是连续的

input                     M_SEND_ACK_I   ,
output                    M_SEND_SUCC_O  ,
output                    M_WAIT_ACK_O   ,
input                     M_WAIT_SUCC_I  ,

input                     S_CLK_I       ,
input                     S_RST_I       ,
input  [AWPORT_WIDTH-1:0] S_AWPORT      ,
input  [AWLEN_WIDTH-1:0]  S_AWLEN       ,
input  [AWSIZE_WIDTH-1:0] S_AWSIZE      ,
input                     S_AWVALID     ,
output  reg               S_AWREADY     ,
input                     S_WVALID      ,  // lite端数据可以不连续
output                    S_WREADY      ,
input  [SDATA_WIDTH-1:0]  S_WDATA       ,  
input  [SDATA_WIDTH/8-1:0]S_WSTRB       ,
input                     S_WLAST         //输出端采用多拉数据的方式; 传递的是实际字节数和总字节数


);
 
        
parameter   SDATA_WIDTH       = 64   ;
parameter   MDATA_WIDTH       = 8 ; 
parameter   AWPORT_WIDTH      = 2   ;
parameter   AWLEN_WIDTH       = 16  ;
parameter   AWSIZE_WIDTH      = 16  ;
parameter   WAIT_ACK_TIME_OUT = 1000;//外部通知本模块接收ACK时，多久没收到后退出
parameter   RX_CHECK_CRC_EN   = 0;
  
//接收端


assign S_WREADY = (~tx_wr_full) & (~tx_rst_busy) & (state_s== 2);


reg [7:0] state_s; 
reg [15:0] beat_num;
reg [7:0] last_byte_num;
reg [31:0] last_strb;

always@(* )begin
    case(last_strb)
        8'b00000001:last_byte_num=1;
        8'b00000011:last_byte_num=2;
        8'b00000111:last_byte_num=3;
        8'b00001111:last_byte_num=4;
        8'b00011111:last_byte_num=5;
        8'b00111111:last_byte_num=6;
        8'b01111111:last_byte_num=7;
        8'b11111111:last_byte_num=8;
        default:last_byte_num=8;
    endcase
end 


reg trig_s   ;       
reg [15:0] trig_total_beat ;
reg [15:0] trig_actual_beat;



always@(posedge S_CLK_I)begin
    if(S_RST_I)begin
        state_s <= 0;
        beat_num <= 0;
        trig_s <= 0;
    end
    else begin
        case(state_s)
            0:begin
                S_AWREADY <= S_AWVALID ? 1 : 0 ;
                state_s <= S_AWVALID ? 1 : state_s;
            end
            1:begin
                state_s <= S_AWREADY & S_AWVALID ? 2 : state_s;
            end
            2:begin
                beat_num <= S_WVALID & S_WREADY ? beat_num + 1 : beat_num;
                state_s    <= S_WVALID & S_WREADY & S_WLAST ? 3 : state_s;
                last_strb <= S_WVALID & S_WREADY & S_WLAST ? S_WSTRB : 32'hffffffffffffffff;
            end
            3:begin//通知另一侧发出
                trig_s           <= 1;
                trig_total_beat <= beat_num*(SDATA_WIDTH/MDATA_WIDTH) ;  //m端的total beat
                trig_actual_beat<= (beat_num-1)*(SDATA_WIDTH/MDATA_WIDTH)+ last_byte_num  ; //m端的实际beat
                state_s <= 4;
            end
            4:begin
                trig_s  <= 0;
                state_s <= 0; 
                beat_num <= 0;                
            end
            default:;
        endcase
    end
end 

 

wire [7:0] m_data_fifo;
 
fifo_async_xpm  
   #(.C_WR_WIDTH             (SDATA_WIDTH          ),
     .C_WR_DEPTH             (1024                 ),
     .C_RD_WIDTH             (MDATA_WIDTH           ),
     .C_WR_COUNT_WIDTH       (16),
     .C_RD_COUNT_WIDTH       (16),
     //.C_RD_PROG_EMPTY_THRESH (),
     //.C_WR_PROG_FULL_THRESH  (),
     .C_RD_MODE              ("fwft"   ), 
     //.C_DBG_COUNT_WIDTH      (16),
      .C_RELATED_CLOCKS       (0)
    )
   fifo_tx_u( //cmd type
   .WR_RST_I         (S_RST_I                      ),
   .WR_CLK_I         (S_CLK_I                      ),
   .WR_EN_I          (S_WVALID & S_WREADY          ),
   .WR_EN_VALID_O    (                             ),
   .WR_EN_NAMES_O    (                             ),
   .WR_EN_ACCUS_O    (                             ),
   .WR_DATA_I        (S_WDATA                      ),
   .WR_FULL_O        ( tx_wr_full                  ),
   .WR_DATA_COUNT_O  (                             ), 
   .WR_PROG_FULL_O   (                             ),
   .WR_RST_BUSY_O    ( tx_rst_busy                 ),

   .RD_RST_I         (M_RST_I                      ), 
   .RD_CLK_I         (M_CLK_I                      ),
   .RD_EN_I          (   rd                     ),
   .RD_EN_NAMES_O    (                             ),
   .RD_EN_ACCUS_O    (                             ),
   .RD_DATA_VALID_O  (                             ),
   .RD_DATA_O        ( m_data_fifo                 ),
   .RD_EMPTY_O       (                   ),
   .RD_DATA_COUNT_O  (                             ),
   .RD_PROG_EMPTY_O  (                             ),
   .RD_RST_BUSY_O    (                )
   );




wire trig_m;
wire [15:0] trig_total_beat_m;
wire [15:0] trig_actual_beat_m;

//`CDC_SINGLE_BIT_PULSE_OUTGEN(S_CLK_I,S_RST_I,trig_s,M_CLK_I,M_RST_I,trig_m,0,4)

handshake #(.C_DATA_WIDTH(32)) hs_u0(
    .SRC_CLK_I        ( S_CLK_I ),
    .SRC_RST_I        ( S_RST_I ),
    .SRC_DATA_I       ({trig_total_beat,trig_actual_beat}),//[C_DATA_WIDTH-1:0]
    .SRC_SYNC_PULSE_I (trig_s ),
    .SRC_SYNC_FINISH_O(),
    .DST_CLK_I        (M_CLK_I ),
    .DST_DATA_O       ({trig_total_beat_m,trig_actual_beat_m}),//[C_DATA_WIDTH-1:0]
    .DST_SYNC_FINISH_O(trig_m));




reg rd = 0;
reg [7:0] state_m;
reg [15:0] cnt_actual_m;
reg [15:0] cnt_comp_m;
reg sel;
reg [7:0] m_data;

always@(posedge M_CLK_I)begin
    if(M_RST_I)begin
        state_m <= 0;
        m_data <= 8'hff;
        sel <= 0;
        rd <= 0;
    end
    else begin
        case(state_m)
            0:begin
                state_m      <= trig_m ? 1 : state_m ;
                cnt_actual_m <= trig_m ? trig_actual_beat_m : cnt_actual_m;
                cnt_comp_m   <= trig_m ? (trig_total_beat_m-trig_actual_beat_m) : cnt_comp_m ;
            end
            1:begin
                m_data <= 8'h00;  
                state_m  <= 2;
            end
            2:begin 
                sel <= 1;
                rd <= 1;
                state_m <= 3; 
            end
            3:begin
                cnt_actual_m <= rd ? cnt_actual_m - 1 : cnt_actual_m;
                //rd <= cnt_actual_m==1 ? 0 : 1;
                state_m <= cnt_actual_m==1 ? 4 : state_m;
                sel <= cnt_actual_m==1 ? 0 : 1;
            end
            4:begin
                cnt_comp_m <= rd ? cnt_comp_m - 1: cnt_comp_m ;
                rd <= cnt_comp_m==1 ? 0 : 1;
                m_data <= 8'h00;
                state_m <= cnt_comp_m==1 ? 5 : state_m; 
            end
            5:begin
                m_data <= 8'hFF;
                state_m <= 0;
            end
            default:;
        endcase
    end
end


assign M_DATA_O = sel ? m_data_fifo : m_data ;

  
endmodule



