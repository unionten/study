`define POS_MONITOR_INGEN(clk,rst,in,out)                                                               begin  reg buf_name1 = 0; always@(posedge clk)begin if(rst)buf_name1 <= 0; else  buf_name1 <= in; end assign out = (~buf_name1)&(in);  end  
`define NEG_MONITOR_INGEN(clk,rst,in,out)                                                               begin  reg buf_name1 = 0; always@(posedge clk)begin if(rst)buf_name1 <= 0; else  buf_name1 <= in; end assign out = (buf_name1)&(~in);  end  



module vs_filter (
input  CLK_I  ,
input  RSTN_I ,
input   VS_I   ,// __|————|_____ 
output  VS_O   ,//  --- 检测上沿
output  VS_STABLE_O   , // 
output  VS_TIMEOUT_O  ,

input       FILTER_EN_I ,
input [7:0] FILTER_TIMES_I ,
input [C_THRESHHOLD_CLKPRD_BW-1:0] FILTER_THRESHHOLD_CLKPRD_I  //差值


);


parameter C_AXI_CLK_PRD_NS       = 10 ;
parameter C_THRESHHOLD_CLKPRD_BW = 16 ;//差值 位宽   <= 65535
parameter C_TIMEOUT_TIME_CLKNUM_BW = 24 ; // 超时 位宽    <= 16777215
parameter C_TIMEOUT_TIME_CLKNUM   = 65536 ;//默认超时 周期数
parameter [0:0] C_TIMEOUT_DET_BLOCK_EN  = 0;


reg [C_TIMEOUT_TIME_CLKNUM_BW-1:0] cnt_timeout  = 0; //注意位宽  两次vs之间
reg [C_TIMEOUT_TIME_CLKNUM_BW-1:0] count_now = 0 ;
reg [C_TIMEOUT_TIME_CLKNUM_BW-1:0] count_last = 0 ;


    wire VS_I_pos;
    wire VS_I_neg;
    wire vs_stable_neg ;
    
    
    reg VS_I_ff;
    reg VS_I_ff2;
    always@(posedge CLK_I)begin
        VS_I_ff  <= VS_I;
        VS_I_ff2 <= VS_I_ff ;
    end
    
    assign VS_I_pos = VS_I& ~VS_I_ff  ;
    assign VS_I_neg = ~VS_I & VS_I_ff  ;
    
    
     
    
    `NEG_MONITOR_INGEN(CLK_I,0,vs_stable,vs_stable_neg)  
    

    
    reg vs_compare_en_0 =0 ;
    reg vs_compare_en  =0  ;
    reg vs_stable=0 ;
    reg [C_THRESHHOLD_CLKPRD_BW-1:0] vs_same_time =0 ;// 比较后相同的次数（根据阈值） （比vs次数少1）
    
    wire time_out_flag ; 
    
    assign  time_out_flag = C_TIMEOUT_DET_BLOCK_EN ? (  cnt_timeout==C_TIMEOUT_TIME_CLKNUM  ) :  0  ;
    
    always@(posedge CLK_I)begin
        if(~RSTN_I)begin
            cnt_timeout <=  0 ; 
        end
        else begin
            cnt_timeout <= VS_I_pos ? 0 : (  time_out_flag  ? cnt_timeout :  cnt_timeout + 1  ) ;
        end
    end
    

    
    always@(posedge CLK_I)begin
        if(~RSTN_I)begin 
            vs_stable       <= 0 ;
            vs_compare_en_0 <= 0;
            vs_compare_en   <= 0 ; // 标记需要比较 count_now 的 节点
               
                     
        end
        else begin
            vs_stable       <= time_out_flag ? 0 : (   vs_same_time >= FILTER_TIMES_I  ) ;
            
            vs_compare_en_0 <=  vs_stable_neg ? 0 :  (  VS_I_pos ? 1 : vs_compare_en_0  ) ;
            vs_compare_en   <=  vs_stable_neg ? 0 :  (  vs_compare_en_0 & VS_I_pos ? 1 : vs_compare_en  );

       end
    end
    
    
    always @(posedge CLK_I ) begin
        if (~RSTN_I | time_out_flag ) begin
            count_now <= 0;
            count_last <= 0; 
        end else if (VS_I_pos) begin
            count_last <= count_now ;
            count_now  <= 0;   
        end else begin
            count_now <= count_now + 1;
        end
    end


    always @(posedge CLK_I ) begin
        if (~RSTN_I) begin
            vs_same_time <= 0;
        end
        else begin 
            vs_same_time <= time_out_flag ? 0 : (  ( VS_I_pos &  vs_compare_en  ) ?  ( abs_diff(count_now,count_last)>FILTER_THRESHHOLD_CLKPRD_I  ? 0 :  vs_same_time + 1   )  :  vs_same_time   ) ;
        end
    end


    assign VS_O = FILTER_EN_I ?  ( vs_stable & VS_I_ff2 ) : VS_I_ff2 ;
    assign VS_STABLE_O = FILTER_EN_I  ?  vs_stable  :  1  ;
    assign VS_TIMEOUT_O = FILTER_EN_I ? time_out_flag  : 0 ; 
    




/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function [C_TIMEOUT_TIME_CLKNUM_BW-1:0] abs_diff;
    input [C_TIMEOUT_TIME_CLKNUM_BW-1:0] a;   // 输入寄存器a
    input [C_TIMEOUT_TIME_CLKNUM_BW-1:0] b;   // 输入寄存器b
    
    begin
        // 通过条件判断实现绝对值计算，避免使用不可综合的$abs函数
        if (a > b) begin
            abs_diff = a - b;
        end else begin
            abs_diff = b - a;
        end
    end
endfunction





endmodule 




