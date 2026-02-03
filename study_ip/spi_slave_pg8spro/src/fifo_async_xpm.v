`timescale 1ns / 1ps
`define CDC_SINGLE_BIT_PULSE(aclk_in,arst_in,apulse_in,bclk_in,brst_in,bpulse_out,SIM)          generate if(SIM==0)begin  xpm_cdc_pulse #(.DEST_SYNC_FF(4), .INIT_SYNC_FF(0),.REG_OUTPUT(0),.RST_USED(1),.SIM_ASSERT_CHK (0)) cdc_u (.src_clk(aclk_in),.src_rst(arst_in),.src_pulse(apulse_in),.dest_clk(bclk_in),.dest_rst(brst_in),.dest_pulse(bpulse_out));   end else begin   reg [5:0] name1 = 0;wire name2;always@(posedge aclk_in)if(arst_in)name1[0] <=0;else name1[0] <= apulse_in;assign name2 = apulse_in & ~name1[0]; always@(posedge aclk_in)if(arst_in)name1[1] <= 0;else name1[1] <= name2 ? ~name1[1]:name1[1];always@(posedge bclk_in)if(brst_in)name1[5:2]<=0;else begin name1[2]<=name1[1];name1[3]<=name1[2];name1[4]<=name1[3];name1[5]<=name1[4];end  assign bpulse_out=name1[4]^name1[5];  end  endgenerate
`define CDC_MULTI_BIT_SIGNAL(aclk_in,adata_in,bclk_in,bdata_out,C_DATA_WIDTH)                   generate begin xpm_cdc_array_single #(.DEST_SYNC_FF(4),.INIT_SYNC_FF(0),.SIM_ASSERT_CHK(0),.SRC_INPUT_REG(1),.WIDTH(C_DATA_WIDTH)) cdc_u(.src_clk(aclk_in),.src_in(adata_in),.dest_clk(bclk_in),.dest_out(bdata_out));    end  endgenerate  
`define SYN_STRETCH_POS_CNT(pulse_p_in,clk_in,C_TOTAL_PERIOD,cnt_name,pulse_p_out)       reg [31:0] cnt_name = 0;always@(posedge clk_in)begin if(pulse_p_in )begin cnt_name <= C_TOTAL_PERIOD-1; end  else begin  cnt_name <= (cnt_name == 0) ? 0 : (cnt_name - 1);end end  assign pulse_p_out = pulse_p_in|((cnt_name != 0)? 1:0);



//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: yzhu
// Create Date: 2022/09/30 16:47:58
// Module Name: fifo_async_xpm
//////////////////////////////////////////////////////////////////////////////////
/*

fifo_async_xpm  
    #(.C_WR_WIDTH             (),// ratio must be 1:1, 1:2, 1:4, 1:8,
      .C_WR_DEPTH             (),// must>=16 ; actual depth = C_WR_DEPTH - 1;  must be power of 2
      .C_RD_WIDTH             (),
      .C_WR_COUNT_WIDTH       (),
      .C_RD_COUNT_WIDTH       (),
      .C_RD_PROG_EMPTY_THRESH (),
      .C_WR_PROG_FULL_THRESH  (),
      .C_RD_MODE              (), //"std" "fwft"  
      .C_DBG_COUNT_WIDTH      ()
     )
    fifo_async_xpm_u(
    .WR_RST_I         (),
    .WR_CLK_I         (),
    .WR_EN_I          (),
    .WR_EN_VALID_O    (),
    .WR_EN_NAMES_O    (),
    .WR_EN_ACCUS_O    (),
    .WR_DATA_I        (),
    .WR_FULL_O        (),
    .WR_DATA_COUNT_O  (),
    .WR_PROG_FULL_O   (),
    .WR_RST_BUSY_O    (),

    .RD_RST_I         (), 
    .RD_CLK_I         (),
    .RD_EN_I          (),
    .RD_EN_NAMES_O    (),
    .RD_EN_ACCUS_O    (),
    .RD_DATA_VALID_O  (),
    .RD_DATA_O        (),
    .RD_EMPTY_O       (),
    .RD_DATA_COUNT_O  (),
    .RD_PROG_EMPTY_O  (),
    .RD_RST_BUSY_O    ()
    );

*/

