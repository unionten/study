`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/01/31 13:58:26
// Design Name: 
// Module Name: tb_prbs_en_wrapper
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//////////////////////////////////////////////////////////////////////////////////


module tb_prbs_en_wrapper(

    );

parameter C_TX_DATA_WIDTH_16_EN  = 0 ;
parameter C_TX_DATA_WIDTH_20_EN  = 0 ;
parameter C_TX_DATA_WIDTH_32_EN  = 0 ;
parameter C_TX_DATA_WIDTH_64_EN  = 0 ;
parameter C_TX_DATA_WIDTH_80_EN  = 1 ;

parameter C_TX_PATTERN_0_EN      = 1 ;
parameter C_TX_PATTERN_1_EN      = 1 ;
parameter C_TX_PATTERN_2_EN      = 0 ;
parameter C_TX_PATTERN_3_EN      = 0 ;
parameter C_TX_PATTERN_4_EN      = 0 ;
parameter C_TX_PATTERN_5_EN      = 0 ;
parameter C_TX_PATTERN_9_EN      = 1 ;
parameter C_TX_PATTERN_10_EN     = 0 ;


parameter C_RX_DATA_WIDTH_16_EN  = 0 ;
parameter C_RX_DATA_WIDTH_20_EN  = 0 ;
parameter C_RX_DATA_WIDTH_32_EN  = 0 ;
parameter C_RX_DATA_WIDTH_64_EN  = 0 ;
parameter C_RX_DATA_WIDTH_80_EN  = 1 ;

parameter C_RX_PATTERN_0_EN      = 1 ;
parameter C_RX_PATTERN_1_EN      = 1 ;
parameter C_RX_PATTERN_2_EN      = 0 ;
parameter C_RX_PATTERN_3_EN      = 0 ;
parameter C_RX_PATTERN_4_EN      = 0 ;
parameter C_RX_PATTERN_5_EN      = 0 ;
parameter C_RX_PATTERN_9_EN      = 1 ;
parameter C_RX_PATTERN_10_EN     = 0 ;



reg [3:0] tx_pattern  = 0; 
parameter tx_width    = 80 ;

reg [3:0] rx_pattern  = 0; 
parameter rx_width    = 80 ;



wire [79:0] data_1;
wire [79:0] data_2;
reg clk;
reg rst;
wire [31:0] ERR_BIT_NUM;
wire [31:0] ERR_BIT_NUM_dym;
wire CHK_LOCKED;
reg err;

prbs_en_wrapper  
  #(.C_MODE_0GEN_1CHK       (0) , //=  0 ; //0: gen   1:check
    .C_CHK_LOCK_CLK_PRD_NUM (100) , //= 100;//多少个时钟无误码认为锁定(同时，一旦有错，立刻失锁)
    .C_CHK_STAT_CLK_PRD_NUM (10000),
    .C_DATA_WIDTH_16_EN  (C_TX_DATA_WIDTH_16_EN ),
    .C_DATA_WIDTH_20_EN  (C_TX_DATA_WIDTH_20_EN ),
    .C_DATA_WIDTH_32_EN  (C_TX_DATA_WIDTH_32_EN ),
    .C_DATA_WIDTH_64_EN  (C_TX_DATA_WIDTH_64_EN ),
    .C_DATA_WIDTH_80_EN  (C_TX_DATA_WIDTH_80_EN ),
    .C_PATTERN_0_EN      (C_TX_PATTERN_0_EN     ),
    .C_PATTERN_1_EN      (C_TX_PATTERN_1_EN     ),
    .C_PATTERN_2_EN      (C_TX_PATTERN_2_EN     ),
    .C_PATTERN_3_EN      (C_TX_PATTERN_3_EN     ),
    .C_PATTERN_4_EN      (C_TX_PATTERN_4_EN     ),
    .C_PATTERN_5_EN      (C_TX_PATTERN_5_EN     ),
    .C_PATTERN_9_EN      (C_TX_PATTERN_9_EN     ),
    .C_PATTERN_10_EN     (C_TX_PATTERN_10_EN    )

    ) 
    prbs_en_tx_u(
    .CLK_I              (clk),      
    .RST_I              (rst),    
    .USR_PATTERN_I      (32'haabbccdd) ,    
    .DATA_I             (0),    
    .DATA_O             (data_1),    
    .PATTERN_I          (tx_pattern),  
    .DATA_WIDTH_I       (tx_width  ) 
    );

  
prbs_en_wrapper  
  #(.C_MODE_0GEN_1CHK       (1) , //=  0 ; //0: gen   1:check
    .C_CHK_LOCK_CLK_PRD_NUM (100) , //= 100;//多少个时钟无误码认为锁定(同时，一旦有错，立刻失锁)
    .C_CHK_STAT_CLK_PRD_NUM (10000),
    .C_DATA_WIDTH_16_EN  (C_RX_DATA_WIDTH_16_EN ),
    .C_DATA_WIDTH_20_EN  (C_RX_DATA_WIDTH_20_EN ),
    .C_DATA_WIDTH_32_EN  (C_RX_DATA_WIDTH_32_EN ),
    .C_DATA_WIDTH_64_EN  (C_RX_DATA_WIDTH_64_EN ),
    .C_DATA_WIDTH_80_EN  (C_RX_DATA_WIDTH_80_EN ),
    .C_PATTERN_0_EN      (C_RX_PATTERN_0_EN     ),
    .C_PATTERN_1_EN      (C_RX_PATTERN_1_EN     ),
    .C_PATTERN_2_EN      (C_RX_PATTERN_2_EN     ),
    .C_PATTERN_3_EN      (C_RX_PATTERN_3_EN     ),
    .C_PATTERN_4_EN      (C_RX_PATTERN_4_EN     ),
    .C_PATTERN_5_EN      (C_RX_PATTERN_5_EN     ),
    .C_PATTERN_9_EN      (C_RX_PATTERN_9_EN     ),
    .C_PATTERN_10_EN     (C_RX_PATTERN_10_EN    )
    ) 
    prbs_en_rx_u(
    .CLK_I              (clk),      
    .RST_I              (rst),     
    .USR_PATTERN_I      (32'haabbccdd) ,
    .DATA_I             (data_1+err),    
    .DATA_O             (data_2),    
    .PATTERN_I          (rx_pattern),  
    .DATA_WIDTH_I       (rx_width),
    .CHK_LOCKED_O       (CHK_LOCKED),
    .CHK_ERR_BIT_NUM_O  (ERR_BIT_NUM)  ,
    .CHK_ERR_BIT_NUM_DYM_O (ERR_BIT_NUM_dym)    
    );   



always #5 clk = ~clk;

initial begin
    tx_pattern = 1;
    rx_pattern = 1;
    err = 0;
    clk = 0;
    rst = 0;
    #1000;
    
    rst = 0;
    #1000;
    
    #5000;
    err =1 ;
    #200;
    err = 0;
    
    
    #5000;
    tx_pattern = 1;
    rx_pattern = 0;
    
    #5000;
    tx_pattern = 0;
    rx_pattern = 0;
    
    #10000;
    
    err =1 ;
    #200;
    err = 0;
  
end
 
    
endmodule
