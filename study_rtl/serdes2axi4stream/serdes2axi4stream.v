`timescale 1ns / 1ps

`define DELAY_OUTGEN(clk,rst,data_in,data_out,DATA_WIDTH,DLY)                                           generate if(DLY==0)begin  assign data_out = data_in; end  else if(DLY==1)begin  reg [DATA_WIDTH-1:0] a_temp = 0; always@(posedge clk) a_temp <= data_in; assign data_out = a_temp ; end  else begin  reg [DATA_WIDTH-1:0] a_temp [DLY-1:0] ;always@(posedge clk) begin  if(rst)a_temp[DLY-1] <= 0; else   a_temp[DLY-1] <= data_in; end  for(i=0;i<=DLY-2;i=i+1)begin  always@(posedge clk)begin  if(rst)begin  a_temp[i] <= 0; end  else begin  a_temp[i] <= a_temp[i+1]; end  end  end  assign data_out = a_temp[0]; end  endgenerate


//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/11/25 11:10:37
// Design Name: 
// Module Name: serdes2axi4stream
// Project Name: 
//////////////////////////////////////////////////////////////////////////////////
//

//1 serdes来的数据可能有误码，所以会做crc检查
//2 而对于axi4stream 转serdes，不需要做crc检查； 而且axi4转serdes是宽转窄，所以也不需要进行处理


module serdes2axi4stream(
input                    S_CLK_I        ,  
input                    S_RST_I        ,
input  [SDATA_WIDTH-1:0] S_DATA_I       ,//check CRC in this module   serdes端数据是连续的
output  reg               S_SEND_ACK_O   ,
input                    S_SEND_SUCC_I  ,
input                    S_WAIT_ACK_I   ,
output   reg              S_WAIT_SUCC_O  ,

input                     M_CLK_I       ,
input                     M_RST_I       ,
output [AWPORT_WIDTH-1:0] M_AWPORT      ,
output [AWLEN_WIDTH-1:0]  M_AWLEN       ,
output [AWSIZE_WIDTH-1:0] M_AWSIZE      ,
output                    M_AWVALID     ,
input                     M_AWREADY     ,
output                    M_WVALID      , // lite端数据可以不连续
input                     M_WREADY      ,
output [MDATA_WIDTH-1:0]  M_WDATA       ,  
output [MDATA_WIDTH/8-1:0]M_WSTRB       ,
output                    M_WLAST        


);
    
parameter   SDATA_WIDTH  = 8   ;
parameter   MDATA_WIDTH  = 64 ; 
parameter   AWPORT_WIDTH = 2   ;
parameter   AWLEN_WIDTH  = 16  ;
parameter   AWSIZE_WIDTH = 16  ;
parameter   WAIT_ACK_TIME_OUT = 1000;//外部通知本模块接收ACK时，多久没收到后退出
parameter   RX_CHECK_CRC_EN = 0;
  
  
genvar i,j,k;
  
//尚无初始化
//SOP 
localparam  STATE_SDS_SOP       =  0 , // 如果为0则进入sop
            STATE_INS_SOP1    =  1 , //00000
            STATE_INS_SOP2   =  2 , //a5 //此时已经开始写入，并计算CRC
            STATE_ID_HIGH    =  4 ,
            STATE_ID_LOW     =  5 ,
            STATE_FLAG       =  6 ,
            STATE_BYTE_HIGH  =  7 ,
            STATE_BYTE_LOW   =  8 ,
            STATE_RESERVE    =  9 ,
            STATE_DAT        =  10 , //获取实际数据
            STATE_CRC        =  11 , //判断crc
            STATE_WAIT_EOP   =  12 , //等待结束
            STATE_SEND_ACK   =  13 , //请求发送反馈的ACK
            STATE_SEND_SUCC  =  14 , //反馈的ACK发送完成
            STATE_WAIT_ACK   =  15 , //进入等待对方ACK
            STATE_WAIT_ACK2  =  16 ,
            STATE_ACK_EOP    =  17 ,
            STATE_WAIT_SUCC  =  18 , //等待对方ACK完成
            STATE_FILL       =  19 ,
            STATE_CRC1       =  20 ,
            STATE_CRC2       =  21 ;
 


reg [7:0] state;
reg [15:0] cnt_byte_left;
reg succ_flag;
reg [7:0] cnt_fill;

