`timescale 1ns / 1ps

`define POS_MONITOR_OUTGEN(clk,rst,in,out)                                                              generate  begin  reg buf_name1 = 0; always@(posedge clk)begin if(rst)buf_name1 <= 0; else  buf_name1 <= in; end assign out = (~buf_name1)&(in);  end  endgenerate


//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: yzhu
// 
// Create Date: 2024/01/19 17:35:24
// Design Name: 
// Module Name: bit_align
//////////////////////////////////////////////////////////////////////////////////

module bit_align
#( parameter  C_DEVICE      = "KUP" ,  //"KU" "K7" "A7" "KUP"  only support kup
   parameter  C_DATA_WIDTH  = 4        //8 or 4
)

(
input                     CLK_I                 , // be the dependant clk controlling idelay (not the fast or slow clk of i/o serdes)
input                     RST_I                 , 
input                     REQ_I                 , // pulse, start bit align op
input  [C_DATA_WIDTH-1:0] DATA_I                , // data before bit align                        
output  reg               INC_O  = 0            , // no use
output  reg               LD_O   = 0            , // pulse, load delay tap
output  reg [8:0]         CNTVALUE_SET_O = 0        , // proposed   delay tap num    0  ~  511  (for 7 series 0~31)
input   [8:0]             CNTVALUE_TRUE_I            , // effective  delay tap num    0  ~  511  (for 7 series 0~31)
output [C_DATA_WIDTH-1:0] DATA_O                , // data after bit align 
output  reg               BITALIGN_DONE_O  = 0

                                                                             
);

wire REQ_I_pos;
`POS_MONITOR_OUTGEN(CLK_I,RST_I,REQ_I,REQ_I_pos)

assign DATA_O = DATA_I ;

reg [8:0] cntvalue_right ;
reg [8:0] cntvalue_left;
(*keep="true"*)reg [7:0] state = 0;
(*keep="true"*)reg [C_DATA_WIDTH-1:0] data_mid;


localparam  TAP_MID  = (C_DEVICE=="KU" | C_DEVICE=="KUP") ? 256  :  16 ;
localparam  TAP_TOP  = (C_DEVICE=="KU" | C_DEVICE=="KUP") ? 511  :  31 ;
localparam  TAP_LOW  = 0 ;

reg [7:0] cnt_delay;

localparam LD_DELAY = 10;
always@(posedge CLK_I)begin
    if(RST_I)begin
        state <= 0;
        cntvalue_right <= 0;
        cntvalue_left  <= 0;
        BITALIGN_DONE_O <= 0;
    end
    else begin
        case(state)
            0:begin//LD and cntvalue  --> 直到生效 --> 判断是否变化 
                state <= REQ_I_pos ? 1 : state ;  
            end
            1:begin
                LD_O  <= 1 ;
                CNTVALUE_SET_O <= TAP_MID ; //选择最中间级别的延迟
                state <= 2;
                cnt_delay <= LD_DELAY;
            end
            2:begin //记录中间值
                LD_O  <= 0 ;
                cnt_delay <= cnt_delay==0 ? 0 : cnt_delay -1 ;
                state <= (cnt_delay==0 & CNTVALUE_TRUE_I == CNTVALUE_SET_O) ? 3 : state ;
                data_mid <= DATA_I ;
            end
            3:begin //increase stage
                LD_O <= 1 ;
                CNTVALUE_SET_O <= CNTVALUE_SET_O + 1 ;
                state <=  4 ;
                cnt_delay <= LD_DELAY;
            end
            4:begin
                LD_O <= 0 ;
                cnt_delay <= cnt_delay==0 ? 0 : cnt_delay -1 ;
                state <= (cnt_delay==0 & CNTVALUE_TRUE_I == CNTVALUE_SET_O) ?  ( DATA_I!=data_mid  |  CNTVALUE_SET_O>=TAP_TOP ) ?  9 : 3 : state ;
                cntvalue_right <=  CNTVALUE_SET_O ;
            end
            9:begin
                LD_O <= 1 ;
                CNTVALUE_SET_O <= TAP_MID ; //回到中间 ???  为何中间不稳定？？
                state <= 10 ;  
                cnt_delay <= LD_DELAY;
            end
            10:begin
                LD_O  <= 0 ;
                cnt_delay <= cnt_delay==0 ? 0 : cnt_delay -1 ;
                state <= (cnt_delay==0 & CNTVALUE_TRUE_I == CNTVALUE_SET_O ) ? 5 : state ;
            end
            5:begin//decrease stage; 从中间级延迟开始递减
                LD_O <= 1 ;
                CNTVALUE_SET_O <= CNTVALUE_SET_O - 1 ;
                state <= 6 ;  
                cnt_delay <= LD_DELAY;
            end
            6:begin
                LD_O <= 0 ;
                cnt_delay <= cnt_delay==0 ? 0 : cnt_delay -1 ;
                state <= (cnt_delay==0  & CNTVALUE_TRUE_I == CNTVALUE_SET_O) ?  ( DATA_I!=data_mid  |  CNTVALUE_SET_O==TAP_LOW ) ?  7 : 5 : state ;
                cntvalue_left <=  CNTVALUE_SET_O ;
            end
            7:begin
                LD_O <= 1 ;
                CNTVALUE_SET_O <= ( cntvalue_right + cntvalue_left ) / 2;//
                state <= 8;
                cnt_delay <= LD_DELAY;
            end
            8:begin
                LD_O <= 0 ;
                cnt_delay <= cnt_delay==0 ? 0 : cnt_delay -1 ;
                state <= (cnt_delay==0  & CNTVALUE_TRUE_I == CNTVALUE_SET_O) ? 0 : state ;
                BITALIGN_DONE_O <= CNTVALUE_TRUE_I == CNTVALUE_SET_O ? 1 : 0; 
            end
            default:;    
        endcase
    end
end

   
    
    
endmodule
