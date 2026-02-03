`timescale 1ns / 1ps
`define MACRO_80  80
`define MACRO_31  31
`define MACRO_16  16

//this module is  the TOP file of  PRBS  

/*  
prbs_en_wrapper  
  #(.C_MODE_0GEN_1CHK       (1                     ),  
    .C_CHK_LOCK_CLK_PRD_NUM (100                   ), 
    .C_CHK_STAT_CLK_PRD_NUM (10000                 ),
    .C_DATA_WIDTH_16_EN     (C_RX_DATA_WIDTH_16_EN ),
    .C_DATA_WIDTH_20_EN     (C_RX_DATA_WIDTH_20_EN ),
    .C_DATA_WIDTH_32_EN     (C_RX_DATA_WIDTH_32_EN ),
    .C_DATA_WIDTH_64_EN     (C_RX_DATA_WIDTH_64_EN ),
    .C_DATA_WIDTH_80_EN     (C_RX_DATA_WIDTH_80_EN ),
    .C_PATTERN_0_EN         (C_RX_PATTERN_0_EN     ),
    .C_PATTERN_1_EN         (C_RX_PATTERN_1_EN     ),
    .C_PATTERN_2_EN         (C_RX_PATTERN_2_EN     ),
    .C_PATTERN_3_EN         (C_RX_PATTERN_3_EN     ),
    .C_PATTERN_4_EN         (C_RX_PATTERN_4_EN     ),
    .C_PATTERN_5_EN         (C_RX_PATTERN_5_EN     ),
    .C_PATTERN_9_EN         (C_RX_PATTERN_9_EN     ),
    .C_PATTERN_10_EN        (C_RX_PATTERN_10_EN    )
    ) 
    prbs_en_rx_u(
    .CLK_I              (clk          ),      
    .RST_I              (rst          ),     
    .USR_PATTERN_I      (32'haabbccdd ), //[31:0]
    .DATA_I             (             ), //[79:0]   
    .DATA_O             (             ), //[79:0]     
    .PATTERN_I          (rx_pattern   ), //[ 3:0] 
    .DATA_WIDTH_I       (rx_width     ), 
    .CHK_LOCKED_O       (CHK_LOCKED   ),
    .CHK_ERR_BIT_NUM_O  (ERR_BIT_NUM  )  //[31:0]
    );  
*/   

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: yzhu
// 
// Create Date: 2024/01/31 09:51:23
// Design Name: 
// Module Name: prbs_en_wrapper
//
//////////////////////////////////////////////////////////////////////////////////
//不存在绝对的不误码，所以可以设定连续多少个周期无误码为锁定，连续多少周期有误码为不锁定
//误码率如果要做到实时更新，即类似于平滑滤波那种方式，是不现实的
//对于误码率，使用定期（例如2^10次采样）更新的方式 ；对外提供采样数和误码数（根据bit计算）
//对于锁定，采用一定周期无错误则锁定，一旦有错误立刻失锁的 模式

//estimate resource: 860LUT  211FF  when all function

// hierarchy -> prbs_en_wrapper.v - prbs_en.v & bit_counter.v

module prbs_en_wrapper( 
input  CLK_I ,      
input  RST_I  ,      // do not must need to rst when power up
input  [31:0]                 USR_PATTERN_I ,
input  [`MACRO_80 -1:0]       DATA_I       ,    
output [`MACRO_80 -1:0]       DATA_O       ,    
input  [3:0]                  PATTERN_I    ,  
input  [7:0]                  DATA_WIDTH_I ,
output                        CHK_LOCKED_O ,
output reg [31:0]             CHK_ERR_BIT_NUM_O = 0 ,
output     [31:0]             CHK_ERR_BIT_NUM_DYM_O   
    );

parameter  C_INPUT_FF_NUM    = 3;
parameter  C_OUTPUT_FF_NUM   = 3;
parameter C_MODE_0GEN_1CHK    =  1 ; //0: gen   1:check
parameter [0:0] C_ERR_BIT_CHK_EN  = 1;
parameter C_CHK_LOCK_CLK_PRD_NUM = 100;//参数: 多少个时钟无误码时认为锁定(同时，一旦有错，立刻失锁)
parameter C_CHK_STAT_CLK_PRD_NUM = 1000;//误码率的统计周期；注意 : 和锁定失锁检测周期，概念不同
parameter [0:0] C_DATA_WIDTH_16_EN = 0 ;
parameter [0:0] C_DATA_WIDTH_20_EN = 0 ;
parameter [0:0] C_DATA_WIDTH_32_EN = 0 ;
parameter [0:0] C_DATA_WIDTH_64_EN = 0 ;
parameter [0:0] C_DATA_WIDTH_80_EN = 1 ;
parameter [0:0] C_PATTERN_0_EN     = 1 ;
parameter [0:0] C_PATTERN_1_EN     = 0 ;
parameter [0:0] C_PATTERN_2_EN     = 0 ;
parameter [0:0] C_PATTERN_3_EN     = 0 ;
parameter [0:0] C_PATTERN_4_EN     = 0 ;
parameter [0:0] C_PATTERN_5_EN     = 0 ;
parameter [0:0] C_PATTERN_9_EN     = 0 ;
parameter [0:0] C_PATTERN_10_EN    = 0 ;


