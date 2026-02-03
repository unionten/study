
`timescale 1 ns / 1 ps

//测试记录： DATA_NUM 为多少时，就是出多少数据
//

//1 valid_b1 
//2 valid_b1 和 非空 结合后得到 第一个部分valid
//3 再加上 empty 下降沿 构成最终 read信号
//4 last信号不用额外忽略(他们全部已经被上述两种情况考虑)
//5 第一次发送数据结束后，要进行第二次数据发送，情况同样被上述考虑进去了

//其他注意事项： 外部fifo在复位时引发的empty的异常变化会导致本模块判断错误，需要外部根据一些信号做处理
//如果上来外部fifo就是非空，那么本模块无法进行第一次的额外读（暂时不解决）
//使用方法：对与其连接的外部fifo和本模块同时复位（这样外部的empty就会从1变为0,这样本模块就能正常工作）

module axi4_stream_gen #
(
    parameter DATA_WIDTH = 48,
    parameter DATA_NUM   = 1024
    //parameter [0:0] C_FIFO_TYPE = 0 //0(延迟出数据,标准fifo) 1(立刻出数据的fifo，内部按照这个写)
)
(
input  wire   CLK_I,                              
input  wire   RSTN_I,                           
output wire    TVALID_O,                          
input  wire   TREADY_I,                           
output wire   [DATA_WIDTH-1 : 0] TDATA_O,  
output wire   TLAST_O,  
output [15:0] USER_O, //from 0 to 511 ex                         

//USER WRITE CHANNEL 
input  START_I,
input  FIFO_EMPTY_I,
output FIFO_READ_O,
input  [DATA_WIDTH-1:0] FIFO_DATA_I

);



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////AXI WRITE CHANNEL//////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// START_I  ___|—|______
// burst    _____|—|_________________|—|_主状态机管理
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

    reg        w_start_burst;
    reg [15:0] w_cnt_beat_al__per;
    reg [7:0]  w_state;
    wire       w_transmiter ;
   

    // data
    assign TDATA_O = FIFO_DATA_I;
    
       
    // M_AXI_WVALID_b1   
    reg M_AXI_WVALID_b1;
    always @(posedge CLK_I)begin                                                                             
        if (~RSTN_I)begin                                                                         
            M_AXI_WVALID_b1 <= 0;                                                         
        end                                                                           
        else if (w_start_burst)begin                                                                         
            M_AXI_WVALID_b1 <= 1; /////////////假拉高                                                        
        end                                                                                                  
        else if (TLAST_O & TREADY_I) begin                                                 
            M_AXI_WVALID_b1 <= 0;   
        end
    end                                                                               
     
    // TLAST_O  
    assign TLAST_O =  TVALID_O & ( w_cnt_beat_al__per == DATA_NUM-1 );
    
    
    
    // TVALID_O  该信号本身暗含了非空时，所以不会出现last时空的情况
    //assign TVALID_O = (C_FIFO_TYPE==1) ? ( M_AXI_WVALID_b1 & ~FIFO_EMPTY_I ) : ( M_AXI_WVALID_b1 & ~FIFO_EMPTY_I & ~W_FIFO_EMPTY_I_neg ) ;
    assign TVALID_O =  M_AXI_WVALID_b1 & ~FIFO_EMPTY_I & ~W_FIFO_EMPTY_I_neg ;
    
    

    
    wire fifo_rd_extra;
    wire W_FIFO_EMPTY_I_neg;
    reg  W_FIFO_EMPTY_I_ff1 = 0;
    always@(posedge CLK_I)begin
        if(~RSTN_I)W_FIFO_EMPTY_I_ff1 <= 0;
        W_FIFO_EMPTY_I_ff1 <= FIFO_EMPTY_I;
    end
    
    //
    assign W_FIFO_EMPTY_I_neg = ~FIFO_EMPTY_I & W_FIFO_EMPTY_I_ff1;
    assign fifo_rd_extra = W_FIFO_EMPTY_I_neg;
    
    // FIFO_READ_O
    //assign FIFO_READ_O = (C_FIFO_TYPE==1) ? (TVALID_O & TREADY_I) : ((TVALID_O & TREADY_I) | fifo_rd_extra);
    assign FIFO_READ_O = (TVALID_O & TREADY_I) | fifo_rd_extra;
    
    // w_transmiter 
    
    assign w_transmiter =  TVALID_O & TREADY_I;

    // cnt_beat_p;
    
    wire W_REQ_I_pos;
    reg  W_REQ_I_ff1;
    always@(posedge CLK_I)begin
        if(~RSTN_I)begin
            W_REQ_I_ff1 <= 1;
        end
        else begin
            W_REQ_I_ff1 <= START_I;
        end
    end
    assign W_REQ_I_pos = START_I & ~W_REQ_I_ff1;
    
    
    
    always@(posedge CLK_I)begin
        if(~RSTN_I)begin
            w_state <= 0; 
            w_start_burst <= 0;
            w_cnt_beat_al__per <= 0;
        end
        else begin
            case(w_state)
                0:begin
                    if(W_REQ_I_pos )begin
                        w_start_burst  <= 1;
                        w_state <= 2;
                    end
                end
                2:begin//传输
                    w_start_burst <= 0;
                    if(w_transmiter)begin
                        if(w_cnt_beat_al__per == DATA_NUM-1 )begin
                            w_state <= 0;
                            w_cnt_beat_al__per <= 0;
                        end
                        else begin
                            w_cnt_beat_al__per <= w_cnt_beat_al__per + 1;
                        end
                    end
                end
                default:begin
                    w_state <= 0; 
                    w_start_burst <= 0;
                    w_cnt_beat_al__per <= 0;
                end
            endcase
        end
    end
                

assign  USER_O = w_cnt_beat_al__per;
                
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
          
      function integer clogb2 (input integer bit_depth);              
      begin                                                           
        for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                   
          bit_depth = bit_depth >> 1;                                 
        end                                                           
      endfunction   



    endmodule
