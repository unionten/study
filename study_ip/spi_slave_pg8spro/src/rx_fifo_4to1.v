`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/14 17:35:19
// Design Name: 
// Module Name: rx_fifo_4to1
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


module tx_fifo_4to1(
input  FIFO_WR_CLK_I         ,
input  FIFO_WR_RSTN_I        ,
input  FIFO_WR_I             ,
input  [31:0] FIFO_WR_DATA_I        ,
input  [3:0] FIFO_WR_STRB_I        ,
                             
input  FIFO_RD_CLK_I         ,
input  FIFO_RD_EN_I          ,
output [7:0] FIFO_RD_DATA_O        ,
output FIFO_RD_EMPTY_O       , //safe 
output [15:0] FIFO_RD_DATA_COUNT_O  , //safe ; delay to rd_en
output RD_RST_BUSY_O        


);
    
wire M_WVALID0 ;
wire M_WREADY0 ;
wire [15:0] M_WDATA0 ;
wire [1:0] M_WSTRB0 ;
wire M_WLAST0 ;


wire M_WVALIDs ;
wire M_WREADYs ;
wire [15:0] M_WDATAs ;
wire [1:0] M_WSTRBs ;
wire M_WLASTs ;

wire M_WVALIDs2 ;
wire M_WREADYs2 ;
wire [15:0] M_WDATAs2 ;
wire [1:0] M_WSTRBs2 ;
wire M_WLASTs2 ;



wire M_WVALID1 ;
wire M_WREADY1 ;
wire WR_RST_BUSY ;
wire [7:0] M_WDATA1 ;

wconverter   
   #( .IN_WIDTH  (32),
      .OUT_WIDTH (16)
     )
    wconverter_u0(
    .CLK       (FIFO_WR_CLK_I      ),
    .RSTN      (FIFO_WR_RSTN_I   ),
    .S_WVALID  (FIFO_WR_I       ),
    .S_WREADY  ( ),
    .S_WDATA   (FIFO_WR_DATA_I),
    .S_WSTRB   (FIFO_WR_STRB_I   ),
    .S_WLAST   (FIFO_WR_I        ),
    .M_WVALID  (M_WVALIDs        ),
    .M_WREADY  (M_WREADYs        ),
    .M_WDATA   (M_WDATAs         ),
    .M_WSTRB   (M_WSTRBs         ),
    .M_WLAST   (M_WLASTs         )
    );



reg_fifo_cas 
    #( .WIDTH (21 ), 
       .CAS_NUM ( 16 ) 
       )
    reg_fifo_u
    (
    .CLK_I     (FIFO_WR_CLK_I ) ,
    .RST_I     (~FIFO_WR_RSTN_I) , 
    .S_WVALID  (M_WVALIDs ) ,  
    .S_WREADY  (M_WREADYs ) , 
    .S_WDATA   ({M_WDATAs,M_WSTRBs,M_WLASTs}  ) ,
    .M_WVALID  (M_WVALID0 ) ,
    .M_WREADY  (M_WREADY0 ) ,
    .M_WDATA   ({M_WDATA0,M_WSTRB0,M_WLAST0}  )
    );

wconverter   
   #( .IN_WIDTH  (16),
      .OUT_WIDTH (8)
     )
    wconverter_u1(
    .CLK       (FIFO_WR_CLK_I      ),
    .RSTN      (FIFO_WR_RSTN_I   ),
    .S_WVALID  (M_WVALID0       ),
    .S_WREADY  (M_WREADY0       ),
    .S_WDATA   (M_WDATA0        ),
    .S_WSTRB   (M_WSTRB0        ),
    .S_WLAST   (M_WLAST0        ),
    
    .M_WVALID  (M_WVALID1       ),
    .M_WREADY  (~M_WREADY1 & ~WR_RST_BUSY  ),
    .M_WDATA   (M_WDATA1        ),
    .M_WSTRB   (),
    .M_WLAST   ()
    );


fifo_async_xpm   
#( .C_RD_MODE               ("fwft" ),//"std" "fwft"  
   .C_WR_WIDTH              (8),//Write and read width aspect ratio must be 1:1, 1:2, 1:4, 1:8, 8:1, 4:1 and 2:1     
   .C_RD_WIDTH              (8),
   .C_WR_DEPTH              (1024),//must>=16 ; actual depth = C_WR_DEPTH - 1(实测结果符合，即配置深度16，最多写15个值就会报full);  must be power of two
   .C_WR_COUNT_WIDTH        (16),
   .C_RD_COUNT_WIDTH        (16),
   .C_RD_PROG_EMPTY_THRESH  (10),  
   .C_WR_PROG_FULL_THRESH   (1024-10), //WRITE_FIFO_DEPTH时即完全等同于full
   .C_DBG_COUNT_WIDTH       (16 ) )
    fifo_async_xpm_u(
    .WR_RST_I                   (~FIFO_WR_RSTN_I  ) , //at least 1 WR_CLK_I period
    .WR_CLK_I                   (FIFO_WR_CLK_I      ) ,
    .WR_EN_I                    (M_WVALID1 & ~M_WREADY1 & ~WR_RST_BUSY  ) , //sync to wr_full (和 wr_full 同一)
    .WR_EN_VALID_O              () , //和 WR_EN_I 之间无延迟
    .WR_EN_NAMES_O              () ,
    .WR_EN_ACCUS_O              () , //total valid wr num
    .WR_DATA_I                  (M_WDATA1   ) ,
    .WR_SUCC_I                  () , //NO USE
    .WR_FAIL_I                  () , //NO USE
    .WR_FULL_O                  (M_WREADY1  ) , //safe 
    .WR_DATA_COUNT_O            () , //not safe ; dealy to  ( wr_en or wr_full ) (和  wr_en or wr_full  不同一)
    .WR_PROG_FULL_O             () , //safe
    .WR_RST_BUSY_O              (WR_RST_BUSY ) , 
    .WR_ERR_O                   () ,
    
    .RD_RST_I                   (~FIFO_WR_RSTN_I)  , //NO USE
    .RD_CLK_I                   (FIFO_RD_CLK_I  )  ,
    .RD_EN_I                    (FIFO_RD_EN_I   )  ,
    .RD_EN_NAMES_O              ()  ,
    .RD_EN_ACCUS_O              ()  ,
    .RD_DATA_VALID_O            ()  , 
    .RD_SUCC_I                  ()  , //NO USE
    .RD_FAIL_I                  ()  , //NO USE
    .RD_DATA_O                  (FIFO_RD_DATA_O       )  ,
    .RD_EMPTY_O                 (FIFO_RD_EMPTY_O      )  , //safe 
    .RD_DATA_COUNT_O            (FIFO_RD_DATA_COUNT_O )  , //safe ; delay to rd_en
    .RD_PROG_EMPTY_O            ()  , //safe
    .RD_RST_BUSY_O              (RD_RST_BUSY_O        )  ,
    .RD_ERR_O                   ()     
    
    );
  

    
    
endmodule