///////////////////////////////////////////////////////////////////////////////
reg [31:0] err_bit_num_dym = 0; 
wire [$clog2(`MACRO_80 ):0] err_num_per_clk;
reg locked_reg = 0;
reg [$clog2(C_CHK_LOCK_CLK_PRD_NUM):0] cnt_locked = 0;
wire err_flag_per_clk ;
reg [31:0] cnt_stat_err = 0;  
wire chk_err_bit_update_pulse;

assign CHK_ERR_BIT_NUM_DYM_O = err_bit_num_dym ;

prbs_en  
    #(
      .C_INPUT_FF_NUM     (C_INPUT_FF_NUM     ) ,// >=0 
      .C_OUTPUT_FF_NUM    (C_OUTPUT_FF_NUM    ) ,// >=0 
      .C_CHK_MODE         (C_MODE_0GEN_1CHK   ) ,   
      .C_DATA_WIDTH_16_EN (C_DATA_WIDTH_16_EN ),
      .C_DATA_WIDTH_20_EN (C_DATA_WIDTH_20_EN ),
      .C_DATA_WIDTH_32_EN (C_DATA_WIDTH_32_EN ),
      .C_DATA_WIDTH_64_EN (C_DATA_WIDTH_64_EN ),
      .C_DATA_WIDTH_80_EN (C_DATA_WIDTH_80_EN ),
      .C_PATTERN_0_EN     (C_PATTERN_0_EN     ),
      .C_PATTERN_1_EN     (C_PATTERN_1_EN     ),
      .C_PATTERN_2_EN     (C_PATTERN_2_EN     ),
      .C_PATTERN_3_EN     (C_PATTERN_3_EN     ),
      .C_PATTERN_4_EN     (C_PATTERN_4_EN     ),
      .C_PATTERN_5_EN     (C_PATTERN_5_EN     ),
      .C_PATTERN_9_EN     (C_PATTERN_9_EN     ),
      .C_PATTERN_10_EN    (C_PATTERN_10_EN    ) )
    prbs_en_u(
    .CLK_I        (CLK_I ), 
    .RST_I        (RST_I ),
    .USR_PATTERN_I(USR_PATTERN_I),
    .DATA_I       (DATA_I),
    .DATA_O       (DATA_O),
    .PATTERN_I    (PATTERN_I   ), //0 1 2 3 4 5 9 10 
    .DATA_WIDTH_I (DATA_WIDTH_I)  // 16 20 32 64 80
    );



bit_counter
    #(.C_MAX_DATA_WIDTH(`MACRO_80 ))
    bit_counter_u(
    .DATA_I        (DATA_O), 
    .VALID_WIDTH_I (DATA_WIDTH_I),
    .RESULT_O      (err_num_per_clk ) // 按bit展示错误位的情况（已经是最终错误数）
    );


//gen locked signal
assign err_flag_per_clk = err_num_per_clk!=0;
always@(posedge CLK_I)begin
    if(RST_I )begin
        cnt_locked <= 0;
    end
    else begin
        cnt_locked <= err_flag_per_clk ? 0 : ~err_flag_per_clk ? cnt_locked + 1 : cnt_locked ;
    end
end

always@(posedge CLK_I)begin
    if(RST_I)begin
        locked_reg <= 0;
    end
    else begin
        locked_reg <= err_flag_per_clk ? 0 : cnt_locked==C_CHK_LOCK_CLK_PRD_NUM ? 1 : locked_reg ; 
    end
end

assign CHK_LOCKED_O = locked_reg;



//gen err bit num (every sample period)
assign chk_err_bit_update_pulse = cnt_stat_err==C_CHK_STAT_CLK_PRD_NUM;

always@(posedge CLK_I)begin
    if(RST_I | ~C_ERR_BIT_CHK_EN)begin
        cnt_stat_err <= 0;
        err_bit_num_dym <= 0;
        CHK_ERR_BIT_NUM_O <= 0; 
    end
    else begin
        cnt_stat_err <= chk_err_bit_update_pulse ? 0 : cnt_stat_err + 1;  
        err_bit_num_dym  <= chk_err_bit_update_pulse ? 0 : err_bit_num_dym + err_num_per_clk  ;
        CHK_ERR_BIT_NUM_O <= chk_err_bit_update_pulse ? err_bit_num_dym : CHK_ERR_BIT_NUM_O ;
    end
end

    
endmodule