module fifo_async_xpm(
input                                WR_RST_I                    , //at least 1 WR_CLK_I period
input                                WR_CLK_I                    ,
input                                WR_EN_I                     , //sync to wr_full (和 wr_full 同一)
output                               WR_EN_VALID_O               , //和 WR_EN_I 之间无延迟
output [C_DBG_COUNT_WIDTH-1:0]       WR_EN_NAMES_O               ,
output [C_DBG_COUNT_WIDTH-1:0]       WR_EN_ACCUS_O               , //total valid wr num
input  [C_WR_WIDTH-1:0]              WR_DATA_I                   ,
input                                WR_SUCC_I                   , //NO USE
input                                WR_FAIL_I                   , //NO USE
output                               WR_FULL_O                   , //safe 
output [C_WR_COUNT_WIDTH-1:0]        WR_DATA_COUNT_O             , //not safe ; dealy to  ( wr_en or wr_full ) (和  wr_en or wr_full  不同一)
output                               WR_PROG_FULL_O              , //safe
output                               WR_RST_BUSY_O               , 
output                               WR_ERR_O                    ,

input                                RD_RST_I                    , //NO USE
input                                RD_CLK_I                    ,
input                                RD_EN_I                     ,
output [C_DBG_COUNT_WIDTH-1:0]       RD_EN_NAMES_O               ,
output [C_DBG_COUNT_WIDTH-1:0]       RD_EN_ACCUS_O               ,
output                               RD_DATA_VALID_O             , 
input                                RD_SUCC_I                   , //NO USE
input                                RD_FAIL_I                   , //NO USE
output [C_RD_WIDTH-1:0]              RD_DATA_O                   ,
output                               RD_EMPTY_O                  , //safe 
output [C_RD_COUNT_WIDTH-1:0]        RD_DATA_COUNT_O             , //safe ; delay to rd_en
output                               RD_PROG_EMPTY_O             , //safe
output                               RD_RST_BUSY_O               ,
output                               RD_ERR_O                       

);
//////////////////////////////////////////core para///////////////////////////////////////
parameter C_RD_MODE               = "std" ;//"std" "fwft"  
parameter C_WR_WIDTH              = 8; //Write and read width aspect ratio must be 1:1, 1:2, 1:4, 1:8, 8:1, 4:1 and 2:1     
parameter C_RD_WIDTH              = 8;
parameter C_WR_DEPTH              = 1024;//must>=16 ; actual depth = C_WR_DEPTH - 1(实测结果符合，即配置深度16，最多写15个值就会报full);  must be power of two
parameter C_WR_COUNT_WIDTH        = 10;
parameter C_RD_COUNT_WIDTH        = 10;


localparam  FIFO_READ_DEPTH = C_WR_DEPTH/(C_RD_WIDTH/C_WR_WIDTH);
//parameter C_RD_PROG_EMPTY_THRESH  = 10;  
//parameter C_WR_PROG_FULL_THRESH   = C_WR_DEPTH-10; //WRITE_FIFO_DEPTH时即完全等同于full


parameter   C_RD_PROG_EMPTY_THRESH  =  3 + ( C_RD_MODE=="std" ? 0 : 2)  ; //默认取最小值
parameter   C_WR_PROG_FULL_THRESH   =   (C_WR_DEPTH-3) - ( C_RD_MODE=="std" ?  0 :  2*(C_WR_DEPTH/FIFO_READ_DEPTH))  - 64  ;//默认取最大值

parameter C_DBG_COUNT_WIDTH       = 32 ;


///////////////////////////////////////////////////////////////////////////////////////////
parameter C_RELATED_CLOCKS        = 0; 
//no use parameters for unify//////////////////////////////////////////////////////////////
parameter C_WR_CHANGE_COUNT       = 4;
///////////////////////////////////////////////////////////////////////////////////////////
localparam INNER_WR_DATA_COUNT_WIDTH =   $clog2(C_WR_DEPTH) + 1;
localparam INNER_RD_DATA_COUNT_WIDTH =  (C_WR_WIDTH>=C_RD_WIDTH) ?
                                          ( $clog2(C_WR_DEPTH*(C_WR_WIDTH/C_RD_WIDTH)) + 1 ) :
                                          ( $clog2(C_WR_DEPTH/(C_RD_WIDTH/C_WR_WIDTH)) + 1 ) ;
                                          
localparam RATIO = (C_WR_WIDTH>=C_RD_WIDTH) ?  (C_WR_WIDTH/C_RD_WIDTH) : (C_RD_WIDTH/C_WR_WIDTH);                            
                                          
wire [INNER_WR_DATA_COUNT_WIDTH-1:0] wr_data_count;
wire [INNER_RD_DATA_COUNT_WIDTH-1:0] rd_data_count;


wire rd_empty;
wire wr_full;
wire rd_prog_empty;
wire wr_prog_full;

wire actual_wr_en;
assign actual_wr_en = WR_EN_I & ~WR_FULL_O & ~WR_RST_BUSY_O;
assign WR_EN_VALID_O = actual_wr_en;
assign WR_ERR_O  =  WR_EN_I != actual_wr_en;


wire actual_rd_en;
assign actual_rd_en = RD_EN_I & ~RD_EMPTY_O & ~RD_RST_BUSY_O;
assign RD_ERR_O  =  RD_EN_I != actual_rd_en ;


reg [C_DBG_COUNT_WIDTH-1:0] wr_accus = 0;//unless reset, this variable represent total valid wr num 
reg [C_DBG_COUNT_WIDTH-1:0] rd_accus = 0;//unless reset, this variable represent total valid rd num 
reg [C_DBG_COUNT_WIDTH-1:0] wr_names = 0;//unless reset, this variable represent total valid wr num 
reg [C_DBG_COUNT_WIDTH-1:0] rd_names = 0;//unless reset, this variable represent total valid wr num 


always@(posedge WR_CLK_I)begin
    if(WR_RST_I)begin
        wr_names <= 0;
    end
    else begin
        wr_names <= WR_EN_I ? wr_names + 1 : wr_names ;
    end
end
assign  WR_EN_NAMES_O = wr_names;


