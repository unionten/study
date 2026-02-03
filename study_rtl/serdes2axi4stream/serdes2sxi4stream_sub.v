`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/11/25 15:55:31
// Design Name: 
// Module Name: serdes2sxi4stream_sub
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 

//////////////////////////////////////////////////////////////////////////////////
//补齐逻辑 + 缓存逻辑
//低位宽->高位宽存在需要补齐的时候; 高位宽->低位宽不存在需要补齐的时候

module serdes2sxi4stream_sub(
input                    S_CLK_I        ,  
input                    S_RST_I        ,
input  [SDATA_WIDTH-1:0] S_DATA_I       ,//check CRC in this module
input                    S_WR_EN_I      ,
input                    S_SUCC_I       ,//这个不存在last，所以数量是用succ来计算的
input                    S_FAIL_I       ,
output                   S_READY_O       ,

input                     M_CLK_I       ,
input                     M_RST_I       ,
output [AWPORT_WIDTH-1:0] M_AWPORT      ,
output [AWLEN_WIDTH-1:0]  M_AWLEN       ,
output [AWSIZE_WIDTH-1:0] M_AWSIZE      ,
output  reg               M_AWVALID     ,
input                     M_AWREADY     ,
output                  M_WVALID      ,
input                     M_WREADY      ,
output [MDATA_WIDTH-1:0]  M_WDATA       ,  
output [MDATA_WIDTH/8-1:0]M_WSTRB       ,
output                    M_WLAST        



    );

parameter  SDATA_WIDTH  =  8 ; 
parameter MDATA_WIDTH = 64;

parameter  AWPORT_WIDTH =  2 ;
parameter  AWLEN_WIDTH  = 16 ;
parameter  AWSIZE_WIDTH = 16;


////////////////////////////////////////////////////////////////////////////////

reg  [7:0] rx_state_s = 0;
reg        tp_wr_s    = 0;
reg [15:0] tp_beats_in_s = 0;
reg [15:0] tp_bytes_in_s = 0;


reg [7:0] rx_strb_num;
wire rx_ins_fifo_rd;
wire tx_ins_fifo_wr ;
wire [15:0] r_tx_beat_num ; 
wire [15:0] rx_wr_data_count ;

reg [7:0] tx_state = 0;
reg [7:0] tp_state_m = 0;
reg tp_rd_m = 0;
wire [15:0] tp_beats_out;
wire [15:0] tp_bytes_out;
wire tp_rd_empty;
wire tp_rd_rst_busy;
reg [15:0] cnt_beat_s;
reg rx_busy_s; //补齐过程
wire [15:0] beats_after_fill;//total 
reg [15:0] beats_need_fill_s = 0;
reg [15:0] cnt_beats_need_fill_s =0;
reg fifo_wr_extra;
wire [15:0] last_beats_s;//相当于右侧最后一个beat时对应的左侧多少个beat
wire [15:0] last_bytes_s;//相当于右侧最后一个beat时的字节数

reg [MDATA_WIDTH/8-1:0] last_strb;
wire tp_wr_full ;
wire tp_rst_busy ;
reg [7:0] tp_strb;


////////////////////////////////////////////////////////////////////////////////


assign S_READY_O = ~rx_busy_s & ~rx_fifo_wr_full ;
assign beats_after_fill = f_upper_align(cnt_beat_s,MDATA_WIDTH/SDATA_WIDTH) ;
always@(posedge S_CLK_I)begin
    beats_need_fill_s <= beats_after_fill - cnt_beat_s;
end
assign last_beats_s = cnt_beat_s - cnt_beat_s/(MDATA_WIDTH/SDATA_WIDTH)*(MDATA_WIDTH/SDATA_WIDTH);
assign last_bytes_s = last_beats_s*(SDATA_WIDTH/8);


//目前最多1:8
always@(*)begin
    case(last_bytes_s)
        0:last_strb = 8'b11111111;
        1:last_strb = 8'b00000001;
        2:last_strb = 8'b00000011;
        3:last_strb = 8'b00000111;
        4:last_strb = 8'b00001111;
        5:last_strb = 8'b00011111;
        6:last_strb = 8'b00111111;
        7:last_strb = 8'b01111111;
        8:last_strb = 8'b11111111;
        default:last_strb = 8'b11111111;
    endcase
end



always@(posedge S_CLK_I)begin
   if(S_RST_I)begin
       tp_wr_s       <= 0;
       rx_state_s    <= 0;
       tp_beats_in_s <= 0;
       tp_bytes_in_s <= 0;
       rx_busy_s     <= 0;
       cnt_beat_s    <= 0;
   end
   else begin 
       case(rx_state_s)
           0:begin //默认起始状态就是空的状态
               cnt_beat_s <= S_FAIL_I ? 0 : S_WR_EN_I ? cnt_beat_s + 1 : cnt_beat_s ;
               rx_state_s <= S_SUCC_I ? 1 : 0; 
               rx_busy_s  <= S_SUCC_I ? 1 : 0;
           end
           1:begin //补充，此时 beats_need_fill_s 已经稳定有效
                cnt_beats_need_fill_s <= beats_need_fill_s ;
                rx_state_s <= beats_need_fill_s!=0 ? 2 : 3;            
           end
           2:begin//填充 fifo
                cnt_beats_need_fill_s <=  cnt_beats_need_fill_s - 1;
                rx_state_s <= cnt_beats_need_fill_s==1 ? 3 : rx_state_s;
           end
           3:begin//写入tp fifo
                tp_wr_s    <= ((~tp_wr_full) & (~tp_rst_busy)) ? 1 : 0;
                tp_beats_in_s <= cnt_beat_s/(MDATA_WIDTH/SDATA_WIDTH) + (beats_need_fill_s!=0);//右侧总beat数
                tp_bytes_in_s <= last_bytes_s;//最后一个beat的字节数
                rx_state_s <= ((~tp_wr_full) & (~tp_rst_busy)) ? 4 : rx_state_s ;
           end
           4:begin
                cnt_beat_s <= 0;
                tp_wr_s   <= 0;
                rx_busy_s <= 0;
                rx_state_s <= 0;
           end
           default:;
       endcase
   end
end


wire wr_extra_s;
assign wr_extra_s = rx_state_s==2 ;//& cnt_beats_need_fill_s>0 ;

wire fifo_rx_rd_empty;


fifo_rx 
    #(.C_FIFO_WRITE_WIDTH( SDATA_WIDTH ),
      .C_FIFO_READ_WIDTH ( MDATA_WIDTH )
      )
    fifo_rx_u(
  
   
    .FIFO_WR_CLK_I        (S_CLK_I                  ),            
    .FIFO_WR_RST_I        (S_RST_I                  ),
    .FIFO_WR_EN_I         (S_WR_EN_I | wr_extra_s   ),     
    .FIFO_WR_EN_VALID_O   (       ),  
    .FIFO_WR_DATA_COUNT_O (     ),
    .FIFO_WR_IN_RD_ACCUS_O(                         ),                      
    .FIFO_WR_IN_WR_ACCUS_O(                         ),  
    .FIFO_WR_EN_NAMES_O   (          ),
    .FIFO_WR_EN_ACCUS_O   (          ),                                         
    .FIFO_WR_DATA_I       (S_DATA_I           ), //[31:0]        
    .FIFO_WR_SUCC_I       (S_SUCC_I                 ),         
    .FIFO_WR_FAIL_I       (S_FAIL_I                 ),         
    .FIFO_WR_FULL_O       (rx_fifo_wr_full          ),      
    
    .FIFO_RD_CLK_I        (M_CLK_I                  ),
    .FIFO_RD_RST_I        (M_RST_I                  ),
    .FIFO_RD_EN_I         (M_WVALID & M_WREADY      ),  
    .FIFO_RD_DATA_VALID_O (                         ),                       
    .FIFO_RD_DATA_O       (M_WDATA                  ), //[C_M_AXI4_DATA_WIDTH-1:0]              
    .FIFO_RD_EMPTY_O      (fifo_rx_rd_empty ),
    .FIFO_RD_DATA_COUNT_O (     ),
    .FIFO_RD_EN_ACCUS_O   (          )
    );  
    
reg [15:0] cnt_tp_beats_out;
reg [15:0] cnt_tp_bytes_out;   


 


always@(posedge M_CLK_I)begin
    if(M_RST_I)begin
        tp_state_m   <= 0;
        tp_rd_m      <= 0;
        cnt_tp_beats_out   <= 0;
        cnt_tp_bytes_out   <= 0;
        M_AWVALID <= 0;
        //M_WVALID <= 0;
    end
    else begin
        case(tp_state_m)
            0:begin
                tp_state_m <= (~tp_rd_empty & ~tp_rd_rst_busy) ? 1 : tp_state_m ;   
            end
            1:begin
                tp_rd_m        <= 1;
                tp_state_m     <= 2;
            end
            2:begin 
                tp_rd_m        <= 0;
                cnt_tp_beats_out     <= tp_beats_out ;//cnt_tp_beats_out
                cnt_tp_bytes_out     <= tp_bytes_out; //cnt_tp_bytes_out
                tp_state_m     <= 3;
            end
            3:begin//然后主动向下发送 
                M_AWVALID <= M_AWVALID & M_AWREADY ? 0 : 1 ;
                tp_state_m  <= M_AWVALID & M_AWREADY ? 4 : tp_state_m ;   
            end
            4:begin
                //M_WVALID <= 1;
                cnt_tp_beats_out <= M_WVALID & M_WREADY ? cnt_tp_beats_out - 1 : cnt_tp_beats_out ;  
                tp_state_m <= M_WVALID & M_WREADY & M_WLAST ? 0 : tp_state_m ;
            end
            default :;
        endcase
    end
end

assign M_WVALID = tp_state_m==4 & ~fifo_rx_rd_empty;


assign  M_WLAST = cnt_tp_beats_out==1 ? 1 : 0;
assign  M_WSTRB = cnt_tp_beats_out==1 ?  tp_strb : 32'hfffffffff;



always@(*)begin
    case(cnt_tp_bytes_out)
    0 :tp_strb = 32'b11111111;
    1 :tp_strb = 32'b00000001;
    2 :tp_strb = 32'b00000011;
    3 :tp_strb = 32'b00000111;
    4 :tp_strb = 32'b00001111;
    5 :tp_strb = 32'b00011111;
    6 :tp_strb = 32'b00111111;
    7 :tp_strb = 32'b01111111;
    8 :tp_strb = 32'b11111111; 
    default:tp_strb = 8'b11111111;
    endcase
end



fifo_async_xpm  
   #(.C_WR_WIDTH             (32          ),
     .C_WR_DEPTH             (64         ),
     .C_RD_WIDTH             (32          ),
     .C_WR_COUNT_WIDTH       (16),
     .C_RD_COUNT_WIDTH       (16),
     //.C_RD_PROG_EMPTY_THRESH (),
     //.C_WR_PROG_FULL_THRESH  (),
     .C_RD_MODE              ("fwft"   ), 
     //.C_DBG_COUNT_WIDTH      (16),
      .C_RELATED_CLOCKS       (1)
    )
   fifo_tp_u( //cmd type
   .WR_RST_I         (S_RST_I                  ),
   .WR_CLK_I         (S_CLK_I                   ),
   .WR_EN_I          (tp_wr_s                        ),
   .WR_EN_VALID_O    (                             ),
   .WR_EN_NAMES_O    (                             ),
   .WR_EN_ACCUS_O    (                             ),
   .WR_DATA_I        ({tp_bytes_in_s,tp_beats_in_s }   ),
   .WR_FULL_O        ( tp_wr_full                  ),
   .WR_DATA_COUNT_O  (                             ), 
   .WR_PROG_FULL_O   (                             ),
   .WR_RST_BUSY_O    ( tp_rst_busy                 ),

   .RD_RST_I         (M_RST_I                      ), 
   .RD_CLK_I         (M_CLK_I                      ),
   .RD_EN_I          (   tp_rd_m                     ),
   .RD_EN_NAMES_O    (                             ),
   .RD_EN_ACCUS_O    (                             ),
   .RD_DATA_VALID_O  (                             ),
   .RD_DATA_O        ( {tp_bytes_out,tp_beats_out}          ),
   .RD_EMPTY_O       ( tp_rd_empty                 ),
   .RD_DATA_COUNT_O  (                             ),
   .RD_PROG_EMPTY_O  (                             ),
   .RD_RST_BUSY_O    ( tp_rd_rst_busy              )
   );



function [15:0] f_upper_align ;
input  [15:0] in;
input  [15:0] align_unit;//must be power of 2, must >= 1, do not allow to be 0
begin : AA
    reg [15:0] tail;
    tail = in & {0,{align_unit-1}} ; //取尾部
    f_upper_align = (in & ~{0,{align_unit-1}}) + (tail!=0)*align_unit ;
end
endfunction




    
endmodule
