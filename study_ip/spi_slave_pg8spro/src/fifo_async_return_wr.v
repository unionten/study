`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: yzhu
// 
// Create Date: 2023/06/25 21:28:14
// Design Name: 
// Module Name: fifo_async_return_wr
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//////////////////////////////////////////////////////////////////////////////////
//(*keep_hierarchy="yes"*) 
module fifo_async_return_wr(
input                           FIFO_WR_CLK_I        ,            
input                           FIFO_WR_RST_I        ,            
input                           FIFO_WR_EN_I         , 
output                          FIFO_WR_EN_VALID_O   ,      
input                           FIFO_WR_SUCC_I       ,         
input                           FIFO_WR_FAIL_I       ,  
input  [C_FIFO_WRITE_WIDTH-1:0] FIFO_WR_DATA_I       ,      
output                          FIFO_WR_FULL_O       ,   
output [C_DATA_COUNT_WIDTH-1:0] FIFO_WR_DATA_COUNT_O ,
output [C_DBG_COUNT_WIDTH-1:0] FIFO_WR_IN_RD_ACCUS_O, 
output [C_DBG_COUNT_WIDTH-1:0] FIFO_WR_IN_WR_ACCUS_O, 
output [C_DBG_COUNT_WIDTH-1:0] FIFO_WR_EN_NAMES_O   ,//名义写入次数
output [C_DBG_COUNT_WIDTH-1:0] FIFO_WR_EN_ACCUS_O   ,

output  FIFO_WR_RST_BUSY_O ,

input                           FIFO_RD_CLK_I        ,
input                           FIFO_RD_RST_I        , // NO USE
input                           FIFO_RD_EN_I         ,    
output [C_FIFO_READ_WIDTH-1:0]  FIFO_RD_DATA_O       ,    
output                          FIFO_RD_DATA_VALID_O ,
output                          FIFO_RD_EMPTY_O      ,
output [C_DATA_COUNT_WIDTH-1:0] FIFO_RD_DATA_COUNT_O ,
output [C_DBG_COUNT_WIDTH-1:0]  FIFO_RD_EN_NAMES_O   ,
output [C_DBG_COUNT_WIDTH-1:0]  FIFO_RD_EN_ACCUS_O    ,   
output  FIFO_RD_RST_BUSY_O 
//input                           CRC_RST_I,
//output [31:0]                   CRC_VAL_O  
   
);

parameter C_FIFO_WRITE_WIDTH      = 32    ;
parameter C_FIFO_READ_WIDTH       = 32   ;
parameter C_WR_TMN_RTL_FIFO_DEPTH = 32  ; // atpg： 至少应该能缓存指令头
parameter C_RD_TMN_XPM_FIFO_DEPTH = 1024   ; // atpg：根据rx fifo的目标缓存大小而定
parameter C_DATA_COUNT_WIDTH      = 16    ;
parameter C_DBG_COUNT_WIDTH       = 16    ;

assign FIFO_WR_RST_BUSY_O = 0;
assign  FIFO_RD_RST_BUSY_O = 0;



wire                          inter_full;
wire                          inter_empty; 
wire                          inter_transfer;
wire                          inter_transfer_valid;
wire [C_FIFO_WRITE_WIDTH-1:0] inter_data;
reg [C_DBG_COUNT_WIDTH-1:0]  wr_names;
reg [C_DBG_COUNT_WIDTH-1:0]  wr_accus;
reg [C_DBG_COUNT_WIDTH-1:0]  inter_rd_accus;
reg [C_DBG_COUNT_WIDTH-1:0]  inter_wr_accus;
wire                          fifo_rd_empty;
wire [C_DATA_COUNT_WIDTH-1:0] fifo_rd_data_count;
wire [31:0]                   crc_data_out;// fixed 32

//assign CRC_VAL_O = crc_data_out;


always@(posedge FIFO_WR_CLK_I)begin
    if(FIFO_WR_RST_I)inter_rd_accus <= 0;
    else inter_rd_accus <= inter_transfer ? inter_rd_accus + 1 :inter_rd_accus; 
end
assign FIFO_WR_IN_RD_ACCUS_O = inter_rd_accus;
always@(posedge FIFO_WR_CLK_I)begin
    if(FIFO_WR_RST_I)inter_wr_accus <= 0;
    else inter_wr_accus <= inter_transfer_valid ? inter_wr_accus + 1 : inter_wr_accus;
end
assign FIFO_WR_IN_WR_ACCUS_O = inter_wr_accus;


assign inter_transfer = ~inter_empty & ~inter_full & ~inter_wr_rst_busy;

//(*keep_hierarchy="yes"*)
fifo_sync_return  
    #(
     .C_RD_MODE               ("fwft"                          ),
     .C_WR_WIDTH              (C_FIFO_WRITE_WIDTH              ), //建议稍浅一些
     .C_WR_DEPTH              (C_WR_TMN_RTL_FIFO_DEPTH         ),
     .C_RD_WIDTH              (C_FIFO_WRITE_WIDTH              ),
     .C_WR_PROG_FULL_THRESH   (C_WR_TMN_RTL_FIFO_DEPTH - 1024  ), //note for hspi wr
     .C_RD_PROG_EMPTY_THRESH  (0                               ),
     .C_WR_RETURN_EN          (1                               ),
     .C_RD_RETURN_EN          (0                               ),
     .C_WR_COUNT_WIDTH        (C_DATA_COUNT_WIDTH              ),
     .C_RD_COUNT_WIDTH        (C_DATA_COUNT_WIDTH              ),
     .C_DBG_COUNT_WIDTH       (C_DBG_COUNT_WIDTH               )
     )
    rx_buffer_u(
    .CLK_I              (FIFO_WR_CLK_I                    ),
    .RST_I              (FIFO_WR_RST_I                    ),
    .WR_EN_I            (FIFO_WR_EN_I                     ),
    .WR_EN_NAMES_O      (FIFO_WR_EN_NAMES_O               ),
    .WR_EN_ACCUS_O      (FIFO_WR_EN_ACCUS_O               ),
    .WR_EN_VALID_O      (FIFO_WR_EN_VALID_O               ), 
    .WR_DATA_I          (FIFO_WR_DATA_I                   ),
    .WR_SUCC_I          (FIFO_WR_SUCC_I                   ),
    .WR_FAIL_I          (FIFO_WR_FAIL_I                   ),
    .WR_FULL_O          (                                 ),
    .WR_PROG_FULL_O     (FIFO_WR_FULL_O                   ),
    .WR_DATA_COUNT_O    (FIFO_WR_DATA_COUNT_O             ), 
    .RD_EN_I            (inter_transfer                   ), 
    .RD_DATA_VALID_O    (),
    .RD_EN_NAMES_O      (),
    .RD_EN_ACCUS_O      (    ), 
    .RD_DATA_O          (inter_data                       ),   
    .RD_SUCC_I          (0                                ),
    .RD_FAIL_I          (0                                ),
    .RD_EMPTY_O         (inter_empty                      ), 
    .RD_PROG_EMPTY_O    (                                 ), 
    .RD_DATA_COUNT_O    (                                 )  
    );


//crc32  calc_crc32_u (		
//	.clk     ( FIFO_WR_CLK_I                     ),
//	.rst     ( CRC_RST_I        | FIFO_WR_RST_I  ),
//    .crc_en  ( inter_transfer                    ), 
//    .data_in ( inter_data                        ),
//	.crc_out ( crc_data_out                      )
//    );
//    

fifo_async_xpm  
    #(.C_RD_MODE  ("fwft"             ), //"std" "fwft"  
      .C_WR_WIDTH (C_FIFO_WRITE_WIDTH ),     //atpg -- 建议稍深一些
      .C_RD_WIDTH (C_FIFO_READ_WIDTH  ), 
      .C_WR_DEPTH (C_RD_TMN_XPM_FIFO_DEPTH    ),
      .C_WR_COUNT_WIDTH (C_DATA_COUNT_WIDTH),
      .C_RD_COUNT_WIDTH (C_DATA_COUNT_WIDTH),
      .C_RD_PROG_EMPTY_THRESH(6  ),
      .C_WR_PROG_FULL_THRESH (100),
      .C_DBG_COUNT_WIDTH     (C_DBG_COUNT_WIDTH)
      )
    tx_fifo_u(
    .WR_RST_I        (FIFO_WR_RST_I        ),//at least 1 WR_CLK_I period
    .WR_CLK_I        (FIFO_WR_CLK_I        ),
    .WR_EN_I         (inter_transfer       ),
    .WR_EN_VALID_O   (inter_transfer_valid ),  
    .WR_EN_NAMES_O   (                     ),
    .WR_EN_ACCUS_O   (                     ),  //total valid wr num
    .WR_DATA_I       (inter_data           ),
    .WR_FULL_O       (inter_full           ),
    .WR_DATA_COUNT_O (                     ),
    .WR_PROG_FULL_O  (                     ),
    .WR_RST_BUSY_O   (inter_wr_rst_busy    ),
                     
    .RD_CLK_I        (FIFO_RD_CLK_I        ),
    .RD_EN_I         (FIFO_RD_EN_I         ),
    .RD_DATA_O       (FIFO_RD_DATA_O       ),
    .RD_DATA_VALID_O (FIFO_RD_DATA_VALID_O ), 
    .RD_EN_NAMES_O   (FIFO_RD_EN_NAMES_O   ),
    .RD_EN_ACCUS_O   (FIFO_RD_EN_ACCUS_O   ), 
    .RD_EMPTY_O      (fifo_rd_empty        ),
    .RD_DATA_COUNT_O (fifo_rd_data_count   ), 
    .RD_PROG_EMPTY_O (                     ),
    .RD_RST_BUSY_O   (fifo_rd_rst_busy     )

    );

assign FIFO_RD_EMPTY_O      =   fifo_rd_empty | fifo_rd_rst_busy;
assign FIFO_RD_DATA_COUNT_O =   ~fifo_rd_rst_busy ? fifo_rd_data_count : 0;
  
    
endmodule