always@(posedge WR_CLK_I)begin
    if(WR_RST_I)begin
        wr_accus <= 0;
    end
    else begin
        wr_accus <= actual_wr_en ? wr_accus + 1 : wr_accus ;
    end
end
assign  WR_EN_ACCUS_O = wr_accus;


always@(posedge RD_CLK_I)begin
    if(RD_RST_BUSY_O)begin
        rd_names <= 0;
    end 
    else begin
        rd_names <= RD_EN_I ? rd_names + 1 : rd_names ;
    end
end
assign RD_EN_NAMES_O = rd_names;



always@(posedge RD_CLK_I)begin
    if(RD_RST_BUSY_O)begin
        rd_accus <= 0;
    end 
    else begin
        rd_accus <= actual_rd_en ? rd_accus + 1 : rd_accus ;
    end
end
assign RD_EN_ACCUS_O = rd_accus;


generate if(C_RD_MODE=="std")begin : rd_valid_std
    reg rd_data_valid = 0;
    always@(posedge RD_CLK_I)begin
        rd_data_valid <= actual_rd_en ;
    end
    assign RD_DATA_VALID_O =  rd_data_valid;
end
else begin : rd_valid_fwft
    wire rd_data_valid;
    assign rd_data_valid = actual_rd_en;
    assign RD_DATA_VALID_O =  rd_data_valid;
end
endgenerate


assign RD_EMPTY_O      = rd_empty        ; 
assign RD_PROG_EMPTY_O = rd_prog_empty   ; 
assign WR_FULL_O       = wr_full         ; 
assign WR_PROG_FULL_O  = wr_prog_full    ; 



