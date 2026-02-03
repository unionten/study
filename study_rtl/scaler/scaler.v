`timescale 1ns / 1ps

`define POS_MONITOR_OUTGEN(clk,rst,in,out)                                                              generate  begin  reg buf_name1 = 0; always@(posedge clk)begin if(rst)buf_name1 <= 0; else  buf_name1 <= in; end assign out = (~buf_name1)&(in);  end  endgenerate

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:   yzhu
//  典型模式：进4像素，出4像素， 但是出的4像素中是4个像素选一个，或者2个选一个这样，重新拼接。 
//             有横向缩放 和 纵向缩放 
// Create Date: 2025/10/16 09:55:08
// Design Name: 
// Module Name: scaler
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

/*
scaler  
    #(.C_IN_PORT_NUM         (4)    ,
      .C_BYTES_PER_PIXEL  (2)    ,
      .C_FIFO_DEPTH       (1024) 
    scaler_u
    .AXI4_CLK_I          ()   ,
    .AXI4_RSTN_I         ()    ,
    .VS_AXI4_I           ()    ,
    .HACTIVE_AXI4_I      ()   ,
    .VACTIVE_AXI4_I      () ,
    .SCALE_ENABLE_AXI4_I ()  ,
    .HSCALE_MODE_AXI4_I  (), //0:原始bypass  1:/2   2:4 
    .VSCALE_MODE_AXI4_I  (), //0:原始bypass  1:/2   2:4 
    .RD_EMPTY_AXI4_I     (),
    .RD_RST_BUSY_AXI4_I  (),
    .RD_AXI4_O           () ,//对于上级读；  上级模式假定为fwft  ; 一般为从axi4 拉取
    .RD_DATA_AXI4_I      ()   ,
    .VID_CLK_I           (),
    .VID_RSTN_I          ()   ,
    .VS_VID_I            ()  ,
    .RD_VID_I            (),
    .RD_DATA_VALID_VID_O (),
    .RD_EMPTY_VID_O      (),
    .RD_RST_BUSY_VID_O   (),
    .DATA_VID_O          ()//内部结构为fifo;  外部强行拉数据

    );


*/




module scaler(
input  AXI4_CLK_I ,
input  AXI4_RSTN_I ,
input  VS_AXI4_I  ,
input  [15:0] HACTIVE_AXI4_I ,
input  [15:0] VACTIVE_AXI4_I ,
input  SCALE_ENABLE_AXI4_I   ,
input  [1:0] HSCALE_MODE_AXI4_I  , //0:原始bypass  1:/2   2:4 
input  [1:0] VSCALE_MODE_AXI4_I  , //0:原始bypass  1:/2   2:4 


input                                         RD_EMPTY_AXI4_I     ,
input                                         RD_RST_BUSY_AXI4_I  ,
output   reg                                  RD_AXI4_O      = 0  ,//对于上级读；  上级模式假定为fwft  ; 一般为从axi4 拉取
input  [C_IN_PORT_NUM*C_BYTES_PER_PIXEL*8-1 :0 ] RD_DATA_AXI4_I         ,

////////////////////////////////////////////////////////////////////////
input  VID_CLK_I  ,
input  VID_RSTN_I ,
input                                         VS_VID_I              ,
input                                         RD_VID_I            ,
output                                        RD_DATA_VALID_VID_O ,
output                                        RD_EMPTY_VID_O     ,
output                                        RD_RST_BUSY_VID_O ,
output [C_IN_PORT_NUM*C_BYTES_PER_PIXEL*8-1 :0 ] DATA_VID_O          //内部结构为fifo;  外部强行拉数据


    );
parameter  C_ID = 0 ;
parameter  C_IN_PORT_NUM         =16 ;
parameter  C_OUT_PORT_NUM        = 4;
parameter  C_BYTES_PER_PIXEL  = 2 ;
parameter  C_FIFO_DEPTH       = 2048;


(*keep="true"*)reg [3:0] state = 0;
reg  [C_IN_PORT_NUM*C_BYTES_PER_PIXEL*8-1 :0 ] data_reg =0;//拼接后数据的缓存空间

wire    fifo_outer_vld;//
assign  fifo_outer_vld = (~RD_EMPTY_AXI4_I) & (~RD_RST_BUSY_AXI4_I)  ;
wire    fifo_inner_vld;
assign  fifo_inner_vld =  (~wr_full) & (~wr_rst_busy);
wire    fifo_vld;
assign  fifo_vld = fifo_outer_vld & fifo_inner_vld ;

reg wreq = 0; //拼接后写， 时序逻辑 
reg  [C_IN_PORT_NUM*C_BYTES_PER_PIXEL*8-1 :0 ] wdata   = 0;  
wire wr_full ;  
wire wr_rst_busy ;  