wire [SDATA_WIDTH-1:0] S_DATA_I_s2;



//数据FFFFFFFFFFF000000A5A5IDIDAABBBBSSDDDDDDDDDDDDDDCRC00000FFFFFFFFF
always@(posedge S_CLK_I)begin
    if(S_RST_I)begin
        state <= STATE_SDS_SOP;
    end
    else begin
        case(state)
            STATE_SDS_SOP   : state <= S_DATA_I==8'h00 ? STATE_INS_SOP1  : S_WAIT_ACK_I ?  STATE_WAIT_ACK  : STATE_SDS_SOP    ;
            STATE_INS_SOP1  : state <= S_DATA_I==8'ha5 ? STATE_INS_SOP2 : STATE_INS_SOP1 ; //如果为00则一直等待,如果检测到非00,非A5,则判断异常
            STATE_INS_SOP2  : state <= S_DATA_I==8'ha5 ? STATE_ID_HIGH : STATE_SDS_SOP    ;
            STATE_ID_HIGH  : state <= STATE_ID_LOW  ;
            STATE_ID_LOW   : state <= STATE_FLAG    ;
            STATE_FLAG     : state <= STATE_BYTE_HIGH ;
            STATE_BYTE_HIGH: state <= STATE_BYTE_LOW  ; //根据计数来决定收多少字节
            STATE_BYTE_LOW : state <= STATE_RESERVE   ;
            STATE_RESERVE  : begin state <= STATE_DAT ; cnt_bytes_total_left <= bytes_total ;  end
            STATE_DAT      : begin cnt_bytes_total_left <= cnt_bytes_total_left - 1 ; state <= cnt_bytes_total_left==1 ? STATE_CRC : STATE_DAT ; end
            STATE_CRC      : state <= STATE_CRC1 ;
            STATE_CRC1     : state <= STATE_CRC2 ;
            STATE_CRC2     : state <= STATE_WAIT_EOP ;
            STATE_WAIT_EOP : state <= S_DATA_I==8'hFF ? succ_flag ? STATE_SEND_ACK : STATE_SDS_SOP : STATE_WAIT_EOP;        
            STATE_SEND_ACK : state <= S_SEND_SUCC_I ? STATE_SDS_SOP : STATE_SEND_ACK ;
            
            STATE_WAIT_ACK : state <= cnt_wait_ack_time_out==0 ?  STATE_SDS_SOP: ( S_DATA_I==8'h00 ? STATE_WAIT_ACK2 : STATE_WAIT_ACK ) ;//是否需要检测00
            STATE_WAIT_ACK2: state <= cnt_wait_ack_time_out==0 ?  STATE_SDS_SOP: ( S_DATA_I==8'hee ? STATE_ACK_EOP : STATE_WAIT_ACK2 );
            STATE_ACK_EOP  : state <= cnt_wait_ack_time_out==0 ?  STATE_SDS_SOP: ( S_DATA_I==8'hFF ? STATE_WAIT_SUCC : STATE_ACK_EOP) ;
            STATE_WAIT_SUCC : ; 
            default:;
        endcase
    end
end

//____|—————————————|______
//----///////////////--
//________________|—|_____
//--------------------|——|-____ 补齐在
//succ 需要稍微延后 -------------------|—|---

reg wr_en_s2;
reg succ;
reg fail;

//BUF
reg [7:0] reg_id_high =0;
reg [7:0] reg_id_low=0;
reg [7:0] reg_flag=0;
reg [7:0] reg_bytes_high=0;
reg [7:0] reg_bytes_low=0;
reg [7:0] reg_reserve=0;


wire [15:0] bytes_total;
assign bytes_total = {reg_bytes_high,reg_bytes_low};
reg [15:0] cnt_bytes_total_left;

reg [7:0] crc_recv;



reg crc_en;


`DELAY_OUTGEN(S_CLK_I,S_RST_I,S_DATA_I,S_DATA_I_s2,SDATA_WIDTH,2)
wire [7:0] crc_calc;
//
always@(posedge S_CLK_I)begin
    if(S_RST_I)begin
        wr_en_s2 <= 0;
        succ  <= 0;
        fail  <= 0;
        reg_id_high <=0;
        reg_id_low<=0;
        reg_flag<=0;
        reg_bytes_high<=0;
        reg_bytes_low<=0;
        reg_reserve<=0;
        
    end
    else begin 
        case(state)
            STATE_SDS_SOP  : begin  succ <= 0;  fail <= 0; end
            STATE_INS_SOP1 :  ;
            STATE_INS_SOP2 :  begin wr_en_s2   <= S_DATA_I==8'ha5 ? 1 : 0; crc_en <= 1; end
            STATE_ID_HIGH  :  reg_id_high    <=  S_DATA_I;//因为周期内数据全部有效，所以可以直接打入
            STATE_ID_LOW   :  reg_id_low     <=  S_DATA_I;
            STATE_FLAG     :  reg_flag       <=  S_DATA_I;
            STATE_BYTE_HIGH:  reg_bytes_high <= S_DATA_I;
            STATE_BYTE_LOW :  reg_bytes_low  <= S_DATA_I;
            STATE_RESERVE  :  begin reg_reserve <= S_DATA_I ; end
            STATE_DAT      : ;// 接收数据
            STATE_CRC      :  begin  crc_recv <= S_DATA_I; end
            STATE_CRC1     :  crc_en   <= 0;
            STATE_CRC2     :  begin wr_en_s2 <= 0;  succ_flag <= RX_CHECK_CRC_EN ? (crc_calc==crc_recv ? 1 : 0) : 1; end

            STATE_WAIT_EOP :  begin
                                if(S_DATA_I==8'hFF )begin
                                    S_SEND_ACK_O <= succ_flag ? 1 : 0 ;
                                end 
                              end  
            STATE_SEND_ACK : begin 
                                S_SEND_ACK_O <= 0;
                                if(succ_flag)begin
                                     succ <= 1; 
                                end
                                else begin
                                    fail <= 1;
                                end
                            end
            STATE_WAIT_ACK : ;
            STATE_WAIT_ACK2: ;
            STATE_WAIT_SUCC  :  S_WAIT_SUCC_O <= 1;
            default:;
        endcase
    end
end


//assign succ_flag =  state==STATE_CRC & crc_recv ==S_DATA_I;


//STATE_SDS_SOP   : state <= S_DATA_I==8'h00 ? STATE_INS_SOP1  : S_WAIT_ACK_I ?  STATE_WAIT_ACK




reg [15:0] cnt_wait_ack_time_out;
always@(posedge S_CLK_I)begin
    if(S_RST_I)begin
        cnt_wait_ack_time_out <= 0;
    end
    else begin
        cnt_wait_ack_time_out <= S_WAIT_ACK_I ? WAIT_ACK_TIME_OUT : ( state == STATE_WAIT_ACK |  state == STATE_WAIT_ACK2 | state == STATE_ACK_EOP  ) ? cnt_wait_ack_time_out-1 : cnt_wait_ack_time_out;
    end
end




serdes2sxi4stream_sub  
#(.SDATA_WIDTH  (SDATA_WIDTH  ),  //=  8 ; 
  .MDATA_WIDTH  (MDATA_WIDTH  ),  //= 16;
  .AWPORT_WIDTH (AWPORT_WIDTH ),  //=  2 ;
  .AWLEN_WIDTH  (AWLEN_WIDTH  ),  //= 16 ;
  .AWSIZE_WIDTH (AWSIZE_WIDTH )  //= 16;
  ) 
serdes2sxi4stream_sub(
.S_CLK_I    (S_CLK_I     ) ,  
.S_RST_I    (S_RST_I     ) ,
.S_DATA_I   (S_DATA_I_s2 ) , 
.S_WR_EN_I  (wr_en_s2    ) ,
.S_SUCC_I   (succ        ) ,
.S_FAIL_I   (fail        ) ,
.S_READY_O  (fifo_ready        ) ,

.M_CLK_I    (M_CLK_I     ) ,
.M_RST_I    (M_RST_I     ) ,
.M_AWPORT   (M_AWPORT    ) ,
.M_AWLEN    (M_AWLEN     ) ,
.M_AWSIZE   (M_AWSIZE    ) ,
.M_AWVALID  (M_AWVALID   ) ,
.M_AWREADY  (M_AWREADY   ) ,
.M_WVALID   (M_WVALID    ) ,
.M_WREADY   (M_WREADY    ) ,
.M_WDATA    (M_WDATA     ) ,  
.M_WSTRB    (M_WSTRB     ) ,
.M_WLAST    (M_WLAST     )  

 );



    
endmodule