assign WR_DATA_COUNT_O = {0,wr_data_count}; 
assign RD_DATA_COUNT_O = {0,rd_data_count}; 


  xpm_fifo_async #(
      .CDC_SYNC_STAGES (2),       // DECIMAL | Range: 2 - 8. Default value = 2.   
      .DOUT_RESET_VALUE("0"),    // String
      .ECC_MODE("no_ecc"),       // String
      .FIFO_MEMORY_TYPE("auto"), // String   "auto", "block", or "distributed"
      .FIFO_READ_LATENCY(1),     // DECIMAL Range: 0 - 10. Default value = 1. 
      .FIFO_WRITE_DEPTH(C_WR_DEPTH), //16~ //|Defines the FIFO Write Depth, must be power of two.      
           // | In standard READ_MODE, the effective depth = WRITE_FIFO_DEPTH-1                                                   |
           // | In First-Word-Fall-Through READ_MODE, the effective depth = WRITE_FIFO_DEPTH+1   
      .FULL_RESET_VALUE(1),      // DECIMAL   safe: during reset  full and almoust_full   == 1
      .PROG_EMPTY_THRESH(C_RD_PROG_EMPTY_THRESH),    // DECIMAL  定义中含等号
      .PROG_FULL_THRESH(C_WR_PROG_FULL_THRESH),     // DECIMAL 定义中含等号
      .RD_DATA_COUNT_WIDTH(INNER_RD_DATA_COUNT_WIDTH),   // DECIMAL
      .READ_DATA_WIDTH(C_RD_WIDTH),      // DECIMAL
      .READ_MODE(C_RD_MODE),         // String 默认标准模式  “std” “fwft”
      .RELATED_CLOCKS(C_RELATED_CLOCKS),        // DECIMAL  wr时钟和 rd时钟 是否同源（可以不同频）
      .SIM_ASSERT_CHK(0),        // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      .USE_ADV_FEATURES("0707"), // String
      .WAKEUP_TIME(0),           // DECIMAL   0 - Disable sleep   
      .WRITE_DATA_WIDTH(C_WR_WIDTH),     // DECIMAL
      .WR_DATA_COUNT_WIDTH(INNER_WR_DATA_COUNT_WIDTH)    // DECIMAL
   )
   xpm_fifo_async_inst (
      .almost_empty(RD_ALMOST_EMPTY_O),   // 1-bit output: Almost Empty : When asserted, this signal indicates that
                                          // only one more read can be performed before the FIFO goes to empty
      .almost_full(WR_ALMOST_FULL_O),     // 1-bit output: Almost Full: When asserted, this signal indicates that
                                          // only one more write can be performed before the FIFO is full.
      .data_valid( ),                     // 1-bit output: Read Data Valid: When asserted, this signal indicates
                                          // that valid data is available on the output bus (dout).
      .dbiterr( ),                   // 1-bit output: Double Bit Error: Indicates that the ECC decoder detected
                                     // a double-bit error and data in the FIFO core is corrupted.
      .dout(RD_DATA_O),                   // READ_DATA_WIDTH-bit output: Read Data: The output data bus is driven
                                     // when reading the FIFO.
      .empty(rd_empty),                 // 1-bit output: Empty Flag: When asserted, this signal indicates that the
                                     // FIFO is empty. Read requests are ignored when the FIFO is empty,
                                     // initiating a read while empty is not destructive to the FIFO.
      .full(wr_full),                   // 1-bit output: Full Flag: When asserted, this signal indicates that the
                                     // FIFO is full. Write requests are ignored when the FIFO is full,
                                     // initiating a write when the FIFO is full is not destructive to the
                                     // contents of the FIFO.
      .overflow( ),                  // 1-bit output: Overflow: This signal indicates that a write request
                                     // (wren) during the prior clock cycle was rejected, because the FIFO is
                                     // full. Overflowing the FIFO is not destructive to the contents of the
                                     // FIFO.
      .prog_empty(rd_prog_empty),       // 1-bit output: Programmable Empty: This signal is asserted when the
                                     // number of words in the FIFO is less than or equal to the programmable
                                     // empty threshold value. It is de-asserted when the number of words in
                                     // the FIFO exceeds the programmable empty threshold value.
      .prog_full(wr_prog_full),         // 1-bit output: Programmable Full: This signal is asserted when the
                                     // number of words in the FIFO is greater than or equal to the
                                     // programmable full threshold value. It is de-asserted when the number of
                                     // words in the FIFO is less than the programmable full threshold value.
      .rd_data_count(rd_data_count), // RD_DATA_COUNT_WIDTH-bit output: Read Data Count: This bus indicates the
                                     // number of words read from the FIFO.
      .rd_rst_busy(RD_RST_BUSY_O),     // 1-bit output: Read Reset Busy: Active-High indicator that the FIFO read
                                     // domain is currently in a reset state.
      .sbiterr( ),                   // 1-bit output: Single Bit Error: Indicates that the ECC decoder detected
                                     // and fixed a single-bit error.
      .underflow( ),                 // 1-bit output: Underflow: Indicates that the read request (rd_en) during
                                     // the previous clock cycle was rejected because the FIFO is empty. Under
                                     // flowing the FIFO is not destructive to the FIFO.
      .wr_ack( ),                    // 1-bit output: Write Acknowledge: This signal indicates that a write
                                     // request (wr_en) during the prior clock cycle is succeeded.
      .wr_data_count(wr_data_count), // WR_DATA_COUNT_WIDTH-bit output: Write Data Count: This bus indicates
                                     // the number of words written into the FIFO.
      .wr_rst_busy(WR_RST_BUSY_O),     // 1-bit output: Write Reset Busy: Active-High indicator that the FIFO
                                     // write domain is currently in a reset state.
      .din(WR_DATA_I),                     // WRITE_DATA_WIDTH-bit input: Write Data: The input data bus used when
                                     // writing the FIFO.
      .injectdbiterr(0),             // 1-bit input: Double Bit Error Injection: Injects a double bit error if
                                     // the ECC feature is used on block RAMs or UltraRAM macros.
      .injectsbiterr(0),             // 1-bit input: Single Bit Error Injection: Injects a single bit error if
                                     // the ECC feature is used on block RAMs or UltraRAM macros.
      .rd_clk(RD_CLK_I),               // 1-bit input: Read clock: Used for read operation. rd_clk must be a free
                                     // running clock.
      .rd_en(RD_EN_I),                 // 1-bit input: Read Enable: If the FIFO is not empty, asserting this
                                     // signal causes data (on dout) to be read from the FIFO. Must be held
                                     // active-low when rd_rst_busy is active high.
      .rst(WR_RST_I),                     // 1-bit input: Reset: Must be synchronous to wr_clk. The clock(s) can be
                                     // unstable at the time of applying reset, but reset must be released only
                                     // after the clock(s) is/are stable.
      .sleep(0),                      // 1-bit input: Dynamic power saving: If sleep is High, the memory/fifo
                                     // block is in power saving mode.
      .wr_clk(WR_CLK_I),               // 1-bit input: Write clock: Used for write operation. wr_clk must be a
                                     // free running clock.
      .wr_en(WR_EN_I)                  // 1-bit input: Write Enable: If the FIFO is not full, asserting this
                                     // signal causes data (on din) to be written to the FIFO. Must be held
                                     // active-low when rst or wr_rst_busy is active high.
     );


endmodule



// XPM_FIFO instantiation template for Asynchronous FIFO configurations
// Refer to the targeted device family architecture libraries guide for XPM_FIFO documentation
// =======================================================================================================================