reg [3:0]   cnt_pingjie = 0;
//wire [31:0] v_lane_beats_c =  HACTIVE_AXI4_I * C_BYTES_PER_PIXEL /  (C_IN_PORT_NUM*C_BYTES_PER_PIXEL);    //一行数据的fifo beat数


reg [31:0] v_lane_beats_c =  0 ;    //一行数据的fifo beat数

always@(posedge AXI4_CLK_I)begin
    v_lane_beats_c <= HSCALE_MODE_AXI4_I==1 ?  HACTIVE_AXI4_I / C_IN_PORT_NUM  / 2 :   HACTIVE_AXI4_I / C_IN_PORT_NUM  / 4 ;
end





reg [15:0] lane_cnt = 0;

reg [31:0]  v_beat_cnt = 0;
reg [15:0] v_lane_beats_next= 0 ;

wire VS_AXI4_I_pos ;
wire VS_VID_I_pos;

`POS_MONITOR_OUTGEN(AXI4_CLK_I,0,VS_AXI4_I ,VS_AXI4_I_pos)  
`POS_MONITOR_OUTGEN(VID_CLK_I,0, VS_VID_I ,VS_VID_I_pos)  



always@(posedge AXI4_CLK_I)begin
    if(VS_AXI4_I_pos)begin
        state <= 0;  
        wreq  <= 0;
        v_beat_cnt <= 0 ;
        lane_cnt <= 0;
        v_lane_beats_next <= v_lane_beats_c ;
        RD_AXI4_O <= 0;
       // wdata <= 0;
        cnt_pingjie <= 0;
    end
     else if(~AXI4_RSTN_I )begin
         state <= 2;  
         wreq  <= 0;
         v_beat_cnt <= 0 ;
         lane_cnt <= 0;
         v_lane_beats_next <= v_lane_beats_c ;
         RD_AXI4_O <= 0;
        // wdata <= 0;
         cnt_pingjie <= 0;
     end
    else if(~SCALE_ENABLE_AXI4_I)begin //byass
        RD_AXI4_O     <= fifo_vld  ; //内外fifo全部有效时
        wreq         <= fifo_vld  ;
        //wdata    <= RD_DATA_AXI4_I ;
    end
    else begin
        case(state)
            0:begin //从外部fifo拉数据
                wreq <= 0;
                if(HSCALE_MODE_AXI4_I==1)begin
                    if(fifo_outer_vld)begin
                        RD_AXI4_O        <= 1 ;
                      //  data_reg    <= {RD_DATA_AXI4_I[C_BYTES_PER_PIXEL*8*3-1:C_BYTES_PER_PIXEL*8*2],RD_DATA_AXI4_I[C_BYTES_PER_PIXEL*8*1-1:0],data_reg[C_IN_PORT_NUM*C_BYTES_PER_PIXEL*8-1: C_BYTES_PER_PIXEL*2*8]} ;
                        cnt_pingjie <= cnt_pingjie==1 ? 0 : cnt_pingjie + 1;
                        state       <= cnt_pingjie==1 ? 1 : 0;
                    end
                    else begin
                        RD_AXI4_O <= 0;
                    end
                end
                else if(HSCALE_MODE_AXI4_I==2)begin
                    if(fifo_outer_vld)begin
                        RD_AXI4_O        <= 1 ;
                        //data_reg    <= {RD_DATA_AXI4_I[C_BYTES_PER_PIXEL*8-1:0],data_reg[C_IN_PORT_NUM*C_BYTES_PER_PIXEL*8-1: C_BYTES_PER_PIXEL*8]};
                        cnt_pingjie <= cnt_pingjie==3 ? 0 : cnt_pingjie + 1; // 读取够 beat 后 跳到1 
                        state       <= cnt_pingjie==3 ? 1 : 0;
                    end
                    else begin
                        RD_AXI4_O <= 0;
                    end
                end
                else begin
                    RD_AXI4_O  <= 0;
                    state <= 0;
                end
            end
            1:begin  // 拼好数据后向fifo写
                RD_AXI4_O <= 0;
                if(VSCALE_MODE_AXI4_I==1)begin
                    if(lane_cnt[0]==0)begin //lane_cnt[0:0]==0 2行抽1行   lane_cnt[1:0] == 00  4行抽1行
                        if(fifo_inner_vld)begin
                            wreq  <=   1 ;
                           // wdata <= data_reg  ;
                            state <= 0;
                            v_beat_cnt         <= v_beat_cnt + 1 ;
                            lane_cnt           <= v_beat_cnt==(v_lane_beats_next-1)  ?  lane_cnt + 1 : lane_cnt ;
                            v_lane_beats_next  <= v_beat_cnt==(v_lane_beats_next-1)  ?  v_lane_beats_next + v_lane_beats_c: v_lane_beats_next ;
                        end
                        else begin
                            wreq <= 0 ; 
                        end
                    end
                    else begin // 属于其他lane时，跳过,  不需要判断 fifo_inner_vld  ; 但仍然统计  v_beat_cnt
                        wreq        <= 0 ; 
                        v_beat_cnt <= v_beat_cnt + 1 ;
                        
                        state      <= v_beat_cnt==(v_lane_beats_next-1) &&  lane_cnt==(VACTIVE_AXI4_I-1)  ?  2:   0 ; //处理完所有行，则跳出; 否则回到 对外部fifo的读
                        
                        lane_cnt   <= v_beat_cnt==(v_lane_beats_next-1)  ?  lane_cnt + 1 : lane_cnt ;
                        v_lane_beats_next  <= v_beat_cnt==(v_lane_beats_next-1)  ?  v_lane_beats_next + v_lane_beats_c : v_lane_beats_next ;
                    end
                end
                else if(VSCALE_MODE_AXI4_I==2)begin
                    if(lane_cnt[1:0]==2'b00)begin //lane_cnt[0:0]==0 2行抽1行   lane_cnt[1:0] == 00  4行抽1行 --  是4行抽取1行
                        if(fifo_inner_vld)begin
                            wreq  <=   1 ;
                           // wdata <= data_reg  ;
                            state <= 0;
                            v_beat_cnt <= v_beat_cnt + 1 ;
                            lane_cnt           <= v_beat_cnt==(v_lane_beats_next-1)  ?  lane_cnt + 1 : lane_cnt ;
                            v_lane_beats_next  <= v_beat_cnt==(v_lane_beats_next-1)  ?  v_lane_beats_next + v_lane_beats_c : v_lane_beats_next ;
                        end
                        else begin
                            wreq <= 0 ; 
                        end
                    end
                    else begin  // 属于其他lane时，跳过,  不需要判断 fifo_inner_vld
                        wreq        <= 0 ; 
                        v_beat_cnt <= v_beat_cnt + 1 ;
                        
                        state      <= v_beat_cnt==(v_lane_beats_next-1) &&  lane_cnt==(VACTIVE_AXI4_I-1)  ?  2:   0 ;     //处理完所有行，则跳出; 否则回到 对外部fifo的读
                        
                        
                        lane_cnt   <= v_beat_cnt==(v_lane_beats_next-1)  ?  lane_cnt + 1 : lane_cnt ;
                        v_lane_beats_next  <= v_beat_cnt==(v_lane_beats_next-1)  ?  v_lane_beats_next + v_lane_beats_c : v_lane_beats_next ;
                    end
                end
                else begin
                    wreq  <= 0 ; 
                    RD_AXI4_O  <= 0;
                    state <= 0;
                end
            end
            2:begin
                ;
            
            end
            
            default:;
        endcase
 
         // 
         // 计数1轮 ,该轮中，所有读取的fifo内容都要进行拼接，转存
         //        在处理中，（根据参数），读一次就转存，   读两次转存，   或者 四次后转存        
         //             
         //             
         //             
         // 然后跳过0轮，   1轮，或3轮 （根据参数）；  根据 v_lane_beats_c （每次上限加 v_lane_beats_c）
         // 
         // 一直到 最大行数 的轮数，一帧处理即结束
         //         
        
    
    end

end

always@(posedge AXI4_CLK_I)begin
    if(VS_AXI4_I_pos)begin 
        data_reg <= 0;   
    end
     else if(~AXI4_RSTN_I )begin
         data_reg <= 0;
     end
  else begin
 // data_reg     <=  RD_AXI4_O  ?  (  (HSCALE_MODE_AXI4_I==1)  ?  
//                         {RD_DATA_AXI4_I[C_BYTES_PER_PIXEL*8*3-1:C_BYTES_PER_PIXEL*8*2],RD_DATA_AXI4_I[C_BYTES_PER_PIXEL*8*1-1:0],data_reg[C_IN_PORT_NUM*C_BYTES_PER_PIXEL*8-1: C_BYTES_PER_PIXEL*2*8]} 
 //                    :  {RD_DATA_AXI4_I[C_BYTES_PER_PIXEL*8-1:0],data_reg[C_IN_PORT_NUM*C_BYTES_PER_PIXEL*8-1: C_BYTES_PER_PIXEL*8]} 



  data_reg     <=  RD_AXI4_O  ?  (  (HSCALE_MODE_AXI4_I==1)  ?   // 两个像素 取 一个 ，  一次取8个像素
                         {  
                         
                         RD_DATA_AXI4_I[C_BYTES_PER_PIXEL*8*16-1 -:(C_BYTES_PER_PIXEL*8)], //注意，每两个间隔 yuyv 要一次取yu  一次取yv
                         RD_DATA_AXI4_I[C_BYTES_PER_PIXEL*8*13-1 -:(C_BYTES_PER_PIXEL*8)], // 即 奇数像素和偶数像素交替 取
                         RD_DATA_AXI4_I[C_BYTES_PER_PIXEL*8*12-1 -:(C_BYTES_PER_PIXEL*8)],
                         RD_DATA_AXI4_I[C_BYTES_PER_PIXEL*8*9-1-:(C_BYTES_PER_PIXEL*8)],
                         RD_DATA_AXI4_I[C_BYTES_PER_PIXEL*8*8-1 -:(C_BYTES_PER_PIXEL*8)],
                         RD_DATA_AXI4_I[C_BYTES_PER_PIXEL*8*5-1 -:(C_BYTES_PER_PIXEL*8)],
                         RD_DATA_AXI4_I[C_BYTES_PER_PIXEL*8*4-1 -:(C_BYTES_PER_PIXEL*8)],
                         RD_DATA_AXI4_I[C_BYTES_PER_PIXEL*8*1-1-:(C_BYTES_PER_PIXEL*8)],
                         data_reg[C_IN_PORT_NUM*C_BYTES_PER_PIXEL*8-1 -:  C_BYTES_PER_PIXEL*8*(8) ]} 
                     :  {    // 4个像素 取 一个 ，一次取4个像素
                        
                           
                        
                        
                        RD_DATA_AXI4_I[C_BYTES_PER_PIXEL*8*14-1-:(C_BYTES_PER_PIXEL*8)],
                        RD_DATA_AXI4_I[C_BYTES_PER_PIXEL*8*9-1-:(C_BYTES_PER_PIXEL*8)],
                        RD_DATA_AXI4_I[C_BYTES_PER_PIXEL*8*6-1-:(C_BYTES_PER_PIXEL*8)],
                        RD_DATA_AXI4_I[C_BYTES_PER_PIXEL*8*1-1-:(C_BYTES_PER_PIXEL*8)],
                        data_reg[C_IN_PORT_NUM*C_BYTES_PER_PIXEL*8-1 -:  C_BYTES_PER_PIXEL*8*(12)]
                     
                     } 







   ) : data_reg   ;
end
end


wire [15:0 ] wr_data_count ;
wire [15:0 ] RD_DATA_COUNT_O ;
wire RD_ERR_O;
wire wr_err; 



fifo_async_xpm
    #(.C_WR_WIDTH             (C_IN_PORT_NUM*C_BYTES_PER_PIXEL*8 ),// ratio must be 1:1, 1:2, 1:4, 1:8,
      .C_WR_DEPTH             (C_FIFO_DEPTH),// must>=16 ; actual depth = C_WR_DEPTH - 1;  must be power of 2
      .C_RD_WIDTH             (C_OUT_PORT_NUM *C_BYTES_PER_PIXEL*8 ),
      .C_WR_COUNT_WIDTH       (16),
      .C_RD_COUNT_WIDTH       (16),
      //.C_RD_PROG_EMPTY_THRESH (),
      .C_WR_PROG_FULL_THRESH  (C_FIFO_DEPTH-16),
      .C_RD_MODE              ("fwft" ) //"std" "fwft"
     )
    fifo_rd_u(
    .WR_RST_I         (VS_AXI4_I_pos  |   (~AXI4_RSTN_I)        ),
    .WR_CLK_I         (AXI4_CLK_I           ),
    .WR_EN_I          (wreq            ),
    //.WR_DATA_I        (wdata           ),
    
    .WR_DATA_I        (   data_reg        ), // bug 修复
    
    .WR_FULL_O        (wr_full         ),
    .WR_DATA_COUNT_O  (wr_data_count                ),
    .WR_PROG_FULL_O   (                ),
    .WR_RST_BUSY_O    (wr_rst_busy     ),
    .WR_EN_NAMES_O    (                )  ,
    .WR_EN_ACCUS_O    (                )   , //total valid wr num
    .WR_ERR_O         (wr_err         ),

    .RD_RST_I         (VS_VID_I_pos  |   (~VID_RSTN_I)          ),
    .RD_CLK_I         (VID_CLK_I               ),
    .RD_EN_I          (RD_VID_I                ),
    .RD_DATA_VALID_O  (RD_DATA_VALID_VID_O ),
    .RD_DATA_O        (DATA_VID_O           ),
    .RD_EMPTY_O       (RD_EMPTY_VID_O       ),
    .RD_DATA_COUNT_O  ( RD_DATA_COUNT_O      ),
    .RD_PROG_EMPTY_O  (                  ),
    .RD_RST_BUSY_O    (RD_RST_BUSY_VID_O ),
    .RD_EN_NAMES_O    ( RD_EN_NAMES_O    ),//16
    .RD_EN_ACCUS_O    ( RD_EN_ACCUS_O    ),//16
    .RD_ERR_O         ( RD_ERR_O          )

    );
    

 
    
    
endmodule