// Parameter usage table, organized as follows:
// +---------------------------------------------------------------------------------------------------------------------+
// | Parameter name       | Data type          | Restrictions, if applicable                                             |
// |---------------------------------------------------------------------------------------------------------------------|
// | Description                                                                                                         |
// +---------------------------------------------------------------------------------------------------------------------+
// +---------------------------------------------------------------------------------------------------------------------+
// | CDC_SYNC_STAGES      | Integer            | Range: 2 - 8. Default value = 2.                                        |
// |---------------------------------------------------------------------------------------------------------------------|
// | Specifies the number of synchronization stages on the CDC path                                                      |
// |                                                                                                                     |
// |   Must be < 5 if FIFO_WRITE_DEPTH = 16                                                                              |
// +---------------------------------------------------------------------------------------------------------------------+
// | DOUT_RESET_VALUE     | String             | Default value = 0.                                                      |
// |---------------------------------------------------------------------------------------------------------------------|
// | Reset value of read data path.                                                                                      |
// +---------------------------------------------------------------------------------------------------------------------+
// | ECC_MODE             | String             | Allowed values: no_ecc, en_ecc. Default value = no_ecc.                 |
// |---------------------------------------------------------------------------------------------------------------------|
// |                                                                                                                     |
// |   "no_ecc" - Disables ECC                                                                                           |
// |   "en_ecc" - Enables both ECC Encoder and Decoder                                                                   |
// |                                                                                                                     |
// | NOTE: ECC_MODE should be "no_ecc" if FIFO_MEMORY_TYPE is set to "auto". Violating this may result incorrect behavior.|
// +---------------------------------------------------------------------------------------------------------------------+
// | FIFO_MEMORY_TYPE     | String             | Allowed values: auto, block, distributed. Default value = auto.         |
// |---------------------------------------------------------------------------------------------------------------------|
// | Designate the fifo memory primitive (resource type) to use.                                                         |
// |                                                                                                                     |
// |   "auto"- Allow Vivado Synthesis to choose                                                                          |
// |   "block"- Block RAM FIFO                                                                                           |
// |   "distributed"- Distributed RAM FIFO                                                                               |
// |                                                                                                                     |
// | NOTE: There may be a behavior mismatch if Block RAM or Ultra RAM specific features, like ECC or Asymmetry, are selected with FIFO_MEMORY_TYPE set to "auto".|
// +---------------------------------------------------------------------------------------------------------------------+
// | FIFO_READ_LATENCY    | Integer            | Range: 0 - 10. Default value = 1.                                       |
// |---------------------------------------------------------------------------------------------------------------------|
// | Number of output register stages in the read data path.                                                             |
// |                                                                                                                     |
// |   If READ_MODE = "fwft", then the only applicable value is 0.                                                       |
// +---------------------------------------------------------------------------------------------------------------------+
// | FIFO_WRITE_DEPTH     | Integer            | Range: 16 - 4194304. Default value = 2048.                              |
// |---------------------------------------------------------------------------------------------------------------------|
// | Defines the FIFO Write Depth, must be power of two.                                                                 |
// |                                                                                                                     |
// |   In standard READ_MODE, the effective depth = FIFO_WRITE_DEPTH-1                                                   |
// |   In First-Word-Fall-Through READ_MODE, the effective depth = FIFO_WRITE_DEPTH+1                                    |
// |                                                                                                                     |
// | NOTE: The maximum FIFO size (width x depth) is limited to 150-Megabits.                                             |
// +---------------------------------------------------------------------------------------------------------------------+
// | FULL_RESET_VALUE     | Integer            | Range: 0 - 1. Default value = 0.                                        |
// |---------------------------------------------------------------------------------------------------------------------|
// | Sets full, almost_full and prog_full to FULL_RESET_VALUE during reset                                               |
// +---------------------------------------------------------------------------------------------------------------------+
// | PROG_EMPTY_THRESH    | Integer            | Range: 3 - 4194301. Default value = 10.                                 |
// |---------------------------------------------------------------------------------------------------------------------|
// | Specifies the minimum number of read words in the FIFO at or below which prog_empty is asserted.                    |
// |                                                                                                                     |
// |   Min_Value = 3 + (READ_MODE_VAL*2)                                                                                 |
// |   Max_Value = (FIFO_WRITE_DEPTH-3) - (READ_MODE_VAL*2)                                                              |
// |                                                                                                                     |
// | If READ_MODE = "std", then READ_MODE_VAL = 0; Otherwise READ_MODE_VAL = 1.                                          |
// | NOTE: The default threshold value is dependent on default FIFO_WRITE_DEPTH value. If FIFO_WRITE_DEPTH value is      |
// | changed, ensure the threshold value is within the valid range though the programmable flags are not used.           |
// +---------------------------------------------------------------------------------------------------------------------+
// | PROG_FULL_THRESH     | Integer            | Range: 5 - 4194301. Default value = 10.                                 |
// |---------------------------------------------------------------------------------------------------------------------|
// | Specifies the maximum number of write words in the FIFO at or above which prog_full is asserted.                    |
// |                                                                                                                     |
// |   Min_Value = 3 + (READ_MODE_VAL*2*(FIFO_WRITE_DEPTH/FIFO_READ_DEPTH))+CDC_SYNC_STAGES                              |
// |   Max_Value = (FIFO_WRITE_DEPTH-3) - (READ_MODE_VAL*2*(FIFO_WRITE_DEPTH/FIFO_READ_DEPTH))                           |
// |                                                                                                                     |
// | If READ_MODE = "std", then READ_MODE_VAL = 0; Otherwise READ_MODE_VAL = 1.                                          |
// | NOTE: The default threshold value is dependent on default FIFO_WRITE_DEPTH value. If FIFO_WRITE_DEPTH value is      |
// | changed, ensure the threshold value is within the valid range though the programmable flags are not used.           |
// +---------------------------------------------------------------------------------------------------------------------+
// | RD_DATA_COUNT_WIDTH  | Integer            | Range: 1 - 23. Default value = 1.                                       |
// |---------------------------------------------------------------------------------------------------------------------|
// | Specifies the width of rd_data_count. To reflect the correct value, the width should be log2(FIFO_READ_DEPTH)+1.    |
// |                                                                                                                     |
// |   FIFO_READ_DEPTH = FIFO_WRITE_DEPTH*WRITE_DATA_WIDTH/READ_DATA_WIDTH                                               |
// +---------------------------------------------------------------------------------------------------------------------+
// | READ_DATA_WIDTH      | Integer            | Range: 1 - 4096. Default value = 32.                                    |
// |---------------------------------------------------------------------------------------------------------------------|
// | Defines the width of the read data port, dout                                                                       |
// |                                                                                                                     |
// |   Write and read width aspect ratio must be 1:1, 1:2, 1:4, 1:8, 8:1, 4:1 and 2:1                                    |
// |   For example, if WRITE_DATA_WIDTH is 32, then the READ_DATA_WIDTH must be 32, 64,128, 256, 16, 8, 4.               |
// |                                                                                                                     |
// | NOTE:                                                                                                               |
// |                                                                                                                     |
// |   READ_DATA_WIDTH should be equal to WRITE_DATA_WIDTH if FIFO_MEMORY_TYPE is set to "auto". Violating this may result incorrect behavior. |
// |   The maximum FIFO size (width x depth) is limited to 150-Megabits.                                                 |
// +---------------------------------------------------------------------------------------------------------------------+
// | READ_MODE            | String             | Allowed values: std, fwft. Default value = std.                         |
// |---------------------------------------------------------------------------------------------------------------------|
// |                                                                                                                     |
// |   "std"- standard read mode                                                                                         |
// |   "fwft"- First-Word-Fall-Through read mode                                                                         |
// +---------------------------------------------------------------------------------------------------------------------+
// | RELATED_CLOCKS       | Integer            | Range: 0 - 1. Default value = 0.                                        |
// |---------------------------------------------------------------------------------------------------------------------|
// | Specifies if the wr_clk and rd_clk are related having the same source but different clock ratios                    |
// +---------------------------------------------------------------------------------------------------------------------+
// | SIM_ASSERT_CHK       | Integer            | Range: 0 - 1. Default value = 0.                                        |
// |---------------------------------------------------------------------------------------------------------------------|
// | 0- Disable simulation message reporting. Messages related to potential misuse will not be reported.                 |
// | 1- Enable simulation message reporting. Messages related to potential misuse will be reported.                      |
// +---------------------------------------------------------------------------------------------------------------------+
// | USE_ADV_FEATURES     | String             | Default value = 0707.                                                   |
// |---------------------------------------------------------------------------------------------------------------------|
// | Enables data_valid, almost_empty, rd_data_count, prog_empty, underflow, wr_ack, almost_full, wr_data_count,         |
// | prog_full, overflow features.                                                                                       |
// |                                                                                                                     |
// |   Setting USE_ADV_FEATURES[0] to 1 enables overflow flag; Default value of this bit is 1                            |
// |   Setting USE_ADV_FEATURES[1] to 1 enables prog_full flag; Default value of this bit is 1                           |
// |   Setting USE_ADV_FEATURES[2] to 1 enables wr_data_count; Default value of this bit is 1                            |
// |   Setting USE_ADV_FEATURES[3] to 1 enables almost_full flag; Default value of this bit is 0                         |
// |   Setting USE_ADV_FEATURES[4] to 1 enables wr_ack flag; Default value of this bit is 0                              |
// |   Setting USE_ADV_FEATURES[8] to 1 enables underflow flag; Default value of this bit is 1                           |
// |   Setting USE_ADV_FEATURES[9] to 1 enables prog_empty flag; Default value of this bit is 1                          |
// |   Setting USE_ADV_FEATURES[10] to 1 enables rd_data_count; Default value of this bit is 1                           |
// |   Setting USE_ADV_FEATURES[11] to 1 enables almost_empty flag; Default value of this bit is 0                       |
// |   Setting USE_ADV_FEATURES[12] to 1 enables data_valid flag; Default value of this bit is 0                         |
// +---------------------------------------------------------------------------------------------------------------------+
// | WAKEUP_TIME          | Integer            | Range: 0 - 2. Default value = 0.                                        |
// |---------------------------------------------------------------------------------------------------------------------|
// |                                                                                                                     |
// |   0 - Disable sleep                                                                                                 |
// |   2 - Use Sleep Pin                                                                                                 |
// |                                                                                                                     |
// | NOTE: WAKEUP_TIME should be 0 if FIFO_MEMORY_TYPE is set to "auto". Violating this may result incorrect behavior.   |
// +---------------------------------------------------------------------------------------------------------------------+
// | WRITE_DATA_WIDTH     | Integer            | Range: 1 - 4096. Default value = 32.                                    |
// |---------------------------------------------------------------------------------------------------------------------|
// | Defines the width of the write data port, din                                                                       |
// |                                                                                                                     |
// |   Write and read width aspect ratio must be 1:1, 1:2, 1:4, 1:8, 8:1, 4:1 and 2:1                                    |
// |   For example, if WRITE_DATA_WIDTH is 32, then the READ_DATA_WIDTH must be 32, 64,128, 256, 16, 8, 4.               |
// |                                                                                                                     |
// | NOTE:                                                                                                               |
// |                                                                                                                     |
// |   WRITE_DATA_WIDTH should be equal to READ_DATA_WIDTH if FIFO_MEMORY_TYPE is set to "auto". Violating this may result incorrect behavior. |
// |   The maximum FIFO size (width x depth) is limited to 150-Megabits.                                                 |
// +---------------------------------------------------------------------------------------------------------------------+
// | WR_DATA_COUNT_WIDTH  | Integer            | Range: 1 - 23. Default value = 1.                                       |
// |---------------------------------------------------------------------------------------------------------------------|
// | Specifies the width of wr_data_count. To reflect the correct value, the width should be log2(FIFO_WRITE_DEPTH)+1.   |
// +---------------------------------------------------------------------------------------------------------------------+

// Port usage table, organized as follows:
// +---------------------------------------------------------------------------------------------------------------------+
// | Port name      | Direction | Size, in bits                         | Domain  | Sense       | Handling if unused     |
// |---------------------------------------------------------------------------------------------------------------------|
// | Description                                                                                                         |
// +---------------------------------------------------------------------------------------------------------------------+
// +---------------------------------------------------------------------------------------------------------------------+
// | almost_empty   | Output    | 1                                     | rd_clk  | Active-high | DoNotCare              |
// |---------------------------------------------------------------------------------------------------------------------|
// | Almost Empty : When asserted, this signal indicates that only one more read can be performed before the FIFO goes to|
// | empty.                                                                                                              |
// +---------------------------------------------------------------------------------------------------------------------+
// | almost_full    | Output    | 1                                     | wr_clk  | Active-high | DoNotCare              |
// |---------------------------------------------------------------------------------------------------------------------|
// | Almost Full: When asserted, this signal indicates that only one more write can be performed before the FIFO is full.|
// +---------------------------------------------------------------------------------------------------------------------+
// | data_valid     | Output    | 1                                     | rd_clk  | Active-high | DoNotCare              |
// |---------------------------------------------------------------------------------------------------------------------|
// | Read Data Valid: When asserted, this signal indicates that valid data is available on the output bus (dout).        |
// +---------------------------------------------------------------------------------------------------------------------+
// | dbiterr        | Output    | 1                                     | rd_clk  | Active-high | DoNotCare              |
// |---------------------------------------------------------------------------------------------------------------------|
// | Double Bit Error: Indicates that the ECC decoder detected a double-bit error and data in the FIFO core is corrupted.|
// +---------------------------------------------------------------------------------------------------------------------+
// | din            | Input     | WRITE_DATA_WIDTH                      | wr_clk  | NA          | Required               |
// |---------------------------------------------------------------------------------------------------------------------|
// | Write Data: The input data bus used when writing the FIFO.                                                          |
// +---------------------------------------------------------------------------------------------------------------------+
// | dout           | Output    | READ_DATA_WIDTH                       | rd_clk  | NA          | Required               |
// |---------------------------------------------------------------------------------------------------------------------|
// | Read Data: The output data bus is driven when reading the FIFO.                                                     |
// +---------------------------------------------------------------------------------------------------------------------+
// | empty          | Output    | 1                                     | rd_clk  | Active-high | Required               |
// |---------------------------------------------------------------------------------------------------------------------|
// | Empty Flag: When asserted, this signal indicates that the FIFO is empty.                                            |
// | Read requests are ignored when the FIFO is empty, initiating a read while empty is not destructive to the FIFO.     |
// +---------------------------------------------------------------------------------------------------------------------+
// | full           | Output    | 1                                     | wr_clk  | Active-high | Required               |
// |---------------------------------------------------------------------------------------------------------------------|
// | Full Flag: When asserted, this signal indicates that the FIFO is full.                                              |
// | Write requests are ignored when the FIFO is full, initiating a write when the FIFO is full is not destructive       |
// | to the contents of the FIFO.                                                                                        |
// +---------------------------------------------------------------------------------------------------------------------+
// | injectdbiterr  | Input     | 1                                     | wr_clk  | Active-high | Tie to 1'b0            |
// |---------------------------------------------------------------------------------------------------------------------|
// | Double Bit Error Injection: Injects a double bit error if the ECC feature is used on block RAMs or                  |
// | UltraRAM macros.                                                                                                    |
// +---------------------------------------------------------------------------------------------------------------------+
// | injectsbiterr  | Input     | 1                                     | wr_clk  | Active-high | Tie to 1'b0            |
// |---------------------------------------------------------------------------------------------------------------------|
// | Single Bit Error Injection: Injects a single bit error if the ECC feature is used on block RAMs or                  |
// | UltraRAM macros.                                                                                                    |
// +---------------------------------------------------------------------------------------------------------------------+
// | overflow       | Output    | 1                                     | wr_clk  | Active-high | DoNotCare              |
// |---------------------------------------------------------------------------------------------------------------------|
// | Overflow: This signal indicates that a write request (wren) during the prior clock cycle was rejected,              |
// | because the FIFO is full. Overflowing the FIFO is not destructive to the contents of the FIFO.                      |
// +---------------------------------------------------------------------------------------------------------------------+
// | prog_empty     | Output    | 1                                     | rd_clk  | Active-high | DoNotCare              |
// |---------------------------------------------------------------------------------------------------------------------|
// | Programmable Empty: This signal is asserted when the number of words in the FIFO is less than or equal              |
// | to the programmable empty threshold value.                                                                          |
// | It is de-asserted when the number of words in the FIFO exceeds the programmable empty threshold value.              |
// +---------------------------------------------------------------------------------------------------------------------+
// | prog_full      | Output    | 1                                     | wr_clk  | Active-high | DoNotCare              |
// |---------------------------------------------------------------------------------------------------------------------|
// | Programmable Full: This signal is asserted when the number of words in the FIFO is greater than or equal            |
// | to the programmable full threshold value.                                                                           |
// | It is de-asserted when the number of words in the FIFO is less than the programmable full threshold value.          |
// +---------------------------------------------------------------------------------------------------------------------+
// | rd_clk         | Input     | 1                                     | NA      | Rising edge | Required               |
// |---------------------------------------------------------------------------------------------------------------------|
// | Read clock: Used for read operation. rd_clk must be a free running clock.                                           |
// +---------------------------------------------------------------------------------------------------------------------+
// | rd_data_count  | Output    | RD_DATA_COUNT_WIDTH                   | rd_clk  | NA          | DoNotCare              |
// |---------------------------------------------------------------------------------------------------------------------|
// | Read Data Count: This bus indicates the number of words read from the FIFO.                                         |
// +---------------------------------------------------------------------------------------------------------------------+
// | rd_en          | Input     | 1                                     | rd_clk  | Active-high | Required               |
// |---------------------------------------------------------------------------------------------------------------------|
// | Read Enable: If the FIFO is not empty, asserting this signal causes data (on dout) to be read from the FIFO.        |
// |                                                                                                                     |
// |   Must be held active-low when rd_rst_busy is active high.                                                          |
// +---------------------------------------------------------------------------------------------------------------------+
// | rd_rst_busy    | Output    | 1                                     | rd_clk  | Active-high | Required               |
// |---------------------------------------------------------------------------------------------------------------------|
// | Read Reset Busy: Active-High indicator that the FIFO read domain is currently in a reset state.                     |
// +---------------------------------------------------------------------------------------------------------------------+
// | rst            | Input     | 1                                     | wr_clk  | Active-high | Required               |
// |---------------------------------------------------------------------------------------------------------------------|
// | Reset: Must be synchronous to wr_clk. The clock(s) can be unstable at the time of applying reset, but reset must be released only after the clock(s) is/are stable.|
// +---------------------------------------------------------------------------------------------------------------------+
// | sbiterr        | Output    | 1                                     | rd_clk  | Active-high | DoNotCare              |
// |---------------------------------------------------------------------------------------------------------------------|
// | Single Bit Error: Indicates that the ECC decoder detected and fixed a single-bit error.                             |
// +---------------------------------------------------------------------------------------------------------------------+
// | sleep          | Input     | 1                                     | NA      | Active-high | Tie to 1'b0            |
// |---------------------------------------------------------------------------------------------------------------------|
// | Dynamic power saving: If sleep is High, the memory/fifo block is in power saving mode.                              |
// +---------------------------------------------------------------------------------------------------------------------+
// | underflow      | Output    | 1                                     | rd_clk  | Active-high | DoNotCare              |
// |---------------------------------------------------------------------------------------------------------------------|
// | Underflow: Indicates that the read request (rd_en) during the previous clock cycle was rejected                     |
// | because the FIFO is empty. Under flowing the FIFO is not destructive to the FIFO.                                   |
// +---------------------------------------------------------------------------------------------------------------------+
// | wr_ack         | Output    | 1                                     | wr_clk  | Active-high | DoNotCare              |
// |---------------------------------------------------------------------------------------------------------------------|
// | Write Acknowledge: This signal indicates that a write request (wr_en) during the prior clock cycle is succeeded.    |
// +---------------------------------------------------------------------------------------------------------------------+
// | wr_clk         | Input     | 1                                     | NA      | Rising edge | Required               |
// |---------------------------------------------------------------------------------------------------------------------|
// | Write clock: Used for write operation. wr_clk must be a free running clock.                                         |
// +---------------------------------------------------------------------------------------------------------------------+
// | wr_data_count  | Output    | WR_DATA_COUNT_WIDTH                   | wr_clk  | NA          | DoNotCare              |
// |---------------------------------------------------------------------------------------------------------------------|
// | Write Data Count: This bus indicates the number of words written into the FIFO.                                     |
// +---------------------------------------------------------------------------------------------------------------------+
// | wr_en          | Input     | 1                                     | wr_clk  | Active-high | Required               |
// |---------------------------------------------------------------------------------------------------------------------|
// | Write Enable: If the FIFO is not full, asserting this signal causes data (on din) to be written to the FIFO.        |
// |                                                                                                                     |
// |   Must be held active-low when rst or wr_rst_busy is active high.                                                   |
// +---------------------------------------------------------------------------------------------------------------------+
// | wr_rst_busy    | Output    | 1                                     | wr_clk  | Active-high | Required               |
// |---------------------------------------------------------------------------------------------------------------------|
// | Write Reset Busy: Active-High indicator that the FIFO write domain is currently in a reset state.                   |
// +---------------------------------------------------------------------------------------------------------------------+



